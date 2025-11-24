
local ESX = nil
local QBCore = nil
local Framework = { type = nil }

CreateThread(function()
    Wait(500)
    if GetResourceState(cfg.esxResource) == "started" then
        ESX = exports[cfg.esxResource]:getSharedObject()
        Framework.type = "ESX"
        print(("^2[Framework]^0 Using ESX (%s)"):format(cfg.esxResource))
        return
    end

    if GetResourceState(cfg.qbResource) == "started" then
        QBCore = exports[cfg.qbResource]:GetCoreObject()
        Framework.type = "QB"
        print(("^2[Framework]^0 Using QBCore (%s)"):format(cfg.qbResource))
        return
    end

    print("^1[ERROR]^0 No ESX or QBCore detected. Stopping resource.")
    StopResource(GetCurrentResourceName())
end)

local function whitelisted(group)
    for i = 1, #cfg.whitelisted_groups do
        if group == cfg.whitelisted_groups[i] then
            return true
        end
    end
    return false
end

local flag_target = function(target, args)
    local todo = cfg.flag:lower()
    discordlog(('```Account: %s | Amount: %s | Player: %s (ID: %s)```')
        :format(args.label, args.money, GetPlayerName(target), target))
    if (todo ~= 'kick' and todo ~= 'log' and todo ~= 'wipe') then
        print(('^1[ERROR]^0: Configuration isn\'t set up properly. The "cfg.flag" value isn\'t correct. Accepted: kick, wipe, log. (Current Value: %s)')
            :format(todo))
        return
    end

    if todo == "kick" then
        DropPlayer(target, "Modded money detected.")
    end
end


local function getPlayers()
    if Framework.type == "ESX" then
        return ESX.GetExtendedPlayers()
    else
        local list = {}
        for _, src in pairs(QBCore.Functions.GetPlayers()) do
            list[#list + 1] = QBCore.Functions.GetPlayer(src)
        end
        return list
    end
end

local function getAccounts(xPlayer)
    if Framework.type == "ESX" then
        return xPlayer.getAccounts()
    else
        return {
            money = {
                name = "money",
                money = xPlayer.PlayerData.money["cash"],
                label = "Cash"
            },
            bank = {
                name = "bank",
                money = xPlayer.PlayerData.money["bank"],
                label = "Bank"
            },
            black_money = {
                name = "black_money",
                money = xPlayer.PlayerData.money["crypto"] or 0,
                label = "Crypto"
            }
        }
    end
end

local function setAccountMoney(xPlayer, account, value)
    if Framework.type == "ESX" then
        xPlayer.setAccountMoney(account, value)
    else
        xPlayer.Functions.SetMoney(account, value)
    end
end

local function getGroup(xPlayer)
    if Framework.type == "ESX" then
        return xPlayer.getGroup()
    else
        return xPlayer.PlayerData.job.name
    end
end


local function check_players()
    if not Framework.type then return end

    local players = getPlayers()
    if not players then return end

    for _, xPlayer in pairs(players) do
        if not whitelisted(getGroup(xPlayer)) then
            for _, acc in pairs(getAccounts(xPlayer)) do
                if cfg.max[acc.name] and acc.money >= cfg.max[acc.name] then
                    print(("^3[WARNING]^0 %s has $%s (%s)")
                        :format(GetPlayerName(xPlayer.source), acc.money, acc.label))

                    if cfg.flag:lower() ~= "log" then
                        setAccountMoney(xPlayer, acc.name, 0)
                    end

                    Wait(500)
                    flag_target(xPlayer.source, acc)
                end
            end
        end
    end
end

CreateThread(function()
    while true do
        if Framework.type then
            check_players()
        end
        Wait(cfg.checkTime * 1000)
    end
end)


function discordlog(desc)
    if not desc or desc == "" then return end
    if cfg.webhook == "" then return end

    local embed = {
        color = 1,
        title = "Modded Money Detected",
        footer = { text = os.date("%B %d, %Y at %I:%M %p") },
        description = desc
    }

    PerformHttpRequest(cfg.webhook, function() end, 'POST', json.encode({
        username = 'Trase#0001',
        avatar_url = 'https://imgur.com/3igi3eC.png',
        embeds = { embed }
    }), { ["Content-Type"] = "application/json" })
end
