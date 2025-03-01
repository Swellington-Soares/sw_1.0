local CarControl = {}

local Utils = require 'modules.utils.client'

local isHrsGearsStarted = nil

-- Toggles the state of a vehicle door
---@param doorIndex number
---@return table Response A table indicating success and the new state of the door
function CarControl.ToggleDoorState(doorIndex)
    local vehicle = cache.vehicle
    if vehicle and DoesEntityExist(vehicle) then
        if (GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0) then
            SetVehicleDoorShut(vehicle, doorIndex, false)
            return { success = true, state = false }
        else
            SetVehicleDoorOpen(vehicle, doorIndex, false, false)
            return { success = true, state = true }
        end
    end
    return { success = false }
end

-- Sets the vehicle lights to the specified state
---@param state number
---@return boolean state
function CarControl.SetVehicleLights(state)
    local vehicle = cache.vehicle
    if vehicle and DoesEntityExist(vehicle) then
        local _, x, y = GetVehicleLightsState(vehicle)
        local newState
        if x == 1 or y == 1 then
            newState = 1
        else
            newState = 2
        end
        SetVehicleLights(vehicle, newState)
        return true
    end
    return false
end

-- Makes the player sit in a specific seat of the vehicle
---@param seatIndex number
---@return boolean state
function CarControl.SitAtSeat(seatIndex)
    local vehicle = cache.vehicle
    if vehicle and DoesEntityExist(vehicle) then
        local ped = cache.ped
        if (IsVehicleSeatFree(vehicle, seatIndex)) then
            SetPedIntoVehicle(ped, vehicle, seatIndex)
            return true
        end
    end
    return false
end

-- Sets the manual mode for the 'hrsgears' resource
---@param state boolean
---@return boolean state
function CarControl.SetManualMode(state)
    if not isHrsGearsStarted then
        Utils.Notify(locale('hrs_gears_not_found'), 'error')
        return false
    end
    local manual = state == 'manual'
    TriggerEvent('hrsgears:SetManualMode', manual)
    return true
end

-- Determines the fuel type of a vehicle
---@param vehicle number
---@return string FuelType A string indicating the fuel type ('electric' or 'gasoline')
function CarControl.GetVehicleFuelType(vehicle)
    local model = GetEntityModel(vehicle)
    return Config.ElectricVehicles[model] and 'electric' or 'gasoline'
end

-- Turns the vehicle's engine on|off
---@return boolean state Return current engine state
function CarControl.ToggleEngine()
    local veh = cache.vehicle
    if veh and GetPedInVehicleSeat(veh, -1) == cache.ped then
        local isEngineOn = GetIsVehicleEngineRunning(veh)
        SetVehicleEngineOn(veh, not isEngineOn, not isEngineOn, true)
        return not isEngineOn
    end
    return false
end

-- Initializes the 'hrsgears' resource state check
isHrsGearsStarted = shared.IsResourceStart('hrsgears')

return CarControl
