--[[ Main Client File]]

client = {
    framework = shared.GetFrameworkObject(),
    load = false,
    uiLoad = false,
}
PlayerData = {}

require 'modules.bridge.client'

local Utils = require 'modules.utils.client'
local Hud = require 'modules.hud.client'
local Music = require 'modules.music.client'
local CarControl = require 'modules.car_control.client'
local Seatbelt = require 'modules.seatbelt.client'

---Sends message to the ReactUI.
---@param action string
---@param data any
function client.SendReactMessage(action, data)
    SendNUIMessage({ action = action, data = data })
end

--- Prepare the frontend and send the data
function client.SetupUI()
    if client.uiLoad then return end
    Hud.SetDefaultSettings()
    local defaultLocale = GetConvar('ox:locale', 'en')
    client.SendReactMessage('ui:setupUI', {
        setLocale = {
            data = lib.loadJson(('locales.%s'):format(defaultLocale)).ui
        },
        setDefaultSettings = Hud.data
    })
end

--Opens the page of Hud settings.
local function openHudSettings()
    SetNuiFocus(true, true)
    client.SendReactMessage('ui:setSettingsOpen', true)
end

RegisterNetEvent('0r-hud:Client:cinematiccamstart', function()
    client.SendReactMessage('ui:toggleCinematicMode')
end)
RegisterNetEvent('0r-hud:Client:cinematiccamstart1', function()
    client.SendReactMessage('ui:toggleCinematicMode')
end)
-- Toggle cinematic mode
local function toggleCinematicMode()
    client.SendReactMessage('ui:toggleCinematicMode')
end

-- Reset hud positions
local function resetHudPositions()
    client.SendReactMessage('ui:resetHudPositions')
end

--Register script commands
local function registerCommands()
    if Config.ToggleSettingsMenu.active then
        RegisterCommand(Config.ToggleSettingsMenu.command, openHudSettings, false)
        if Config.ToggleSettingsMenu.key then
            lib.addKeybind({
                name = 'hud-settings',
                description = locale('open_hud_settings'),
                defaultKey = Config.ToggleSettingsMenu.key,
                onPressed = function()
                    if IsNuiFocused() then return end
                    openHudSettings()
                end
            })
        end
    end
    if Config.ToggleSeatBelt.active then
        lib.addKeybind({
            name = 'hud_toggle_seatbelt',
            description = locale('toggle_seatbelt'),
            defaultKey = Config.ToggleSeatBelt.key,
            onPressed = function()
                Seatbelt.ToggleSeatBelt()
            end
        })
    end
    if Config.ToggleVehicleEngine.active then
        lib.addKeybind({
            name = 'hud_toggle_engine',
            description = locale('toggle_engine'),
            defaultKey = Config.ToggleVehicleEngine.key,
            onPressed = function()
                CarControl.ToggleEngine()
            end
        })
    end
    if Config.ToggleCinematicMode.active then
        RegisterCommand(Config.ToggleCinematicMode.command, toggleCinematicMode, false)
        if Config.ToggleCinematicMode.key then
            lib.addKeybind({
                name = 'hud_toggle_cinematicmode',
                description = locale('toggle_cinematicmode'),
                defaultKey = Config.ToggleCinematicMode.key,
                onPressed = function()
                    toggleCinematicMode()
                end
            })
        end
    end
    if Config.ResetHudPositions.active then
        RegisterCommand(Config.ResetHudPositions.command, resetHudPositions, false)
    end
    registerCommands = nil
end

function client.onPlayerLoad(isLoggedIn)
    client.load = isLoggedIn
    if isLoggedIn then
        if registerCommands then registerCommands() end
        if client.LoadFirstPlayerData then
            client.LoadFirstPlayerData()
        end
        TriggerServerEvent(_e('server:getTotalPlayerCount'))
    else
        DisplayRadar(false)
        Hud.SetVisible(false)
    end
    while not client.uiLoad do
        Wait(100)
    end
    if isLoggedIn then
        Hud.SetVisible(true)
        Wait(1000)
        Hud.FixMiniMap()
    end
end

--- Starts the client resource.
function client.StartResource()
    DisplayRadar(false)
    if client.IsPlayerLoaded() then
        client.onPlayerLoad(true)
    end
