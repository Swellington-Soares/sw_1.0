local module = {}
local imod = {}
local logging_queue = {}

local default_log_method = GetConvar('sw:logging_method', 'database')
local enable_queue = GetConvarInt('sw:logging_queue', 1) == 1
local queue_max = GetConvarInt('sw:logging_queue_max', 50)

local function slice_and_remove(tbl, start_idx, end_idx)
    local sliced = {}
    local length = #tbl

    start_idx = start_idx or 1
    if start_idx < 0 then start_idx = length + start_idx + 1 end

    end_idx = end_idx or length
    if end_idx < 0 then end_idx = length + end_idx + 1 end

    for i = start_idx, end_idx do
        sliced[#sliced+1] = tbl[i]
    end

    for i = end_idx, start_idx, -1 do
        table.remove(tbl, i)
    end

    return sliced
end

function module.SaveToDatabase(data)
    if not data or type(data) ~= "table" then return end
    local q = 'INSERT INTO logs (resource, log_type, trigger_user, data)'
    if table.type(data) == 'array' then
        q = q .. ' VALUES '
        local values = {}
        for i = 1, #data do
            local resource = data[i]?.resource or GetInvokingResource() or 'NONE'
            local log_type = data[i]?.log_type or 'SYSTEM'
            local trigger_user = data[i]?.trigger_user or 'SYSTEM'
            local data = data[i]?.data or {}
            values[#values] = '(' .. resource .. ', ' .. log_type .. ', ' .. trigger_user .. ', ' .. json.encode(data) .. ')'
        end
        q = q .. table.concat(values, ', ')
        return imod.storage.Insert(q, {})
    else
        q = q .. ' VALUES (?, ?, ?, ?)'
        return imod.storage.Insert(q, {
            data?.resource or GetInvokingResource() or 'NONE',
            data?.log_type or 'SYSTEM',
            data?.trigger_user or 'SYSTEM',
            json.encode(data?.data or {})
        })
    end
end

function module.SendToDiscord(data)
end

function module.SendToFiveManager(data)
end

function module.SendToHost(data)
end

function module.Create(data)
    if default_log_method == 'database' then
        module.SaveToDatabase(data)
    elseif default_log_method == 'discord' then
        module.SendToDiscord(data)
    elseif default_log_method == 'fivemanager' then
        module.SendToFiveManager(data)
    elseif default_log_method == 'host' then
        module.SendToHost(data)
    else
        lib.print.info('LOGGING', data)
    end
end

function module.Add(data)

end

local function init()
    if not enable_queue then return end
    CreateThread(function()
        while true do
            Wait(2000)
            if #logging_queue >= queue_max then
                local log_data = slice_and_remove(logging_queue, 1, queue_max)
                module.Create(log_data)
            end
        end
    end)
end

local function __init__(storage_module)
    local _module = { name = 'Logging', exp_prefix = 'Log', }
    imod.storage = storage_module
    init()
    return setmetatable(_module, {
        __index = module,
        __tostring = function()
            return _module.name
        end
    })
end

return __init__
