---@diagnostic disable: missing-parameter
local require = lib.require
local old_print = print
local print = lib.print.info
local config = require '@sw_multichar.shared.config'

local cos = math.cos
local sin = math.sin
local rad = math.rad

local preview_slots = {}
local preview_cam
local allow_max = 4
local in_selector = true
local in_creator = true
local current_index = 1
local is_cam_moving = false
local current_chars = {}
local lock_input = false

local screen_text = {
    text = '',
    color = { 255, 255, 255, 255 },
    scale = 0.6,
    thStarted = false
}

local cButtons <const> = {
    ['LEFT'] = 174,
    ['RIGHT'] = 175,
    ['SELECT'] = 191,
    ['DELETE'] = 178
}

local function clear_all()
    in_selector = false
    for i = 1, #preview_slots do
        if DoesEntityExist(preview_slots[i]) then
            SetEntityAsMissionEntity(preview_slots[i], true, true)
            DeleteEntity(preview_slots[i])
        end
    end
    current_chars = {}
    preview_slots = {}
    if DoesCamExist(preview_cam) then
        RenderScriptCams(false, true, 0, true, false)
        DestroyCam(preview_cam)
        preview_cam = nil
    end

    NetworkEndTutorialSession()
end

local function is_new_char_input_valid(firstname, lastname, sex, birthdate)
    local v1 = firstname and firstname:len() >= 4 and firstname:len() <= 16
    if not v1 then
        return false, locale('validations.v1')
    end
    local v2 = lastname and lastname:len() >= 4 and lastname:len() <= 16
    if not v2 then
        return false, locale('validations.v2')
    end
    local v3 = sex and sex:len() == 1 and (sex == 'M' or sex == 'F')
    if not v3 then
        return false, locale('validations.v3')
    end
    local v4 = birthdate > 0
    if not v4 then
        return false, locale('validations.v4')
    end
    return true
end

