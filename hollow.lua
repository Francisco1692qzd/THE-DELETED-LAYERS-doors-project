-- THE DELETED LAYERS: THE HOLLOW (FINAL AUDIO SEQUENCE)

-- ==========================================
-- 1. FUNÇÕES DE CARREGAMENTO (UTILITÁRIOS)
-- ==========================================
local function GithubModelLoader(url)
    if not (writefile and getcustomasset and request) then return nil end
    local response = request({Url = url, Method = "GET"})
    if response.StatusCode ~= 200 then return nil end
    
    local fileName = "hollow_model_" .. tick() .. ".rbxm"
    writefile(fileName, response.Body)
    local assetId = getcustomasset(fileName)
    
    local success, result = pcall(function()
        return game:GetObjects(assetId)[1]
    end)
    
    return success and result or nil
end

local function ImageLoader(url)
    if not (writefile and getcustomasset and request) then return nil end
    local rawUrl = url:gsub("github.com", "raw.githubusercontent.com"):gsub("/blob/", "/")
    local response = request({Url = rawUrl, Method = "GET"})
    if response.StatusCode ~= 200 then return nil end
    
    local fileName = "hollow_tex_" .. tick() .. ".png"
    writefile(fileName, response.Body)
    return getcustomasset(fileName)
end

-- ==========================================
-- 2. CONFIGURAÇÕES E VARIÁVEIS
-- ==========================================
local RAW_MODEL_URL = "https://raw.githubusercontent.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/main/hollow.rbxm"
local RAW_IMAGE_URL = "https://github.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/blob/main/hollow.png"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local latestRoomObj = ReplicatedStorage.GameData.LatestRoom
local initialRoomValue = latestRoomObj.Value
local CameraShaker = require(ReplicatedStorage:WaitForChild("CameraShaker"))

-- ==========================================
-- 3. LÓGICA DE SPAWN
-- ==========================================
local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(initialRoomValue))

if currentRoom and currentRoom:FindFirstChild("RoomEnd") then
    local entityModel = GithubModelLoader(RAW_MODEL_URL)
    
    if entityModel then
        entityModel.Name = "TheHollow"
        local roomEnd = currentRoom.RoomEnd
        local spawnPos = roomEnd.CFrame * CFrame.new(math.random(-5, 5), 3.5, math.random(5, 15))
        
        if entityModel:IsA("Model") then
            entityModel:SetPrimaryPartCFrame(spawnPos)
        else
            entityModel.CFrame = spawnPos
        end
        
        -- Carregar textura no ParticleEmitter
        local entityFolder = entityModel:FindFirstChild("Entity")
        if entityFolder then
            local particles = entityFolder:FindFirstChildWhichIsA("ParticleEmitter", true)
            if particles then
                local textureAsset = ImageLoader(RAW_IMAGE_URL)
                if textureAsset then particles.Texture = textureAsset end
            end
        end

        for _, p in pairs(entityModel:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = true p.CanCollide = false end
        end
        
        entityModel.Parent = workspace
        entityModel.PrimaryPart.Dis:Stop()
        entityModel.PrimaryPart.Dis.Looped = false

        -- 4. CAMERA SHAKER
        local cam = workspace.CurrentCamera
        local shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
            cam.CFrame = cam.CFrame * shakeCFrame
        end)
        shaker:Start()

        -- 5. LOOP DE COMPORTAMENTO E MONITORAMENTO
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local isBanished = false
            local targetEye = entityModel:FindFirstChild("Eye", true)
            local isShaking = false
            local checkTimer = 0
            
            local connection
            connection = RunService.RenderStepped:Connect(function(dt)
                if not entityModel or not entityModel.Parent or isBanished then 
                    shaker:StopSustained(0)
                    connection:Disconnect()
                    return 
                end

                -- Mudança de Sala
                if latestRoomObj.Value ~= initialRoomValue then
                    isBanished = true
                end

                -- Isqueiro (0.5s)
                checkTimer = checkTimer + dt
                if checkTimer >= 0.5 and not isBanished then
                    checkTimer = 0
                    local char = player.Character
                    local lighter = char and char:FindFirstChild("Lighter")
                    if lighter then
                        local fire = lighter:FindFirstChild("FireParticles", true)
                        if fire and fire.Enabled == true then
                            isBanished = true
                        end
                    end
                end

                -- EXECUÇÃO DO BANIMENTO
                if isBanished then
                    shaker:StopSustained(0.5)
                    
                    -- AÇÃO: Parar todos os sons e luzes/partículas
                    for _, obj in pairs(entityModel:GetDescendants()) do
                        if obj:IsA("Sound") and obj.Name ~= "Dis" then
                            obj:Stop()
                        elseif obj:IsA("Light") or obj:IsA("ParticleEmitter") then
                            obj.Enabled = false
                        end
                    end

                    -- Tween de Fade
                    local mesh = entityModel:FindFirstChild("Mesh") or entityModel:FindFirstChildWhichIsA("BasePart")
                    if mesh then TweenService:Create(mesh, TweenInfo.new(1.5), {Transparency = 1}):Play() end
                    
                    -- AÇÃO: Tocar o som "Dis" e esperar acabar
                    local disSound = entityModel:FindFirstChild("Dis", true)
                    if disSound then
                        disSound:Play()
                        disSound.Looped = false
                        disSound.Ended:Wait()
                    end
                    
                    entityModel:Destroy()
                    return
                end

                -- Tremor de câmera
                if targetEye then
                    local dir = (targetEye.Position - cam.CFrame.Position).Unit
                    if dir:Dot(cam.CFrame.LookVector) > 0.97 then
                        if not isShaking then
                            shaker:Shake(CameraShaker.Presets.Vibration)
                            isShaking = true
                        end
                    else
                        if isShaking then
                            shaker:StopSustained(0.5)
                            isShaking = false
                        end
                    end
                end
            end)
        end)
    end
end
