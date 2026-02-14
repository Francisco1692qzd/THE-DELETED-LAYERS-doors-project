-- [[ OpenDoor.lua - The Final Stand ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function GetOpener()
    local p = Players:GetPlayers()
    table.sort(p, function(a, b) return a.UserId < b.UserId end)
    return p[1]
end

local function FinalAttempt()
    -- Only the Lowest UserID runs this
    if LocalPlayer ~= GetOpener() then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local latestRoom = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(latestRoom))

    if room and root then
        local roomEnd = room:FindFirstChild("RoomEnd")
        local door = room:FindFirstChild("Door")
        
        if roomEnd and door then
            local prevCF = root.CFrame
            
            -- 1. SNAP TO THE END
            root.CFrame = roomEnd.CFrame
            if char:GetAttribute("Hiding") then
                char:SetAttribute("Hiding", false)
            end
            
            -- 2. FIRE THE OPENER (Remote + Proximity)
            if door:FindFirstChild("ClientOpen") then
                door.ClientOpen:FireServer()
            end
            
            -- Optional: Force-trigger any prompts at the door just in case
            for _, v in pairs(door:GetDescendants()) do
                if v:IsA("ProximityPrompt") then fireproximityprompt(v) end
            end

            -- 3. THE "SYNC" WAIT
            -- We wait just a tiny bit longer (0.1s) to make sure the server 
            -- sees us at RoomEnd before we teleport back.
            task.wait(0.07)
            char:SetAttribute("Hiding", true)
            
            -- 4. SNAP BACK
            root.CFrame = prevCF
            print("Door opened by Lowest ID: " .. LocalPlayer.Name)
        end
    end
end

-- Wrap in a function so you can call it from your Entity Script
task.spawn(function()
    local success, err = pcall(FinalAttempt)
    if not success then warn("Final Attempt Failed: " .. err) end
end)
