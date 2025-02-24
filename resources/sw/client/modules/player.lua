local module = {}
local PlayerData = {}
local anims = {}

function module.StartPlayerTeleport(x, y, z)
    local entity = GetVehiclePedIsIn(cache.ped, false)
    entity = entity == 0 and cache.ped or entity
    NetworkFadeOutEntity(entity, true, false)
    SetEntityCollision(entity, false, false)
    DoScreenFadeOut(500)
    Wait(510)
    SetEntityCoordsNoOffset(entity, x + 0.001, y + 0.001, z + 0.001, false, false, true)
    local timeout = GetGameTimer() + 5000
    repeat
        local aux_z = z
        local isFound, _z = GetGroundZAndNormalFor_3dCoord(x, y, aux_z)
        if not isFound and GetGameTimer() < timeout then
            aux_z = aux_z + 10.0
            isFound, _z = GetGroundZAndNormalFor_3dCoord(x, y, aux_z)
        else
            SetEntityCoordsNoOffset(entity, x + 0.001, y + 0.001, _z + 0.001, false, false, true)
        end
    until isFound
    DoScreenFadeIn(250)
    NetworkFadeInEntity(entity, true)
    SetEntityCollision(entity, true, true)
end

function module.GetPlayerPosition()
    local x, y, z = table.unpack(GetEntityCoords(cache.ped, true))
    return x, y, z
end

function module.GetPlayerData()
    return PlayerData
end

function module.SetPlayerData(key, value)
    PlayerData[key] = value
end

local function sync_job(job)
    PlayerData.job = job
end

local function sync_gang(gang)
    PlayerData.gang = gang
end

local function sync_money(moneytable, action, money_type, value)
    PlayerData.money = moneytable
end

function module.GetJob()
    return PlayerData.job
end

function module.GetGang()
    return PlayerData.gang
end

function module.GetMoney(money_type)
    return PlayerData.money[money_type] or 0
end

function module.SetMoney(money_type, value)
    TriggerServerEvent('Player:Server:Money', 'set', money_type, value)
end

function module.AddMoney(money_type, value)
    TriggerServerEvent('Player:Server:Money', 'add', money_type, value)
end

function module.RemoveMoney(money_type, value)
    TriggerServerEvent('Player:Server:Money', 'remove', money_type, value)
end

function module.PlayAnim(upper, seq, looping)
    if seq?.task then
        module.StopAnim(true)
        if seq.task == 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER' then
            local pos = GetEntityCoords(cache.ped)
            TaskStartScenarioAtPosition(cache.ped, seq.task, pos.x, pos.y, pos.z - 1, GetEntityHeading(ped), 0, false,
                false)
        else
            TaskStartScenarioInPlace(cache.ped, seq.task, 0, not seq.play_exit)
        end
    else
        module.StopAnim(upper)
        local flags = 0
        if upper then flags = flags + 48 end
        if looping then flags = flags + 2 end
        CreateThread(function()
            local id = 'ANIM ' .. lib.string.random('11111')
            anims[id] = true
            for k, v in ipairs(seq) or {} do
                if not anims[id] then break end
                local dict = v[1]
                local name = v[2]
                local loops = v[3] or 1
                lib.requestAnimDict(dict)
                if not HasAnimDictLoaded(dict) then break end
                for i = 1, loops do
                    if not anims[id] then break end
                    local first = (k == 1 and i == 1)
                    local last = (k == #seq and i == loops)
                    local inspeed = 8.001
                    local outspeed = -8.001
                    if not first then inspeed = 2.0001 end
                    if not last then outspeed = 2.0001 end
                    TaskPlayAnim(cache.ped, dict, name, inspeed, outspeed, -1, flags, 0, false, false, false)
                    Wait(0)
                    while GetEntityAnimCurrentTime(cache.ped, dict, name) < 0.95 and IsEntityPlayingAnim(cache.ped, dict, name, 3) do
                        Wait(0)
                    end
                end
            end
            anims[id] = nil
        end)
    end
end

function module.StopAnim(upper, force)
    anims = {}
    if force then
        ClearPedTasksImmediately(cache.ped)
    else
        if upper then
            ClearPedSecondaryTask(cache.ped)
        else
            ClearPedTasks(cache.ped)
        end
    end
end

--events
RegisterNetEvent('Player:SyncJob', sync_job)
RegisterNetEvent('Player:SyncGang', sync_gang)
RegisterNetEvent('Player:SyncMoney', sync_money)
RegisterNetEvent('Player:PlayAnim', module.PlayAnim)
RegisterNetEvent('Player:StopAnim', module.StopAnim)
RegisterNetEvent('Player:SetPlayerData', module.SetPlayerData)

RegisterNetEvent('Player:SyncData', function(data)
    PlayerData = data or {}
end)


local function init()
    local ped = PlayerPedId()
    SetPedDropsWeaponsWhenDead(ped, false)
    SetPedConfigFlag(ped, 422, true)
    SetPedConfigFlag(ped, 35, false)
    SetPedConfigFlag(ped, 128, false)
    SetPedConfigFlag(ped, 184, true)
    SetPedConfigFlag(ped, 229, true)
    SetPlayerWantedLevel(PlayerId(), 0, false)
end

--refresh ped setup
lib.onCache('ped', function()
    init()
end)

local function __init__()
    local _module = { name = 'Player' }
    return setmetatable(_module, { __index = module })
end

return __init__
