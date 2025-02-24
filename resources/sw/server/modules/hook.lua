local module = {}

local hooks = {}

function module.Add(name, cb)    
    local __resource = GetInvokingResource()
    if not hooks[name] then hooks[name] = {} end
    hooks[name][__resource] = cb
end

function module.Remove(name)
    local __resource = GetInvokingResource()
    if not hooks[name] then return end
    if hooks[name][__resource] then
        hooks[name][__resource] = nil
    end
end

function module.Clear()
    hooks = {}
end

function module.RemoveAll(name)
    if hooks[name] then
        hooks[name] = nil
    end
end

function module.Trigger(name, ...)    
    if hooks[name] then
        for k in next, hooks[name] do            
            hooks[name][k](...)           
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)   
    for k in next, hooks do
        if hooks[k][resourceName] then            
            hooks[k][resourceName] = nil
        end
    end
end)

local function __init__()
    local _module = { name = 'Hook', exp_prefix = 'Hook'}
    return setmetatable(_module, {__index = module })
end

return __init__