local function Draw2DText(text, x, y, scale, r, g, b, a)
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 255
    scale = scale or 0.5
    x = x or 0.5
    y = y or 0.5
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextDropshadow(2, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetTextCentre(true)
    DrawText(x, y)
end

local function show_not_deleted_char_message(char_name)
    lib.notify({
        title = locale('delete_char_title'),
        description = locale('delete_char_error', char_name),
        type = 'error',
        position = 'top',
        duration = 10000,
        style = {
            zoom = '1.8'
        }
    })
end

local function start_deleted_animation(ped)
    -- local ped = preview_slots[current_index]
    local slot_info = config.CharacterSpawnPreview[current_index]
    if not slot_info then return end
    ClearPedTasksImmediately(ped)
    Wait(1000)
    if slot_info?.deleted_at?.scenary then
        TaskStartScenarioInPlace(ped, slot_info.deleted_at.scenary, 0, true)
    elseif slot_info?.deleted_at?.animation then
        lib.requestAnimDict(slot_info.deleted_at.animation.dict, 10000)
        TaskPlayAnim(ped, slot_info.deleted_at.animation.dict, slot_info.deleted_at.animation.name, 8.0, -8.0, -1, 0, 0,
            false, false, false)
        RemoveAnimDict(slot_info.deleted_at.animation.dict)
    end

    if slot_info?.deleted_at?.effect then
        lib.requestNamedPtfxAsset(slot_info.deleted_at.effect.asset)
        UseParticleFxAsset(slot_info.deleted_at.effect.asset)
        StartParticleFxLoopedAtCoord(slot_info.deleted_at.effect.name, ped.x, ped.y, ped.z, 0.0, 0.0, 0.0, 1.0, false,
            false, false, false)
    end
end

local function table_array_filter(t, fn)
    local new_t = {}
    for k, n in next, t do
        if fn(t, k, n) then
            new_t[#new_t + 1] = n
        end
    end
    return new_t
end

local function create_screen_text_ui(initial_text, x, y, scale)
    screen_text.text = initial_text
    screen_text.scale = scale or 0.6
    screen_text.x = x or 0.5
    screen_text.y = y or 0.5
    if not screen_text.thStarted and in_selector then
        screen_text.thStarted = true
        CreateThread(function()
            while screen_text.thStarted and in_selector do
                Wait(0)
                if screen_text.text ~= '' then
                    Draw2DText(screen_text.text, screen_text.x, screen_text.y, screen_text.scale, screen_text.color[1],
                        screen_text.color[2], screen_text.color[3], screen_text.color[4])
                end
            end
        end)
    end
end

local function create_preview_cam(x, y, z, rx, ry, rz, fov)
    preview_cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, rx, ry, rz, fov, true, 2)
    RenderScriptCams(true, true, 0, true, true)
end

local function do_login(char_id, cb)
    if not cb then return false end
    lib.callback('sw_multichar:server:login', false, cb, char_id)
end


local function prepare_preview_char(slot, character)
    local slot_data = config.CharacterSpawnPreview[slot]
    local model = `mp_m_freemode_01`
    local preview_ped
    if not character then
        lib.requestModel(model, 10000)
        preview_ped = CreatePed(23, model, slot_data.spawn.x, slot_data.spawn.y, slot_data.spawn.z, slot_data.spawn.w,
            false, false)
        SetPedHeadBlendData(preview_ped, 0, 0, 0, 1, 0, 0, 0, 0, 0, false)
        SetPedDefaultComponentVariation(preview_ped)
    else
        create_screen_text_ui(locale('loading_char', character.fullName), 0.5, 0.5, 1.0)
        local _nmodel = lib.requestModel(character?.skin?.model or model, 10000)
        preview_ped = CreatePed(23, _nmodel, slot_data.spawn.x, slot_data.spawn.y, slot_data.spawn.z, slot_data.spawn.w,
            false, false)
        exports.sw_appearance:setPedAppearance(preview_ped, character.skin)
    end

    if slot_data.scenary then
        TaskStartScenarioInPlace(preview_ped, slot_data.scenary, 0, true)
    elseif slot_data.idle_anim then
        lib.requestAnimDict(slot_data.idle_anim[1])
        TaskPlayAnim(preview_ped, slot_data.idle_anim[1], slot_data.idle_anim[2], 8.0, 0.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(slot_data.idle_anim[1])
    end

    if slot_data.prop and not slot_data.scenary then
        lib.requestModel(slot_data.prop.model, 10000)
        local prop = CreateObject(slot_data.prop.model, slot_data.spawn.x, slot_data.spawn.y, slot_data.spawn.z, true,
            true, false)
        AttachEntityToEntity(prop, preview_ped, GetPedBoneIndex(preview_ped, slot_data.prop.boneId),
            slot_data.prop.distance_offset.x, slot_data.prop.distance_offset.y, slot_data.prop.distance_offset.z,
            slot_data.prop.rot_offset.x, slot_data.prop.rot_offset.y, slot_data.prop.rot_offset.z, true, true, false,
            true, 1, true)
    end

    if character?.deleted_at then
        start_deleted_animation(preview_ped)
        character.fullName = locale('deleted_char')
    end

    preview_slots[slot] = preview_ped
end

local function CalculateDirectionOffset(heading, distance)
    local x = sin(rad(heading)) * distance
    local y = cos(rad(heading)) * distance
    return vec3(x, y, 0.0)
end

local function update_selecion_cam()
    local ped = preview_slots[current_index]
    local aux_cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
    local h = GetEntityHeading(ped)
    local of = CalculateDirectionOffset(h, 2.0)
    local pos = GetEntityCoords(ped)
    SetCamCoord(aux_cam, pos.x - of.x, pos.y + of.y, pos.z + of.z)
    SetCamRot(aux_cam, 0.0, 0.0, h + 180.0, 2)
    SetCamActiveWithInterp(aux_cam, preview_cam, 1000, 0, 1)
    is_cam_moving = true
    Wait(1100)
    SetCamActive(preview_cam, false)
    DestroyCam(preview_cam, true)
    preview_cam = aux_cam
    is_cam_moving = false
end

local function do_edit_char(char_id, sex)
    SetEntityVisible(cache.ped, true, true)
    SetEntityCoords(cache.ped, config.StartPoint.x, config.StartPoint.y, config.StartPoint.z, false, false, false)
    SetEntityHeading(cache.ped, config.StartPoint.w or 0.0)
    local model = sex == 'M' and `mp_m_freemode_01` or `mp_f_freemode_01`
    if GetEntityModel(cache.ped) ~= model then
        lib.requestModel(model, 10000)
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        cache.ped = PlayerPedId()
        Wait(1000)
        SetPedHeadBlendData(cache.ped, 0, 0, 0, 1, 0, 0, 0, 0, 0, false)
        SetPedDefaultComponentVariation(cache.ped)
    end
    Wait(0)
    DoScreenFadeIn(0)
    exports.sw_appearance:startPlayerCustomization(function(data)
        in_creator = false
        TriggerServerEvent('sw:player:update_player_skin', char_id, data)
        if config.EnableIntro then
            TriggerEvent('sw_multichar:client:intro')
        else
            TriggerEvent('sw_multichar:client:spawn_menu', true)
        end
    end, {
        ped = false,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        allowExit = false,
        tattoos = true
    })
end

local function show_new_char_screen()
    in_selector = false
    DoScreenFadeOut(250)
    Wait(2000)
    local edit_pos = config.StartPoint
    SetEntityCoordsNoOffset(cache.ped, edit_pos.x, edit_pos.y, edit_pos.z, false, false, false)
    SetEntityHeading(cache.ped, edit_pos.w or 0.0)
    local is_creating = true

    while is_creating do
        Wait(0)
        local input = lib.inputDialog(locale('menu.new_char'), {
            { type = 'input', label = locale('form.input1.label'),      description = locale('form.input1.description'),      required = true, min = 4, max = 16 },
            { type = 'input', label = locale('form.input2.label'), description = locale('form.input2.description'), required = true, min = 4, max = 16 },
            {
                type = 'select',
                label = locale('form.input3.label'),
                description = locale('form.input3.description'),
                required = true,
                default = 'M',
                options = {
                    {
                        label = locale('form.input3.options.M'),                        
                        value = 'M'
                    },
                    {
                        label = locale('form.input3.options.F'),
                        value = 'F'
                    }
                }
            },
            {
                type = 'date',
                label = locale('form.input4.label'),
                icon = { 'far', 'calendar' },
                required = true,
                format = locale('form.input4.format')
            }
        }, {
            allowCancel = true
        })

        if not input then
            lib.notify({
                title = locale('menu.new_char'),
                description = locale('field_error'),
                type = 'error',
                position = 'top',
                style = {
                    zoom = '1.5'
                }
            })
        else
            local firstname = input[1]
            local lastname = input[2]
            local sex = input[3]
            local birthdate = input[4]

            local isValid, message = is_new_char_input_valid(firstname, lastname, sex, birthdate)
            if not isValid then
                lib.notify({
                    title = locale('menu.new_char'),
                    description = message,
                    type = 'error',
                    position = 'top',
                    style = {
                        zoom = '1.5'
                    }
                })
            else
                local char_created, message, id = lib.callback.await('sw_multichar:server:createNewCharacter', false,
                    firstname, lastname, sex, birthdate)
                if not char_created then
                    lib.notify({
                        title = locale('menu.new_char'),
                        description = message,
                        type = 'error',
                        position = 'top',
                        style = {
                            zoom = '1.5'
                        }
                    })
                else
                    is_creating = false
                    DoScreenFadeOut(0)
                    do_login(id, function(result)
                        if not result then return end
                        clear_all()
                        do_edit_char(id, sex)
                    end)
                end
            end
        end
    end
end

local function can_delete_current_char()
    if #table_array_filter(current_chars, function(_, _, n)
            return not n.deleted_at
        end) == 1 then
        return false
    end
    return true
end

local _start_selection_controls_started = false
local function start_selection_controls()
    if not _start_selection_controls_started then
        _start_selection_controls_started = true
        CreateThread(function()
            while in_selector do
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(2)
                if is_cam_moving or lock_input then goto continue end
                if IsDisabledControlJustPressed(0, cButtons['RIGHT']) then
                    if current_index + 1 > #config.CharacterSpawnPreview then
                        current_index = 1
                    else
                        current_index = current_index + 1
                    end
                    update_selecion_cam()
                    local message = current_chars[current_index]?.fullName or locale('new_char')
                    create_screen_text_ui('~h~' .. message .. '~h~', 0.5, 0.90, 1.2)
                elseif IsDisabledControlJustPressed(0, cButtons['LEFT']) then
                    if current_index - 1 < 1 then
                        current_index = #config.CharacterSpawnPreview
                    else
                        current_index = current_index - 1
                    end
                    update_selecion_cam()
                    local message = current_chars[current_index]?.fullName or locale('new_char')
                    create_screen_text_ui('~h~' .. message .. '~h~', 0.5, 0.90, 1.2)
                elseif IsDisabledControlJustPressed(0, cButtons['SELECT']) then
                    if not current_chars[current_index] then
                        if allow_max > 1 and #current_chars < config.MaxPlayerCharacters then
                            show_new_char_screen()
                        end
                    elseif current_chars[current_index]?.deleted_at then
                        lib.notify({
                            header =  locale('menu.header'),
                            description = locale('content_not_allow_to_delete'),
                            type = 'error',
                            position = 'top',
                            duration = 8000,
                            style = {
                                zoom = '1.5'
                            }
                        })
                    else
                        local input_dialog = lib.alertDialog({
                            header =  locale('menu.header'),
                            content = locale('menu.content'),
                            centered = true,
                            cancel = true
                        })
                        if input_dialog ~= 'confirm' then goto continue end
                        do_login(current_chars[current_index].char_id,
                            function(result, is_first_login, position)                                
                                if not result then return end
                                if not position or not position?.x then position = nil end
                                in_creator = false
                                SetEntityVisible(PlayerPedId(), true, true)
                                FreezeEntityPosition(PlayerPedId(), false)
                                local skin = current_chars[current_index].skin
                                if not skin then return end
                                exports.sw_appearance:setPlayerAppearance(skin)
                                TriggerEvent('sw_multichar:client:spawn_menu', is_first_login, position)                               
                                clear_all()
                            end)
                    end
                elseif IsDisabledControlJustPressed(0, cButtons['DELETE']) then
                    if current_chars[current_index] and not current_chars[current_index]?.deleted_at then
                        if can_delete_current_char() then
                            lock_input = true
                            lib.callback('sw_multichar:server:try_delete_char', false,
                                function(result)
                                    if result then
                                        start_deleted_animation(preview_slots[current_index])
                                        current_chars[current_index].deleted_at = true
                                        current_chars[current_index].fullName = locale('deleted_char')
                                        create_screen_text_ui('~h~' .. current_chars[current_index]?.fullName .. '~h~',
                                            0.5, 0.90, 1.2)
                                    else
                                        show_not_deleted_char_message(current_chars[current_index]?.fullName)
                                    end
                                    lock_input = false
                                end, current_chars[current_index].char_id)
                        else
                            show_not_deleted_char_message(current_chars[current_index]?.fullName)
                        end
                    end
                end
                ::continue::
                Wait(0)
            end
        end)
    end
end

local function button_caption(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local _start_control_help_started = false
local function start_control_help()
    if not _start_control_help_started then
        _start_control_help_started = true
        local k1 = locale('menu.select')
        local k2 = locale('menu.next')
        local k3 = locale('menu.prev')
        local k4 = locale('menu.delete')
        CreateThread(function()
            local ButtonsHandle = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')
            while not HasScaleformMovieLoaded(ButtonsHandle) do Wait(0) end

            PushScaleformMovieFunction(ButtonsHandle, "CLEAR_ALL")
            PopScaleformMovieFunctionVoid()

            PushScaleformMovieFunction(ButtonsHandle, "SET_CLEAR_SPACE")
            PushScaleformMovieFunctionParameterInt(200)
            PopScaleformMovieFunctionVoid()

            PushScaleformMovieFunction(ButtonsHandle, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(0)
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, 175, true))
            button_caption(k2)
            PopScaleformMovieFunctionVoid()

            PushScaleformMovieFunction(ButtonsHandle, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(1)
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, 174, true))
            button_caption(k3)
            PopScaleformMovieFunctionVoid()

            PushScaleformMovieFunction(ButtonsHandle, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(2)
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, 178, true))
            button_caption(k4)
            PopScaleformMovieFunctionVoid()

            PushScaleformMovieFunction(ButtonsHandle, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(3)
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, 191, true))
            button_caption(k1)
            PopScaleformMovieFunctionVoid()


            -- End the function
            EndScaleformMovieMethod()
            -- Sets buttons ready to be drawn
            CallScaleformMovieMethod(ButtonsHandle, 'DRAW_INSTRUCTIONAL_BUTTONS')

            while in_selector do
                Wait(0)
                DrawScaleformMovieFullscreen(ButtonsHandle, 255, 255, 255, 255, 0)
            end
            SetScaleformMovieAsNoLongerNeeded(ButtonsHandle)
        end)
    end
