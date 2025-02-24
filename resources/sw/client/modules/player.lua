local module = {}
local PlayerData = {}

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

RegisterNetEvent('Player:SetPlayerData', module.SetPlayerData)
RegisterNetEvent('Player:SyncData', function(data)
    PlayerData = data or {}
end)

local function __init__()
    local _module = { name = 'Player'}    
    return setmetatable(_module, {__index = module })
end

return __init__