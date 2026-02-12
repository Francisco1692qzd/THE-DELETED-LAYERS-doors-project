-- THE DELETED LAYERS: THE WINDOWS
-- Entidade que espreita através do Skybox (Fix para modelos soltos na Assets)

-- ==========================================
-- 1. CONFIGURAÇÕES
-- ==========================================
local IMAGE_ID = "rbxassetid://13380424908" 
local SOUND_ID = "rbxassetid://9119582193"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local latestRoomObj = ReplicatedStorage.GameData.LatestRoom
local initialRoomValue = latestRoomObj.Value
local CameraShaker = require(ReplicatedStorage:WaitForChild("CameraShaker"))

-- ==========================================
-- 2. BUSCA RESILIENTE POR JANELAS
-- ==========================================
local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(initialRoomValue))
local assets = currentRoom and currentRoom:FindFirstChild("Assets")

if assets then
    local allSkyboxes = {}
    
    -- Função para verificar e adicionar Skyboxes de modelos "Window"
    local function findSkyboxes(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj.Name == "Window" and obj:FindFirstChild("Skybox") then
                table.insert(allSkyboxes, obj.Skybox)
            elseif obj.Name == "Windows" then -- Se houver a pasta, entra nela
                findSkyboxes(obj)
            end
        end
    end

    findSkyboxes(assets)

    -- Chance de spawn (ex: 45%)
    if #allSkyboxes > 0 and math.random(1, 100) <= 45 then
        local targetSkybox = allSkyboxes[math.random(1, #allSkyboxes)]
        
        -- 3. CRIAÇÃO DA ENTIDADE
        local windowFace = Instance.new("Part")
        windowFace.Name = "TheWindows_Entity"
        windowFace.Size = Vector3.new(5, 5, 0.5)
        windowFace.Transparency = 1
        windowFace.CanCollide = false
        windowFace.Anchored = true
        
        local bGui = Instance.new("BillboardGui")
        bGui.Size = UDim2.new(6, 0, 6, 0)
        bGui.AlwaysOnTop = false -- Mantém atrás do vidro
        bGui.LightInfluence = 0
        bGui.Parent = windowFace
        
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Image = IMAGE_ID
        img.ImageTransparency = 0.4
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Parent = bGui

        -- Posicionamento: Usa o CFrame do Skybox com leve offset
        windowFace.CFrame = targetSkybox.CFrame * CFrame.new(0, 0, 1.2)
        windowFace.Parent = workspace

        -- Setup Camera Shaker para o susto sutil
        local cam = workspace.CurrentCamera
        local shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
            cam.CFrame = cam.CFrame * shakeCFrame
        end)
        shaker:Start()

        -- 4. LÓGICA DE SUMIÇO E SUSTO
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local isTriggered = false
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not windowFace or not windowFace.Parent or isTriggered then 
                    connection:Disconnect()
                    return 
                end

                if latestRoomObj.Value ~= initialRoomValue then
                    windowFace:Destroy()
                    return
                end

                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    local dist = (root.Position - windowFace.Position).Magnitude
                    
                    if dist < 12 then -- Distância de ativação
                        isTriggered = true
                        
                        -- Efeitos de Susto
                        local sfx = Instance.new("Sound", windowFace)
                        sfx.SoundId = SOUND_ID
                        sfx.Volume = 1
                        sfx:Play()
                        
                        shaker:ShakeOnce(4, 5, 0.1, 0.8) -- Tremor sutil, mas perceptível

                        -- Fade out rápido (Glitch out)
                        TweenService:Create(img, TweenInfo.new(0.2), {
                            ImageTransparency = 1,
                            ImageColor3 = Color3.new(0,0,0)
                        }):Play()
                        
                        task.wait(0.2)
                        windowFace:Destroy()
                    end
                end
            end)
        end)
    end
end
