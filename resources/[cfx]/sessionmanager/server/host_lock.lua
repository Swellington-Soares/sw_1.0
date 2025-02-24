-- Whitelist de eventos do cliente para o servidor
RegisterServerEvent('hostingSession')
RegisterServerEvent('hostedSession')

-- Variáveis de controle de hospedagem
local hosting = {
    current = nil,
    releaseCallbacks = {},
    timeout = 5000 -- Timeout configurável
}

-- Adiciona um evento para iniciar uma sessão de hospedagem
AddEventHandler('hostingSession', function()
    local playerId = source

    -- Se já houver um host, aguarde a liberação
    if hosting.current then
        TriggerClientEvent('sessionHostResult', playerId, 'wait')

        -- Registra callback para notificar o jogador quando a sessão for liberada
        hosting.releaseCallbacks[#hosting.releaseCallbacks + 1] = function()
            TriggerClientEvent('sessionHostResult', playerId, 'free')
        end
        return
    end

    -- Evita conflitos se o host atual estiver ativo
    local currentHost = GetHostId()
    if currentHost and GetPlayerLastMsg(currentHost) < 1000 then
        TriggerClientEvent('sessionHostResult', playerId, 'conflict')
        return
    end

    -- Define o novo host e limpa callbacks antigos
    hosting.current = playerId
    hosting.releaseCallbacks = {}

    -- Notifica o cliente que ele pode hospedar
    TriggerClientEvent('sessionHostResult', playerId, 'go')

    -- Define um timeout para a sessão de hospedagem
    SetTimeout(hosting.timeout, function()
        if hosting.current == playerId then
            hosting.current = nil
            for _, cb in ipairs(hosting.releaseCallbacks) do cb() end
        end
    end)
end)

-- Evento para confirmar a sessão de hospedagem
AddEventHandler('hostedSession', function()
    local playerId = source

    -- Verifica se o jogador é realmente o host
    if hosting.current ~= playerId then
        print(('Tentativa inválida de host: esperado %s, recebido %s'):format(hosting.current, playerId))
        return
    end

    -- Libera a sessão e executa os callbacks
    hosting.current = nil
    for _, cb in ipairs(hosting.releaseCallbacks) do cb() end
end)

-- Ativa suporte aprimorado para host
EnableEnhancedHostSupport(true)
