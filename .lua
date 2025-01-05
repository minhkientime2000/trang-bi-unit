getgenv().unitequip = { "Forcefield Cameraman" }
getgenv().data = {
    ["Auto Buy Limit"] = true,
    ["Amount Limit Potion"] = 100,
    ["Disable Notifications"] = true, -- Thêm tùy chọn để tắt thông báo
}

repeat wait() until game:IsLoaded() and game.ReplicatedStorage and game.ReplicatedStorage:FindFirstChild("MultiboxFramework")
repeat wait() until require(game:GetService("ReplicatedStorage").MultiboxFramework).Loaded
local plr = game.Players.LocalPlayer

local save = require(game:GetService("ReplicatedStorage"):WaitForChild("MultiboxFramework"))

local equippedUnits = {}

local function isUnitEquipped(unitName)
    return equippedUnits[unitName] or false
end

local function moveToRandomPosition(radius)
    local currentPosition = plr.Character.HumanoidRootPart.Position
    local randomX = currentPosition.X + math.random(-radius, radius)
    local randomZ = currentPosition.Z + math.random(-radius, radius)
    local newPosition = Vector3.new(randomX, currentPosition.Y, randomZ)
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
end

local function equipUnits()
    local inventory = save.Inventory.GetAllCopies({ "Troops", "Crates" })
    for _, item in pairs(inventory) do
        local itemConfig = save.Inventory.GetItemConfig(item[1], item[2])
        if table.find(getgenv().unitequip, itemConfig.DisplayName) then
            if not isUnitEquipped(itemConfig.DisplayName) then
                local args = {
                    [1] = {
                        [1] = {
                            [1] = game:GetService("ReplicatedStorage").IdentifiersContainer
                                .RE_3becfe855dbdfda9b2d7daeadbeaf7b7247743142c5b392cc7153259ef97cb50.Value,
                            [2] = item[3]
                        }
                    }
                }
                local success, err = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("NetworkingContainer"):WaitForChild("DataRemote"):FireServer(unpack(args))
                end)
                if success then
                    equippedUnits[itemConfig.DisplayName] = true 
                    print("Successfully equipped unit: " .. itemConfig.DisplayName)
                else
                    warn("Failed to equip unit: " .. tostring(err))
                end
            else
                print("Unit already equipped: " .. itemConfig.DisplayName)
            end
        end
    end
end

local function disableNotifications()
    if getgenv().data["Disable Notifications"] then
        local uiService = game:GetService("StarterGui")
        uiService:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        print("Notifications have been disabled.")
    end
end

local function closeUpdateLog()
    local GuiService = game:GetService('GuiService')
    local VirtualInputManager = game:GetService('VirtualInputManager')

    spawn(function()
        while wait() do
            if game:GetService("Players").LocalPlayer.PlayerGui.Lobby.UpdateLog.Visible then
                GuiService.SelectedObject = game:GetService("Players").LocalPlayer.PlayerGui.Lobby.UpdateLog.LogHolder.Frame
                    .CloseButton
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                task.wait(10)
            end
        end
    end)
end

local function buyAndActivateBoost()
    while wait(1) do
        if getgenv().data["Auto Buy Limit"] and getgenv().data["Amount Limit Potion"] > 0 then
            local gems = plr.leaderstats.Gems.Value

            if gems >= 750 and getgenv().data["Amount Limit Potion"] > 0 then
                local args = {
                    [1] = {
                        [1] = {
                            [1] = game:GetService("ReplicatedStorage").IdentifiersContainer
                                .RE_b9c3ae5aa7d736a2953c6d3d6e2569f97cfc437bfe82296bc47fe7b0a712d94c.Value,
                            [2] = "2xCandyCaneBoost",
                            [3] = "Purchase10"
                        }
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("NetworkingContainer"):WaitForChild("DataRemote"):FireServer(unpack(args))
                getgenv().data["Amount Limit Potion"] = getgenv().data["Amount Limit Potion"] - 10

                local boostArgs = {
                    [1] = {
                        [1] = {
                            [1] = game:GetService("ReplicatedStorage").IdentifiersContainer
                                .RE_391aead9e69a2515ad15d39d4041b29860df1c6d5abe42979f4dbf0b086bec80.Value,
                            [2] = "2xCandyCaneBoost"
                        }
                    }
                }
                for i = 1, 10 do
                    game:GetService("ReplicatedStorage"):WaitForChild("NetworkingContainer"):WaitForChild("DataRemote"):FireServer(unpack(boostArgs))
                end
            elseif gems >= 75 and getgenv().data["Amount Limit Potion"] > 0 then
                local args = {
                    [1] = {
                        [1] = {
                            [1] = game:GetService("ReplicatedStorage").IdentifiersContainer
                                .RE_b9c3ae5aa7d736a2953c6d3d6e2569f97cfc437bfe82296bc47fe7b0a712d94c.Value,
                            [2] = "2xCandyCaneBoost",
                            [3] = "Purchase1"
                        }
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("NetworkingContainer"):WaitForChild("DataRemote"):FireServer(unpack(args))
                getgenv().data["Amount Limit Potion"] = getgenv().data["Amount Limit Potion"] - 1

                local boostArgs = {
                    [1] = {
                        [1] = {
                            [1] = game:GetService("ReplicatedStorage").IdentifiersContainer
                                .RE_391aead9e69a2515ad15d39d4041b29860df1c6d5abe42979f4dbf0b086bec80.Value,
                            [2] = "2xCandyCaneBoost"
                        }
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("NetworkingContainer"):WaitForChild("DataRemote"):FireServer(unpack(boostArgs))
            end
        end
    end
end

local function claimPosts()
    if not plr.PlayerGui.Lobby.PostOffice.Visible then
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(-460.2208557128906, 243.8795623779297, -68.29618835449219)
        wait(5)
    else
        local children = plr.PlayerGui.Lobby.PostOffice.Menus.ReceivePackages.ScrollingFrame:GetChildren()
        for index, v in ipairs(children) do
            if v:IsA("Frame") and v:FindFirstChild("Package") and v.Package:FindFirstChild("From") then
                local packageName = v.Name
                if packageName and #packageName > 0 then
                    local args = {
                        [1] = {
                            [1] = {
                                [1] = game:GetService("ReplicatedStorage").IdentifiersContainer
                                    .RF_59fb8da4c771fdd9e7348c3e113b4939ec60069b536a2ff0e2dd4f9e857a6611_S.Value,
                                [2] = "HonglamxWasHere",
                                [3] = packageName
                            }
                        }
                    }
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").NetworkingContainer.DataRemote:FireServer(unpack(args))
                    end)
                    if success then
                        print("Successfully claimed: " .. packageName)
                    else
                        warn("Failed to claim post: " .. tostring(err))
                    end
                    wait(1)
                else
                    warn("Invalid package name for frame: " .. tostring(v))
                end
            end
        end
    end
end

disableNotifications() -- Gọi hàm tắt thông báo
closeUpdateLog() -- Gọi hàm tự động đóng Update Log

spawn(buyAndActivateBoost)
spawn(function()
    while wait(5) do
        equipUnits()
    end
end)
spawn(function()
    while wait(10) do
        claimPosts()
    end
end)
