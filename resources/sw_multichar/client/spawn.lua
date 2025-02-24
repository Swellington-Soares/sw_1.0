local require = lib.require
local print = lib.print.info
local config = require '@sw_multichar.shared.config'
local spawn_cam

local function create_preview_cam(coord)
    
    spawn_cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(spawn_cam, coord.x, coord.y, coord.z + 150.0)
    SetCamRot(spawn_cam, -90.0, 0.0, 0.0, 2)
    RenderScriptCams(true, true, 0, true, true)
end

local function change_cam(coord)
    if DoesCamExist(spawn_cam) then
        SetCamCoord(spawn_cam, coord.x, coord.y, coord.z + 100.0)
        SetCamRot(spawn_cam, -90.0, 0.0, 0.0, 2)
        SetFocusPosAndVel(coord.x, coord.y, coord.z, 0.0, 0.0, 0.0)
    end
end

local function clear_all()
    if DoesCamExist(spawn_cam) then
        RenderScriptCams(false, true, 1000, true, false)
        DestroyCam(spawn_cam, false)
        spawn_cam = nil
    end
end

local function spawn(isFirst, last_location)    
    DoScreenFadeIn(0)
    lib.hideMenu()
    Wait(250)
    local options = {}

    if not isFirst and last_location then
        options[#options + 1] = {
            label = 'Última Localização',
            args = { last_location }
        }
    end


    for i = 1, #config.SpawnPoints or {} do
        options[#options + 1] = {
            label = config.SpawnPoints[i].title,
            args = { config.SpawnPoints[i].pos }
        }
    end

    lib.registerMenu({
        id = 'spawn_menu',
        title = 'Menu de Spawn',
        position = 'top-left',
        options = options,
        onSelected = function(selected, _, args, _)
            local pos = args[1]
            change_cam(pos)                
        end,
        canClose = false,
        disableInput = true,
    }, function(_, _, args)
        SetEntityCoords(PlayerPedId(), args[1].x, args[1].y, args[1].z, true, false, false, false)
        ClearFocus()
        Wait(100)
        local fw = GetEntityForwardVector(cache.ped) * -2.0
        local aux_cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
        SetCamCoord(aux_cam, args[1].x + fw.x, args[1].y + fw.y, args[1].z)
        SetCamActiveWithInterp(aux_cam, spawn_cam, 1000, 0, 1)
        Wait(1100)
        SetCamActive(spawn_cam, false)
        DestroyCam(spawn_cam, true)
        spawn_cam = aux_cam
        Wait(100)
        FreezeEntityPosition(PlayerPedId(), false)
        clear_all()
    end)

    create_preview_cam(options[1].args[1])    
    lib.showMenu('spawn_menu', 1)

end

AddEventHandler('sw_multichar:client:spawn_menu', spawn)
