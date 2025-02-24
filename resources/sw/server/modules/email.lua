local module = {}

function module._IsStarted()       
    if GetConvar('sw:email_service_host', '') == '' then
        return false
    end

    local errorCode = PerformHttpRequestAwait(GetConvar('sw:email_service_host', ''))        
    return errorCode == 200
end

function module._SendEmail(to, data) 
    assert(type(to) == 'string', 'to must be a string')
    assert(type(data) == 'table', 'data must be a table')
    if not module._IsStarted() then return end 
    local url = GetConvar('sw:email_service_host', '') .. '/send'    
    local errorCode, resultData =  PerformHttpRequestAwait(url, 'POST', json.encode({ to = to, data = data }))
    return errorCode == 200, resultData
end

local function __init__()
    local _module = { name = 'Email' }
    return setmetatable(_module, { __index = module })
end

return __init__