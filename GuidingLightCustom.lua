local G = getgenv()

G.LoadGithubAudio = function(url)
    if not (writefile and getcustomasset and request) then return nil end
    local response = request({Url = url .. "?t=" .. tick(), Method = "GET"})
    if response.StatusCode ~= 200 then return nil end
    local fileName = "death_music.mp3"
    writefile(fileName, response.Body)
    return getcustomasset(fileName)
end

_G.ShowCustomDeathHint = function(data)
    local player = game.Players.LocalPlayer
    local tips = data.Tips or {}
    local color = data.Color or Color3.fromRGB(0, 255, 255)
    
    local sg = Instance.new("ScreenGui", player.PlayerGui)
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 10000

    local audioId = G.LoadGithubAudio("https://raw.githubusercontent.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/main/Iron%20Veins%20-%20Phobia%20Echoes%20-%20Sonauto.mp3")

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 1

    local textLabel = Instance.new("TextLabel", bg)
    textLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
    textLabel.Position = UDim2.new(0.1, 0, 0.45, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SpecialElite
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.TextTransparency = 1

    local music = Instance.new("Sound", workspace)
    music.SoundId = audioId
    music.Volume = 1.3
    music:Play()

    task.spawn(function()
        local TS = game:GetService("TweenService")
        TS:Create(bg, TweenInfo.new(1.2), {BackgroundTransparency = 0.15}):Play()
        task.wait(1.2)

        for _, content in ipairs(tips) do
            textLabel.Text = tostring(content)
            textLabel.Position = UDim2.new(0.1, 0, 0.45, 0)
            textLabel.TextTransparency = 1

            -- CORREÇÃO DEFINITIVA: Style e Direction separados
            TS:Create(textLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.1, 0, 0.4, 0),
                TextTransparency = 0
            }):Play()
            
            task.wait(2.5 + (#textLabel.Text * 0.04)) 
            
            TS:Create(textLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.1, 0, 0.35, 0),
                TextTransparency = 1
            }):Play()
            
            task.wait(1.5)
        end

        TS:Create(bg, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
        task.wait(1.5)
        music:Destroy()
        sg:Destroy()
    end)
end
