local module = {}


---Set global server runtime data
---@param key string
---@param value CommonData
---@param sync boolean
function module.SetTempData(key, value, sync)
    GlobalState:set(key, value, sync)
end

---Remove Temporary data from server 
---@param key any
function module.RemoveTempData(key)
    GlobalState:set(key, nil, true)
end

---Get Temporary data from server
---@param key string
---@return CommonData
function module.GetTempData(key)
    return GlobalState[key] or nil
end

---Save data to database. Use nil in value to remove
---@param key string
---@param value CommonData
function module.SetServerData(key, value)
    assert(type(key) == 'string', 'Key must be a string')
    if value == nil then
        return exports.sw:SQLUpdate('DELETE FROM server_data WHERE dkey = ?', {key})
    end
    if type(value) == "table" then value = json.encode(value) end
    return exports.sw:SQLUpdate('INSERT INTO server_data (dkey, dvalue) VALUES (?, ?) ON DUPLICATE KEY UPDATE dvalue = VALUES(dvalue)', {key, value})
end

---Get data from server_data table passing the key
---@param key any
---@return unknown
function module.GetServerData(key)
    assert(type(key) == 'string', 'Key must be a string')
    return exports.sw:SQLScalar('SELECT dvalue FROM server_data WHERE dkey = ?', {key})
end

function module.GetPlayerIdentifier(source, _type)
    _type = _type or 'license'
    if not source or source == 0 or source == '0' then return end
    local identifier = GetPlayerIdentifierByType(source, _type)
    return identifier and (identifier:gsub(_type .. ':', ''))    
end



local function __init__()
    local _module = { name = 'Server',}
    return setmetatable(_module, {__index = module } )
end

return __init__