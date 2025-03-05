-- Adds a state bag change handler for 'isLoggedIn'
AddStateBagChangeHandler('isLoggedIn', nil, function(_, _, isLoggedIn)
    client.onPlayerLoad(isLoggedIn)
end)

-- Event triggered to update hunger and thirst values
RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    PlayerData.hunger = newHunger
    PlayerData.thirst = newThirst
end)

-- Event triggered to update stress value
RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    PlayerData.stress = newStress
end)

-- Retrieves the player's data using the updated method
---@return object PlayerData
function client.GetPlayerData()
    return client.framework.Functions.GetPlayerData()
end

-- Retrieves the balance of the specified account
---@param account 'bank'|'cash'|'extra_currency'
---@return integer Balance
function client.GetPlayerBalance(account)
    local xPlayer = client.GetPlayerData()

    local function getItemAmount(itemName)
        for _, item in pairs(xPlayer.items or {}) do
            if item.name == itemName then
                return item.amount or item.count or 0
            end
        end
        return 0
    end

    if account == 'cash' and Config.MoneySettings.isMoneyItem then
        return getItemAmount(Config.MoneySettings.itemName)
    elseif account == 'extra_currency' then
        if Config.MoneySettings.extra_currency.type == 'item' then
            return getItemAmount(Config.MoneySettings.extra_currency.name)
        else
            account = Config.MoneySettings.extra_currency.name
        end
    end

    return xPlayer.money[account] or 0
end

-- Retrieves the player's job information with updated field names
---@return table JobInfo
function client.GetPlayerJob()
    local label, grade = nil, nil
    local xPlayer = client.GetPlayerData()
    label = xPlayer.job.label
    grade = xPlayer.job.grade.name
    return { label = label, grade = grade }
end

-- Checks if the player is logged in based on local player state
---@return boolean isLoggedIn
function client.IsPlayerLoaded()
    return LocalPlayer.state.isLoggedIn
end

-- Loads initial player data into PlayerData
function client.LoadFirstPlayerData()
    local xPlayer = client.GetPlayerData() or {}
    PlayerData.thirst = xPlayer?.metadata?.thirst or 0
    PlayerData.hunger = xPlayer?.metadata?.hunger or 0
    PlayerData.stress = xPlayer?.metadata?.stress or 0
end
