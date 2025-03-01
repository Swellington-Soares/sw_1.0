local module = {}
local imod = {}

function module.SetPlayerHealth( health )
    SetEntityHealth(cache.ped, math.floor(math.min(200, math.max(0, health))))
end

local function CEventNetworkEntityDamage(args)
   lib.print.info(args)    
end

function module.Start()
    local events = {
        ['CEventNetworkEntityDamage'] = CEventNetworkEntityDamage
    }
    local ped = cache.ped
    SetPedArmour(ped, 0)
    SetEntityHealth(ped, 200)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    AddEventHandler('gameEventTriggered', function(name, args)
        if not events[name] then return end
        events[name](args)
    end)    
end

local function init_rpc()
    imod.client.RegisterRpc('SetEntityHealth', module.SetPlayerHealth)
end


local function __init__(client, player)    
    imod.client = client
    imod.player = player
    init_rpc()
    local _module = { name = 'Player', exp_prefix = 'Survival' }
    return setmetatable(_module, {
        __index = module,
        __tostring = function()
            return _module.name
        end
    })
end


return __init__