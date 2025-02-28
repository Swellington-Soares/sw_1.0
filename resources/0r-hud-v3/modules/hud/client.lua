--[[
    - All data to be sent to the HUD is processed.
    - Threads are created.
--]]

local Hud = {}

local Utils = require 'modules.utils.client'
local Voice = require 'modules.voice.client'
local CarControl = require 'modules.car_control.client'
local Seatbelt = require 'modules.seatbelt.client'

local Weapons = lib.load('data.weapons')

-- Load initial data
Hud.data = lib.load('data.hud') --[[@type iHud]]

local screenResolution = { x = 0, y = 0 }
local isPauseActive = false
local oldVehicle = nil
local isPlayerDeath = false

---Get game active screen resolution and save
---@return table ScreenResolution
local function getScreenResolution()
    local screenWidth, screenHeight = GetActiveScreenResolution()
    screenResolution.x = screenWidth
    screenResolution.y = screenHeight
    return { x = screenWidth, y = screenHeight }
end

---Get mini map positions to client screen resolution
---@param mapType any
---@param screenResolution any
---@return table
local function getMinimapPositions(mapType, screenResolution)
    local positions = { minimap = {}, minimap_blur = {}, minimap_mask = {}, }
    local defaultAspectRatio = 1920 / 1080
    local resolution = getScreenResolution()
    local resolutionX, resolutionY = resolution.x, resolution.y
    local aspectRatio = resolutionX / resolutionY

    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6)
    end

    local mapPlacer = Hud.data.mini_map.map_placer[mapType]
    if not mapPlacer then
        if mapType == 'rectangle' then
            if screenResolution.x >= 3440 then
                positions.minimap = { x = -0.007, y = -0.075, width = 0.1685, height = 0.19 }
                positions.minimap_blur = { x = -0.0085, y = -0.045, width = 0.27, height = 0.3 }
                positions.minimap_mask = { x = 0.0, y = 0.0, width = 0.128, height = 0.2 }
            elseif screenResolution.x >= 2560 then
                positions.minimap = { x = -0.007, y = -0.075, width = 0.1685, height = 0.19 }
                positions.minimap_blur = { x = -0.0085, y = -0.045, width = 0.27, height = 0.3 }
                positions.minimap_mask = { x = 0.0, y = 0.0, width = 0.128, height = 0.2 }
            else
                positions.minimap = { x = -0.007, y = -0.075, width = 0.1685, height = 0.19 }
                positions.minimap_blur = { x = -0.0085, y = -0.045, width = 0.27, height = 0.3 }
                positions.minimap_mask = { x = 0.0, y = 0.0, width = 0.128, height = 0.2 }
            end
        else
            if screenResolution.x >= 3440 then
                positions.minimap = { x = 0.0085, y = -0.075, width = 0.14, height = 0.18 }
                positions.minimap_blur = { x = 0.007, y = -0.075, width = 0.14, height = 0.18 }
                positions.minimap_mask = { x = 0.1, y = -0.020, width = 0.08, height = 0.22 }
            elseif screenResolution.x >= 2560 then
                positions.minimap = { x = 0.0085, y = -0.075, width = 0.14, height = 0.18 }
                positions.minimap_blur = { x = 0.007, y = -0.075, width = 0.14, height = 0.18 }
                positions.minimap_mask = { x = 0.1, y = -0.020, width = 0.08, height = 0.22 }
            else
                positions.minimap = { x = 0.0085, y = -0.075, width = 0.14, height = 0.18 }
                positions.minimap_blur = { x = 0.007, y = -0.075, width = 0.14, height = 0.18 }
                positions.minimap_mask = { x = 0.1, y = -0.020, width = 0.08, height = 0.22 }
            end
        end

        positions.minimap.x += minimapOffset
        positions.minimap_blur.x += minimapOffset
        positions.minimap_mask.x += minimapOffset
        if not Hud.data.is_res_style_active then
            if Hud.data.bar_style == 'zarg-m' then
                local wInc = 0.01
                local hInc = 0.02
                local yInc = 0.045
                local xInc = -0.03
                positions.minimap.y = positions.minimap.y + yInc
                positions.minimap_blur.y = positions.minimap_blur.y + yInc
                positions.minimap.x = positions.minimap.x + xInc
                positions.minimap_blur.x = positions.minimap_blur.x + xInc
                positions.minimap.width = positions.minimap.width + wInc
                positions.minimap.height = positions.minimap.height + hInc
                positions.minimap_blur.width = positions.minimap_blur.width + wInc
                positions.minimap_blur.height = positions.minimap_blur.height + hInc
            elseif Hud.data.bar_style == 'universal' then
                local inc = 0.0
                positions.minimap.y = positions.minimap.y + inc
                positions.minimap_blur.y = positions.minimap_blur.y + inc
            else
                local inc = 0.012
                positions.minimap.y = positions.minimap.y + inc
                positions.minimap_blur.y = positions.minimap_blur.y + inc
            end
        end
    else
        local _minimap = { x = -0.007, y = -0.075, width = 0.1685, height = 0.19 }
        local _minimap_blur = { x = -0.0085, y = -0.045, width = 0.27, height = 0.3 }
        if mapType == 'circle' then
            _minimap = { x = 0.0085, y = -0.075, width = 0.14, height = 0.18 }
            _minimap_blur = { x = 0.007, y = -0.075, width = 0.14, height = 0.18 }
        end
        positions.minimap = {
            x = _minimap.x + mapPlacer.offsetX,
            y = _minimap.y + mapPlacer.offsetY,
            width = _minimap.width + mapPlacer.scale,
            height = _minimap.height + mapPlacer.scale
        }
        positions.minimap_blur = {
            x = _minimap_blur.x + mapPlacer.offsetX,
            y = _minimap_blur.y + mapPlacer.offsetY,
            width = _minimap_blur.width + mapPlacer.scale,
            height = _minimap_blur.height + mapPlacer.scale
        }
        positions.minimap_mask = { x = 0.0, y = 0.0, width = 0.128, height = 0.2 }
    end
    return positions
