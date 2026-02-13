-- [[ OpenDoor.lua - Backside Shield Breach ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function SafeInstantBreach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- [1. WAIT FOR EXIT]
    if char:GetAttribute("Hiding") == true then
        repeat task.wait() until char:GetAttribute("Hiding") ~= true
    end

    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room or not room:FindFirstChild("Door") then return end

    local door = room.Door
    local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

    if main and main.CanCollide == true then
        -- [2. CAPTURE EXACT POSITION]
        local lastPos = root.CFrame
        
        -- [3. THE SAFE SNAP]
        -- Instead of being IN the door, we stay 4 studs back (the safe side)
        -- This keeps the door between us and the Entity.
        local safeCFrame = main.CFrame * CFrame.new(0, 0, 4) 

        for i = 1, 5 do 
            root.CFrame = safeCFrame
            
            -- Trigger interaction
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
            
            if main.CanCollide == false then break end
            RunService.Heartbeat:Wait() 
        end

        -- [4. THE INSTANT RETURN]
        root.CFrame = lastPos
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

task.spawn(function()
    pcall(SafeInstantBreach)
end)
