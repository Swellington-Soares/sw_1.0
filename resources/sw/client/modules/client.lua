local module = {}

local PlayerCount = 0

local function set_relationships()
    local relation_mode = GetConvarInt('sw:client:hate_mode', 1) == 1 and 5 or 1
    SetRelationshipBetweenGroups(relation_mode, `AMBIENT_GANG_HILLBILLY`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `AMBIENT_GANG_BALLAS`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `AMBIENT_GANG_MEXICAN`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `AMBIENT_GANG_FAMILY`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `AMBIENT_GANG_MARABUNTE`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `AMBIENT_GANG_SALVA`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `AMBIENT_GANG_LOST`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `GANG_1`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `GANG_2`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `GANG_9`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `GANG_10`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `FIREMAN`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `MEDIC`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `COP`, `PLAYER`)
    SetRelationshipBetweenGroups(relation_mode, `PRISONER`, `PLAYER`)
end

local function set_dispatch_and_pause_title()
    local city_name = GetConvar('sw:city_name', '')
    if city_name ~= '' then
        AddTextEntry('FE_THDR_GTAO', city_name)
    end


    for i = 1, 15 do
        EnableDispatchService(i, false)
    end

    local stealthKills <const> = {
        `ACT_stealth_kill_a`,
        `ACT_stealth_kill_weapon`,
        `ACT_stealth_kill_b`,
        `ACT_stealth_kill_c`,
        `ACT_stealth_kill_d`,
        `ACT_stealth_kill_a_gardene`
    }

    for _, killName in next, stealthKills do
        RemoveStealthKill(killName, false)
    end

    if GetConvarInt('sw:client:disable_auto_swap_weapon', 1) == 1 then
        SetWeaponsNoAutoswap(true)
    end

    if GetConvarInt('sw:client:disable_auto_reload', 1) == 1 then
        SetWeaponsNoAutoreload(true)
    end

    if GetConvarInt('sw:client:disable_idle_cam', 1) == 1 then
        CreateThread(function()
            while true do
                InvalidateIdleCam()
                InvalidateVehicleIdleCam()
                Wait(20000)
            end
        end)
    end
end

local function remove_vehicle_weapons()
    lib.onCache('vehicle', function(value)
        if not value then return end
        DisablePlayerVehicleRewards(cache.playerId)
        SetVehicleWeaponCapacity(value, 0, 0)
        SetVehicleWeaponCapacity(value, 1, 0)
        SetVehicleWeaponCapacity(value, 2, 0)
        SetVehicleWeaponCapacity(value, 3, 0)
        Wait(0)
    end)
    
end

local function enable_rich_presence()
    if GetConvarInt('sw:client:enable_rich_presence', 0) == 1 then  
        local app_id = GetConvar('sw:client:discord_app_id', '')
        if app_id == '' then return end
        local icon_large = GetConvar('sw:client:discord_icon_large', '')
        local icon_large_hover_text = GetConvar('sw:client:discord_icon_large_hover_text', '')
        local icon_small = GetConvar('sw:client:discord_icon_small', '')
        local icon_small_hover_text = GetConvar('sw:client:discord_icon_small_hover_text', '')
        local show_player_count = GetConvarInt('sw:client:discord_show_player_count', 1) == 1
        local update_rate = GetConvarInt('sw:client:discord_update_rate', 30000)    
        local buttons = GetConvar('sw:client:discord_buttons', '') 
        local buttons_table = buttons == '' and {} or json.decode(buttons)
        local city_name = GetConvar('sw:city_name', '')
        SetDiscordAppId(app_id)
        SetDiscordRichPresenceAsset(icon_large)
        SetDiscordRichPresenceAssetText(icon_large_hover_text)
        SetDiscordRichPresenceAssetSmall(icon_small)
        SetDiscordRichPresenceAssetSmallText(icon_small_hover_text)

        local max_players = GetConvarInt('sv_maxclients', 48)

        for k, v in ipairs(buttons_table) do
            SetDiscordRichPresenceAction(k - 1, v.text, v.url)
        end


        CreateThread(function()
            while true do
                if show_player_count then
                    SetRichPresence(locale('players') .. ': ' .. PlayerCount .. '/' .. max_players)
                else
                    SetRichPresence('Jogando ' .. city_name == '' and 'FiveM' or city_name)
                end
                Wait(update_rate)
            end
        end) 
        

    end
end

local function init()
    set_relationships()
    set_dispatch_and_pause_title()
    remove_vehicle_weapons()
    enable_rich_presence()
end

--event
RegisterNetEvent('Player:Count', function(count)
    PlayerCount = count or 0
end)

--map
local blips = {}

function module.AddBlip(x, y, z, sprite, color, scale, name, shortRange)
    if not x or not y or not z then return end
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite or 0)
    SetBlipScale(blip, scale or 1.0)
    SetBlipColour(blip, color or 0)
    SetBlipAsShortRange(blip, shortRange or false)
    if name then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringBlipName(name)
        EndTextCommandSetBlipName(blip)
    end

    local id = 'BLIP_' .. #blip+1

    blips[id] = blip

    return id
end

function module.RemoveBlip(id)
    if not id or not blips[id] then return end
    RemoveBlip(blips[id])
    blips[id] = nil
end

function module.GetBlip(id)
    return blips[id]
end

function module.SetBlipRoute(id)
    if not id or not blips[id] then return end
    SetBlipRoute(blips[id], true)
end

function module.SetMapGpsPoint(x, y)
    if not x or not y then return end
    SetNewWaypoint(x, y)
end


AddEventHandler('onResourceStop', function (resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, blip in next, blips do
        RemoveBlip(blip)
    end
end)

local function __init__()
    init()
    local _module = { name = 'Client' }
    return setmetatable(_module, { __index = module })
end

return __init__