end

---Update ClientInfo Data
---It retrieves data from the cache and refreshes the data if timeout.
local function updateClientInfo()
    local client_info = Hud.data.client_info
    client_info.time.gameHours = GetClockHours()
    client_info.time.gameMinutes = GetClockMinutes()
    if not Hud.data.client_info.active then return end
    client_info.bank.amount = cache('client.bank.amount', function()
        return client.GetPlayerBalance('bank')
    end, 2000)
    client_info.cash.amount = cache('client.cash.amount', function()
        return client.GetPlayerBalance('cash')
    end, 2000)
    if Config.DefaultHudSettings.client_info.extra_currency.active then
        client_info.extra_currency.amount = cache('client.extra_currency.amount', function()
            return client.GetPlayerBalance('extra_currency')
        end, 2000)
    end
    client_info.job.label = cache('client.job.label', function()
        return client.GetPlayerJob().label
    end, 2000)
    client_info.job.gradeLabel = cache('client.job.gradeLabel', function()
        return client.GetPlayerJob().grade
    end, 2000)
    client_info.radio.inChannel = cache('client.radio.inChannel', function()
        return Voice.GetPlayerRadio().inChannel
    end, 2000)
    client_info.radio.channel = cache('client.radio.channel', function()
        return Voice.GetPlayerRadio().channel
    end, 2000)
    client_info.weapon.name = cache('client.weapon.name', function()
        return Weapons[GetSelectedPedWeapon(cache.ped)]
    end, 1000)
    local weapon = GetSelectedPedWeapon(cache.ped)
    local inWeapon = GetAmmoInPedWeapon(cache.ped, weapon)
    local _, inClip = GetAmmoInClip(cache.ped, weapon)
    local ammo = { inClip = inClip, inWeapon = inWeapon }
    client_info.weapon.ammo = ammo
    client_info.player_source.source = cache.serverId
end

---Update Compass Data
local function updateCompassStreet()
    local compassInfo = Hud.data.compass
    local playerCoords = GetEntityCoords(cache.ped)
    local streetHash, crossingRoadHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    compassInfo.street1 = GetStreetNameFromHashKey(streetHash)
    compassInfo.street2 = GetStreetNameFromHashKey(crossingRoadHash)
end

---Update Compass Data
---It works if it is active and in use.
local function updateCompassHeading()
    if not Hud.data.compass.active or
        (Hud.data.compass.onlyInVehicle and not Hud.data.vehicle_info.entity) then
        return
    end
    local camRotZ = GetGameplayCamRot(0).z
    local heading = math.floor(360.0 - ((camRotZ + 360.0) % 360.0))
    Hud.data.compass.heading = heading
end

