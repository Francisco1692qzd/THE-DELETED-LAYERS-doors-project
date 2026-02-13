-- [[ OpenDoor.lua - Brute Force Underworld Edition ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function BruteForceBreach()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local latestRoomNum = RS.GameData.LatestRoom.Value
    local roomFolder = workspace.CurrentRooms:FindFirstChild(tostring(latestRoomNum))

    if roomFolder and roomFolder:FindFirstChild("Door") then
        local doorModel = roomFolder.Door
        local mainPart = doorModel:FindFirstChild("Door") or doorModel:FindFirstChild("Panel")
        
        -- Make the "Hidden" part invisible if it exists
        local hiddenPart = doorModel:FindFirstChild("Hidden")
        if hiddenPart and hiddenPart:IsA("BasePart") then
            hiddenPart.Transparency = 1
        end

        if mainPart and mainPart.CanCollide == true then
            local originalPos = Root.CFrame
            local startTime = tick()
            
            -- [ BRUTE FORCE LOOP ]
            -- Keep trying for up to 2 seconds or until CanCollide is false
            repeat
                -- Snap underground (Stay safe from Raycasts)
                Root.CFrame = mainPart.CFrame * CFrame.new(0, -15, 0)
                
                -- Fire Remote
                local remote = doorModel:FindFirstChild("ClientOpen")
                if remote then remote:FireServer() end

                -- Fire Interactions
                for _, v in pairs(doorModel:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        fireproximityprompt(v)
                    elseif v:IsA("TouchTransmitter") then
                        firetouchinterest(Root, v.Parent, 0)
                        firetouchinterest(Root, v.Parent, 1)
                    end
                end
                
                task.wait(0.1) -- Rapid fire interval
            until mainPart.CanCollide == false or (tick() - startTime) > 2

            -- [ RETURN ]
            Root.CFrame = originalPos
            Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

pcall(BruteForceBreach)
