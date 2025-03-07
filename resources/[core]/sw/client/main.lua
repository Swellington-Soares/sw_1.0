local require = lib.require
local old_print = print
local print = lib.print.info
local modules = {}
local config = lib.load('shared.config')

modules.client = require '@sw.client.modules.client' ()
modules.player = require '@sw.client.modules.player' (modules.client)
modules.hook = require '@sw.shared.modules.hook' ()

for k, v in next, modules do    
    print('Loading module: ' .. v?.name or k:upper())
    for k2, v2 in next, getmetatable(v)?.__index or {} do
        if k2:sub(1, 1) ~= '_' then
            print('Registering method exports: ', '[' .. cache.resource .. ']', (v?.exp_prefix or "") .. k2)
            exports((v?.exp_prefix or "") .. k2, v2)
        end
    end
end

AddEventHandler('entityCreating', function(entity)
    if config.block_entity[entity] then
        CancelEvent()
    end
end)