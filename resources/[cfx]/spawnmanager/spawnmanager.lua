-- In-memory spawnpoint array
local spawnPoints = {}
local autoSpawnEnabled = false
local autoSpawnCallback
local spawnNum = 1
local spawnLock = false
local respawnForced
local diedAt

-- Support for mapmanager maps

local function addSpawnPoint(spawn)
    assert(tonumber(spawn.x) and tonumber(spawn.y) and tonumber(spawn.z), "Invalid spawn position")
    assert(tonumber(spawn.heading), "Invalid spawn heading")
    
    local model = tonumber(spawn.model) or GetHashKey(spawn.model)
    assert(IsModelInCdimage(model), "Invalid spawn model")
    
    spawn.model, spawn.idx = model, spawnNum
    spawnNum = spawnNum + 1
    spawnPoints[#spawnPoints+1] =  spawn
    return spawn.idx
end

AddEventHandler('getMapDirectives', function(add)
    add('spawnpoint', function(state, model)
        return function(opts)
            local success, err = pcall(function()
                local x, y, z = opts.x or opts[1], opts.y or opts[2], opts.z or opts[3]
                if not x or not y or not z then error("Invalid spawn coordinates") end
                
                local heading = opts.heading or 0
                x, y, z, heading = x + 0.0001, y + 0.0001, z + 0.0001, heading + 0.01
                
                addSpawnPoint({ x = x, y = y, z = z, heading = heading, model = model })
                state.add('xyz', { x, y, z })
                state.add('model', tonumber(model) or GetHashKey(model))
            end)
            
            if not success then Citizen.Trace(err .. "\n") end
        end
    end, function(state)
        for i, sp in next, spawnPoints do
            if sp.x == state.xyz[1] and sp.y == state.xyz[2] and sp.z == state.xyz[3] and sp.model == state.model then                
                spawnPoints[i] = nil
                return
            end
        end
    end)
end)


local function loadSpawns(spawnString)
    local data = json.decode(spawnString)
    assert(data.spawns, "No 'spawns' field in JSON data")
    for _, spawn in next, data.spawns do addSpawnPoint(spawn) end
end


local function removeSpawnPoint(spawn)
    for i = #spawnPoints, 1, -1 do
        if spawnPoints[i].idx == spawn then table.remove(spawnPoints, i) return end
    end
end

local function setAutoSpawn(enabled) autoSpawnEnabled = enabled end
local function setAutoSpawnCallback(cb) autoSpawnCallback, autoSpawnEnabled = cb, true end

local function freezePlayer(id, freeze)
    local ped = GetPlayerPed(id)
    SetPlayerControl(id, not freeze, false)
    
    if freeze then
        SetEntityVisible(ped, false)
        SetEntityCollision(ped, false)
        FreezeEntityPosition(ped, true)
        SetPlayerInvincible(id, true)
        if not IsPedFatallyInjured(ped) then ClearPedTasksImmediately(ped) end
    else
        SetEntityVisible(ped, true)
        SetEntityCollision(ped, true)
        FreezeEntityPosition(ped, false)
        SetPlayerInvincible(id, false)
    end
end

local function spawnPlayer(spawnIdx, cb)
    print(spawnLock)
    if spawnLock then return end
    spawnLock = true
    
    Citizen.CreateThread(function()
        spawnIdx = spawnIdx or GetRandomIntInRange(1, #spawnPoints + 1)
        local spawn = type(spawnIdx) == 'table' and spawnIdx or spawnPoints[spawnIdx]
        
        if not spawn then
            Citizen.Trace("Invalid spawn index\n")
            spawnLock = false
            return
        end
        
        if not spawn.skipFade then
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do Citizen.Wait(0) end
        end
        
        freezePlayer(PlayerId(), true)

        if spawn.changeSkin ~= false then
            RequestModel(spawn.model)
            while not HasModelLoaded(spawn.model) do Citizen.Wait(0) end
            
            SetPlayerModel(PlayerId(), spawn.model)
            SetModelAsNoLongerNeeded(spawn.model)
        end
        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
        
        local ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
        NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.heading, 0, true, 0)
        
        ClearPedTasksImmediately(ped)
        RemoveAllPedWeapons(ped, true)
        ClearPlayerWantedLevel(PlayerId())
        
        local time = GetGameTimer()
        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 5000) do Citizen.Wait(0) end
        
        ShutdownLoadingScreen()
        if IsScreenFadedOut() then DoScreenFadeIn(500) end
        freezePlayer(PlayerId(), false)
        
        TriggerEvent('playerSpawned', spawn)
        if cb then cb(spawn) end
        spawnLock = false
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= -1 and autoSpawnEnabled and NetworkIsPlayerActive(PlayerId()) then
            if (diedAt and GetTimeDifference(GetGameTimer(), diedAt) > 2000) or respawnForced then
                (autoSpawnCallback or spawnPlayer)()
                respawnForced = false
            end
        end
        diedAt = IsEntityDead(playerPed) and GetGameTimer() or nil
    end
end)

local function forceRespawn() spawnLock, respawnForced = false, true end
local function unlockSpawn() spawnLock = false end

exports('spawnPlayer', spawnPlayer)
exports('addSpawnPoint', addSpawnPoint)
exports('removeSpawnPoint', removeSpawnPoint)
exports('loadSpawns', loadSpawns)
exports('setAutoSpawn', setAutoSpawn)
exports('setAutoSpawnCallback', setAutoSpawnCallback)
exports('forceRespawn', forceRespawn)
exports('unlockSpawn', unlockSpawn)
