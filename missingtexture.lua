-- THE DELETED LAYERS: THE ARCHIVE (LOOT MIMIC)
-- Som: 104205757519095 | Imagem: 1420713128 (Warning)

local IMAGE_ID = "rbxassetid://4310418531" 
local SOUND_ID = "rbxassetid://104205757519095"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local latestRoomObj = ReplicatedStorage.GameData.LatestRoom
local initialRoomValue = latestRoomObj.Value
local CameraShaker = require(ReplicatedStorage:WaitForChild("CameraShaker"))

local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(initialRoomValue))
local assets = currentRoom and currentRoom:FindFirstChild("Assets")

if assets then
    local lootSpots = {}

    -- 1. BUSCA POR LOCAIS DE LOOT
    for _, obj in ipairs(assets:GetDescendants()) do
        if obj.Name == "Table" and obj:IsA("BasePart") then
            table.insert(lootSpots, obj)
        elseif obj.Name == "DrawerContainer" then
            local mainPart = obj:FindFirstChild("Main")
            if mainPart then table.insert(lootSpots, mainPart) end
        end
    end

    -- 2. EXECUÇÃO DO SPAWN (Sem random, controlado externamente)
    if #lootSpots > 0 then
        local targetPart = lootSpots[math.random(1, #lootSpots)]
        
        local archive = Instance.new("Part")
        archive.Name = "TheArchive"
        archive.Size = Vector3.new(0.8, 0.8, 0.8)
        archive.Color = Color3.fromRGB(255, 255, 0) -- Amarelo Neon
        archive.Material = Enum.Material.Neon
        archive.CanCollide = false
        archive.Anchored = false 
        
        local bGui = Instance.new("BillboardGui")
        bGui.Size = UDim2.new(1.5, 0, 1.5, 0)
        bGui.AlwaysOnTop = true
        bGui.Parent = archive
        
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Image = IMAGE_ID
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Parent = bGui

        -- 3. SOLDA (WELD) PARA MOVER COM A GAVETA
        if targetPart.Name == "Main" then
            archive.CFrame = targetPart.CFrame * CFrame.new(0, 0.2, 0)
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = archive
            weld.Part1 = targetPart
            weld.Parent = archive
        else
            archive.Anchored = true
            archive.CFrame = targetPart.CFrame * CFrame.new(0, 1.3, 0)
        end
        
        archive.Parent = workspace

        -- 4. LÓGICA DE INTERAÇÃO
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local isTriggered = false
            
            local cam = workspace.CurrentCamera
            local shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
                cam.CFrame = cam.CFrame * shakeCFrame
            end)
            shaker:Start()

            while archive and archive.Parent and not isTriggered do
                 RunService.Heartbeat:Wait()
                
                if latestRoomObj.Value ~= initialRoomValue then 
                    archive:Destroy() 
                    break 
                end

                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root and (root.Position - archive.Position).Magnitude < 5 then
                    isTriggered = true
                    
                    -- Som de Glitch (ID 104205757519095)
                    local sfx = Instance.new("Sound", archive)
                    sfx.SoundId = SOUND_ID
                    sfx.Volume = 2.5
                    sfx:Play()
                    
                    shaker:ShakeOnce(6, 12, 0.1, 0.6)

                    -- Efeito visual de distorção
                    local cc = Instance.new("ColorCorrectionEffect", Lighting)
                    cc.Contrast = 3
                    cc.Saturation = -1 -- Deixa o mundo preto e branco por um instante

                    archive.Anchored = true
                    if archive:FindFirstChild("WeldConstraint") then archive.WeldConstraint:Destroy() end

                    -- Animação de Deleção (Estica e some)
                    TweenService:Create(archive, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        Size = Vector3.new(0, 10, 0),
                        Transparency = 1
                    }):Play()
                    local infss = TweenInfo.new(0.7)
                    local ofsss = {Brightness = 0}
                    for i, lighterssss in pairs(currentRoom:GetDescendants()) do
                        if lighterssss:IsA("Light") then
                            TweenService:Create(lighterssss, infss, ofsss):Play()
                            if lighterssss.Parent:FindFirstChild("Neon") then
                                lighterssss.Parent.Neon.Material = Enum.Material.Plastic
                            end
                        end
                    end
                    local myeyeshurt = Color3.fromRGB(0,0,0)
                    currentRoom:SetAttribute("Ambient", myeyeshurt)
                    
                    task.delay(0.3, function()
                        cc:Destroy()
                        archive:Destroy()
                    end)
                end
            end
        end)
    end
end