---Update Navigation Data
---It works if it is active and in use.
local function updateNavigation()
    if not Hud.data.navigation_widget.active then return end
    local navigation = Hud.data.navigation_widget
    local compassInfo = Hud.data.compass
    if IsWaypointActive() then
        local waypointBlip = GetFirstBlipInfoId(8) -- 8 is the id for waypoint blips
        if waypointBlip ~= 0 then
            local waypointCoord = GetBlipInfoIdCoord(waypointBlip)
            local streetHash, crossingRoadHash = GetStreetNameAtCoord(waypointCoord.x, waypointCoord.y, waypointCoord.z)
            local streetName = GetStreetNameFromHashKey(streetHash)
            local crossingStreetName = GetStreetNameFromHashKey(crossingRoadHash)

            navigation.navigation.isDestinationActive = true
            navigation.navigation.currentStreet = (compassInfo.street1 or '') .. ' ' .. (compassInfo.street2 or '')
            navigation.navigation.destinationStreet = streetName
            if crossingStreetName ~= nil and crossingStreetName ~= '' then
                navigation.navigation.destinationStreet =
                    navigation.navigation.destinationStreet ..
                    ' & ' .. crossingStreetName
            end
        end
    else
        if navigation.navigation.isDestinationActive then
            navigation.navigation.isDestinationActive = false
        end
    end
end

---Update Bar Data
local function updateBars()
    local bars = Hud.data.bars
    local ped = cache.ped
    local playerId = cache.playerId
    --armor
    bars.armor.value = GetPedArmour(ped)
    --health
    local maxHealth = GetEntityMaxHealth(ped)
    local baseHealth = GetEntityHealth(ped)
    local adjustedHealth = maxHealth == 175 and (baseHealth + 25) or baseHealth
    local health = math.clamp(adjustedHealth - 100, 0, 100)
    if isPlayerDeath then
        health = 0
    end
    bars.health.value = health
    --hunger
    bars.hunger.value = PlayerData.hunger
    --oxygen
    local oxygen = 100
    if IsEntityInWater(ped) then
        oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
    end
    bars.oxygen.value = oxygen
    --stamina
    local stamina = 100 - GetPlayerSprintStaminaRemaining(playerId)
    bars.stamina.value = stamina
    --stress
    bars.stress.value = PlayerData.stress
    --thirst
    bars.thirst.value = PlayerData.thirst
    --voice
    local function valueToPercentageVoice(value)
        return (value >= 3 and 100) or (value == 2 and 50) or (value == 1 and 25) or 0
    end
    bars.voice.talkRange = Voice.GetTalkRange()
    bars.voice.value = valueToPercentageVoice(bars.voice.talkRange)
    bars.voice.isTalking = NetworkIsPlayerTalking(playerId)
    -- #
end

---Update Vehicle Data
local function updateVehicleInfo()
    local vehicle_info = Hud.data.vehicle_info
    local vehicle = cache.vehicle
    vehicle_info.entity = vehicle
    if vehicle and DoesEntityExist(vehicle) then
        if not oldVehicle or oldVehicle ~= vehicle then
            oldVehicle = vehicle
            vehicle_info.fuel.maxLevel = 100
            vehicle_info.fuel.type = CarControl.GetVehicleFuelType(vehicle)
            vehicle_info.veh_class = GetVehicleClass(vehicle)
            Hud.CheckRadarDisplay()
            Seatbelt.EnteredVehicle()
        end
        local engineRunning = GetIsVehicleEngineRunning(vehicle)
        local currentGear = nil
        if vehicle_info.gearType == 'manual' and engineRunning then
            currentGear = vehicle_info.manualGear
        else
            currentGear = engineRunning and GetVehicleCurrentGear(vehicle) or 'N'
        end
        if currentGear == 0 then
            currentGear = 'R'
        end
        local engineHealth = engineRunning and math.max(0, GetVehicleEngineHealth(vehicle)) or 1000
        local entitySpeed = GetEntitySpeed(vehicle)
        local vehicleSpeed = vehicle_info.kmH and
            entitySpeed * 3.6 or entitySpeed * 2.237
        local _, lightson, highbeams = GetVehicleLightsState(vehicle)
        vehicle_info.speed = math.floor(vehicleSpeed)
        vehicle_info.currentGear = currentGear
        vehicle_info.engineHealth = engineHealth * .1
        vehicle_info.fuel.level = Utils.GetVehicleFuelLevel(vehicle)
        vehicle_info.rpm = engineRunning and GetVehicleCurrentRpm(vehicle) or 0
        vehicle_info.isSeatbeltOn = Seatbelt.GetCurrentState()
        vehicle_info.isLightOn = lightson == 1 or highbeams == 1
        Hud.data.bars.vehicle_engine.value = vehicle_info.engineHealth
    else
        if oldVehicle then
            oldVehicle = nil
            vehicle_info = {
                entity = false,
                kmH = vehicle_info.kmH,
                fuel = {}
            }
            Hud.CheckRadarDisplay()
        end
    end