end

RegisterNUICallback('nui:loadUI', function(_, resultCallback)
    resultCallback(true)
    client.SetupUI()
end)

RegisterNUICallback('nui:onLoadUI', function(_, resultCallback)
    resultCallback(true)
    client.uiLoad = true
    lib.print.info('ok: client.SetupUI')
end)

RegisterNUICallback('nui:hideFrame', function(_, resultCallback)
    SetNuiFocus(false, false)
    client.SendReactMessage('ui:setSettingsOpen', false)
    resultCallback(true)
end)

RegisterNUICallback('nui:playNewMusic', function(url, resultCallback)
    --local result = Music.PlayUrl(url)
    --resultCallback(result)
    resultCallback(false)
end)

RegisterNUICallback('nui:toggleCurrentMusic', function(_, resultCallback)
    -- local music = 'hud-music'
    -- if Music.isExist(music) then
    --     local state = false
    --     if Music.isPaused(music) then
    --         state = Music.Resume(music)
    --     else
    --         state = Music.Pause(music)
    --     end
    --     return resultCallback(state)
    -- end
    resultCallback(false)
end)

RegisterNUICallback('nui:updateMiniMapStyle', function(style, resultCallback)
    Hud.data.mini_map.style = style
    resultCallback(true)
end)

RegisterNUICallback('nui:onResStyleUpdate', function(state, resultCallback)
    resultCallback(true)
    Hud.data.is_res_style_active = state
end)

RegisterNUICallback('nui:onBarStyleUpdate', function(state, resultCallback)
    resultCallback(true)
    Hud.data.bar_style = state
end)

RegisterNUICallback('nui:onMiniMapOnlyInVehicle', function(state, resultCallback)
    resultCallback(true)
    Hud.data.mini_map.onlyInVehicle = state
    Hud.CheckRadarDisplay()
end)

RegisterNUICallback('nui:onCompassOnlyInVehicle', function(state, resultCallback)
    resultCallback(true)
    Hud.data.compass.onlyInVehicle = state
end)

RegisterNUICallback('nui:setVehicleDoor', function(doorIndex, resultCallback)
    local result = CarControl.ToggleDoorState(doorIndex)
    resultCallback(result)
end)

RegisterNUICallback('nui:setVehicleLights', function(state, resultCallback)
    local result = CarControl.SetVehicleLights(state)
    resultCallback(result)
end)

RegisterNUICallback('nui:setPedIntoVehicle', function(seatIndex, resultCallback)
    local result = CarControl.SitAtSeat(seatIndex)
    resultCallback(result)
end)

RegisterNUICallback('nui:setVehicleGearType', function(state, resultCallback)
    local result = CarControl.SetManualMode(state)
    if result then
        Hud.data.vehicle_info.gearType = state
    end
    resultCallback(result)
end)

RegisterNUICallback('ui:onChangeCinematicMode', function(show, resultCallback)
    resultCallback(true)
    Hud.data.cinematic.show = show
    if show then
        DisplayRadar(false)
    else
        Hud.CheckRadarDisplay()
    end
end)

RegisterNUICallback('ui:OpenEditMiniMap', function(_, resultCallback)
    resultCallback(true)
    if shared.IsResourceStart('edit_mini_map') then
        SetNuiFocus(false, false)
        client.SendReactMessage('ui:setSettingsOpen', false)
        CreateThread(function()
            local data = exports['edit_mini_map']:usePlacer(Hud.data.mini_map.style == 'circle' and 1 or 0)
            client.SendReactMessage('ui:onMapPlacerEnd', data)
            client.SendReactMessage('ui:setSettingsOpen', true)
            SetNuiFocus(true, true)
        end)
    end
end)

RegisterNUICallback('nui:onChangeMiniMapPlacer', function(data, resultCallback)
    resultCallback(true)
    Hud.data.mini_map.map_placer = data
end)

RegisterNUICallback('nui:fixMiniMap', function(data, resultCallback)
    resultCallback(true)
    Hud.FixMiniMap()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == shared.resource then
        Wait(2000)
        client.StartResource()
    end
end)

-- Exports

-- Sets the visibility of the HUD UI element
---@param state boolean visible (true) or hidden (false)
exports('ToggleVisible', Hud.SetVisible)
