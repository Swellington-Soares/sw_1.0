--[[
Used as initial data.
Please do not change here. All settings are in the shared/config.lua file.
--]]

return {
    bar_style = 'grt-premium',
    is_res_style_active = true,
    vehicle_hud_style = 1,
    mini_map = { onlyInVehicle = false, style = 'rectangle', map_placer = {} },
    compass = { active = true, show = false, onlyInVehicle = false, heading = nil, street = nil, street2 = nil },
    cinematic = { active = true, show = false, },
    vehicle_info = { kmH = true, fuel = {} },
    client_info = {
        active = true,
        radio = { active = true, show = false, inChannel = nil, channel = nil },
        player_source = { active = true, show = false, source = nil },
        time = { active = true, show = false, gameHours = nil, gameMinutes = nil },
        real_time = { active = true },
        server_info = { active = true, show = false, image = nil, name = nil, playerCount = 0, maxPlayers = 0 },
        cash = { active = true, show = false, amount = nil },
        bank = { active = true, show = false, amount = nil },
        extra_currency = { active = true, show = false, amount = nil },
        job = { active = true, show = false, label = nil, gradeLabel = nil },
        weapon = { active = true, show = false, name = nil, ammo = { inClip = 0, inWeapon = 0 } },
    },
    navigation_widget = {
        active = true,
        show = true,
        navigation = {
            isDestinationActive = false,
            destinationStreet = nil,
            currentStreet = nil
        },
    },
    bars = {
        hunger = { show = false, value = 0 },
        health = { show = false, value = 0 },
        thirst = { show = false, value = 0 },
        armor = { show = false, value = 0 },
        stamina = { show = false, value = 0 },
        oxygen = { show = false, value = 0 },
        vehicle_engine = { show = false, value = 0 },
        stress = { show = false, value = 0 },
        vehicle_nitro = { show = false, value = 0 },
        voice = { show = false, value = 0 },
    },
    music_info = {
        active = true,
    },
    colors = {},
} --[[@as iHud]]

---@alias BarStyle 'circle'|'square'|'hexagon'|'hexagon-w'|'zarg'|'wave-c'|'wave-h'|'classic' |'universal'|'grt-premium'|'zarg-m'
---@alias MapStyle 'rectangle'|'circle'

---@class iCompass
---@field active boolean
---@field show boolean
---@field onlyInVehicle boolean
---@field heading string | nil
---@field street string | nil
---@field street2 string | nil
---@field editableByPlayers boolean

---@class iCinematic
---@field active boolean
---@field show boolean

---@class iMusicInfo
---@field active boolean
---@field isPlaying boolean
---@field songName string | nil
---@field songLabel string | nil

---@class iVehicleFuel
---@field level number
---@field maxLevel number
---@field type 'gasoline' | 'electric'

---@class iVehicleInfo
---@field kmH boolean
---@field entity number | nil
---@field gearType 'manual' | 'auto'
---@field entity number | nil
---@field kmH boolean
---@field speed number
---@field fuel iVehicleFuel
---@field currentGear number
---@field rpm number
---@field engineHealth number
---@field manualGear number
---@field isSeatbeltOn boolean
---@field veh_class number
---@field isLightOn boolean

---@class iRadio
---@field active boolean
---@field show boolean
---@field inChannel boolean | nil
---@field channel string | nil

---@class iServerId
---@field active boolean
---@field show boolean
---@field source number | nil

---@class iTime
---@field active boolean
---@field show boolean
---@field gameHours number | nil
---@field gameMinutes number | nil

---@class iRealTime
---@field active boolean

---@class iServerInfo
---@field active boolean
---@field show boolean
---@field image string | nil
---@field name string | nil
---@field playerCount number
---@field maxPlayers number

---@class iCash
---@field active boolean
---@field show boolean
---@field amount number | nil

---@class iBank
---@field active boolean
---@field show boolean
---@field amount number | nil

---@class iExtraCurrency
---@field active boolean
---@field show boolean
---@field amount number | nil

---@class iJob
---@field active boolean
---@field show boolean
---@field label string | nil
---@field gradeLabel string | nil

---@class iWeaponAmmo
---@field inClip number
---@field inWeapon number

---@class iWeapon
---@field active boolean
---@field show boolean
---@field name string | nil
---@field ammo iWeaponAmmo

---@class iClientInfo
---@field active boolean
---@field radio iRadio
---@field player_source iServerId
---@field time iTime
---@field real_time iRealTime
---@field server_info iServerInfo
---@field cash iCash
---@field bank iBank
---@field job iJob
---@field weapon iWeapon
---@field extra_currency iExtraCurrency

---@class iNavigation
---@field isDestinationActive boolean
---@field destinationStreet string | nil
---@field currentStreet string | nil

---@class iNavigationWidget
---@field active boolean
---@field show boolean
---@field navigation iNavigation

---@class iBar
---@field show boolean
---@field value number
---@field color string

---@class iBars
---@field hunger iBar
---@field health iBar
---@field thirst iBar
---@field armor iBar
---@field stamina iBar
---@field oxygen iBar
---@field stress iBar
---@field voice iBar
---@field vehicle_engine iBar
---@field vehicle_nitro iBar

---@class iMiniMap
---@field onlyInVehicle boolean
---@field style 'circle' | 'rectangle'
---@field editableByPlayers boolean
---@field map_placer table

---@class iMusic
---@field active boolean

---@class iHud
---@field bar_style BarStyle
---@field is_res_style_active boolean
---@field vehicle_hud_style number
---@field mini_map iMiniMap
---@field compass iCompass
---@field cinematic iCinematic
---@field vehicle_info iVehicleInfo
---@field client_info iClientInfo
---@field music iMusic
---@field navigation_widget iNavigationWidget
---@field bars iBars
---@field colors string[]
