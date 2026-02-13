local function ApplyDrain()
    local drainWaitTime = 4 -- Seconds before damage
    local damageAmount = 7 -- HP per tick
    local isActive = true
    
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    -- CREATE FRAME VIGNETTE
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "DrainVignette"
    gui.IgnoreGuiInset = true -- Fills the whole screen including top bar

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Deep Red
    frame.BorderSizePixel = 0

    -- Add a UIStroke or UIGradient to make it look like a vignette
    local gradient = Instance.new("UIGradient", frame)
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4), -- Darker at edges
        NumberSequenceKeypoint.new(0.5, 1), -- Clear in middle
        NumberSequenceKeypoint.new(1, 0.4)  -- Darker at edges
    })

    -- DEATH HANDLER
    local function TriggerGuidingLight()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/refs/heads/main/GuidingLightCustom.lua"))()
        end)
        
        task.wait(0.5)

        if _G.ShowCustomDeathHint then
            _G.ShowCustomDeathHint({
                Color = Color3.fromRGB(160, 32, 240),
                Tips = {
                    "You stayed hidden for too long...",
                    "Drain infects the closets in this area.",
                    "Do not wait for death; leave before your air runs out.",
                    "The red screen is a warning—get out of the closet!"
                }
            })
        end
    end

    task.spawn(function()
        while isActive do
            if char:GetAttribute("Hiding") == true then
                local timeHidden = 0
                
                while char:GetAttribute("Hiding") == true and isActive do
                    task.wait(1)
                    timeHidden = timeHidden + 1
                    
                    if timeHidden > drainWaitTime then
                        hum.Health = math.max(0, hum.Health - damageAmount)
                        
                        -- PULSE EFFECT
                        game.TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
                        task.wait(0.3)
                        game.TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()

                        if hum.Health <= 0 then
                            isActive = false
                            TriggerGuidingLight()
                            break
                        end
                    end
                end
                -- Fade out when safe
                game.TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            end
            task.wait(0.1)
        end
        gui:Destroy()
    end)

    -- Cleanup on room change
    local latestRoom = game.ReplicatedStorage.GameData.LatestRoom
    local startRoom = latestRoom.Value
    local connection; connection = latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
        if latestRoom.Value > startRoom then
            isActive = false
            connection:Disconnect()
        end
    end)
end

spawn(ApplyDrain)
