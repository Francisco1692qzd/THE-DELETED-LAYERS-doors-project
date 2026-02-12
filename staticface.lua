-- THE DELETED LAYERS: STATIC FACE (ULTIMATE EDITION)
-- Configurações: BillboardGui + Push + CameraImpact + Random Spawn

-- ==========================================
-- 1. CONFIGURAÇÕES E ASSETS
-- ==========================================
local IMAGE_ID = "rbxassetid://13380424908" 
local SOUND_ID = "rbxassetid://9119582193"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local latestRoomObj = ReplicatedStorage.GameData.LatestRoom
local initialRoomValue = latestRoomObj.Value
local CameraShaker = require(ReplicatedStorage:WaitForChild("CameraShaker"))

-- ==========================================
-- 2. SELEÇÃO DE LOCALIZAÇÃO (MOEDA ALEATÓRIA)
-- ==========================================
local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(initialRoomValue))

if currentRoom then
    -- Criando a âncora invisível
    local anchor = Instance.new("Part")
    anchor.Name = "StaticFace_Anchor"
    anchor.Size = Vector3.new(2, 2, 2)
    anchor.Transparency = 1
    anchor.Anchored = true
    anchor.CanCollide = false
    
    -- Lógica Aleatória: RoomStart ou RoomEnd?
    local startPart = currentRoom:FindFirstChild("RoomStart")
    local endPart = currentRoom:FindFirstChild("RoomEnd")
    local possibleAnchors = {}
    
    if startPart then table.insert(possibleAnchors, startPart) end
    if endPart then table.insert(possibleAnchors, endPart) end
    
    -- Escolhe uma das partes da sala para ser a base do spawn
    local chosenPoint = possibleAnchors[math.random(1, #possibleAnchors)]

    -- ==========================================
    -- 3. SETUP VISUAL (BILLBOARD GUI)
    -- ==========================================
    local bGui = Instance.new("BillboardGui")
    bGui.Name = "FaceGui"
    bGui.Size = UDim2.new(10, 0, 10, 0)
    bGui.AlwaysOnTop = true -- Ignora paredes para garantir visibilidade
    bGui.LightInfluence = 0 -- Brilha no escuro
    bGui.Parent = anchor
    
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image = IMAGE_ID
    img.Size = UDim2.new(1, 0, 1, 0)
    img.ImageTransparency = 0 
    img.Parent = bGui

    local sfx = Instance.new("Sound", anchor)
    sfx.SoundId = SOUND_ID
    sfx.Volume = 2

    -- Posicionamento final baseado no ponto escolhido
    if chosenPoint then
        local side = (math.random(1, 2) == 1 and 1 or -1)
        -- Afasta 11.8 para os lados e varia a profundidade entre 5 e 20 studs
        anchor.CFrame = chosenPoint.CFrame * CFrame.new(11.8 * side, 6.5, -math.random(5, 20))
    end
    
    anchor.Parent = workspace

    -- ==========================================
    -- 4. CAMERA SHAKER & COMPORTAMENTO
    -- ==========================================
    local cam = workspace.CurrentCamera
    local shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
        cam.CFrame = cam.CFrame * shakeCFrame
    end)
    shaker:Start()

    task.spawn(function()
        local player = game.Players.LocalPlayer
        local isTriggered = false
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not anchor or not anchor.Parent or isTriggered then 
                connection:Disconnect()
                return 
            end

            -- Limpeza se o jogador avançar de sala
            if latestRoomObj.Value ~= initialRoomValue then
                anchor:Destroy()
                return
            end

            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                local dist = (root.Position - anchor.Position).Magnitude
                
                -- GATILHO DE SUSTO (Distância de 8 studs)
                if dist < 8 then 
                    isTriggered = true
                    
                    -- AÇÃO 1: Som e Impacto Seco na Câmera
                    sfx:Play()
                    shaker:ShakeOnce(12, 15, 0.1, 1.2)

                    -- AÇÃO 2: O Empurrão (Push)
                    local pushDir = (root.Position - anchor.Position).Unit
                    root.AssemblyLinearVelocity = (pushDir * 65) + Vector3.new(0, 20, 0)

                    -- AÇÃO 3: Glitch Visual (Correção de Tint e Contrast)
                    local colorCorr = Instance.new("ColorCorrectionEffect", Lighting)
                    colorCorr.Contrast = 8
                    colorCorr.Brightness = -0.3
                    colorCorr.TintColor = Color3.fromRGB(255, 150, 150) -- Tom avermelhado de tensão

                    -- AÇÃO 4: Fade Out com Expansão (Efeito de "avançar" no jogador)
                    TweenService:Create(img, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        ImageTransparency = 1,
                        Size = UDim2.new(16, 0, 16, 0) -- Ela cresce enquanto desaparece
                    }):Play()
                    
                    -- AÇÃO 5: Limpeza do efeito e da entidade
                    task.delay(0.3, function()
                        local t = TweenService:Create(colorCorr, TweenInfo.new(0.5), {
                            Contrast = 0, 
                            Brightness = 0,
                            TintColor = Color3.new(1, 1, 1)
                        })
                        t:Play()
                        t.Completed:Wait()
                        colorCorr:Destroy()
                        anchor:Destroy()
                    end)
                end
            end
        end)
    end)
end