end

---Process config settings
function Hud.SetDefaultSettings()
    local def = Config.DefaultHudSettings
    Hud.data.bar_style = def.bar_style
    Hud.data.vehicle_hud_style = def.vehicle_hud_style
    Hud.data.is_res_style_active = def.is_res_style_active
    Hud.data.mini_map.onlyInVehicle = def.mini_map.onlyInVehicle
    Hud.data.mini_map.style = def.mini_map.style
    Hud.data.mini_map.editableByPlayers = def.mini_map.editableByPlayers
    Hud.data.compass.active = def.compass.active
    Hud.data.compass.onlyInVehicle = def.compass.onlyInVehicle
    Hud.data.compass.editableByPlayers = def.compass.editableByPlayers
    Hud.data.cinematic.active = def.cinematic.active
    Hud.data.vehicle_info.kmH = def.vehicle_info.kmH
    Hud.data.client_info.active = def.client_info.active
    Hud.data.client_info.server_info.active = def.client_info.server_info.active
    Hud.data.client_info.server_info.image = def.client_info.server_info.image
    Hud.data.client_info.server_info.name = def.client_info.server_info.name
    Hud.data.client_info.bank.active = def.client_info.bank.active
    Hud.data.client_info.cash.active = def.client_info.cash.active
    Hud.data.client_info.job.active = def.client_info.job.active
    Hud.data.client_info.player_source.active = def.client_info.player_source.active
    Hud.data.client_info.radio.active = def.client_info.radio.active
    Hud.data.client_info.real_time.active = def.client_info.real_time.active
    Hud.data.client_info.time.active = def.client_info.time.active
    Hud.data.client_info.weapon.active = def.client_info.weapon.active
    Hud.data.client_info.extra_currency.active = def.client_info.extra_currency.active
    Hud.data.bars.armor.color = def.bar_colors.armor
    Hud.data.bars.health.color = def.bar_colors.health
    Hud.data.bars.hunger.color = def.bar_colors.hunger
    Hud.data.bars.oxygen.color = def.bar_colors.oxygen
    Hud.data.bars.stamina.color = def.bar_colors.stamina
    Hud.data.bars.stress.color = def.bar_colors.stress
    Hud.data.bars.thirst.color = def.bar_colors.thirst
    Hud.data.bars.vehicle_engine.color = def.bar_colors.vehicle_engine
    Hud.data.bars.vehicle_nitro.color = def.bar_colors.vehicle_nitro
    Hud.data.bars.voice.color = def.bar_colors.voice
    Hud.data.music_info.active = def.music_info.active
    Hud.data.colors = Config.BarColors
    Hud.data.navigation_widget.active = def.navigation_widget.active
end

-- Radar display or hidden by options
function Hud.CheckRadarDisplay()
    DisplayRadar(false)
    if client.IsPlayerLoaded() and client.uiLoad then
        if not Hud.data.cinematic.show then
            if Hud.data.mini_map.onlyInVehicle then
                if (cache.vehicle and DoesEntityExist(cache.vehicle)) then
                    DisplayRadar(true)
                end
            else
                DisplayRadar(true)
            end
        end
    end
end

