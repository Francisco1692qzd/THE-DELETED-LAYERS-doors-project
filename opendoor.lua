-- [[ OpenDoor.lua - True Ghost Edition ]]
-- Keeps Hiding attribute TRUE so Raycasts/Entities ignore you entirely.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function TrueGhostBreach()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local latestRoomNum = RS.GameData.LatestRoom.Value
    local roomFolder = workspace.CurrentRooms:FindFirstChild(tostring(latestRoomNum))

    if roomFolder and roomFolder:FindFirstChild("Door") then
        local doorModel = roomFolder.Door
        local mainPart = doorModel:FindFirstChild("Door") or doorModel:FindFirstChild("Panel")

        if mainPart and mainPart.CanCollide == true then
            -- 1. SAVE POSITION ONLY
            local originalPos = Root.CFrame
            
            -- WE DO NOT TOUCH THE HIDING ATTRIBUTE. 
            -- If you are hiding, you stay hiding. 
            -- If you are walking, you stay walking.

            -- 2. THE UNDERWORLD SNAP
            -- Snapping below the floor is an extra layer of "Raycast" protection
            Root.CFrame = mainPart.CFrame * CFrame.new(0, -15, 0)
            
            task.wait(0.02) -- Minimal sync

            -- 3. FORCE INTERACTION
            -- FireServer and firetouchinterest do NOT check if you are hiding.
            local remote = doorModel:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            for _, v in pairs(doorModel:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    -- Script-side triggering usually bypasses the "Hiding" check
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    firetouchinterest(Root, v.Parent, 0)
                    firetouchinterest(Root, v.Parent, 1)
                end
            end

            -- 4. THE RETURN
            Root.CFrame = originalPos
            Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- If this is called while hiding, you stay safe!
pcall(TrueGhostBreach)
