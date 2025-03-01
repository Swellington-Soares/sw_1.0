-- Event triggered on change death status
RegisterNetEvent('hospital:server:SetDeathStatus', function(state)
    local src = source
    TriggerClientEvent(_e('client:setPlayerDeathStatus'), src, state)
end)
