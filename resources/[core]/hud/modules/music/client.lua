--[[ Perform music functions using xsound ]]

local Music = {}

local isPlay = false
local list = {}
local xSound = exports.xsound

-- Plays a music track from a given URL
---@param url string The URL of the music track
---@return table result
function Music.PlayUrl(url)
    xSound:PlayUrl('hud-music', url, 0.5, true)
    xSound:setVolumeMax('hud-music', 0.5)
    local alreadyExist = false
    for key, value in pairs(list) do
        if value == url then
            alreadyExist = key
            break
        end
    end
    isPlay = true
    local songName = ''
    if alreadyExist then
        songName = 'Music #' .. alreadyExist
    else
        list[#list + 1] = url
        songName = 'Music #' .. #list
    end

    return { name = songName, label = songName }
end

-- Checks if a sound with the given name exists
---@param name string The name of the sound
---@return boolean state
function Music.isExist(name)
    return xSound:soundExists(name)
end

-- Checks if the sound with the given name is paused
---@param name string
---@return boolean state
function Music.isPaused(name)
    return xSound:isPaused(name)
end

-- Pauses the sound with the given name
---@param name string
---@return boolean state
function Music.Pause(name)
    if not xSound:isPaused(name) then
        xSound:Pause(name)
        return true
    end
    return false
end

-- Resumes the sound with the given name
---@param name string
---@return boolean state
function Music.Resume(name)
    if xSound:isPaused(name) then
        xSound:Resume(name)
        return true
    end
    return false
end

return Music
