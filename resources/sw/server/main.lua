local require = lib.require
local old_print = print
local print = lib.print.info
local modules = {}


modules.storage = require '@sw.server.modules.storage' ()
modules.server = require '@sw.server.modules.server' (modules.storage)
modules.character = require '@sw.server.modules.character' (modules.storage)
modules.player = require '@sw.server.modules.player' (modules.storage, modules.server, modules.character)
modules.hooks = require '@sw.server.modules.hook' (modules.storage)
modules.auth = require '@sw.server.modules.auth' (modules.storage)
modules.email = require '@sw.server.modules.email' ()

for k, v in next, modules do
    old_print()
    print('Loading module: ' .. v?.name or k:upper())
    for k2, v2 in next, getmetatable(v)?.__index or {} do
        if k2:sub(1, 1) ~= '_' then
            print('Registering method exports: ', '[' .. cache.resource .. ']', (v?.exp_prefix or "") .. k2)
            exports((v?.exp_prefix or "") .. k2, v2)
        end
    end
end


RegisterCommand('test', function(source)
    modules.server:GetPlayerIdentifier(source, 'license')
end)

local AdaptiveCards = {}
AdaptiveCards.Reg = lib.loadJson('@sw.server.adaptive_card.reg_card')
AdaptiveCards.InputToken = lib.loadJson('@sw.server.adaptive_card.input_token_card')
AdaptiveCards.InputEmailPassword = lib.loadJson('@sw.server.adaptive_card.login_card')


local function input_token(deff)
    local p = promise.new()
    CreateThread(function()
        Wait(0)
        deff.presentCard(AdaptiveCards.InputToken, function (data)
            if not data.token then
                p:resolve(nil)
            else
                p:resolve(data.token)
            end
        end)
    end)
    return Citizen.Await(p)
end


--fivem default events
AddEventHandler('playerConnecting', function(name, _, deff)
    local src = source        
    deff.defer()
    Wait(50)
        
    deff.update(locale('verify_license'))   
    local license = modules.server.GetPlayerIdentifier(src, 'license')
    Wait(50)
    deff.update(locale('verify_discord'))
    local discord = modules.server.GetPlayerIdentifier(src, 'discord')
    Wait(50)
    deff.update(locale('verify_fivem_account'))
    local cfx = modules.server.GetPlayerIdentifier(src, 'fivem')
    Wait(50)

    if not license then
        return deff.done(locale('verify_license_error'))
    end

    if not discord then
        return deff.done(locale('verify_discord_error'))
    end

    if not cfx then
        return deff.done(locale('verify_fivem_account_error'))
    end

    deff.update('Verificando dados...')

    local user = modules.auth._GetUser(license) --[[ @as User ]]
    
    Wait(50)
    

    if not user then    
        return deff.presentCard(AdaptiveCards.Reg, function(data, rawdata)
            deff.update(locale('infor_validation'))
            Wait(50)            
            if not data.privacy_field or not data.term_field then
                return deff.done(locale('accept_terms'))
            end
            local isUserCreated, message = modules.auth._CreateUser(
                {
                    license = license, 
                    discord = discord, 
                    cfx = cfx, 
                    email = data.email_field, 
                    password = data.password_field
                })
            
            if not isUserCreated then
                return deff.done(message)
            end

            deff.update(locale('validating_register'))
            Wait(50)

            local generatedToken = modules.auth._GenerateToken(license)  
            
            local isSendedEmail, message = modules.email._SendEmail(data.email_field, { template = 'token_received', { token = generatedToken } })

            if not isSendedEmail then
                return deff.done(message)
            end

            local user_token = input_token(deff)
            
            if not user_token then
                return deff.done(locale('token_not_found'))
            end

            if not modules.auth._ValidateToken(license, user_token) then
                return deff.done(locale('token_invalid'))
            end

            return deff.done()
        end)
    end


    --e-mail and password validation
    local is_login_valid = modules.auth._AuthUser(user, license, deff, AdaptiveCards.InputEmailPassword )

    if not is_login_valid then
        return deff.done(locale('invalid_login'))
    end

    if not user.is_valided then
        Wait(50)

        local user_token = input_token(deff)

        if not user_token then
            return deff.done(locale('token_not_found'))
        end

        if not modules.auth._ValidateToken(license, user_token) then
            return deff.done(locale('token_invalid'))
        end

        return deff.done()
    end

    if GetConvarInt('sw:enable_allowlist', 1) == 1 and not user.is_allowed then
        return deff.done(locale('not_allowed'))
    end    

    if modules.auth._IsUserBlocked(license) then
        return deff.done(locale('is_blocked'))
    end
    
    deff.done()
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    modules.player._SaveAndUnload(src)
    print('Player dropped: ', src, reason)
end)

local function player_save_thread()
    local save_interval = GetConvarInt('sw:save_interval', 1) * 60000 --save in minutes    
    while true do
        
        Wait(save_interval)
        modules.player._SaveAllOnlinePlayers()        
    end
end


CreateThread(player_save_thread)