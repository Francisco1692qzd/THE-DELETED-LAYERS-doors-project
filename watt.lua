local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

-- 1. INTERNAL LOADER for .rbxm
local function LoadWatt(url)
    local success, response = pcall(function()
        return request({Url = url, Method = "GET"})
    end)
    if not success or response.StatusCode ~= 200 then return nil end
    local fileName = "watt_temp.rbxm"
    writefile(fileName, response.Body)
    local assetId = getcustomasset(fileName)
    return game:GetObjects(assetId)[1]
end

local function SpawnWatt()
    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room then return end

    -- 2. LOAD YOUR GITHUB MODEL
    local rawUrl = "https://raw.githubusercontent.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/main/watt.rbxm"
    local wattModel = LoadWatt(rawUrl)
    if not wattModel then return end
    
    local mainPart = wattModel:FindFirstChild("Main") or wattModel.PrimaryPart or wattModel:FindFirstChildWhichIsA("BasePart")
    wattModel.Parent = workspace

    -- 3. FIND LIGHTS
    local lights = {}
    for _, v in pairs(room:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name == "Neon" or v.Material == Enum.Material.Neon) then
            table.insert(lights, v)
        end
    end

    if #lights < 2 then wattModel:Destroy() return end

    -- 4. STALKING LOGIC
    task.spawn(function()
        for i = 1, #lights do
            local targetLight = lights[i]
            local isLast = (i == #lights)
            
            -- Position Watt to the side of the light
            local targetCF = targetLight.CFrame * CFrame.new(3, -1, 0)
            TweenService:Create(mainPart, TweenInfo.new(0.5), {CFrame = targetCF}):Play()
            
            task.wait(math.random(2, 4)) -- Suspense

            if not isLast then
                -- BREAK LIGHT
                local sound = RS.Sounds.BulbBreak:Clone()
                sound.Parent = targetLight
                sound:Play()
                game.Debris:AddItem(sound, 3)

                targetLight.Material = Enum.Material.Glass
                targetLight.Color = Color3.fromRGB(20, 20, 20)

                for _, l in pairs(targetLight:GetDescendants()) do
                    if l:IsA("Light") then l.Enabled = false end
                end
            else
                -- AT THE LAST LIGHT: Play a "Staring" animation or glow
                local highlight = Instance.new("Highlight", wattModel)
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.FillTransparency = 0.5
            end
        end
    end)

    -- 5. CLEANUP
    local conn; conn = RS.GameData.LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
        conn:Disconnect()
        wattModel:Destroy()
    end)
end

spawn(SpawnWatt)
