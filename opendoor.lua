-- [[ OpenDoor.lua - Raycast-Proof Underworld Edition ]]
-- Snap 15 studs below the floor to block Line-of-Sight kills.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function RaycastProofBreach()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local latestRoomNum = RS.GameData.LatestRoom.Value
    local roomFolder = workspace.CurrentRooms:FindFirstChild(tostring(latestRoomNum))

    if roomFolder and roomFolder:FindFirstChild("Door") then
        local doorModel = roomFolder.Door
        local mainPart = doorModel:FindFirstChild("Door") or doorModel:FindFirstChild("Panel")

        if mainPart and mainPart.CanCollide == true then
            local originalPos = Root.CFrame
            local wasHiding = Character:GetAttribute("Hiding")

            -- 1. PREPARE THE GHOST
            if wasHiding then Character:SetAttribute("Hiding", false) end

            -- 2. UNDERWORLD SNAP (Blocking Raycasts)
            -- We teleport 15 studs BELOW the door. 
            -- Most raycasts start at the entity's height and won't go through the floor.
            Root.CFrame = mainPart.CFrame * CFrame.new(0, -15, 0)
            
            -- We give it a tiny moment to register position
            task.wait(0.02) 

            -- 3. THE TRIGGER (Remote + Search)
            local remote = doorModel:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            for _, v in pairs(doorModel:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    -- ProximityPrompts work through walls/floors if triggered via script
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    -- firetouchinterest doesn't care about distance or raycasts!
                    firetouchinterest(Root, v.Parent, 0)
                    firetouchinterest(Root, v.Parent, 1)
                end
            end

            -- 4. THE INSTANT RETURN
            Root.CFrame = originalPos
            if wasHiding then Character:SetAttribute("Hiding", true) end
            
            Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

pcall(RaycastProofBreach)
