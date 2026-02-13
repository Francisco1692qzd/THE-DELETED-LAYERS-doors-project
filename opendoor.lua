-- [[ OpenDoor.lua - The Universal Ghost Breach ]]
-- Optimized for: The Deleted Layers Project

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- [1. DESIGNATED BREACHER CHECK]
-- Prevents everyone from teleporting at the exact same time (Anti-Cheat Safety)
local function IsDesignatedBreacher()
    local allPlayers = Players:GetPlayers()
    table.sort(allPlayers, function(a, b) return a.UserId < b.UserId end)
    return allPlayers[1] == Player
end

local function Breach()
    -- Only the "Leader" (lowest UserId) performs the physical teleport/trigger
    if not IsDesignatedBreacher() then 
        return 
    end

    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local latestRoomNum = RS.GameData.LatestRoom.Value
    local roomFolder = workspace.CurrentRooms:FindFirstChild(tostring(latestRoomNum))

    if roomFolder and roomFolder:FindFirstChild("Door") then
        local doorModel = roomFolder.Door
        
        -- Find the best part to teleport to (The actual door or the frame)
        local mainPart = doorModel:FindFirstChild("Door") 
            or doorModel:FindFirstChild("Panel") 
            or doorModel:FindFirstChildOfClass("BasePart")

        if mainPart then
            -- Check if door is already open to save resources
            if mainPart.CanCollide == false then return end

            local originalPos = Root.CFrame

            -- 2. THE GHOST MANEUVER
            Root.CFrame = mainPart.CFrame
            task.wait() -- Minimal delay for server distance check

            -- 3. THE TRIPLE-THREAT TRIGGER (Remote, Prompt, and Touch)
            
            -- Method A: Remote Event
            local remote = doorModel:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            -- Method B & C: Prompts and TouchInterests
            for _, v in pairs(doorModel:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    firetouchinterest(Root, v.Parent, 0) -- Touch
                    firetouchinterest(Root, v.Parent, 1) -- Untouch
                end
            end

            -- 4. THE INSTANT RETURN
            task.wait() -- Smallest possible wait for engine registration
            Root.CFrame = originalPos
            Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Kill momentum
        end
    end
end

-- Execute safely
pcall(Breach)
