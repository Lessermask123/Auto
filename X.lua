-- โหลด Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId

-- 🌸 สร้างหน้าต่าง UI ในธีม Mental Health App
local Window = Fluent:CreateWindow({
    Title = "🌸 Auto ALL Arcane Conquest",
    SubTitle = "Welcome, " .. LocalPlayer.Name,
    TabWidth = 180,
    Size = UDim2.fromOffset(620, 280),
    Acrylic = true,
    Theme = "Light",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- สร้างแท็บ
local Tabs = {
    CalmZone = Window:AddTab({ Title = "🧘 ออโต้", Icon = "🌿" }),
    Support = Window:AddTab({ Title = "🌈 จบเกม", Icon = "💬" }),
    Settings = Window:AddTab({ Title = "⚙️ ตั้งค่า", Icon = "🔧" }),
    Player = Window:AddTab({ Title = "👤 Player", Icon = "🎮" })
}

-- ฟังก์ชันกดคีย์แบบ soft delay
local function pressKey(keycode)
    VirtualInputManager:SendKeyEvent(true, keycode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keycode, false, game)
end

-- ป้องกันรบกวนตอนพิมพ์
local function isTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

-- สกิลออโต้ใน Calm Zone
local autoSkills = {
    { name = "✨ Auto All Skill (F)", key = Enum.KeyCode.F },
    { name = "💨 Auto (R)", key = Enum.KeyCode.R },
    { name = "🕊️ Auto (Q)", key = Enum.KeyCode.Q },
    { name = "🌿 Auto (E)", key = Enum.KeyCode.E },
}

for _, skill in ipairs(autoSkills) do
    local enabled = false

    Tabs.CalmZone:AddToggle(skill.name, {
        Title = skill.name,
        Default = false,
        Callback = function(state)
            enabled = state
        end
    })

    task.spawn(function()
        while true do
            if enabled and not isTyping() then
                pressKey(skill.key)
            end
            task.wait(0.5)
        end
    end)
end

-- ปุ่มใน Support
Tabs.Support:AddButton({
    Title = "🏠 Return to Safe Place",
    Description = "Teleport back to home for rest & reset.",
    Callback = function()
        local homePlaceId = 125503319883299
        TeleportService:Teleport(homePlaceId, LocalPlayer)
    end
})

Tabs.Support:AddButton({
    Title = "☁️ Let Go (Reset)",
    Description = "Refresh your avatar and let stress go.",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end
})

-- เมนูตั้งค่าเพิ่มเติม
Tabs.Settings:AddParagraph({
    Title = "🎹 Shortcut Key",
    Content = "Use **Left Control** to hide/show this window anytime."
})

Tabs.Settings:AddButton({
    Title = "🔁 Rejoin Current Server",
    Description = "Rejoin the current game.",
    Callback = function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
})

Tabs.Settings:AddButton({
    Title = "🚀 Join Lowest Server",
    Description = "Join a server with the fewest players or no players.",
    Callback = function()
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)

        if success and servers and servers.data then
            local targetServer = nil
            for _, server in ipairs(servers.data) do
                if server.playing == 0 then
                    targetServer = server
                    break
                elseif not targetServer or server.playing < targetServer.playing then
                    targetServer = server
                end
            end

            if targetServer then
                TeleportService:TeleportToPlaceInstance(PlaceId, targetServer.id, LocalPlayer)
            else
                warn("ไม่พบเซิร์ฟเวอร์ที่ไม่มีผู้เล่น หรือมีผู้เล่นน้อยที่สุด.")
            end
        else
            warn("ไม่สามารถดึงข้อมูลเซิร์ฟเวอร์ได้.")
        end
    end
})

Tabs.Settings:AddButton({
    Title = "🌟 Join Full Server",
    Description = "Join a server with the highest number of players that you can join.",
    Callback = function()
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)

        if success and servers and servers.data then
            local targetServer = nil
            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers then
                    if not targetServer or server.playing > targetServer.playing then
                        targetServer = server
                    end
                end
            end

            if targetServer then
                TeleportService:TeleportToPlaceInstance(PlaceId, targetServer.id, LocalPlayer)
            else
                warn("ไม่พบเซิร์ฟเวอร์ที่สามารถเข้าร่วมได้.")
            end
        else
            warn("ไม่สามารถดึงข้อมูลเซิร์ฟเวอร์ได้.")
        end
    end
})

-- 👤 เมนู Player: Speed Boost
local speedEnabled = false
local previousWalkSpeed = nil

Tabs.Player:AddToggle("🚀 Speed Boost", {
    Title = "เพิ่มความเร็วขึ้น 120% จาก WalkSpeed ล่าสุด",
    Default = false,
    Callback = function(state)
        speedEnabled = state

        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character:FindFirstChild("Humanoid")

            if state then
                previousWalkSpeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = previousWalkSpeed * 2.2
            else
                if previousWalkSpeed then
                    humanoid.WalkSpeed = previousWalkSpeed
                end
            end
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    if speedEnabled and previousWalkSpeed then
        task.wait(0.5)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = previousWalkSpeed * 1.5
        end
    end
end)

-- UI Toggle Key
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        uiVisible = not uiVisible
        Window:SetVisible(uiVisible)
    end
end)