end

local function request_chars()
    lib.callback('sw_multichar:server:getCharacters', false, function(chars, max)
        allow_max = max
        current_chars = chars
        create_screen_text_ui(locale('loading_chars'), 0.5, 0.5, 1.0)
        Wait(1000)
        if #chars == 0 then
            create_screen_text_ui('')
            show_new_char_screen()
        else
            for i = 1, #config.CharacterSpawnPreview or {} do
                prepare_preview_char(i, chars[i])
                if chars[i] then
                    Wait(1000)
                end
            end
            Wait(2000)
            update_selecion_cam()
            start_selection_controls()
            start_control_help()
            create_screen_text_ui('~h~' .. current_chars[current_index]?.fullName .. '~h~', 0.5, 0.9, 1.0)
        end
    end)
end

-- exports.spawnmanager:setAutoSpawn(false)

local function SetTimeAndWeather()    
    CreateThread(function()
        --exports.sw_weather_sync:SetEnable(false)
        while in_creator do
            Wait(1000)
            SetWeatherTypePersist('EXTRASUNNY')
            SetWeatherTypeNowPersist('EXTRASUNNY')
            SetWeatherTypeNow('EXTRASUNNY')
            SetOverrideWeather('EXTRASUNNY')
            SetWeatherOwnedByNetwork(false)
            NetworkOverrideClockTime(12, 0, 0)
            SetCanAttackFriendly(PlayerPedId(), false, false)
        end
        SetCanAttackFriendly(PlayerPedId(), true, true)
    end)
