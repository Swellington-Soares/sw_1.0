local module = {}
local imod = {}


local function GenerateUniqueCid()
    local cid
    repeat
        cid = lib.string.random('11AA1A11')
    until not imod.storage.Scalar('SELECT 1 FROM view_player WHERE cid = ?', { cid })
    return cid
end

function module.CharacterGetOne(id)
    local character = imod.storage.Single('SELECT * FROM view_player WHERE char_id = ?', { id })
    if not character then return end
    character.datatable = character.datatable and json.decode(character.datatable) or {}
    character.groups = character.groups and json.decode(character.groups)
    character.lastposition = character.lastposition and json.decode(character.lastposition)
    character.job = character.job and json.decode(character.job) 
    character.gang = character.gang and json.decode(character.gang)
    character.permissions = character.permissions and json.decode(character.permissions) 
    character.skin = character.skin and json.decode(character.skin)
    return character
end

function module.CharacterGetAll(license, exclude_delete)
    local q = 'SELECT * FROM view_player WHERE license = ?'

    if exclude_delete then
        q = q .. ' AND deleted_at IS NULL'
    end

    local characters = imod.storage.Fetch(q, { license })
    if not characters then return end
    for k in next, characters do
        characters[k].datatable = characters[k].datatable and json.decode(characters[k].datatable) or {}
        characters[k].groups = characters[k].groups and json.decode(characters[k].groups) or {}
        characters[k].lastposition = characters[k].lastposition and json.decode(characters[k].lastposition) or {}
        characters[k].job = characters[k].job and json.decode(characters[k].job) or {}
        characters[k].gang = characters[k].gang and json.decode(characters[k].gang) or {}
        characters[k].permissions = characters[k].permissions and json.decode(characters[k].permissions) or {}
        characters[k].skin = characters[k].skin and json.decode(characters[k].skin) or {}
    end

    return characters
end

function module.CharacterDelete(id, hard)
    if hard then
        return imod.storage.Update('DELETE FROM characters WHERE id = ?', { id })
    end
    return imod.storage.Update('UPDATE characters SET deleted_at = NOW() WHERE id = ?', { id })
end

function module.GetUserCharactersCount(license)
    return imod.storage.Scalar('SELECT COUNT(id) as count FROM characters WHERE license = ? AND deleted_at IS NULL',
        { license })
end

function module.CreateCharacter(data)
    return imod.storage.Insert(
        'INSERT INTO characters (license, cid, firstname, lastname, birthdate, sex) VALUES (?, ?, ?, ?, ?, ?)',
        {
            data.license,
            GenerateUniqueCid(),
            data.firstname,
            data.lastname,
            data.birthdate,
            data.sex
        })
end

local function __init__(storage)
    local _module = { name = 'Character', }
    imod.storage = storage
    return setmetatable(_module, { __index = module })
end

return __init__
