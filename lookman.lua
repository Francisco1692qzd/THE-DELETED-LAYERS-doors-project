local TweenService = game:GetService("TweenService")

local function InternalLoadModel(url)
    local success, response = pcall(function()
        return request({Url = url, Method = "GET"})
    end)
    if not success or response.StatusCode ~= 200 then return nil end
    local fileName = "lookman_temp.rbxm"
    writefile(fileName, response.Body)
    local assetId = getcustomasset(fileName)
    return game:GetObjects(assetId)[1]
end

local function SpawnLookman()
    local damageAmount = 15
    local isActive = true
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    local rawUrl = "https://raw.githubusercontent.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/main/Lookman.rbx.rbxm"
    local model = InternalLoadModel(rawUrl)
    if not model then return end
    
    -- Ensure we have the part
    local mainPart = model:FindFirstChild("Lookman") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    model.Parent = workspace

    local mainSound = mainPart:FindFirstChild("Sound")
    if mainSound then
        mainSound.PlaybackSpeed = 0
        mainSound:Play()
        TweenService:Create(mainSound, TweenInfo.new(2.5), {PlaybackSpeed = 0.7}):Play()
    end

    -- Position
    local latestRoomVal = game.ReplicatedStorage.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(latestRoomVal))
    if room and room:FindFirstChild("Nodes") then
        local nodes = room.Nodes:GetChildren()
        model:SetPrimaryPartCFrame(nodes[math.floor(#nodes/2)].CFrame * CFrame.new(0, 6, 0))
    end

    -- 🔍 NEW MONITORING LOGIC
    task.spawn(function()
        while isActive and hum.Health > 0 do
            local camera = workspace.CurrentCamera
            -- Get position on screen
            local screenPos, onScreen = camera:WorldToViewportPoint(mainPart.Position)
            
            if onScreen then
                -- 1. Check Occlusion (Is there a wall?)
                local rayParams = RaycastParams.new()
                -- EXCLUDE player and the monster so the ray ONLY hits walls
                rayParams.FilterDescendantsInstances = {char, model, workspace.CurrentCamera}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local origin = camera.CFrame.Position
                local dest = mainPart.Position
                local ray = workspace:Raycast(origin, (dest - origin).Unit * (dest - origin).Magnitude, rayParams)
                
                -- 2. Check Gaze Angle (Dot Product)
                local camDir = camera.CFrame.LookVector
                local entityDir = (dest - origin).Unit
                local dot = camDir:Dot(entityDir)

                -- If nothing is blocking (ray == nil) AND looking at it (dot > 0.5)
                if not ray and dot > 0.5 then 
                    hum.Health = math.max(0, hum.Health - damageAmount)
                    
                    -- Visual Feedback
                    local f = Instance.new("Frame", player.PlayerGui:FindFirstChild("DrainVignette") or Instance.new("ScreenGui", player.PlayerGui))
                    f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.new(1,0,0); f.BackgroundTransparency = 0.6
                    game.Debris:AddItem(f, 0.1)
                    
                    if hum.Health <= 0 then
                        isActive = false
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/refs/heads/main/GuidingLightCustom.lua"))()
                        task.wait(0.5)
                        if _G.ShowCustomDeathHint then
                            _G.ShowCustomDeathHint({
                                Color = Color3.fromRGB(255, 0, 0),
                                Tips = {"You stared into the void.", "Lookman demands your silence and your lowered gaze.", "Do not look up in this room.", "He cannot hurt what you do not see."}
                            })
                        end
                    end
                end
            end
            task.wait(0.2) -- Faster detection
        end
    end)

    -- Cleanup
    local connection; connection = game.ReplicatedStorage.GameData.LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
        isActive = false
        connection:Disconnect()
        if mainSound then
            TweenService:Create(mainSound, TweenInfo.new(1.5), {PlaybackSpeed = 0}):Play()
        end
        task.wait(1.5)
        model:Destroy()
    end)
end

spawn(SpawnLookman)
