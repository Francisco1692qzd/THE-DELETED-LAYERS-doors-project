-- [[ OpenDoor.lua - Seamless Auto-Progress FIXED ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function SeamlessBreach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- [1. THE HIDING WATCHER]
    if char:GetAttribute("Hiding") == true then
        -- Wait for player to exit hiding
        repeat task.wait(0.1) until char:GetAttribute("Hiding") ~= true
        -- Give the game a split second to finish the "exit" animation
        task.wait(0.1) 
    end

    -- [2. TARGETING]
    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))

    if room and room:FindFirstChild("Door") then
        local door = room.Door
        local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

        -- [3. THE BRUTE FORCE FIX]
        -- We loop the trigger until 'CanCollide' is false (meaning the door is open)
        if main and main.CanCollide == true then
            local oldPos = root.CFrame
            local attempts = 0
            
            -- We try up to 30 times (about 3 seconds total)
            repeat
                attempts = attempts + 1
                
                -- We snap slightly closer (5 studs instead of 25) to ensure we hit the hitbox
                root.CFrame = main.CFrame * CFrame.new(0, 5, 0)
                
                -- Fire Remote
                local remote = door:FindFirstChild("ClientOpen")
                if remote then remote:FireServer() end

                -- Fire Interactions
                for _, v in pairs(door:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        fireproximityprompt(v)
                    elseif v:IsA("TouchTransmitter") then
                        firetouchinterest(root, v.Parent, 0)
                        firetouchinterest(root, v.Parent, 1)
                    end
                end

                task.wait(0.1) -- Small delay between retries
            until main.CanCollide == false or attempts > 30

            -- [4. THE INSTANT RETURN]
            root.CFrame = oldPos
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Execute in a new thread
task.spawn(function()
    pcall(SeamlessBreach)
end)
