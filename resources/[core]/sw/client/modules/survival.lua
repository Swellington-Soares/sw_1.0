local module = {}
local imod = {}

local MAX_DEATH_TIME <const> = GetConvarInt('sw:max_death_time', 120)

local in_coma = false
local respawnKey ---@type CKeybind
local comma_left = MAX_DEATH_TIME 

local HOSPITAL_COORD <const> = {
    HOSPITAL_RH = {
        coord = vec3(-447.2036, -342.8395, 34.5020),
        rot = vec3(0.0000, 0.0000, 109.1352),
        animDict = "respawn@hospital@rockford",
        animName = "rockford",
        animCam = "rockford_cam",
    },
    HOSPITAL_SC = {
        coord = vec3(342.7344, -1397.8510, 32.5092),
        rot = vec3(0.0, 0.0, 62.5160),
        animDict = 'respawn@hospital@south_central',
        animName = 'south_central',
        animCam = 'south_central_cam'
    },
    HOSPITAL_DT = {
        coord = vec3(357.3475, -585.6215, 28.8310),
        rot = vec3(0.0000, 0.0000, -95.0926),
        animDict = 'respawn@hospital@downtown',
        animName = 'downtown',
        animCam = 'downtown_cam'
    },
    HOSPITAL_SS = {
        coord = vec3(1837.655, 3673.500, 34.308),
        rot = vec3(0, 0, -146.160),
        animDict = 'respawn@hospital@sandy_shores',
        animName = 'sandy_shores',
        animCam = 'sandy_shores_cam'
    },
    HOSPITAL_PB = {
        coord = vec3(-244.6081, 6324.9629, 32.4260),
        rot = vec3(0, 0, -57.7613),
        animDict = 'respawn@hospital@paleto_bay',
        animName = 'paleto_bay',
        animCam = 'paleto_bay_cam'
    },
}


local function GetNearbyHospital(current_pos)
    local k
    local min = 99999
    for id, info in next, HOSPITAL_COORD do
        local dist = #(current_pos - info.coord)
        if min > dist then
            min = dist
            k = id
        end
    end
    return HOSPITAL_COORD[k]
end


local function CreateHospitalScene()
    TriggerEvent('hud:client:ToggleVisible', false)
    if not IsScreenFadedOut() then DoScreenFadeOut(0) end
    local ped = cache.ped
    local hospital = GetNearbyHospital(GetEntityCoords(ped))
    SetPlayerControl(cache.playerId, false, 0)
    SetEntityCoords(ped, hospital.coord.x, hospital.coord.y, hospital.coord.z, true, false, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    Wait(1000)
    module.RevivePlayer(false)
    local dict = lib.requestAnimDict(hospital.animDict)
    SetEntityHeading(ped, hospital.rot.z)
    TriggerClientEvent('ox_inventory:disarm', cache.playerId, true)
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, false)
    Wait(1000)
    local sceneId = CreateSynchronizedScene(hospital.coord.x + 0.5, hospital.coord.y + 0.5, hospital.coord.z,
        hospital.rot.x, hospital.rot.y, hospital.rot.z, 2)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetSynchronizedSceneLooped(sceneId, false)
    SetSynchronizedSceneHoldLastFrame(sceneId, false)
    SetForceFootstepUpdate(ped, true)
    DoScreenFadeIn(0)
    TaskSynchronizedScene(ped, sceneId, hospital.animDict, hospital.animName, 1000.0, -8.4, 0, 0x447a0000, 0)
    PlaySynchronizedCamAnim(cam, sceneId, hospital.animCam, dict)
    Wait(0)

    while GetSynchronizedScenePhase(sceneId) < 0.99 do
        Wait(0)
        HideHudAndRadarThisFrame()
    end

    DetachSynchronizedScene(sceneId)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    RemoveAnimDict(dict)
    RenderScriptCams(false, false, 500, true, true)
    SetPlayerControl(cache.playerId, true, 0)
    SetEntityInvincible(ped, false)
    TriggerEvent('hud:client:ToggleVisible', true)
    Wait(0)
end

local function func_92(sParam0)
    BeginTextCommandScaleformString('STRING')
    AddTextComponentSubstringPlayerName(sParam0)
    EndTextCommandScaleformString()
end

