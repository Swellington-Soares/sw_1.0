local module = {}
local injected_modules = {}

local function validemail(str)
    if str == nil or str:len() == 0 then return nil end
    if (type(str) ~= 'string') then
        error("Expected string")
        return nil
    end
    local lastAt = str:find("[^%@]+$")
    local localPart = str:sub(1, (lastAt - 2))
    local domainPart = str:sub(lastAt, #str)

    if localPart == nil then
        return nil, "Local name is invalid"
    end

    if domainPart == nil or not domainPart:find("%.") then
        return nil, "Domain is invalid"
    end
    if string.sub(domainPart, 1, 1) == "." then
        return nil, "First character in domain cannot be a dot"
    end

    if #localPart > 64 then
        return nil, "Local name must be less than 64 characters"
    end

    if #domainPart > 253 then
        return nil, "Domain must be less than 253 characters"
    end

    if lastAt >= 65 then
        return nil, "Invalid @ symbol usage"
    end

    local quotes = localPart:find("[\"]")
    if type(quotes) == 'number' and quotes > 1 then
        return nil, "Invalid usage of quotes"
    end

    if localPart:find("%@+") and quotes == nil then
        return nil, "Invalid @ symbol usage in local part"
    end

    if not domainPart:find("%.") then
        return nil, "No TLD found in domain"
    end

    if domainPart:find("%.%.") then
        return nil, "Too many periods in domain"
    end
    if localPart:find("%.%.") then
        return nil, "Too many periods in local part"
    end

    if not str:match('[%w]*[%p]*%@+[%w]*[%.]?[%w]*') then
        return nil, "Email pattern test failed"
    end

    return true
end

local function GenerateRandomUniqueToken()
    local token = ''
    repeat
        token = lib.string.random('AAA-111AAA-111')
    until injected_modules.storage.Scalar('SELECT 1 FROM account_tokens WHERE token = ?', { token }) == nil
    return token
end

function module._GenerateToken(license)
    local token = GenerateRandomUniqueToken()
    injected_modules.storage.Insert('INSERT INTO account_tokens (license, token) VALUES (?, ?)', { license, token })
    return token
end

function module._GetUser(license)
    return injected_modules.storage.Single('SELECT * FROM accounts WHERE license = ? LIMIT 1', { license })
end

function module._CreateUser(data)
    if not data.email then
        return false, 'Você precisa informar um email'
    end

    if not data.password then
        return false, 'Você precisa informar uma senha'
    end

    if not validemail(data.email) then
        return false, 'Email inválido'
    end

    if #data.password < 8 then
        return false, 'A senha deve ter no mínimo 8 caracteres'
    end

    if #data.password > 15 then
        return false, 'A senha deve ter no máximo 15 caracteres'
    end

    local created = injected_modules.storage.Scalar('CALL `add_user`(?, ?, ?, ?, ?)', {
        data.license,
        data.discord,
        data.cfx,
        data.email,
        GetPasswordHash(data.password)
    })

    if not created or created.status == 0 then
        return false, created.message
    end

    return true, 'Usuário criado com sucesso'
end

function module._ValidateToken(license, token)
    local result = injected_modules.storage.Scalar('CALL `check_auth_token`(?, ?)', { license, token })
    return result and result.status == 1
end

function module._IsUserBlocked(license)
    return injected_modules.storage.Scalar('SELECT 1 FROM accounts_banneds WHERE license = ? LIMIT 1', { license }) ~=
    nil
end

function module.GetUserData(license, key)
    assert(type(license) == 'string', 'license must be a string')
    assert(type(key) == 'string', 'key must be a string')
    return injected_modules.storage.Scalar('SELECT dvalue FROM user_data WHERE license = ? AND dkey = ?', { license, key })
end

function module.SetUserData(license, key, value)
    assert(type(license) == 'string', 'license must be a string')
    assert(type(key) == 'string', 'key must be a string')
    if type(value) == "table" then
        value = json.encode(value)
    end
    return injected_modules.storage.Update(
    'INSERT INTO user_data (license, dkey, dvalue) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE dvalue = VALUES(dvalue)',
        { license, key, value })
end

function module._AuthUser(user, license, deffered, card)
    local result = promise.new()
    CreateThread(function()
        if not user or not license or user.license ~= license then 
            result:resolve(false)
        else
            deffered.presentCard(card, function(data)
                local p = data.password
                local e = data.email                
                result:resolve( e == user.email and VerifyPasswordHash(p, user.password))
            end)
        end
    end)
    return Citizen.Await(result)
end

local function __init__(storage)
    local _module = { name = 'Auth' }
    injected_modules.storage = storage
    return setmetatable(_module, { __index = module })
end

return __init__
