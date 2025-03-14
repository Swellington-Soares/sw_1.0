local imod = {}
local module = {}

local Players = {}

GlobalState.PlayerCount = 0

local func_perms = {} -- special permission created by user

local jobs = lib.require 'shared.jobs'
local gangs = lib.require 'shared.gangs'

local default_job <const> = {
    name = 'unemployed',
    label = 'Desempregado',
    grade = 0,
    gradeName = 'Unemployed',
}

local default_gang <const> = {
    name = 'none',
    label = 'Nenhum',
    gradeName = 'None',
    grade = 0,
}


---Get Online Player from PlayerList
---@param source PlayerSource
---@return table
function module.GetOne(source)
    return Players[source]
end



---Returns all players source from Online PlayerList
---@return table<PlayerSource>
function module.ListAll()
    local p = {}
    for k in next, Players do
        p[#p + 1] = k
    end
    return p
end

function module.GetAll()
    local p = {}
    for _, v in next, Players do
        p[#p+1] = v
    end
    return p
end

---Remove player from PlayerList
---@param source number | string
function module.Unload(source)
    if Players[source] then
        lib.print.debug('Unloading player: ' .. source)

        local PlayerData = table.clone(Players[source].PlayerData)


        local groups = PlayerData.groups
        local permissions = PlayerData.permissions
        local job = PlayerData.job
        local gang = PlayerData.gang

        for k in next, groups or {} do
            lib.removePrincipal(source, 'group.' .. k)
        end

        for _, v in next, permissions or {} do
            lib.removeAce(source, v, 'allow')
        end

        if job?.name and job.name ~= 'unemployed' then
            lib.removePrincipal(source, 'job.' .. job.name)
        end

        if gang?.name and gang.name ~= 'none' then
            lib.removePrincipal(source, 'gang.' .. gang.name)
        end

        Players[source] = nil
        GlobalState.PlayerCount = GlobalState.PlayerCount - 1
    end
end

function module.Load(source, data)
    data.source = source
    Players[source] = {
        user_id = data.user_id,
        license = data.license,
        source = source,
        char_id = data.char_id,
        PlayerData = data,
    }
    GlobalState.PlayerCount = GlobalState.PlayerCount + 1
end

function module.GetData(source, key)
    if not source or type(key) ~= 'string' then return end
    if not Players[source] then return end
    return Players[source].PlayerData[key]
end

function module.SetMetadata(source, key, value)
    if not source or type(key) ~= 'string' then return end
    if not Players[source] then return end
    Players[source].PlayerData.metadata[key] = value
    if table.contains({ 'health', 'stress', 'hunger', 'thirst', 'sickness', 'cold', 'fever', 'coconut', 'piss' }, key) then
        if value < 0 then value = 0 end
        if value > 100 then value = 100 end
        Player(source).state:set(key, value, true)
    end
    TriggerClientEvent('Player:SetPlayerMetadata', source, key, value)
end

function module.GetMetadata(source, key)
    if not source or type(key) ~= 'string' then return end
    if not Players[source] then return end
    return Players[source].PlayerData.metadata[key]
end

function module.SetData(source, key, value)
    if not source or type(key) ~= 'string' then return end
    if not Players[source] then return end
    Players[source].PlayerData[key] = value
    TriggerClientEvent('Player:SetPlayerData', source, key, value)
end

function module.GetCharacterSavedData(id, key)
    assert(type(id) == 'number', 'id must be a number')
    assert(type(key) == 'string', 'key must be a string')
    return imod.storage.Scalar('SELECT dvalue FROM player_data WHERE id = ? AND dkey = ?', { id, key })
end

function module.SetCharacterSavedData(id, key, value)
    assert(type(id) == 'number', 'id must be a number')
    assert(type(key) == 'string', 'key must be a string')
    if type(value) == "table" then
        value = json.encode(value)
    end
    return imod.storage.Update(
        'INSERT INTO player_data (id, dkey, dvalue) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE dvalue = VALUES(dvalue)',
        { id, key, value })
end

function module.UpdateSkin(char_id, skin)
    assert(type(char_id) == 'number', 'char_id must be a number')
    assert(type(skin) == 'table', 'skin must be a table')
    local skin = json.encode(skin)
    imod.storage.Update('UPDATE characters SET skin = ? WHERE id = ?', { skin, char_id })
end

function module.GetSkin(char_id)
    assert(type(char_id) == 'number', 'char_id must be a number')
    local skin = imod.storage.Scalar('SELECT skin FROM characters WHERE id = ?', { char_id })
    return skin and json.decode(skin) or nil
end

RegisterNetEvent('sw:player:update_player_skin', function(char_id, skin)
    local src = source
    local license = imod.server.GetPlayerIdentifier(src, 'license')
    local charExists = imod.storage.Scalar('SELECT 1 FROM characters WHERE license = ? AND id = ?', { license, char_id }) ~=
        nil
    if not charExists then return end
    module.UpdateSkin(char_id, skin)
end)


function module.GetState(source, key)
    assert(type(source) == 'number', 'source must be a number')
    assert(type(key) == 'string', 'key must be a string')
    return Player(source).state[key]
end

function module.SetState(source, key, value, sync)
    assert(type(source) == 'number', 'source must be a number')
    assert(type(key) == 'string', 'key must be a string')
    Player(source).state:set(key, value, sync)
end

lib.callback.register('sw:player:get_skin', function(_, id)
    return module.GetSkin(id)
end)

local function CreatePlayerData(newdata)
    local PlayerData = newdata or {}
    local metadata = PlayerData?.metadata or {}
    metadata.health = metadata?.health or 200
    metadata.hunger = metadata?.hunger or 0
    metadata.thirst = metadata?.thirst or 0
    metadata.stress = metadata?.stress or 0
    metadata.sickness = metadata?.sickness or 0
    metadata.cold = metadata?.cold or 0
    metadata.fever = metadata?.fever or 0
    metadata.coconut = metadata?.coconut or 0
    metadata.piss = metadata?.piss or 0
    metadata.alcohol = metadata?.alcohol or 0
    PlayerData.metadata = metadata
    local groups = PlayerData?.groups or {}
    groups.user = groups?.user or true
    PlayerData.groups = groups
    local money = PlayerData?.money or {}
    money.cash = money?.cash or GetConvarInt('sw:startcash', 5000)
    money.bank = money?.bank or GetConvarInt('sw:startbank', 10000)
    PlayerData.money = money
    PlayerData.permissions = PlayerData?.permissions or {}
    PlayerData.job = PlayerData?.job or table.clone(default_job)
    PlayerData.gang = PlayerData?.gang or table.clone(default_gang)

    return PlayerData
end

function module.Login(source, id)
    local source = tonumber(source)
    local license = imod.server.GetPlayerIdentifier(source, 'license')
    local character = imod.character.CharacterGetOne(id)
    if not character or character?.license ~= license then
        imod.server.Ban(license, 'Tentativa de login com personagem inválido')
        DropPlayer(source, 'Tentativa de login com personagem inválido')
        return false
    end


    local PlayerData = CreatePlayerData(character)

    --update groups
    for k, v in next, PlayerData?.groups or {} do
        if v then
            lib.addPrincipal(source, 'group.' .. k)
        end
    end

    for _, v in next, PlayerData?.permissions or {} do
        lib.addAce(source, v, 'allow')
    end

    if PlayerData?.job?.name and PlayerData.job.name ~= 'unemployed' and PlayerData.job?.duty then
        lib.addPrincipal(source, 'job.' .. PlayerData.job.name)
    end

    if PlayerData?.gang?.name and PlayerData.gang.name ~= 'none' then
        lib.addPrincipal(source, 'gang.' .. PlayerData.gang.name)
    end


    module.Load(source, PlayerData)

    module.SetState(source, 'hunger', PlayerData.metadata.hunger, true)
    module.SetState(source, 'thirst', PlayerData.metadata.thirst, true)
    module.SetState(source, 'stress', PlayerData.metadata.stress, true)
    module.SetState(source, 'sickness', PlayerData.metadata.sickness, true)
    module.SetState(source, 'cold', PlayerData.metadata.cold, true)
    module.SetState(source, 'fever', PlayerData.metadata.fever, true)
    module.SetState(source, 'coconut', PlayerData.metadata.coconut, true)
    module.SetState(source, 'piss', PlayerData.metadata.piss, true)
    module.SetState(source, 'alcohol', PlayerData.metadata.alcohol, true)

    TriggerClientEvent('Player:SyncData', source, PlayerData)
    TriggerClientEvent('Player:SyncJob', source, 'set', PlayerData.job?.name, PlayerData.job)
    TriggerClientEvent('Player:SyncGang', source, 'set',  PlayerData.job?.name, PlayerData.gang)
    TriggerClientEvent('Player:SyncMoney', source, PlayerData.money)

    TriggerEvent('player:login', source, { user_id = PlayerData.user_id, char_id = id })

    -- Player(source).state:set('isLoggedIn', true, true)

    return true, PlayerData.lastposition
end

function module._Save(source, force)
    if not Players[source] then return end
    if Players[source].saving and not force then return end
    Players[source].saving = true
    local prev_data = table.clone(Players[source].PlayerData)
    lib.print.debug(source, 'Player Saved', prev_data.firstname .. ' ' .. prev_data.lastname)
    local ped = GetPlayerPed(source)
    local position = GetEntityCoords(ped)
    local health = GetEntityHealth(ped)

    prev_data.metadata.health = health

    imod.storage.Update([[
            UPDATE characters SET
                lastposition = ?,
                groups = ?,
                permissions = ?,
                job = ?,
                gang = ?,
                money = ?,
                metadata = ?
                WHERE id = ?
            ]],
        {
            json.encode(position),
            json.encode(prev_data.groups),
            json.encode(prev_data.permissions),
            json.encode(prev_data.job),
            json.encode(prev_data.gang),
            json.encode(prev_data.money),
            json.encode(prev_data.metadata),
            prev_data.char_id or prev_data.id
        })

    Players[source].saving = nil
end

function module._SaveAndUnload(src)
    if not Players[src]?.ready then return end
    pcall(module._Save, src, true)
    pcall(module.Unload, src)
end

function module._SaveAllOnlinePlayers()
    for k in next, Players or {} do
        if Players[k]?.ready and DoesPlayerExist(k) and not Players[k]?.saving then
            module._Save(k)
        end
    end
end

function module.PlayAnim(src, upper, seq, looping)
    TriggerClientEvent('Player:PlayAnim', src, upper, seq, looping)
end

function module.StopAnim(src, upper)
    TriggerClientEvent('Player:StopAnim', src, upper)
end

function module.GetMoney(src, money_type)
    if not Players[src] then return end
    if not Players[src].PlayerData.money[money_type] then return 0 end
    return Players[src].PlayerData.money[money_type]
end

function module.SetMoney(src, money_type, value)   
    if value >= 0 then    
        if not Players[src] then return end
        Players[src].PlayerData.money[money_type] = value
        return true
    end
end

function module.AddMoney(src, money_type, value)
    if value >= 0 then
        if not Players[src] then return end
        Players[src].PlayerData.money[money_type] = (Players[src].PlayerData.money[money_type] or 0) + value
        return true
    end
end

function module.RemoveMoney(src, money_type, value)
    if value >= 0 then
        if not Players[src] then return end
        Players[src].PlayerData.money[money_type] = (Players[src].PlayerData.money[money_type] or value) - value
        return true
    end
end

--Net events
RegisterNetEvent('Player:Server:Money', function(action, money_type, value)
    if action == 'set' then
        module.SetMoney(source, money_type, value)
    elseif action == 'add' then
        module.AddMoney(source, money_type, value)
    elseif action == 'remove' then
        module.RemoveMoney(source, money_type, value)
    end    
    TriggerClientEvent('Player:SyncMoney', source, Players[source].PlayerData.money, action, money_type, value)
end)



function module.SetGroup(source, group)
    if not source or not Players[source] or not group then return end
    local src = tonumber(source)
    if not module.HasGroup(source, group) then
        Players[source].PlayerData.groups[group] = true
        TriggerClientEvent('Player:SyncGroups', source, Players[source].PlayerData.groups)
        TriggerClientEvent('Player:SyncData', source, Players[source].PlayerData)
        lib.addPrincipal(src, 'group.' .. group)
        return true
    end
    return false
end

function module.RemoveGroup(source, group)
    if not source or not Players[source] or not group then return end
    local src = tonumber(source)
    if module.HasGroup(source, group) then
        Players[source].PlayerData.groups[group] = nil
        TriggerClientEvent('Player:SyncGroups', source, Players[source].PlayerData.groups)
        TriggerClientEvent('Player:SyncData', source, PlayerData)
        lib.removePrincipal(src, 'group.' .. group)
        return true
    end
    return false
end

function module.AddPermission(source, permission)
    if not source or not Players[source] or not permission then return end
    local src = tonumber(source)
    if not module.HasPermissions(source, permission) then
        Players[source].permissions[permission] = true
        TriggerClientEvent('Player:SyncPermissions', source, Players[source].permissions)
        TriggerClientEvent('Player:SyncData', source, Players[source].PlayerData)
        lib.addAce(src, permission, 'allow')
        return true
    end
end

function module.RemovePermission(source, permission)
    if not source or not Players[source] or not permission then return end
    local src = tonumber(source)
    if module.HasPermissions(source, permission) then
        Players[source].PlayerData.permissions[permission] = nil
        lib.removeAce(src, permission, 'allow')
        TriggerClientEvent('Player:SyncPermissions', source, Players[source].PlayerData.permissions)
        TriggerClientEvent('Player:SyncData', source, Players[source].PlayerData)
        return true
    end
end

function module.HasPermissions(source, permission)
    if not source or not Players[source] or not permission then return false end
    local src = tonumber(source)
    if IsPlayerAceAllowed(src, permission) then return true end
    if type(permission) == 'table' then
        for _, v in next, permission do
            if module.HasPermissions(src, v) then
                return true
            end
        end
    else
        local is_opt = permission:sub(1, 1) == '!'
        if is_opt then
            local parts = lib.string.strsplit(permission:sub(2), '.') or {}
            if #parts > 0 then
                local fperm = func_perms[parts[1]]
                return fperm and fperm(src, parts) or false
            end
        else
            local is_negative = permission:sub(1, 1) == '-'
            permission = permission:sub(2)
            if is_negative then
                if IsPlayerAceAllowed(src, permission) then
                    lib.removeAce(src, permission, 'allow')
                    lib.addAce(src, permission, 'deny')
                    return false
                else
                    return true
                end
            end
        end
    end
    return IsPlayerAceAllowed(src, permission)
end

function module.HasGroup(source, group)
    if not source or not Players[source] or not group then return false end
    return Players[source].PlayerData.groups[group] or IsPlayerAceAllowed(source, 'group.' .. group) or false
end

function module.SetJob(source, job, rank)
    if not source or not Players[source] or not job then return end
    if not jobs[job] then return false, "Serviço com ID: [ " .. job .. "] inválido." end
    local jobinfo = jobs[job]

    if not jobinfo.ranks[rank] then
        return false, "Rank com ID: [ " .. rank .. "] inválido."
    end

    if Players[source].PlayerData.job and Players[source].PlayerData.job.name == job and Players[source].PlayerData.job.grade == rank then
        return false, "Você já está com este serviço."
    end

    if Players[source].PlayerData.job and Players[source].PlayerData.job.name ~= 'unemployed' then
        module.RemoveJob(source, Players[source].PlayerData.job.name)
    end

    Players[source].PlayerData.job = {
        name = job,
        label = jobinfo.label,
        grade = rank,
        gradeName = jobinfo.ranks[rank].label,
    }

    TriggerClientEvent('Player:SyncJob', source, 'set', Players[source].PlayerData.job)
    TriggerClientEvent('Player:SyncData', source, Players[source].PlayerData)
    return true
end

function module.SetGang(source, gang, rank)
    if not source or not Players[source] or not gang then return end
    if not gangs[gang] then return false, "Gang com ID: [ " .. gang .. "] inválido." end

    local ganginfo = gangs[gang]
    if not ganginfo.ranks[rank] then
        return false, "Rank com ID: [ " .. rank .. "] inválido."
    end

    if Players[source].PlayerData.gang and Players[source].PlayerData.gang.name == gang and Players[source].PlayerData.gang.rank == rank then
        return false, "Você já está nessa gangue"
    end

    if Players[source].PlayerData.gang and Players[source].PlayerData.gang.name ~= 'none' then
        module.RemoveGang(source, Players[source].PlayerData.gang.name)
    end

    Players[source].PlayerData.gang = {
        name = gang,
        label = ganginfo.label,
        grade = rank,
        gradeName = ganginfo.ranks[rank].label,
    }

    TriggerClientEvent('Player:SyncGang', source, 'set', Players[source].PlayerData.gang)
    TriggerClientEvent('Player:SyncData', source, Players[source].PlayerData)

    return true
end

function module.RemoveJob(source, job)
    if not source or not Players[source] or not job then return false end
    if Players[source].PlayerData.job and Players[source].PlayerData.job.name ~= job then return false end
    Players[source].PlayerData.job = default_job

    TriggerClientEvent('Player:SyncJob', source, 'remove', job, Players[source].PlayerData.job)
    TriggerClientEvent('Player:SyncData', source, Players[source].PlayerData)

    return true
end

function module.RemoveGang(source, gang)
    if not source or not Players[source] or not gang then return false end
    if Players[source].PlayerData.gang and Players[source].PlayerData.gang.name ~= gang then return false end
    Players[source].PlayerData.gang = default_gang
    TriggerClientEvent('Player:SyncGang', source, 'remove', gang, Players[source].PlayerData.gang)
    TriggerClientEvent('Player:SyncData', source, Players[source].PlayerData)
    return true
end

function module._SetPlayerReady(source, value)
    if not source or not Players[source] then return end
    Players[source].ready = value
end

function module._SetAsDead(source, value)
    if not source or not Players[source] then return end
    Players[source].PlayerData.metadata['isdead'] = value
    Players[source].PlayerData.metadata['health'] = not value and 200 or 0 
end

local function RevivePlayer(src)    
    module._SetAsDead(src, false)
end

local function KillPlayer( src, data )
    module._SetAsDead(src, true)
    lib.print.info('KILL_PLAYER', data)
end


local function register_events()
    imod.server.RegisterEvent('revive_player', RevivePlayer)
    imod.server.RegisterEvent('kill_player', KillPlayer)
end

local function __init__(storage_module, server_module, character_module)
    local _module = { name = 'Player', exp_prefix = 'Player', }
    imod.storage = storage_module
    imod.server = server_module
    imod.character = character_module
    register_events()
    return setmetatable(_module, {
        __index = module,
        __tostring = function()
            return _module.name
        end
    })
end

return __init__