local function DeathScreen()
    TriggerEvent('hud:client:ToggleVisible', false)
    local p = promise.new()
    CreateThread(function()
        local id = 0
        local timeout = GetGameTimer() + 2000
        local scaleform = 'MP_BIG_MESSAGE_FREEMODE'
        local scaleformHandle
        while true do
            Wait(0)
            if id == 0 then
                id = 1
                scaleformHandle = RequestScaleformMovie(scaleform)
            end

            if id == 1 then
                if GetGameTimer() > timeout or HasScaleformMovieFilenameLoaded(scaleform) then
                    BeginScaleformMovieMethod(scaleformHandle, "SHOW_SHARD_WASTED_MP_MESSAGE")
                    func_92('~r~' .. GetLabelText('RESPAWN_W_MP'))
                    EndScaleformMovieMethod()
                    timeout = GetGameTimer() + 8000
                    AnimpostfxPlay('DeathFailOut', 0, false)
                    PlaySoundFrontend(-1, "Bed", "WastedSounds", true)
                    ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
                    Wait(500)
                    PlaySoundFrontend(-1, "TextHit", "WastedSounds", true)
                    id = 2
                end
            end

            if id == 2 then
                if GetGameTimer() < timeout then
                    DrawScaleformMovieFullscreen(scaleformHandle, 255, 255, 255, 255, 0)
                elseif GetGameTimer() < timeout + 100 then
                    BeginScaleformMovieMethod(scaleformHandle, "TRANSITION_OUT")
                    EndScaleformMovieMethod()
                    timeout = timeout - 100
                elseif GetGameTimer() < timeout + 500 then
                    DrawScaleformMovieFullscreen(scaleformHandle, 255, 255, 255, 255, 0)
                else
                    id = 3
                end
            end

            if id == 3 then
                SetScaleformMovieAsNoLongerNeeded(scaleformHandle)
                StopScreenEffect("DeathFailOut")
                break
            end
        end
        p:resolve()
    end)
    return Citizen.Await(p)
end

--API
function module.RevivePlayer(notify_server)
    local ped = cache.ped
    local pos = GetEntityCoords(ped)
    if not IsEntityDead(ped) then return end
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(ped), 0, false)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    ResetPedMovementClipset(ped, 0.0)
    ResetPedStrafeClipset(ped)
    ResetPedWeaponMovementClipset(ped)
    SetPedCanBeDraggedOut(ped, true)
    SetPedCanBeKnockedOffVehicle(ped, 0)
    SetPedCanSmashGlass(ped, true, true)
    SetPedDiesInSinkingVehicle(ped, true)
    SetPedMaxTimeUnderwater(ped, 1)
    SetPedCanSwitchWeapon(ped, true)
    ResetPedInVehicleContext(ped)
    ClearPedDriveByClipsetOverride(ped)
    SetPedInfiniteAmmoClip(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedIsDrunk(ped, false)
    SetPlayerForcedAim(ped, false)
    if notify_server then
        TriggerServerEvent('sw:server:event', 'revive_player')
    end
end

function module.SetPlayerHealth(health)
    SetEntityHealth(cache.ped, math.floor(math.min(200, math.max(0, health))))
end

local function kill_player(notify_server, data)
    local ped = cache.ped
    local pos = GetEntityCoords(ped)
    lib.hideContext()
    lib.hideRadial()
    SetPlayerControl(cache.playerId, false, 0)
    PauseDeathArrestRestart(true)
    comma_left = MAX_DEATH_TIME
    in_coma = true
    if notify_server then
        TriggerServerEvent('sw:server:event', 'kill_player', pos, data)
    end
    DeathScreen()
    FreezeEntityPosition(cache.ped, true)
    CreateThread(function()
        while in_coma do
            local isTextOpen, currentText = lib.isTextUIOpen()
            if comma_left > 0 then
                lib.showTextUI(locale('comma_left', comma_left), { icon = 'skull', position = 'bottom-center', style = { zoom = '2.0'}})
                comma_left = comma_left - 1
            elseif comma_left < 1 then
                if not isTextOpen or ( isTextOpen and currentText ~= locale('respawn_text')) then
                    lib.hideTextUI()
                    lib.showTextUI(locale('respawn_text'), { icon = 'face-smile', position = 'bottom-center', style = { zoom = '2.0'}})
                end
                if respawnKey?.disabled then
                    respawnKey:disable(false)
                end
            end
            Wait(1000)
        end
        lib.hideContext()        
        lib.hideMenu()        
        lib.hideRadial()
        lib.hideTextUI()
    end)
end


--FIVEM NATIVE EVENT
local function CEventNetworkEntityDamage(data)
    lib.print.info(data)
    local ped = cache.ped
    local vict = data[1]
    local is_fatal = data[6] == 1
    if vict == ped and is_fatal and not in_coma then
        kill_player(true, data)
    end
end

function module.Start()
    if GetConvarInt('sw:enable_self_survival', 1) == 0 then return end

    respawnKey = lib.addKeybind({
        description = 'respawn when comma limit end',
        name = 'respawn',
        defaultKey = 'E',
        defaultMapper = 'KEYBOARD',
        disabled = true,
        onPressed = function(self)
            if not in_coma or comma_left > 0 then return end
            in_coma = false
            comma_left = MAX_DEATH_TIME
            lib.hideTextUI()           
            CreateHospitalScene()
            TriggerServerEvent('sw:server:event', 'revive_player')            
        end
    })


    local events = {
        ['CEventNetworkEntityDamage'] = CEventNetworkEntityDamage
    }
    local ped = cache.ped
    SetPedArmour(ped, 0)
    SetEntityHealth(ped, 200)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    AddEventHandler('gameEventTriggered', function(name, args)
        if not events[name] then return end
        events[name](args)
    end)
end

local function init_rpc()
    imod.client.RegisterRpc('SetEntityHealth', module.SetPlayerHealth)
end


local function __init__(client, player)
    imod.client = client
    imod.player = player
    init_rpc()
    local _module = { name = 'Player', exp_prefix = 'Survival' }
    return setmetatable(_module, {
        __index = module,
        __tostring = function()
            return _module.name
        end
    })
end


return __init__
