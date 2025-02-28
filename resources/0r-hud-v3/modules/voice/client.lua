local Voice = {}

local inRadio = false
local channel = nil
local talkRange = 2
local isPmaVoiceStarted = false

---Get player current radio channel
---@return table
function Voice.GetPlayerRadio()
    if isPmaVoiceStarted then
        inRadio = LocalPlayer.state.radioChannel and LocalPlayer.state.radioChannel ~= 0
        channel = LocalPlayer.state.radioChannel
    end
    return { inChannel = inRadio, channel = channel }
end

---Get player current talk range
---@return integer
function Voice.GetTalkRange()
    return talkRange
end

-- SaltyChat integration
RegisterNetEvent('SaltyChat_RadioChannelChanged', function(channel, isPrimary)
    if isPrimary then
        if channel then
            inRadio = true
            channel = channel
        else
            inRadio = false
            channel = nil
        end
    end
end)

RegisterNetEvent('SaltyChat_VoiceRangeChanged', function(range)
    if range < 3.0 then
        talkRange = 1
    elseif range < 5.0 then
        talkRange = 2
    else
        talkRange = 3
    end
end)
-- End

-- Pma-voice integration
RegisterNetEvent('pma-voice:setTalkingMode', function(range)
    talkRange = tonumber(range)
end)
-- End

isPmaVoiceStarted = shared.IsResourceStart('pma-voice')

return Voice
