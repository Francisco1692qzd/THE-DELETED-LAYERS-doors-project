-- [[ OpenDoor.lua - The Winning Formula ]]
local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer

local function Breach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))

    if room and room:FindFirstChild("Door") then
        local door = room.Door
        local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel") or door:FindFirstChildOfClass("BasePart")
        
        if main then
            local oldPos = root.CFrame
            
            -- 1. Snap to door to bypass distance checks
            root.CFrame = main.CFrame
            task.wait() 

            -- 2. Fire everything at once
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

            -- 3. Snap back instantly
            task.wait()
            root.CFrame = oldPos
            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end

pcall(Breach)
