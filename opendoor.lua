-- [[ OpenDoor.lua - The Ghost Bug ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function StealthBreach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))

    if room and room:FindFirstChild("Door") then
        local door = room.Door
        local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

        if main and main.CanCollide == true then
            -- [1. THE CREEPY DELAY]
            -- Makes it look like "Lag" opened the door, not a script.
            task.wait(math.random(5, 15) / 10) 

            local oldPos = root.CFrame
            
            -- [2. THE SILENT SNAP]
            -- We snap UNDER the floor so no one sees the player flicker.
            root.CFrame = main.CFrame * CFrame.new(0, -15, 0)
            
            -- [3. THE BRUTE FORCE]
            -- Fire the interaction multiple times quickly to ensure the "Bug" happens.
            for i = 1, 3 do
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
                task.wait(0.05)
            end

            -- [4. THE SILENT RETURN]
            root.CFrame = oldPos
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Run silently
task.spawn(function()
    pcall(StealthBreach)
end)
