---
--[[ Contains client-side helper functions. ]]
---

local Utils = {}

--- Custom notifications with options.
---@param title string
---@param type 'inform'|'error'|'success'|'warning'
---@param duration number
---@param description string
function Utils.Notify(title, type, duration, description)
    lib.notify({
        title = title,
        description = description,
        duration = duration,
        position = 'center-right',
        type = type,
    })
end

-- Retrieves the fuel level of a vehicle from various possible fuel resources
---@param vehicle number vehicle
---@return integer FuelLevel
function Utils.GetVehicleFuelLevel(vehicle)
    local level = 0
    if GetResourceState('ox_fuel') == 'started' then
        level = Entity(vehicle)?.state?.fuel or 0
    elseif GetResourceState('LegacyFuel') == 'started' then
        level = exports['LegacyFuel']:GetFuel(vehicle)
    elseif GetResourceState('cdn-fuel') == 'started' then
        level = exports['cdn-fuel']:GetFuel(vehicle)
    elseif GetResourceState('ps-fuel') == 'started' then
        level = exports['ps-fuel']:GetFuel(vehicle)
    else
        level = GetVehicleFuelLevel(vehicle)
    end
    return math.floor(level)
end

return Utils
