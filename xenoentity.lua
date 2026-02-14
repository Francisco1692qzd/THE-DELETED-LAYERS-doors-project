local G = getgenv()

-- LOADER ESTÁVEL
G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then return nil end
    local response = request({Url = url, Method = "GET"})
    if response.StatusCode ~= 200 then return nil end
    local fileName = "xeno_logic_fix_" .. tick() .. ".rbxm"
    writefile(fileName, response.Body)
    local assetId = getcustomasset(fileName)
    local success, result = pcall(function() return game:GetObjects(assetId)[1] end)
    return success and result or nil
end

local function SpawnXeno()
    local ambruhspeed = 190 
    local ambruhheight = Vector3.new(0, 3.5, 0)
    local latestRoom = game.ReplicatedStorage.GameData.LatestRoom
    local currentRooms = workspace.CurrentRooms
    local killed = false
    
    local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
    local camera = workspace.CurrentCamera
    local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
        camera.CFrame = camera.CFrame * cf
    end)
    camShake:Start()

    local entity = G.LoadGithubModel("https://github.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/blob/main/xenoentity.rbxm?raw=true")
    if not entity then return end
    entity.Parent = workspace
    local entityPart = entity:FindFirstChild("Xeno") or entity:FindFirstChildWhichIsA("BasePart") or entity.PrimaryPart

    local farSound = entity:FindFirstChild("Far", true)
    local nearSound = entity:FindFirstChild("Near", true)
    if farSound then farSound:Play(); farSound.Looped = true end
    if nearSound then nearSound:Play(); nearSound.Looped = true end

    -- FUNÇÃO DE VISÃO (ESTRUTURA SOLICITADA)
    local function canSeeTarget(target, size)
        if killed == true then return end
        local origin = entityPart.Position
        local direction = (target.HumanoidRootPart.Position - origin).unit * size
        local ray = Ray.new(origin, direction)
        local hit, pos = workspace:FindPartOnRay(ray, entityPart)
        if hit and hit:IsDescendantOf(target) then
            killed = true
            return true
        end
        return false
    end

    -- JUMPSCARE VISUAL AMBUSH
    local function ExecuteJumpscare()
        entityPart.Anchored = true
        if farSound then farSound:Stop() end
        if nearSound then nearSound:Stop() end
        
        game.TweenService:Create(camera, TweenInfo.new(0.05), {FieldOfView = 145}):Play()
        local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
        gui.IgnoreGuiInset = true
        local img = Instance.new("ImageLabel", gui)
        img.Size = UDim2.new(0, 0, 0, 0); img.Position = UDim2.new(0.5, 0, 0.5, 0)
        img.AnchorPoint = Vector2.new(0.5, 0.5); img.Image = "rbxassetid://91249795495927"
        img.BackgroundTransparency = 1; img.ZIndex = 10

        task.spawn(function()
            for i = 1, 80 do
                local scale = 1.5 + math.sin(tick() * 40) * 0.2
                img.Size = UDim2.new(scale, 0, scale, 0)
                img.Rotation = math.random(-8, 8)
                img.ImageColor3 = (i % 2 == 0) and Color3.new(1,1,1) or Color3.new(0.4, 1, 0.4)
                camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(math.random(-2,2)), math.rad(math.random(-2,2)), 0)
                task.wait(0.01)
            end
            game.Players.LocalPlayer.Character.Humanoid.Health = 0
            gui:Destroy()
        end)
    end

    -- MONITORAMENTO HEARTBEAT
    local monitor; monitor = game:GetService("RunService").Heartbeat:Connect(function()
        if not entityPart or not entityPart.Parent or killed then 
            if farSound then farSound:Stop() end
            if nearSound then nearSound:Stop() end
            monitor:Disconnect() 
            return 
        end
        
        local v = game.Players.LocalPlayer
        local char = v.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (entityPart.Position - char.HumanoidRootPart.Position).magnitude
            
            -- Volumes Dinâmicos
            if farSound then farSound.Volume = math.clamp(1 - (dist / 250), 0, 2.5) end
            if nearSound then nearSound.Volume = math.clamp(1 - (dist / 80), 0, 3.5) end

            -- GATILHO DE MORTE (ESTRUTURA SOLICITADA)
            if canSeeTarget(char, 60 - 5.7) and not char:GetAttribute("Hiding") then
                ExecuteJumpscare()
                entityPart.Parent:FindFirstChild("Jumpscare"):Play()
            end
            
            if dist <= 70 then camShake:ShakeOnce(math.clamp(1 - (dist/70), 0, 1) * 15, 20, 0.1, 0.8) end
        end
    end)

    -- MOVIMENTAÇÃO E REBOUNDS (6 VOLTAS)
    for rebound = 1, 6 do
        if killed or not entityPart or not entityPart.Parent then break end
        local isForward = (rebound % 2 ~= 0)
        local startR, endR, stepR = 1, latestRoom.Value, 1
        if not isForward then startR, endR, stepR = latestRoom.Value, 1, -1 end

        for i = startR, endR, stepR do
            if killed or not entityPart or not entityPart.Parent then break end
            local room = currentRooms:FindFirstChild(tostring(i))
            if room then
                -- Coleta de luzes não quebradas
                local roomLights = {}
                for _, v in pairs(room:GetDescendants()) do
                    if v.Name == "LightFixture" and v:GetAttribute("BrokenPermanently") ~= true then 
                        table.insert(roomLights, v) 
                    end
                end

                local nodes = room:FindFirstChild("Nodes")
                if nodes then
                    local nodeChildren = nodes:GetChildren()
                    local startN, endN, stepN = 1, #nodeChildren, 1
                    if not isForward then startN, endN, stepN = #nodeChildren, 1, -1 end

                    for v = startN, endN, stepN do
                        if killed or not entityPart or not entityPart.Parent then break end
                        local node = nodes:FindFirstChild(tostring(v))
                        if node then
                            local moveTween = game.TweenService:Create(entityPart, TweenInfo.new((entityPart.Position - node.Position).magnitude / ambruhspeed, Enum.EasingStyle.Linear), {CFrame = node.CFrame + ambruhheight})
                            moveTween:Play()
                            
                            -- Conexão de quebra de luzes por proximidade durante o movimento
                            local lightConn; lightConn = game:GetService("RunService").Heartbeat:Connect(function()
                                if not entityPart or not entityPart.Parent then lightConn:Disconnect() return end
                                for _, fixture in ipairs(roomLights) do
                                    if fixture:GetAttribute("BrokenPermanently") ~= true and (entityPart.Position - fixture.Position).Magnitude <= 45 then
                                        fixture:SetAttribute("BrokenPermanently", true)
                                        pcall(function()
                                            local s = game.ReplicatedStorage.Sounds.BulbBreak:Clone(); s.Parent = fixture; s:Play()
                                            game.Debris:AddItem(s, 2)
                                            for _, child in pairs(fixture:GetDescendants()) do
                                                if child:IsA("Light") then child.Enabled = false end
                                                if child:IsA("BasePart") and child.Material == Enum.Material.Neon then
                                                    child.Material = Enum.Material.Plastic; child.Color = Color3.fromRGB(30, 30, 30)
                                                end
                                            end
                                        end)
                                    end
                                end
                            end)

                            moveTween.Completed:Wait()
                            lightConn:Disconnect()
                        end
                    end
                end
            end
        end
    end

    -- Limpeza final
    if monitor then monitor:Disconnect() end
    if entity then entity:Destroy() end
end

spawn(SpawnXeno)
