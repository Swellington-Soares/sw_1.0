local require = lib.require
local old_print = print
local print = lib.print.info
local modules = {}

modules.player = require '@sw.client.modules.player' ()

for k, v in next, modules do    
    print('Loading module: ' .. v?.name or k:upper())
    for k2, v2 in next, getmetatable(v)?.__index or {} do
        if k2:sub(1, 1) ~= '_' then
            print('Registering method exports: ', '[' .. cache.resource .. ']', (v?.exp_prefix or "") .. k2)
            exports((v?.exp_prefix or "") .. k2, v2)
        end
    end
end