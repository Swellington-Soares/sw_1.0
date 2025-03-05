-- Adds a state bag change handler for 'isLoggedIn'
AddStateBagChangeHandler('isLoggedIn', nil, function(_, _, isLoggedIn)
    print('isLoggedIn', 'isLoggedIn')
    client.onPlayerLoad(isLoggedIn)
end)

AddStateBagChangeHandler('hunger', nil, function(_, _, value)
    PlayerData.hunger = value
end)

AddStateBagChangeHandler('thirst', nil, function(_, _, value)
    PlayerData.thirst = value    
end)

AddStateBagChangeHandler('stress', nil, function(_, _, value)
    PlayerData.stress = value
end)

-- Retrieves the player's data using the updated method
---@return object PlayerData
function client.GetPlayerData()
    return exports.sw:GetPlayerData()
end

-- Retrieves the balance of the specified account
---@param account 'bank'|'cash'|'extra_currency'
---@return integer Balance
function client.GetPlayerBalance(account)
    return client.GetPlayerData()?.money[account] or 0
end

-- Retrieves the player's job information with updated field names
---@return table JobInfo
function client.GetPlayerJob()
    local label, grade = nil, nil
    local xPlayer = client.GetPlayerData()
    label = xPlayer?.job?.label or 'Desempregado'
    grade = xPlayer?.job?.gradeName or 'Freelancer'
    return { label = label, grade = grade }
end

-- Checks if the player is logged in based on local player state
---@return boolean isLoggedIn
function client.IsPlayerLoaded()
    print('client.IsPlayerLoaded()', LocalPlayer.state.isLoggedIn)
    return LocalPlayer.state.isLoggedIn
end

-- Loads initial player data into PlayerData
function client.LoadFirstPlayerData()    
    PlayerData.thirst = LocalPlayer.state.thirst or 0
    PlayerData.hunger = LocalPlayer.state.hunger or 0
    PlayerData.stress = LocalPlayer.state.stress or 0
end
