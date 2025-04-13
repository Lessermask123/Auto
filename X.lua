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
    Size = UDim2.fromOffset(620, 480),
    Acrylic = true, -- ใช้พื้นหลังเบลอสวยๆ แบบ 3D
    Theme = "Light", -- ใช้โทนสว่างนุ่ม
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- สร้างแท็บ
local Tabs = {
    CalmZone = Window:AddTab({ Title = "🧘 ออโต้", Icon = "🌿" }),
    Support = Window:AddTab({ Title = "🌈 จบเกม", Icon = "💬" }),
    Settings = Window:AddTab({ Title = "⚙️ ตั้งค่า", Icon = "🔧" })
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

            -- ค้นหาเซิร์ฟเวอร์ที่ไม่มีผู้เล่นหรือมีผู้เล่นน้อยที่สุด
            for _, server in ipairs(servers.data) do
                if server.playing == 0 then
                    -- หากเจอเซิร์ฟเวอร์ที่ไม่มีผู้เล่น
                    targetServer = server
                    break
                elseif not targetServer or server.playing < targetServer.playing then
                    -- ถ้าไม่มีเซิร์ฟเวอร์ที่ไม่มีผู้เล่น ให้เลือกเซิร์ฟเวอร์ที่มีผู้เล่นน้อยที่สุด
                    targetServer = server
                end
            end

            -- ถ้าเจอเซิร์ฟเวอร์ที่เหมาะสม
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

            -- ค้นหาเซิร์ฟเวอร์ที่มีผู้เล่นสูงสุดที่สามารถเข้าร่วมได้
            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers then
                    if not targetServer or server.playing > targetServer.playing then
                        targetServer = server
                    end
                end
            end

            -- ถ้าเจอเซิร์ฟเวอร์ที่เหมาะสม
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

-- UI Toggle Key
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        uiVisible = not uiVisible
        Window:SetVisible(uiVisible)
    end
end)
