if GetConvarInt('sw:ac', 0) == 0 then return end

--perfomance 
local print = lib.print.info
local CreateThread = CreateThread
local Wait = Wait
local GetGameTimer = GetGameTimer
local GetEntityCoords = GetEntityCoords
local GetEntityHeading = GetEntityHeading
local GetEntityHealth = GetEntityHealth
local GetEntityModel = GetEntityModel
local resource = cache.resource

print('SW:AC Loaded')

local ac_config = {    
    check_infinite_ammo = GetConvarInt('sw:ac_infinite_ammo', 1) == 1,
    check_infinite_health = GetConvarInt('sw:ac_infinite_health', 1) == 1,
    check_infinite_stamina = GetConvarInt('sw:ac_infinite_stamina', 1) == 1,
    check_infinite_oxygen = GetConvarInt('sw:ac_infinite_oxygen', 1) == 1,
    check_infinite_armor = GetConvarInt('sw:ac_infinite_armor', 1) == 1,
    check_aim_assist = GetConvarInt('sw:ac_aim_assist', 1) == 1,
    check_god_mode =  GetConvarInt('sw:ac_god_mode', 1) == 1,
    check_no_clip = GetConvarInt('sw:ac_no_clip', 1) == 1,
    check_invisible = GetConvarInt('sw:ac_invisible', 1) == 1,
    check_free_cam = GetConvarInt('sw:ac_free_cam', 1) == 1,
    check_no_ragdoll = GetConvarInt('sw:ac_no_ragdoll', 1) == 1,
    check_night_vision = GetConvarInt('sw:ac_night_vision', 1) == 1,
    check_thermal_vision = GetConvarInt('sw:ac_thermal_vision', 1) == 1,
    check_super_jump = GetConvarInt('sw:ac_super_jump', 1) == 1,    
}

local resource_list = {}
local resource_count = 0

AddEventHandler('onResourceStart', function(res)
   if res == resource then return end
   resource_list[res] = true
   resource_count = resource_count + 1
end)
