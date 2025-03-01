local old_print = print
local print = lib.print.info
local require = lib.require
local config = require '@sw_multichar.shared.config'


local spawned = {}
local login = {}

local function GetAllCharacters( license )    
    local chars = exports.sw:CharacterGetAll( license, true )
    for k in next, chars do
        chars[k].fullName = string.format('%s %s', chars[k].firstname, chars[k].lastname)
    end
    
    return chars, exports.sw:GetUserData(license, 'allow_max_chars') or config.MaxPlayerCharacters
end

local function GetUserCharacater( id )
    local character = exports.sw:CharacterGetOne( id )
    if character then
        character.fullName = string.format('%s %s', character.firstname, character.lastname)
    end
    return character
end

lib.callback.register('sw_multichar:server:getCharacters', function( source )    
    return GetAllCharacters( exports.sw:GetPlayerIdentifier( source, 'license' ) )
end)


lib.callback.register('sw_multichar:server:login', function( source, id )

    print(source, id)

    local has_logged, position = exports.sw:PlayerLogin( source, id )
    if has_logged then
        repeat
            Wait(1000)
        until login[source]
        local is_first = not spawned[ login[source].char_id ]
        spawned[ login[source].char_id ] = true
        login[source] = nil
        return true, is_first, position
    end
    
end)

lib.callback.register('sw_multichar:server:try_delete_char', function( source, id )
    local license = exports.sw:GetPlayerIdentifier( source, 'license' )
    local char = GetUserCharacater( id )
    local result = char?.license == license and not char?.deleted_at
    print(result)
    if result then        
        return exports.sw:CharacterDelete( id, false ) == 1
    end
    return false
end)

lib.callback.register('sw_multichar:server:createNewCharacter', function(source, firstname, lastname, sex, birthdate)
    local license = exports.sw:GetPlayerIdentifier( source, 'license' )
    local _d = os.date('*t', birthdate // 1000)
    if os.date('*t', os.time()).year - _d.year < 18 then
        return false, 'O personage deve ter 18 anos ou mais'
    end
    if not firstname or firstname:len() < 4 or firstname:len() > 16 then
        return false, 'Nome deve ter entre 4 e 16 caracteres'
    end
    if not lastname or lastname:len() < 4 or lastname:len() > 16 then
        return false, 'Sobrenome deve ter entre 4 e 16 caracteres'
    end
    if not sex or (sex ~= 'M' and sex ~= 'F') then
        return false, 'Sexo deve ser M ou F'
    end

    local current_char_count = exports.sw:GetUserCharactersCount( license ) 

    local allowed_chars = exports.sw:GetUserData( license, 'allow_max_chars' )     
    allowed_chars = allowed_chars and tonumber(allowed_chars) or config.MaxPlayerCharacters

    if current_char_count >= allowed_chars then        
        return false, 'Você já atingiu o limite de personagens permitidos'
    end

    local id = exports.sw:CreateCharacter({
        license = license,
        firstname = firstname,
        lastname = lastname,
        sex = sex,
        birthdate = os.date('%Y-%m-%d', birthdate // 1000)
    })

    if id then
        return true, 'Personagem criado com sucesso', id
    end

    return false, 'Erro ao criar o personagem. Entre em contato com o suporte.'
    
end)

AddEventHandler('playerDropped', function()
    local src = source
    if login[src] then
        login[src] = nil
    end
end)

AddEventHandler('player:login', function (source, data)
    print(source, data)
    Wait(1000)
    login[source] = data
end)