end

local function run_script()
    create_preview_cam(config.StartPoint.x, config.StartPoint.y, config.StartPoint.z + 150.0, -90.01, 0.0, 0.0, 70.0)
    ShutdownLoadingScreen()
    NetworkStartSoloTutorialSession()
    while not NetworkIsInTutorialSession() do Wait(0) end
    ShutdownLoadingScreenNui()
    Wait(500)
    local playerPed = PlayerPedId()
    SetPedDefaultComponentVariation(playerPed)
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)
    SetEntityInvincible(playerPed, true)
    Wait(1000)
    create_screen_text_ui(locale('find_account_info'), 0.5, 0.5, 1.0)
    Wait(500)
    request_chars()
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(0) end
    LocalPlayer.state:set('isLoggedIn', false, true)
    LocalPlayer.state:set('ready', false, true)
    Wait(1000)
    exports.spawnmanager:unlockSpawn()
    exports.spawnmanager:spawnPlayer({
        model = `mp_m_freemode_01`,
        x = config.StartPoint.x,
        y = config.StartPoint.y,
        z = config.StartPoint.z,
        heading = 0.0,
        skipFade = false,
    }, function()
        lib.closeAlertDialog()
        lib.closeInputDialog()
        --exports.sw_timesync:StopSync( true )
        ClearAreaOfPeds(config.StartPoint.x, config.StartPoint.y, config.StartPoint.z, 100.0, 0)
        ClearAreaOfVehicles(config.StartPoint.x, config.StartPoint.y, config.StartPoint.z, 100.0, 0)
        ClearAreaOfCops(config.StartPoint.x, config.StartPoint.y, config.StartPoint.z, 100.0, 0)        
        ClearPlayerWantedLevel(PlayerId())
        SetTimeAndWeather()
        Wait(1000)
        run_script()
    end)
end)
