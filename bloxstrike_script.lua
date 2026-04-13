--[[
    BloxStrike Simplified Script
    Features: Aimbot (Right Mouse Button activation), ESP Box, ESP Skeleton
    Compatibility: Xeno Executor
    No UI - Always active (Aimbot on key press, ESP always on)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configuration (Hardcoded for simplicity)
local Config = {
    Aimbot = {
        Enabled = true, -- Aimbot is always enabled, activated by key
        Smoothness = 0.1, -- Default smoothness
        FOV = 150, -- Default FOV for target detection
        TargetPart = "Head",
        ActivationKey = Enum.KeyCode.MouseButton2 -- Right Mouse Button to activate Aimbot
    },
    ESP = {
        Box = true, -- ESP Box always on
        Skeleton = true, -- ESP Skeleton always on
        TeamCheck = true, -- Team check always on
        Color = Color3.fromRGB(255, 255, 255) -- White color for ESP
    }
}

-- Helper Functions
local function GetClosestPlayer(fov)
    local closest = nil
    local shortestDistance = fov

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if distance < shortestDistance then
                    closest = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    local isPressed = false
    if Config.Aimbot.ActivationKey.Name:find("MouseButton") then
        isPressed = UserInputService:IsMouseButtonPressed(Config.Aimbot.ActivationKey)
    else
        isPressed = UserInputService:IsKeyDown(Config.Aimbot.ActivationKey)
    end

    if Config.Aimbot.Enabled and isPressed then
        local target = GetClosestPlayer(Config.Aimbot.FOV)
        if target and target.Character and target.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            local targetPart = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
            if targetPart then
                local targetPos = targetPart.Position
                local camPos = Camera.CFrame.Position
                local targetCFrame = CFrame.new(camPos, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.Smoothness)
            end
        end
    end
end)

-- ESP Logic
local playerESPTable = {}

local bones = {
    {"Head", "Neck"},
    {"Neck", "UpperTorso"},
    {"UpperTorso", "RightShoulder"},
    {"RightShoulder", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftShoulder"},
    {"LeftShoulder", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "RightHip"},
    {"RightHip", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"LowerTorso", "LeftHip"},
    {"LeftHip", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
}

local function SetupPlayerESP(player)
    if playerESPTable[player.UserId] then return end
    local espData = {Box = Drawing.new("Square"), Skeleton = {}}

    espData.Box.Visible = false
    espData.Box.Color = Config.ESP.Color
    espData.Box.Thickness = 1
    espData.Box.Transparency = 1
    espData.Box.Filled = false

    for i = 1, #bones do
        espData.Skeleton[i] = Drawing.new("Line")
        espData.Skeleton[i].Visible = false
        espData.Skeleton[i].Color = Config.ESP.Color
        espData.Skeleton[i].Thickness = 1
        espData.Skeleton[i].Transparency = 1
    end

    playerESPTable[player.UserId] = espData

    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            -- Box ESP
            if onScreen and Config.ESP.Box then
                if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                    espData.Box.Visible = false
                else
                    local headPos, headOnScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                    local footPos, footOnScreen = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, rootPart.Size.Y/2, 0))

                    if headOnScreen and footOnScreen then
                        local height = math.abs(headPos.Y - footPos.Y)
                        local width = height * 0.6 -- Approximate width
                        espData.Box.Size = Vector2.new(width, height)
                        espData.Box.Position = Vector2.new(pos.X - width / 2, headPos.Y)
                        espData.Box.Visible = true
                    else
                        espData.Box.Visible = false
                    end
                end
            else
                espData.Box.Visible = false
            end

            -- Skeleton ESP
            if Config.ESP.Skeleton then
                if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                    for _, line in pairs(espData.Skeleton) do line.Visible = false end
                else
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local boneIndex = 1
                        for _, bonePair in pairs(bones) do
                            local part1 = player.Character:FindFirstChild(bonePair[1], true)
                            local part2 = player.Character:FindFirstChild(bonePair[2], true)

                            if part1 and part2 then
                                local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)

                                if onScreen1 and onScreen2 then
                                    espData.Skeleton[boneIndex].From = Vector2.new(pos1.X, pos1.Y)
                                    espData.Skeleton[boneIndex].To = Vector2.new(pos2.X, pos2.Y)
                                    espData.Skeleton[boneIndex].Visible = true
                                else
                                    espData.Skeleton[boneIndex].Visible = false
                                end
                            else
                                espData.Skeleton[boneIndex].Visible = false
                            end
                            boneIndex = boneIndex + 1
                        end
                    else
                        for _, line in pairs(espData.Skeleton) do line.Visible = false end
                    end
                end
            else
                for _, line in pairs(espData.Skeleton) do line.Visible = false end
            end
        else
            espData.Box.Visible = false
            for _, line in pairs(espData.Skeleton) do line.Visible = false end
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    SetupPlayerESP(player)
end
Players.PlayerAdded:Connect(SetupPlayerESP)
Players.PlayerRemoving:Connect(function(player)
    local espData = playerESPTable[player.UserId]
    if espData then
        espData.Box:Remove()
        for _, line in pairs(espData.Skeleton) do
            line:Remove()
        end
        playerESPTable[player.UserId] = nil
    end
end)

-- No Rayfield notifications as there is no UI
-- print("BloxStrike Simplified Script Loaded!") -- For console output if needed
