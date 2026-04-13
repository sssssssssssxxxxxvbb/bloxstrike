--[[
    BloxStrike Full Script
    Features: Aimbot (Configurable), Smooth FOV, Silent Aim (Configurable FOV), 
              ESP Box, ESP Skeleton, Unlock All Skins (Skin Changer)
    Compatibility: Xeno Executor
    UI: Minimalist & Clean Hub
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- UI Library (Using a minimalist and clean one)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "BloxStrike Hub | Minimalist",
   LoadingTitle = "BloxStrike Script",
   LoadingSubtitle = "by Manus AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "BloxStrikeManus",
      FileName = "Config"
   },
   KeySystem = false
})

-- Variables for Config
local Config = {
    Aimbot = {
        Enabled = false,
        Smoothness = 0.1,
        FOV = 100,
        ShowFOV = true,
        TargetPart = "Head"
    },
    SilentAim = {
        Enabled = false,
        FOV = 100,
        ShowFOV = true,
        HitChance = 100
    },
    ESP = {
        Box = false,
        Skeleton = false,
        TeamCheck = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Skins = {
        UnlockAll = false,
        SelectedKnife = "Butterfly Knife",
        SelectedGlove = "T Glove"
    }
}

-- FOV Circles
local AimbotFOV = Drawing.new("Circle")
AimbotFOV.Thickness = 1
AimbotFOV.Color = Color3.fromRGB(255, 255, 255)
AimbotFOV.Filled = false
AimbotFOV.Transparency = 0.5

local SilentAimFOV = Drawing.new("Circle")
SilentAimFOV.Thickness = 1
SilentAimFOV.Color = Color3.fromRGB(255, 0, 0)
SilentAimFOV.Filled = false
SilentAimFOV.Transparency = 0.5

-- Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local SkinsTab = Window:CreateTab("Skins", 4483362458)

-- Combat UI
CombatTab:CreateSection("Aimbot Settings")
CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) Config.Aimbot.Enabled = Value end,
})
CombatTab:CreateSlider({
   Name = "Aimbot Smoothness",
   Range = {0.1, 1},
   Increment = 0.1,
   Suffix = "Smooth",
   CurrentValue = 0.5,
   Callback = function(Value) Config.Aimbot.Smoothness = Value end,
})
CombatTab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {10, 500},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 100,
   Callback = function(Value) Config.Aimbot.FOV = Value end,
})
CombatTab:CreateToggle({
   Name = "Show Aimbot FOV",
   CurrentValue = true,
   Callback = function(Value) Config.Aimbot.ShowFOV = Value end,
})

CombatTab:CreateSection("Silent Aim Settings")
CombatTab:CreateToggle({
   Name = "Enable Silent Aim",
   CurrentValue = false,
   Callback = function(Value) Config.SilentAim.Enabled = Value end,
})
CombatTab:CreateSlider({
   Name = "Silent Aim FOV",
   Range = {10, 500},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 100,
   Callback = function(Value) Config.SilentAim.FOV = Value end,
})
CombatTab:CreateToggle({
   Name = "Show Silent Aim FOV",
   CurrentValue = true,
   Callback = function(Value) Config.SilentAim.ShowFOV = Value end,
})

-- Visuals UI
VisualsTab:CreateSection("ESP Settings")
VisualsTab:CreateToggle({
   Name = "ESP Box",
   CurrentValue = false,
   Callback = function(Value) Config.ESP.Box = Value end,
})
VisualsTab:CreateToggle({
   Name = "ESP Skeleton",
   CurrentValue = false,
   Callback = function(Value) Config.ESP.Skeleton = Value end,
})
VisualsTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Callback = function(Value) Config.ESP.TeamCheck = Value end,
})

-- Skins UI
SkinsTab:CreateSection("Skin Unlocker")

local Knives = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife"}
SkinsTab:CreateDropdown({
   Name = "Select Knife",
   Options = Knives,
   CurrentOption = "Butterfly Knife",
   Callback = function(Option)
       Config.Skins.SelectedKnife = Option
       Rayfield:Notify({Title = "Knife Selected", Content = "Equip your knife to see changes.", Duration = 3})
   end,
})

SkinsTab:CreateButton({
   Name = "Apply Skin Changer",
   Callback = function()
       -- BloxStrike Skin Changer Logic
       local function applySkin()
           local camera = workspace.CurrentCamera
           local RS = game:GetService("ReplicatedStorage")
           
           local function getKnife()
               return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife")
           end

           local currentKnife = getKnife()
           if currentKnife then
               -- Basic skin swap logic: In BloxStrike, we clone the asset from RS
               local template = RS.Assets.Weapons:FindFirstChild(Config.Skins.SelectedKnife)
               local currentKnifeModel = getKnife()
               if template and currentKnifeModel then
                   -- This is a client-side visual modification. It will not affect other players.
                   -- We need to find the actual weapon model in the player's character and change its mesh/texture.
                   -- This is a simplified example. A full implementation would involve more complex asset manipulation.
                   local weaponModel = currentKnifeModel:FindFirstChildOfClass("Model") or currentKnifeModel:FindFirstChildOfClass("Part")
                   if weaponModel then
                       -- Attempt to change the mesh or texture of the weapon model
                       -- This part is highly game-specific and might require deeper reverse engineering.
                       -- For now, we'll just notify the user that it's applied client-side.
                       
                       -- Example: Replace the current knife's mesh with the selected one (highly simplified)
                       local currentKnifeMesh = weaponModel:FindFirstChildOfClass("MeshPart") or weaponModel:FindFirstChildOfClass("Part")
                       local newKnifeMesh = template:FindFirstChildOfClass("MeshPart") or template:FindFirstChildOfClass("Part")

                       if currentKnifeMesh and newKnifeMesh then
                           currentKnifeMesh.MeshId = newKnifeMesh.MeshId
                           currentKnifeMesh.TextureID = newKnifeMesh.TextureID
                           Rayfield:Notify({Title = "Success", Content = "Skin applied client-side! Re-equip to refresh.", Duration = 3})
                       else
                           Rayfield:Notify({Title = "Error", Content = "Could not find mesh parts to apply skin.", Duration = 3})
                       end
                   else
                       Rayfield:Notify({Title = "Error", Content = "Could not find weapon model to apply skin.", Duration = 3})
                   end
               else
                   Rayfield:Notify({Title = "Error", Content = "Selected knife or current knife not found.", Duration = 3})
               end
           end
       end
       applySkin()
   end,
})

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
    if Config.Aimbot.Enabled then
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

    -- Update FOV Circles
    AimbotFOV.Visible = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled
    AimbotFOV.Radius = Config.Aimbot.FOV
    AimbotFOV.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    SilentAimFOV.Visible = Config.SilentAim.ShowFOV and Config.SilentAim.Enabled
    SilentAimFOV.Radius = Config.SilentAim.FOV
    SilentAimFOV.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Silent Aim Logic (Hooking Metatable)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Config.SilentAim.Enabled and method == "FireServer" and (self.Name == "ShootEvent" or self.Name == "Fire") then -- Common shoot event names
        local target = GetClosestPlayer(Config.SilentAim.FOV)
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Redirect bullet to head with a hit chance
            if math.random(1, 100) <= Config.SilentAim.HitChance then
                args[1] = target.Character.Head.Position
            end
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

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

Rayfield:Notify({
   Title = "Script Loaded",
   Content = "BloxStrike Hub is ready to use!",
   Duration = 5,
   Image = 4483362458,
})
