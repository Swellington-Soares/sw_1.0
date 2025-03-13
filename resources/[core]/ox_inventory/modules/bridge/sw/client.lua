local Weapon = require 'modules.weapon.client'


local SW = setmetatable({}, {
    __index = function(self, index)
        self.SetPlayerData = function(k, v)
            exports.sw:SetPlayerData(k, v)
        end
        return self[index]
    end
})

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    lib.print.debug('isLoggedIn', value)
    PlayerData.loaded = value
    if not value then
        return client.onLogout()
    end
end)

AddStateBagChangeHandler('handcuffed', ('player:%s'):format(cache.serverId), function(_, _, value)
    LocalPlayer.state:set('invBusy', value, false)
    PlayerData.cuffed = value
    if not value then return end
    Weapon.Disarm()
end)

AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(_, _, value)
    lib.print.debug('isDead', value)
    PlayerData['isdead'] = value
    OnPlayerData('dead', value)
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerData(key, value)
    PlayerData[key] = value
    SW.SetPlayerData(key, value)
end

---@diagnostic disable-next-line: duplicate-set-field
function client.hasGroup(group)
    if not PlayerData.loaded then return end
    lib.print.info('client.hasGroup', group)
end

RegisterNetEvent('Player:SyncData', function(data)
    if not PlayerData.loaded then return end
    local groups = data.groups or {}
    local job = data.job or {
        name = 'unemployed',
        label = 'Desempregado',
        grade = 0,
        gradeName = 'Unemployed',
    }
    local gang = data.gang or {
        name = 'none',
        label = 'Nenhum',
        gradeName = 'None',
        grade = 0,
    }

    local _groups = PlayerData.groups

    if job.grade == 0 then
        _groups[job.name] = nil
    else
        _groups[job.name] = job.grade
    end

    if gang.grade == 0 then
        _groups[gang.name] = nil
    else
        _groups[gang.name] = gang.grade
    end

    for k, rank in next, groups do
        _groups[k] = rank
    end

    PlayerData.groups = _groups
    client.setPlayerData('groups', groups)
end)

RegisterNetEvent('Player:SyncJob', function(remove, jobname, jobdata)
end)

RegisterNetEvent('layer:SyncGang', function(data)
end)

RegisterNetEvent('Player:SyncMoney', function(action, data)
end)
