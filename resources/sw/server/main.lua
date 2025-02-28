local require = lib.require
local old_print = print
local print = lib.print.info
local modules = {}


modules.storage = require '@sw.server.modules.storage' ()
modules.server = require '@sw.server.modules.server' (modules.storage)
modules.character = require '@sw.server.modules.character' (modules.storage)
modules.player = require '@sw.server.modules.player' (modules.storage, modules.server, modules.character)
modules.hooks = require '@sw.server.modules.hook' (modules.storage)
modules.auth = require '@sw.server.modules.auth' (modules.storage)
modules.email = require '@sw.server.modules.email' ()

for k, v in next, modules do
    old_print()
    print('Loading module: ' .. v?.name or k:upper())
    for k2, v2 in next, getmetatable(v)?.__index or {} do
        if k2:sub(1, 1) ~= '_' then
            print('Registering method exports: ', '[' .. cache.resource .. ']', (v?.exp_prefix or "") .. k2)
            exports((v?.exp_prefix or "") .. k2, v2)
        end
    end
end


local AdaptiveCards = {}
AdaptiveCards.Reg = lib.loadJson('@sw.server.adaptive_card.reg_card')
AdaptiveCards.InputToken = lib.loadJson('@sw.server.adaptive_card.input_token_card')
AdaptiveCards.InputEmailPassword = lib.loadJson('@sw.server.adaptive_card.login_card')


local function input_token(deff)
    local p = promise.new()
    CreateThread(function()
        Wait(0)
        deff.presentCard(AdaptiveCards.InputToken, function(data)
            if not data.token then
                p:resolve(nil)
            else
                p:resolve(data.token)
            end
        end)
    end)
    return Citizen.Await(p)
end

local function send_token_email(email, token)
    CreateThread(function()
        Wait(0)
    end)
end

local function on_player_connecting(name, _, d)
    local src = source
    d.defer()
    Wait(0)
    
    print('Player connecting: ', name, src)

    local response = nil
    local function register_timeout_check()
        response = nil
        CreateThread(function()
            local success = pcall(lib.waitFor, function() return response end, locale('register_timeout'), 300000)
            if not success then
                return d.done(locale('register_timeout'))
            end
        end)
    end

    CreateThread(function()
        repeat
            Wait(250)
        until not DoesPlayerExist(src)
        response = true
    end)

    local license = modules.server.GetPlayerIdentifier(src, 'license')
    local discord = modules.server.GetPlayerIdentifier(src, 'discord')
    local fivemId = modules.server.GetPlayerIdentifier(src, 'fivem')

    d.update(locale('verify_license'))
    Wait(50)
    if not license then
        return d.done(locale('verify_license_error'))
    end

    d.update(locale('verify_discord'))
    Wait(50)
    if not discord then
        return d.done(locale('verify_discord_error'))
    end

    d.update(locale('verify_fivem_account'))
    Wait(50)
    if not fivemId then
        return d.done(locale('verify_fivem_account_error'))
    end

    Wait(100)

    local user = modules.auth._GetUser(license)
    if not user then
        register_timeout_check()
        return d.presentCard(AdaptiveCards.Reg, function(data)
            response = true
            local email = data.email_field
            local accept_terms = data.term_field
            local accept_privacy = data.privacy_field
            if not email or not accept_terms or not accept_privacy then
                return d.done(locale('register_error'))
            end

            local is_user_created, message = modules.auth._CreateUser({
                license = license,
                discord = discord,
                fivem = fivemId,
                email = email
            })

            if not is_user_created then
                return d.done(message)
            end

            Wait(0)
            send_token_email(email, modules.auth._GenerateToken(license))
            register_timeout_check()
            local user_token = input_token(d)
            response = true
            if not user_token or not modules.auth._ValidateToken(license, user_token) then
                return d.done(locale('token_not_found'))
            end
            return d.done()
        end)
    end

    if not user.is_valided then
        register_timeout_check()
        local user_token = input_token(d)
        response = true
        if not user_token or not modules.auth._ValidateToken(license, user_token) then
            return d.done(locale('token_not_found'))
        end
        return d.done()
    end

    d.update(locale('infor_validation'))
    Wait(50)

    if modules.auth._IsUserBlocked(license) then
        return d.done(locale('user_blocked'))
    end

    if GetConvar('sw:enable_allowlist', 1) == 1 and not user.is_allowed then
        return d.done(locale('user_not_allowed', user.id))
    end

    d.update(locale('infor_validation_success'))
    Wait(50)
    d.done()
end

local function on_player_dropped(reason)
    local src = source
    modules.player._SaveAndUnload(src)
    print('Player dropped: ', src, reason)
end

--fivem default events
AddEventHandler('playerConnecting', on_player_connecting)
AddEventHandler('playerDropped', on_player_dropped)

local function player_save_thread()
    local save_interval = GetConvarInt('sw:save_interval', 1) * 60000 --save in minutes
    while true do
        Wait(save_interval)
        modules.player._SaveAllOnlinePlayers()
    end
end


CreateThread(player_save_thread)