---Fix mini map position/scale to client screen resolution
function Hud.FixMiniMap()
    CreateThread(function()
        DisplayRadar(false)
        local mapType = Hud.data.mini_map.style
        local screenResolution = getScreenResolution()
        local minimapPositions = getMinimapPositions(mapType, screenResolution)

        if mapType == 'rectangle' then
            RequestStreamedTextureDict('rectangle', false)
            while not HasStreamedTextureDictLoaded('rectangle') do
                Wait(150)
            end
            AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'rectangle', 'radarmasksm')
            AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'rectangle', 'radarmasksm')
        else
            RequestStreamedTextureDict('circlemap', false)
            while not HasStreamedTextureDictLoaded('circlemap') do
                Wait(150)
            end
            AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'circlemap', 'radarmasksm')
        end

        SetMinimapComponentPosition('minimap', 'L', 'B', minimapPositions.minimap.x, minimapPositions.minimap.y,
            minimapPositions.minimap.width, minimapPositions.minimap.height)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', minimapPositions.minimap_blur.x,
            minimapPositions.minimap_blur.y, minimapPositions.minimap_blur.width, minimapPositions.minimap_blur.height)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', minimapPositions.minimap_mask.x,
            minimapPositions.minimap_mask.y, minimapPositions.minimap_mask.width, minimapPositions.minimap_mask.height)

        SetMinimapClipType(mapType == 'rectangle' and 0 or 1)

        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetBigmapActive(true, false)
        Wait(100)
        SetBigmapActive(false, false)
        Wait(100)
        Hud.CheckRadarDisplay()
    end)
end

-- Sets the visibility of the HUD UI element
---@param state boolean visible (true) or hidden (false)
function Hud.SetVisible(state)
    if state then
        Hud.CheckRadarDisplay()
    else
        DisplayRadar(false)
    end
    client.SendReactMessage('ui:setVisible', state)
end

-- The vehicle gear is updated with data from the `hrsgears` script.
RegisterNetEvent('0r-hud:Client:SetManualGear', function(newGear)
    Hud.data.vehicle_info.manualGear = newGear
end)

RegisterNetEvent(_e('client:updatePlayerCount'), function(playerCount, maxPlayers)
    Hud.data.client_info.server_info.playerCount = playerCount
    Hud.data.client_info.server_info.maxPlayers = maxPlayers
end)

RegisterNetEvent(_e('client:setPlayerDeathStatus'), function(state)
    isPlayerDeath = state
end)

RegisterNetEvent(_e('client:setVehicleNitroValue'), function(value)
    Hud.data.bars.vehicle_nitro.value = value
end)

RegisterNetEvent('hud:client:UpdateNitrous', function(hasNitro, level, state)
    Hud.data.bars.vehicle_nitro.value = level
end)

-- Slow running thick updates secondary priority data
CreateThread(function()
    local wait = 1000 -- more slowly, if the player is not fully loaded
    while true do
        if client.load then
            wait = 500
            updateCompassStreet()
            updateClientInfo()
            updateNavigation()
            Hud.CheckRadarDisplay()
        end
        Wait(wait)
    end
end)
-- Updates priority data
CreateThread(function()
    while true do
        local wait = 1000 -- slow, if the player is not fully loaded
        if client.load then
            wait = Config.RefreshTimes.hud
            updateCompassHeading()
            updateBars()
            updateVehicleInfo()
            client.SendReactMessage('ui:setHudData', Hud.data)
            if Hud.data.vehicle_info.entity then
                wait = Config.RefreshTimes.vehicle
            end
        end
        Wait(wait)
    end
end)

--What to do if the player opens the pause menu or changes the resolution:
CreateThread(function()
    getScreenResolution()
    while true do
        if client.load and client.uiLoad then
            -- Control Pause Menu
            if IsPauseMenuActive() and not isPauseActive then
                Hud.SetVisible(false)
                DisplayRadar(false)
                isPauseActive = true
            elseif not IsPauseMenuActive() and isPauseActive then
                Hud.SetVisible(true)
                Hud.CheckRadarDisplay()
                isPauseActive = false
            end
            -- Control Active Screen Resolution
            local x, y = GetActiveScreenResolution()
            if not screenResolution.x or screenResolution.x ~= x and not isPauseActive then
                screenResolution.x = x
                screenResolution.y = y
                Wait(1000)
                Hud.FixMiniMap()
            end
        end
        Wait(1000)
    end
end)

-- Hide GTA components if option is active
-- Resmon will increase its value. This function was created to make the minimap work more adaptively on servers that use different minimaps or different scripts.
if Config.HideGTAHudComponents then
    CreateThread(function()
        local minimap = RequestScaleformMovie('minimap')
        local HavePostalMap = Config.HavePostalMap
        while true do
            Wait(5)
            for _, component in pairs({ 2, 3, 4, 6, 7, 8, 9 }) do
                HideHudComponentThisFrame(component)
            end
            BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
            if HavePostalMap and not IsRadarHidden() then
                SetRadarZoom(1100)
            end
        end
    end)
end

return Hud
