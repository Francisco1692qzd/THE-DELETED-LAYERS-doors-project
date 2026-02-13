-- [[ OpenDoor.lua - Zero-Frame Instant Breach ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function InstantBreach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- [1. THE HIDING WATCHER]
    -- Wait silently if they are hiding
    if char:GetAttribute("Hiding") == true then
        repeat task.wait() until char:GetAttribute("Hiding") ~= true
    end

    -- [2. GET DOOR DATA]
    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room or not room:FindFirstChild("Door") then return end

    local door = room.Door
    local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

    if main and main.CanCollide == true then
        -- [3. CAPTURE EXACT PREVIOUS POSITION]
        local lastPos = root.CFrame
        
        -- [4. THE INSTANT BRUTE-FORCE]
        -- We run this in a fast loop without 'wait' to force it in a single engine step
        for i = 1, 5 do 
            -- Snap to door (5 studs up is safer than 25)
            root.CFrame = main.CFrame * CFrame.new(0, 5, 0)
            
            -- Fire every trigger possible
            local remote = door:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            for _, v in pairs(door:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    firetouchinterest(root, v.Parent, 0)
                    firetouchinterest(root, v.Parent, 1)
                end
            end
            
            -- If the door opened, stop immediately to go back
            if main.CanCollide == false then break end
            
            -- No task.wait() here makes it happen in the same physics frame
            runService.Heartbeat:Wait() 
        end

        -- [5. THE FORCED RETURN]
        -- We put you back to exactly where you were before the snap
        root.CFrame = lastPos
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- Execute
task.spawn(function()
    pcall(InstantBreach)
end)
