
local Inventory = require 'modules.inventory.server'

local function SetupPlayer(data)
    if not data then return end
    local inv = {
        identifier = data.char_id,
        name = ('%s %s'):format(data.firstname, data.lastname),
        user_id = data.user_id,
        source = data.src,
        license = data.license,
        sex = data.sex or 'M',
        groups = {},
        dateofbirth = os.date("%d/%m/%Y", data.birthdate // 1000),        
    }
    server.setPlayerInventory(inv)
    Inventory.SetItem(data.src, "money", data.money?.cash or 0)
end

AddStateBagChangeHandler('loadInventory', nil, function(bagName, _, value)
    if not value then return end
    local plySrc = GetPlayerFromStateBagName(bagName)
    if not plySrc then return end
    -- setupPlayer(QBX:GetPlayer(plySrc).PlayerData)
    local playerData = exports.sw:PlayerGetOne( plySrc )?.PlayerData
    SetupPlayer(playerData)
end)

SetTimeout(500, function()
    local players = exports.sw:PlayerGetAll() or {}
    for i = 1, #players do
        SetupPlayer(players[i]?.PlayerData)
    end
end)

-- function server.UseItem(source, itemName, data)
--     -- local cb = QBX:CanUseItem(itemName)
--     -- return cb and cb(source, data)
-- end

---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
    lib.print.debug('Setting player data', player)
    -- local groups = QBX:GetGroups(player.source)
    -- return {
    --     source = player.source,
    --     name = ('%s %s'):format(player.charinfo.firstname, player.charinfo.lastname),
    --     groups = groups,
    --     sex = player.charinfo.gender,
    --     dateofbirth = player.charinfo.birthdate,
    -- }
    return {}
end

---@diagnostic disable-next-line: duplicate-set-field
function server.syncInventory(inv)
    -- local accounts = Inventory.GetAccountItemCounts(inv)

    -- if not accounts then return end

    -- local player = QBX:GetPlayer(inv.id)
    -- player.Functions.SetPlayerData('items', inv.items)

    -- for account, amount in pairs(accounts) do
    --     account = account == 'money' and 'cash' or account
    --     if player.Functions.GetMoney(account) ~= amount then
    --         player.Functions.SetMoney(account, amount, ('Sync %s with inventory'):format(account))
    --     end
    -- end
end

---@diagnostic disable-next-line: duplicate-set-field
function server.hasLicense(inv, license)
    -- local player = QBX:GetPlayer(inv.id)
    -- return player and player.PlayerData.metadata.licences[license]
    return false
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense(inv, license)
    -- local player = QBX:GetPlayer(inv.id)
    -- if not player then return end

    -- if player.PlayerData.metadata.licences[license.name] then
    --     return false, 'already_have'
    -- elseif Inventory.GetItem(inv, 'money', false, true) < license.price then
    --     return false, 'can_not_afford'
    -- end

    -- Inventory.RemoveItem(inv, 'money', license.price)
    -- player.PlayerData.metadata.licences[license.name] = true
    -- player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)

    return true, 'have_purchased'
end



---@diagnostic disable-next-line: duplicate-set-field
function server.isPlayerBoss(playerId, group, grade)
    return false--QBX:IsGradeBoss(group, grade)
end


---@param entityId number
---@return number | string
---@diagnostic disable-next-line: duplicate-set-field
function server.getOwnedVehicleId(entityId)
    return Entity(entityId).state.vehicleid --or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(entityId))
end

AddStateBagChangeHandler('ready', nil, function(bagName, _, value)
    local player = GetPlayerFromStateBagName(bagName)
    if player == 0 or not value then return end
    local playerData = exports.sw:PlayerGetOne( player )?.PlayerData
    print('Player Ready', player)
    SetupPlayer(playerData) 
end)