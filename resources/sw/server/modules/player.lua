local imod = {}
local module = {}

local Players = {}

GlobalState.PlayerCount = 0

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

---Remove player from PlayerList
---@param source number | string
function module.Unload(source)
    if Players[source] then
        Players[source] = nil
        GlobalState.PlayerCount = GlobalState.PlayerCount - 1
    end
end

function module.Load(source, data)
    Players[source] = data
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
    Players[source].PlayerData.datatable[key] = value
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
    return Players[source].PlayerData.datatable[key]
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
    local datatable = PlayerData?.datatable or {}
    datatable.health = datatable?.health or 200
    datatable.hunger = datatable?.hunger or 0
    datatable.thirst = datatable?.thirst or 0
    datatable.stress = datatable?.stress or 0
    datatable.sickness = datatable?.sickness or 0
    datatable.cold = datatable?.cold or 0
    datatable.fever = datatable?.fever or 0
    datatable.coconut = datatable?.coconut or 0
    datatable.piss = datatable?.piss or 0
    datatable.alcohol = datatable?.alcohol or 0
    PlayerData.datatable = datatable
    local groups = PlayerData?.groups or {}
    groups.user = groups?.user or true
    PlayerData.groups = groups
    local money = PlayerData?.money or {}
    money.cash = money?.cash or GetConvarInt('sw:startcash', 5000)
    money.bank = money?.bank or GetConvarInt('sw:startbank', 10000)
    PlayerData.money = money
    PlayerData.permissions = PlayerData?.permissions or {}
    PlayerData.job = PlayerData?.job or { name = 'unemployed', label = 'Unemployed', grade = 0 }
    PlayerData.gang = PlayerData?.gang or { name = 'none', label = 'None' }

    return PlayerData
end

function module.Login(source, id)
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
            lib.addPrincipal('player.' .. source, 'group.' .. k)
        end
    end

    for _, v in next, PlayerData?.permissions or {} do
        lib.addAce('player.' .. source, 'permission.' .. v, 'allow')
    end

    if PlayerData?.job?.name and PlayerData.job.name ~= 'unemployed' and PlayerData.job?.duty then
        lib.addPrincipal('player.' .. source, 'job.' .. PlayerData.job.name)
    end

    if PlayerData?.gang?.name and PlayerData.gang.name ~= 'none' then
        lib.addPrincipal('player.' .. source, 'gang.' .. PlayerData.gang.name)
    end


    --sync status data and health
    local ped = GetPlayerPed(source)
    local health = GetEntityHealth(ped)
    if health ~= PlayerData.datatable.health then
        SetEntityHealth(ped, PlayerData.datatable.health)
    end

    module.Load(source, PlayerData)

    module.SetState(source, 'hunger', PlayerData.datatable.hunger, true)
    module.SetState(source, 'thirst', PlayerData.datatable.thirst, true)
    module.SetState(source, 'stress', PlayerData.datatable.stress, true)
    module.SetState(source, 'sickness', PlayerData.datatable.sickness, true)
    module.SetState(source, 'cold', PlayerData.datatable.cold, true)
    module.SetState(source, 'fever', PlayerData.datatable.fever, true)
    module.SetState(source, 'coconut', PlayerData.datatable.coconut, true)
    module.SetState(source, 'piss', PlayerData.datatable.piss, true)
    module.SetState(source, 'alcohol', PlayerData.datatable.alcohol, true)

    TriggerClientEvent('Player:SyncData', source, PlayerData)
    TriggerClientEvent('Player:SyncJob', source, PlayerData.job)
    TriggerClientEvent('Player:SyncGang', source, PlayerData.gang)
    TriggerClientEvent('Player:SyncMoney', source, PlayerData.money)

    TriggerEvent('player:login', source, { user_id = PlayerData.user_id, char_id = id })

    return true, PlayerData.lastposition
end

function module._Save(source, force)
    if not Players[source] then return end
    if Players[source].saving and not force then return end
    Players[source].saving = true
    local prev_data = table.clone(Players[source])
    print(source, 'Player Saved', prev_data.firstname .. ' ' .. prev_data.lastname)
    local ped = GetPlayerPed(source)
    local position = GetEntityCoords(ped)
    local health = GetEntityHealth(ped)

    prev_data.datatable.health = health

    imod.storage.Update([[
            UPDATE characters SET
                lastposition = ?,
                groups = ?,
                permissions = ?,
                job = ?,
                gang = ?,
                money = ?,
                datatable = ?
                WHERE id = ?
            ]],
        {
            json.encode(position),
            json.encode(prev_data.groups),
            json.encode(prev_data.permissions),
            json.encode(prev_data.job),
            json.encode(prev_data.gang),
            json.encode(prev_data.money),
            json.encode(prev_data.datatable),
            prev_data.char_id or prev_data.id
        })

    Players[source].saving = nil
end

function module._SaveAndUnload(src)
    module._Save(src, true)
    module.Unload(src)
end

function module._SaveAllOnlinePlayers()
    for k in next, Players or {} do
        module._Save(k)
    end
end

function module.PlayAnim(src, upper, seq, looping)
    TriggerClientEvent('Player:PlayAnim', src, upper, seq, looping)
end

function module.StopAnim(src, upper)
    TriggerClientEvent('Player:StopAnim', src, upper)
end

--Net events
RegisterNetEvent('Player:Server:Money', function(action, money_type, value)
    local source = source
    if not Players[source] then return end
    if value < 0 then return end
    if action == 'set' then
        Players[source].money[money_type] = value
    elseif action == 'add' then
        if value == 0 then return end
        Players[source].money[money_type] = (Players[source].money[money_type] or 0) + value
    elseif action == 'remove' then
        if value == 0 then return end
        Players[source].money[money_type] = (Players[source].money[money_type] or 0) - value
        if Players[source].money[money_type] < 0 then
            Players[source].money[money_type] = 0
        end
    end
    TriggerClientEvent('Player:SyncMoney', source, Players[source].money, action, money_type, value)
end)


local function __init__(storage_module, server_module, character_module)
    local _module = { name = 'Player', exp_prefix = 'Player', }
    imod.storage = storage_module
    imod.server = server_module
    imod.character = character_module
    return setmetatable(_module, { __index = module })
end

return __init__
