-- [[ deadhub UI Library — Red-Black-Gray Wide Horizontal Edition ]] --
-- Все функции и переменные локальны для обхода getgc()
-- Названия объектов замаскированы под легальные элементы Trident (InventoryFrame, SettingsButton)

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Селектор родительского контейнера (gethui / protect_gui / CoreGui / PlayerGui)
local ParentContainer = nil
do
    local gethui = gethui
    if gethui then
        local success, res = pcall(gethui)
        if success and res then ParentContainer = res end
    end
    if not ParentContainer then
        local syn = syn
        if syn and syn.protect_gui then
            local success = pcall(function()
                local dummy = Instance.new("Folder")
                syn.protect_gui(dummy)
                dummy.Parent = CoreGui
                ParentContainer = dummy
            end)
            if not success then ParentContainer = CoreGui end
        else
            local success, core = pcall(function() return CoreGui end)
            if success and core then
                ParentContainer = core
            else
                ParentContainer = LocalPlayer:WaitForChild("PlayerGui")
            end
        end
    end
end

-- Цветовая схема: Красно-Черно-Серый акцент
local Theme = {
    Background = Color3.fromRGB(8, 8, 8),       -- Глубокий черный
    Header = Color3.fromRGB(14, 14, 14),        -- Темно-серый
    Card = Color3.fromRGB(12, 12, 12),          -- Черные карточки
    StrokeOuter = Color3.fromRGB(229, 9, 20),   -- Красная внешняя обводка
    StrokeInner = Color3.fromRGB(25, 25, 25),   -- Темно-серая внутренняя обводка
    Accent = Color3.fromRGB(229, 9, 20),        -- Яркий красный
    AccentDim = Color3.fromRGB(140, 5, 10),     -- Темно-красный
    Text = Color3.fromRGB(255, 255, 255),       -- Белый
    TextDim = Color3.fromRGB(140, 140, 140)     -- Серый
}

-- Вспомогательная функция анимаций
local function tween(object, info, properties)
    local anim = TweenService:Create(object, TweenInfo.new(info), properties)
    anim:Play()
    return anim
end

-- Вспомогательная функция перетаскивания (Draggable)
local function makeDraggable(frame, dragAnchor)
    local dragging, dragInput, dragStart, startPos
    dragAnchor.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragAnchor.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local Library = {}

function Library:Init(config)
    config = config or {}
    local isHeadless = config.Headless or false
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    if isHeadless then
        -- ==========================================
        -- РЕЖИМ STEALTH (БЕЗ GUI)
        -- ==========================================
        local HeadlessHandler = {
            IsHeadless = true,
            Bindings = {},
            States = {}
        }
        
        local function toggleFeature(name, callback)
            HeadlessHandler.States[name] = not HeadlessHandler.States[name]
            callback(HeadlessHandler.States[name])
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "deadhub",
                    Text = name .. ": " .. (HeadlessHandler.States[name] and "ON" or "OFF"),
                    Duration = 2
                })
            end)
        end
        
        local DummySection = {}
        function DummySection:CreateToggle(name, default, callback, keybind)
            HeadlessHandler.States[name] = default
            if keybind then
                HeadlessHandler.Bindings[keybind] = function() toggleFeature(name, callback) end
            end
            task.spawn(function() callback(default) end)
        end
        function DummySection:CreateButton(name, callback, keybind)
            if keybind then
                HeadlessHandler.Bindings[keybind] = function()
                    callback()
                    pcall(function()
                        StarterGui:SetCore("SendNotification", { Title = "deadhub", Text = "Executed " .. name, Duration = 1.5 })
                    end)
                end
            end
        end
        function DummySection:CreateSlider(name, min, max, default, callback)
            task.spawn(function() callback(default) end)
        end
        function DummySection:CreateTextbox(name, placeholder, callback)
            -- Заглушка
        end
        function DummySection:CreateDropdown(name, list, default, callback)
            task.spawn(function() callback(default) end)
        end
        function DummySection:CreateKeybind(name, default, callback)
            if default then HeadlessHandler.Bindings[default] = callback end
        end
        
        local DummyTab = {}
        function DummyTab:CreateSection(name) return DummySection end
        
        local DummyWindow = { IsHeadless = true }
        function DummyWindow:CreateTab(name) return DummyTab end
        function DummyWindow:Notify(title, text, duration)
            pcall(function()
                StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = duration or 3 })
            end)
        end
        
        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            local handler = HeadlessHandler.Bindings[input.KeyCode]
            if handler then handler() end
        end)
        
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "deadhub stealth",
                Text = "Bypassed GUI. Use registered hotkeys.",
                Duration = 4
            })
        end)
        
        return DummyWindow
    else
        -- ==========================================
        -- ШИРОКИЙ GUI РЕЖИМ (КРАСНО-ЧЕРНО-СЕРЫЙ С ВЕРХНИМ МЕНЮ)
        -- ==========================================
        local UI = {
            CurrentTab = nil,
            Visible = true,
            Tabs = {}
        }
        
        if ParentContainer:FindFirstChild("RobloxNetworkUI") then
            ParentContainer.RobloxNetworkUI:Destroy()
        end
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "RobloxNetworkUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.Parent = ParentContainer
        
        -- Главное окно увеличено до 780x500
        local InventoryFrame = Instance.new("Frame")
        InventoryFrame.Name = "InventoryFrame"
        InventoryFrame.Size = UDim2.new(0, 780, 0, 500)
        InventoryFrame.Position = UDim2.new(0.5, -390, 0.5, -250)
        InventoryFrame.BackgroundColor3 = Theme.Background
        InventoryFrame.BorderSizePixel = 0
        InventoryFrame.Active = true
        InventoryFrame.Parent = ScreenGui
        
        local InventoryFrameCorner = Instance.new("UICorner")
        InventoryFrameCorner.CornerRadius = UDim.new(0, 6)
        InventoryFrameCorner.Parent = InventoryFrame
        
        -- Красная внешняя обводка
        local InventoryFrameStroke = Instance.new("UIStroke")
        InventoryFrameStroke.Color = Theme.StrokeOuter
        InventoryFrameStroke.Thickness = 1.8
        InventoryFrameStroke.Parent = InventoryFrame
        
        -- Внутренний контейнер для эффекта двойной обводки
        local InnerContainer = Instance.new("Frame")
        InnerContainer.Name = "InnerContainer"
        InnerContainer.Size = UDim2.new(1, -6, 1, -6)
        InnerContainer.Position = UDim2.new(0, 3, 0, 3)
        InnerContainer.BackgroundColor3 = Theme.Background
        InnerContainer.BorderSizePixel = 0
        InnerContainer.Parent = InventoryFrame
        
        local InnerCorner = Instance.new("UICorner")
        InnerCorner.CornerRadius = UDim.new(0, 4)
        InnerCorner.Parent = InnerContainer
        
        local InnerStroke = Instance.new("UIStroke")
        InnerStroke.Color = Theme.StrokeInner
        InnerStroke.Thickness = 1.2
        InnerStroke.Parent = InnerContainer
        
        -- Верхний хедер
        local HeaderFrame = Instance.new("Frame")
        HeaderFrame.Name = "HeaderFrame"
        HeaderFrame.Size = UDim2.new(1, 0, 0, 82)
        HeaderFrame.BackgroundColor3 = Theme.Header
        HeaderFrame.BorderSizePixel = 0
        HeaderFrame.Parent = InnerContainer
        
        local HeaderFrameCorner = Instance.new("UICorner")
        HeaderFrameCorner.CornerRadius = UDim.new(0, 4)
        HeaderFrameCorner.Parent = HeaderFrame
        
        -- Скрытие нижних закруглений у хедера
        local HeaderFix = Instance.new("Frame")
        HeaderFix.Name = "HeaderFix"
        HeaderFix.Size = UDim2.new(1, 0, 0, 10)
        HeaderFix.Position = UDim2.new(0, 0, 1, -10)
        HeaderFix.BackgroundColor3 = Theme.Header
        HeaderFix.BorderSizePixel = 0
        HeaderFix.Parent = HeaderFrame
        
        -- Название по центру
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(0, 300, 0, 30)
        TitleLabel.Position = UDim2.new(0.5, -150, 0, 8)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = "deadhub"
        TitleLabel.TextColor3 = Theme.Accent
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 20
        TitleLabel.TextAlignment = Enum.TextAlignment.Center
        TitleLabel.Parent = HeaderFrame
        
        -- Кнопка закрытия справа вверху
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 24, 0, 24)
        CloseButton.Position = UDim2.new(1, -30, 0, 8)
        CloseButton.BackgroundTransparency = 1
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Theme.TextDim
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.TextSize = 22
        CloseButton.Parent = HeaderFrame
        
        CloseButton.MouseEnter:Connect(function() tween(CloseButton, 0.15, {TextColor3 = Theme.Accent}) end)
        CloseButton.MouseLeave:Connect(function() tween(CloseButton, 0.15, {TextColor3 = Theme.TextDim}) end)
        CloseButton.MouseButton1Click:Connect(function()
            UI.Visible = false
            InventoryFrame.Visible = false
        end)
        
        makeDraggable(InventoryFrame, HeaderFrame)
        
        -- Горизонтальный контейнер вкладок снизу под названием
        local TabButtonContainer = Instance.new("ScrollingFrame")
        TabButtonContainer.Name = "TabButtonContainer"
        TabButtonContainer.Size = UDim2.new(1, -30, 0, 32)
        TabButtonContainer.Position = UDim2.new(0, 15, 0, 42)
        TabButtonContainer.BackgroundTransparency = 1
        TabButtonContainer.BorderSizePixel = 0
        TabButtonContainer.ScrollBarThickness = 0
        TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabButtonContainer.Parent = HeaderFrame
        
        local TabListLayout = Instance.new("UIListLayout")
        TabListLayout.Parent = TabButtonContainer
        TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabListLayout.FillDirection = Enum.FillDirection.Horizontal
        TabListLayout.Padding = UDim.new(0, 12)
        
        -- Полоска акцента на границе хедера
        local AccentLine = Instance.new("Frame")
        AccentLine.Name = "AccentLine"
        AccentLine.Size = UDim2.new(1, 0, 0, 1)
        AccentLine.Position = UDim2.new(0, 0, 1, 0)
        AccentLine.BackgroundColor3 = Theme.StrokeInner
        AccentLine.BorderSizePixel = 0
        AccentLine.Parent = HeaderFrame
        
        -- Контейнер для страниц
        local PageList = Instance.new("Frame")
        PageList.Name = "PageList"
        PageList.Size = UDim2.new(1, -24, 1, -96)
        PageList.Position = UDim2.new(0, 12, 0, 90)
        PageList.BackgroundTransparency = 1
        PageList.Parent = InnerContainer
        
        -- Сворачивание
        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == toggleKey then
                UI.Visible = not UI.Visible
                InventoryFrame.Visible = UI.Visible
            end
        end)
        
        -- Уведомления
        function UI:Notify(title, text, duration)
            duration = duration or 3
            local Toast = Instance.new("Frame")
            Toast.Name = "ToastFrame"
            Toast.Size = UDim2.new(0, 240, 0, 55)
            Toast.Position = UDim2.new(1, 10, 1, -70)
            Toast.BackgroundColor3 = Theme.Header
            Toast.BorderSizePixel = 0
            Toast.Parent = ScreenGui
            
            local ToastCorner = Instance.new("UICorner")
            ToastCorner.CornerRadius = UDim.new(0, 6)
            ToastCorner.Parent = Toast
            
            local ToastStroke = Instance.new("UIStroke")
            ToastStroke.Color = Theme.StrokeOuter
            ToastStroke.Thickness = 1.2
            ToastStroke.Parent = Toast
            
            local GlowLine = Instance.new("Frame")
            GlowLine.Name = "GlowLine"
            GlowLine.Size = UDim2.new(0, 3, 1, 0)
            GlowLine.BackgroundColor3 = Theme.Accent
            GlowLine.BorderSizePixel = 0
            GlowLine.Parent = Toast
            
            local GlowLineCorner = Instance.new("UICorner")
            GlowLineCorner.CornerRadius = UDim.new(0, 6)
            GlowLineCorner.Parent = GlowLine
            
            local ToastTitle = Instance.new("TextLabel")
            ToastTitle.Name = "Title"
            ToastTitle.Size = UDim2.new(1, -20, 0, 20)
            ToastTitle.Position = UDim2.new(0, 12, 0, 8)
            ToastTitle.BackgroundTransparency = 1
            ToastTitle.Text = title
            ToastTitle.TextColor3 = Theme.Accent
            ToastTitle.Font = Enum.Font.GothamBold
            ToastTitle.TextSize = 12
            ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToastTitle.Parent = Toast
            
            local ToastDesc = Instance.new("TextLabel")
            ToastDesc.Name = "Desc"
            ToastDesc.Size = UDim2.new(1, -20, 0, 20)
            ToastDesc.Position = UDim2.new(0, 12, 0, 25)
            ToastDesc.BackgroundTransparency = 1
            ToastDesc.Text = text
            ToastDesc.TextColor3 = Theme.TextDim
            ToastDesc.Font = Enum.Font.Gotham
            ToastDesc.TextSize = 10
            ToastDesc.TextXAlignment = Enum.TextXAlignment.Left
            ToastDesc.Parent = Toast
            
            tween(Toast, 0.35, {Position = UDim2.new(1, -250, 1, -70)})
            
            task.delay(duration, function()
                local t = tween(Toast, 0.35, {Position = UDim2.new(1, 10, 1, -70)})
                t.Completed:Connect(function() Toast:Destroy() end)
            end)
        end
        
        -- Создание Вкладки
        function UI:CreateTab(tabName)
            local Tab = { Selected = false, CategoryButton = nil, SubFrame = nil, SectionsCount = 0 }
            
            -- Кнопка вкладки
            local CategoryButton = Instance.new("TextButton")
            CategoryButton.Name = "CategoryButton"
            CategoryButton.Size = UDim2.new(0, 95, 1, 0)
            CategoryButton.BackgroundTransparency = 1
            CategoryButton.Text = tabName
            CategoryButton.TextColor3 = Theme.TextDim
            CategoryButton.Font = Enum.Font.GothamBold
            CategoryButton.TextSize = 12
            CategoryButton.Parent = TabButtonContainer
            
            local Underline = Instance.new("Frame")
            Underline.Name = "Underline"
            Underline.Size = UDim2.new(0.6, 0, 0, 2)
            Underline.Position = UDim2.new(0.2, 0, 1, -2)
            Underline.BackgroundColor3 = Theme.Accent
            Underline.BorderSizePixel = 0
            Underline.BackgroundTransparency = 1
            Underline.Parent = CategoryButton
            
            -- Двухколонный макет для размещения карточек секций
            local SubFrame = Instance.new("ScrollingFrame")
            SubFrame.Name = "SubFrame"
            SubFrame.Size = UDim2.new(1, 0, 1, 0)
            SubFrame.BackgroundTransparency = 1
            SubFrame.BorderSizePixel = 0
            SubFrame.ScrollBarThickness = 2
            SubFrame.ScrollBarImageColor3 = Theme.StrokeInner
            SubFrame.Visible = false
            SubFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            SubFrame.Parent = PageList
            
            -- Левая колонка
            local LeftColumn = Instance.new("Frame")
            LeftColumn.Name = "LeftColumn"
            LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
            LeftColumn.BackgroundTransparency = 1
            LeftColumn.Parent = SubFrame
            
            local LeftLayout = Instance.new("UIListLayout")
            LeftLayout.Parent = LeftColumn
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftLayout.Padding = UDim.new(0, 12)
            
            -- Правая колонка
            local RightColumn = Instance.new("Frame")
            RightColumn.Name = "RightColumn"
            RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
            RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
            RightColumn.BackgroundTransparency = 1
            RightColumn.Parent = SubFrame
            
            local RightLayout = Instance.new("UIListLayout")
            RightLayout.Parent = RightColumn
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 12)
            
            -- Автоматический скролл по высоте контента
            local function updateScroll()
                local leftHeight = LeftLayout.AbsoluteContentSize.Y
                local rightHeight = RightLayout.AbsoluteContentSize.Y
                local maxHeight = math.max(leftHeight, rightHeight)
                SubFrame.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 20)
            end
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
            
            Tab.CategoryButton = CategoryButton
            Tab.SubFrame = SubFrame
            
            local function select()
                for _, otherTab in ipairs(UI.Tabs) do
                    otherTab.Selected = false
                    otherTab.SubFrame.Visible = false
                    tween(otherTab.CategoryButton, 0.15, {TextColor3 = Theme.TextDim})
                    tween(otherTab.CategoryButton.Underline, 0.15, {BackgroundTransparency = 1})
                end
                Tab.Selected = true
                SubFrame.Visible = true
                tween(CategoryButton, 0.15, {TextColor3 = Theme.Text})
                tween(Underline, 0.15, {BackgroundTransparency = 0})
            end
            
            CategoryButton.MouseButton1Click:Connect(select)
            table.insert(UI.Tabs, Tab)
            
            if #UI.Tabs == 1 then select() end
            
            local TabController = {}
            
            -- Создание Секции
            function TabController:CreateSection(secName)
                Tab.SectionsCount = Tab.SectionsCount + 1
                
                local targetColumn = (Tab.SectionsCount % 2 == 1) and LeftColumn or RightColumn
                
                local Section = {}
                
                local CardFrame = Instance.new("Frame")
                CardFrame.Name = "CardFrame"
                CardFrame.Size = UDim2.new(1, 0, 0, 30)
                CardFrame.BackgroundColor3 = Theme.Card
                CardFrame.BorderSizePixel = 0
                CardFrame.Parent = targetColumn
                
                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 4)
                CardCorner.Parent = CardFrame
                
                local CardStroke = Instance.new("UIStroke")
                CardStroke.Color = Theme.StrokeInner
                CardStroke.Thickness = 1
                CardStroke.Parent = CardFrame
                
                local CardList = Instance.new("UIListLayout")
                CardList.Parent = CardFrame
                CardList.SortOrder = Enum.SortOrder.LayoutOrder
                CardList.Padding = UDim.new(0, 8)
                
                local CardPadding = Instance.new("UIPadding")
                CardPadding.PaddingLeft = UDim.new(0, 12)
                CardPadding.PaddingRight = UDim.new(0, 12)
                CardPadding.PaddingTop = UDim.new(0, 10)
                CardPadding.PaddingBottom = UDim.new(0, 12)
                CardPadding.Parent = CardFrame
                
                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "CardLabel"
                CardLabel.Size = UDim2.new(1, 0, 0, 18)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Text = string.upper(secName)
                CardLabel.TextColor3 = Theme.Accent
                CardLabel.Font = Enum.Font.GothamBold
                CardLabel.TextSize = 10
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Parent = CardFrame
                
                local function resizeCard()
                    CardFrame.Size = UDim2.new(1, 0, 0, CardList.AbsoluteContentSize.Y + 22)
                end
                CardList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeCard)
                
                -- ==========================================
                -- ЭЛЕМЕНТЫ ВВОДА (INPUT ELEMENTS)
                -- ==========================================
                
                -- 1. Кнопка (Button)
                function Section:CreateButton(btnText, callback, keybind)
                    local ActionButton = Instance.new("TextButton")
                    ActionButton.Name = "ActionButton"
                    ActionButton.Size = UDim2.new(1, 0, 0, 28)
                    ActionButton.BackgroundColor3 = Theme.StrokeInner
                    ActionButton.Text = btnText
                    ActionButton.TextColor3 = Theme.Text
                    ActionButton.Font = Enum.Font.GothamMedium
                    ActionButton.TextSize = 12
                    ActionButton.Parent = CardFrame
                    
                    local ActionCorner = Instance.new("UICorner")
                    ActionCorner.CornerRadius = UDim.new(0, 4)
                    ActionCorner.Parent = ActionButton
                    
                    local ActionStroke = Instance.new("UIStroke")
                    ActionStroke.Color = Theme.StrokeInner
                    ActionStroke.Thickness = 0.8
                    ActionStroke.Parent = ActionButton
                    
                    ActionButton.MouseEnter:Connect(function()
                        tween(ActionButton, 0.15, {BackgroundColor3 = Theme.Accent})
                    end)
                    ActionButton.MouseLeave:Connect(function()
                        tween(ActionButton, 0.15, {BackgroundColor3 = Theme.StrokeInner})
                    end)
                    ActionButton.MouseButton1Click:Connect(callback)
                    
                    if keybind then
                        UserInputService.InputBegan:Connect(function(input, gp)
                            if gp then return end
                            if input.KeyCode == keybind then callback() end
                        end)
                        ActionButton.Text = btnText .. " [" .. keybind.Name .. "]"
                    end
                end
                
                -- 2. Переключатель (Toggle)
                function Section:CreateToggle(toggleText, default, callback, keybind)
                    local state = default or false
                    
                    local SettingsButton = Instance.new("TextButton")
                    SettingsButton.Name = "SettingsButton"
                    SettingsButton.Size = UDim2.new(1, 0, 0, 26)
                    SettingsButton.BackgroundTransparency = 1
                    SettingsButton.Text = ""
                    SettingsButton.Parent = CardFrame
                    
                    local ToggleLabel = Instance.new("TextLabel")
                    ToggleLabel.Name = "ToggleLabel"
                    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
                    ToggleLabel.BackgroundTransparency = 1
                    ToggleLabel.Text = toggleText
                    ToggleLabel.TextColor3 = Theme.TextDim
                    ToggleLabel.Font = Enum.Font.GothamMedium
                    ToggleLabel.TextSize = 12
                    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    ToggleLabel.Parent = SettingsButton
                    
                    local StatusIndicator = Instance.new("Frame")
                    StatusIndicator.Name = "StatusIndicator"
                    StatusIndicator.Size = UDim2.new(0, 32, 0, 16)
                    StatusIndicator.Position = UDim2.new(1, -32, 0.5, -8)
                    StatusIndicator.BackgroundColor3 = state and Theme.Accent or Theme.StrokeInner
                    StatusIndicator.BorderSizePixel = 0
                    StatusIndicator.Parent = SettingsButton
                    
                    local IndicatorCorner = Instance.new("UICorner")
                    IndicatorCorner.CornerRadius = UDim.new(1, 0)
                    IndicatorCorner.Parent = StatusIndicator
                    
                    local SliderDot = Instance.new("Frame")
                    SliderDot.Name = "SliderDot"
                    SliderDot.Size = UDim2.new(0, 12, 0, 12)
                    SliderDot.Position = UDim2.new(0, state and 18 or 2, 0.5, -6)
                    SliderDot.BackgroundColor3 = Theme.Text
                    SliderDot.BorderSizePixel = 0
                    SliderDot.Parent = StatusIndicator
                    
                    local DotCorner = Instance.new("UICorner")
                    DotCorner.CornerRadius = UDim.new(1, 0)
                    DotCorner.Parent = SliderDot
                    
                    local function update()
                        tween(StatusIndicator, 0.15, {BackgroundColor3 = state and Theme.Accent or Theme.StrokeInner})
                        tween(SliderDot, 0.15, {Position = UDim2.new(0, state and 18 or 2, 0.5, -6)})
                        tween(ToggleLabel, 0.15, {TextColor3 = state and Theme.Text or Theme.TextDim})
                        callback(state)
                    end
                    
                    SettingsButton.MouseButton1Click:Connect(function()
                        state = not state
                        update()
                    end)
                    
                    if keybind then
                        UserInputService.InputBegan:Connect(function(input, gp)
                            if gp then return end
                            if input.KeyCode == keybind then
                                state = not state
                                update()
                            end
                        end)
                        ToggleLabel.Text = toggleText .. " [" .. keybind.Name .. "]"
                    end
                    
                    task.spawn(function() callback(state) end)
                end
                
                -- 3. Ползунок (Slider)
                function Section:CreateSlider(sliderText, min, max, default, callback)
                    local current = default or min
                    
                    local SliderContainer = Instance.new("Frame")
                    SliderContainer.Name = "SliderContainer"
                    SliderContainer.Size = UDim2.new(1, 0, 0, 36)
                    SliderContainer.BackgroundTransparency = 1
                    SliderContainer.Parent = CardFrame
                    
                    local SliderLabel = Instance.new("TextLabel")
                    SliderLabel.Name = "SliderLabel"
                    SliderLabel.Size = UDim2.new(0.7, 0, 0, 16)
                    SliderLabel.BackgroundTransparency = 1
                    SliderLabel.Text = sliderText
                    SliderLabel.TextColor3 = Theme.TextDim
                    SliderLabel.Font = Enum.Font.GothamMedium
                    SliderLabel.TextSize = 11
                    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SliderLabel.Parent = SliderContainer
                    
                    local ValueLabel = Instance.new("TextLabel")
                    ValueLabel.Name = "ValueLabel"
                    ValueLabel.Size = UDim2.new(0.25, 0, 0, 16)
                    ValueLabel.Position = UDim2.new(0.75, 0, 0, 0)
                    ValueLabel.BackgroundTransparency = 1
                    ValueLabel.Text = tostring(current)
                    ValueLabel.TextColor3 = Theme.Accent
                    ValueLabel.Font = Enum.Font.GothamBold
                    ValueLabel.TextSize = 11
                    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValueLabel.Parent = SliderContainer
                    
                    local Track = Instance.new("TextButton")
                    Track.Name = "Track"
                    Track.Size = UDim2.new(1, 0, 0, 6)
                    Track.Position = UDim2.new(0, 0, 0.7, 0)
                    Track.BackgroundColor3 = Theme.StrokeInner
                    Track.BorderSizePixel = 0
                    Track.Text = ""
                    Track.Parent = SliderContainer
                    
                    local TrackCorner = Instance.new("UICorner")
                    TrackCorner.CornerRadius = UDim.new(1, 0)
                    TrackCorner.Parent = Track
                    
                    local ProgressBar = Instance.new("Frame")
                    ProgressBar.Name = "ProgressBar"
                    ProgressBar.Size = UDim2.new((current - min)/(max - min), 0, 1, 0)
                    ProgressBar.BackgroundColor3 = Theme.Accent
                    ProgressBar.BorderSizePixel = 0
                    ProgressBar.Parent = Track
                    
                    local ProgressCorner = Instance.new("UICorner")
                    ProgressCorner.CornerRadius = UDim.new(1, 0)
                    ProgressCorner.Parent = ProgressBar
                    
                    local function update(input)
                        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        current = math.round(min + (max - min) * pos)
                        ValueLabel.Text = tostring(current)
                        ProgressBar.Size = UDim2.new(pos, 0, 1, 0)
                        callback(current)
                    end
                    
                    local sliding = false
                    Track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = true
                            update(input)
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            update(input)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = false
                        end
                    end)
                    
                    task.spawn(function() callback(current) end)
                end
                
                -- 4. Текстовое поле (Textbox / InputField)
                function Section:CreateTextbox(textName, placeholder, callback)
                    local TextboxContainer = Instance.new("Frame")
                    TextboxContainer.Name = "TextboxContainer"
                    TextboxContainer.Size = UDim2.new(1, 0, 0, 44)
                    TextboxContainer.BackgroundTransparency = 1
                    TextboxContainer.Parent = CardFrame
                    
                    local TextboxLabel = Instance.new("TextLabel")
                    TextboxLabel.Name = "TextboxLabel"
                    TextboxLabel.Size = UDim2.new(1, 0, 0, 16)
                    TextboxLabel.BackgroundTransparency = 1
                    TextboxLabel.Text = textName
                    TextboxLabel.TextColor3 = Theme.TextDim
                    TextboxLabel.Font = Enum.Font.GothamMedium
                    TextboxLabel.TextSize = 11
                    TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                    TextboxLabel.Parent = TextboxContainer
                    
                    local InputField = Instance.new("TextBox")
                    InputField.Name = "InputField"
                    InputField.Size = UDim2.new(1, 0, 0, 24)
                    InputField.Position = UDim2.new(0, 0, 0, 18)
                    InputField.BackgroundColor3 = Theme.StrokeInner
                    InputField.BorderSizePixel = 0
                    InputField.Text = ""
                    InputField.PlaceholderText = placeholder or "Введите text..."
                    InputField.PlaceholderColor3 = Theme.TextDim
                    InputField.TextColor3 = Theme.Text
                    InputField.Font = Enum.Font.GothamMedium
                    InputField.TextSize = 11
                    InputField.TextXAlignment = Enum.TextXAlignment.Left
                    InputField.ClearTextOnFocus = false
                    InputField.Parent = TextboxContainer
                    
                    local InputCorner = Instance.new("UICorner")
                    InputCorner.CornerRadius = UDim.new(0, 4)
                    InputCorner.Parent = InputField
                    
                    local InputPadding = Instance.new("UIPadding")
                    InputPadding.PaddingLeft = UDim.new(0, 8)
                    InputPadding.PaddingRight = UDim.new(0, 8)
                    InputPadding.Parent = InputField
                    
                    InputField.FocusLost:Connect(function(enterPressed)
                        callback(InputField.Text, enterPressed)
                    end)
                end
                
                -- 5. Выпадающий список (Dropdown)
                function Section:CreateDropdown(dropText, list, default, callback)
                    local open = false
                    local current = default or list[1]
                    
                    local DropdownContainer = Instance.new("Frame")
                    DropdownContainer.Name = "DropdownContainer"
                    DropdownContainer.Size = UDim2.new(1, 0, 0, 44)
                    DropdownContainer.BackgroundTransparency = 1
                    DropdownContainer.Parent = CardFrame
                    
                    local DropdownLabel = Instance.new("TextLabel")
                    DropdownLabel.Name = "DropdownLabel"
                    DropdownLabel.Size = UDim2.new(1, 0, 0, 16)
                    DropdownLabel.BackgroundTransparency = 1
                    DropdownLabel.Text = dropText
                    DropdownLabel.TextColor3 = Theme.TextDim
                    DropdownLabel.Font = Enum.Font.GothamMedium
                    DropdownLabel.TextSize = 11
                    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                    DropdownLabel.Parent = DropdownContainer
                    
                    local ComboSelector = Instance.new("TextButton")
                    ComboSelector.Name = "ComboSelector"
                    ComboSelector.Size = UDim2.new(1, 0, 0, 24)
                    ComboSelector.Position = UDim2.new(0, 0, 0, 18)
                    ComboSelector.BackgroundColor3 = Theme.StrokeInner
                    ComboSelector.BorderSizePixel = 0
                    ComboSelector.Text = "  " .. tostring(current)
                    ComboSelector.TextColor3 = Theme.Text
                    ComboSelector.Font = Enum.Font.GothamMedium
                    ComboSelector.TextSize = 11
                    ComboSelector.TextXAlignment = Enum.TextXAlignment.Left
                    ComboSelector.Parent = DropdownContainer
                    
                    local SelectorCorner = Instance.new("UICorner")
                    SelectorCorner.CornerRadius = UDim.new(0, 4)
                    SelectorCorner.Parent = ComboSelector
                    
                    local Arrow = Instance.new("TextLabel")
                    Arrow.Name = "Arrow"
                    Arrow.Size = UDim2.new(0, 20, 1, 0)
                    Arrow.Position = UDim2.new(1, -22, 0, 0)
                    Arrow.BackgroundTransparency = 1
                    Arrow.Text = "▼"
                    Arrow.TextColor3 = Theme.TextDim
                    Arrow.Font = Enum.Font.Gotham
                    Arrow.TextSize = 8
                    Arrow.Parent = ComboSelector
                    
                    local SelectionList = Instance.new("ScrollingFrame")
                    SelectionList.Name = "SelectionList"
                    SelectionList.Size = UDim2.new(1, 0, 0, 0)
                    SelectionList.Position = UDim2.new(0, 0, 1, 2)
                    SelectionList.BackgroundColor3 = Theme.Card
                    SelectionList.BorderSizePixel = 0
                    SelectionList.ZIndex = 5
                    SelectionList.Visible = false
                    SelectionList.ScrollBarThickness = 2
                    SelectionList.ScrollBarImageColor3 = Theme.StrokeInner
                    SelectionList.Parent = ComboSelector
                    
                    local ListLayout = Instance.new("UIListLayout")
                    ListLayout.Parent = SelectionList
                    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    
                    local SelectionCorner = Instance.new("UICorner")
                    SelectionCorner.CornerRadius = UDim.new(0, 4)
                    SelectionCorner.Parent = SelectionList
                    
                    local SelectionStroke = Instance.new("UIStroke")
                    SelectionStroke.Color = Theme.StrokeInner
                    SelectionStroke.Thickness = 1
                    SelectionStroke.Parent = SelectionList
                    
                    local function toggleDropdown()
                        open = not open
                        Arrow.Text = open and "▲" or "▼"
                        SelectionList.Visible = open
                        if open then
                            local size = math.min(#list * 22, 88)
                            SelectionList.Size = UDim2.new(1, 0, 0, size)
                            SelectionList.CanvasSize = UDim2.new(0, 0, 0, #list * 22)
                            DropdownContainer.Size = UDim2.new(1, 0, 0, 44 + size)
                        else
                            DropdownContainer.Size = UDim2.new(1, 0, 0, 44)
                        end
                        resizeCard()
                    end
                    
                    ComboSelector.MouseButton1Click:Connect(toggleDropdown)
                    
                    for i, option in ipairs(list) do
                        local OptionBtn = Instance.new("TextButton")
                        OptionBtn.Name = "OptionBtn"
                        OptionBtn.Size = UDim2.new(1, 0, 0, 22)
                        OptionBtn.BackgroundColor3 = Theme.Card
                        OptionBtn.BorderSizePixel = 0
                        OptionBtn.Text = "  " .. tostring(option)
                        OptionBtn.TextColor3 = Theme.TextDim
                        OptionBtn.Font = Enum.Font.GothamMedium
                        OptionBtn.TextSize = 10
                        OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptionBtn.ZIndex = 6
                        OptionBtn.Parent = SelectionList
                        
                        OptionBtn.MouseEnter:Connect(function()
                            tween(OptionBtn, 0.1, {BackgroundColor3 = Theme.StrokeInner, TextColor3 = Theme.Text})
                        end)
                        OptionBtn.MouseLeave:Connect(function()
                            tween(OptionBtn, 0.1, {BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextDim})
                        end)
                        
                        OptionBtn.MouseButton1Click:Connect(function()
                            current = option
                            ComboSelector.Text = "  " .. tostring(option)
                            callback(option)
                            toggleDropdown()
                        end)
                    end
                    
                    task.spawn(function() callback(current) end)
                end
                
                -- 6. Клавиша бинда (Keybind)
                function Section:CreateKeybind(bindText, default, callback)
                    local currentKey = default
                    
                    local KeybindContainer = Instance.new("Frame")
                    KeybindContainer.Name = "KeybindContainer"
                    KeybindContainer.Size = UDim2.new(1, 0, 0, 26)
                    KeybindContainer.BackgroundTransparency = 1
                    KeybindContainer.Parent = CardFrame
                    
                    local KeybindLabel = Instance.new("TextLabel")
                    KeybindLabel.Name = "KeybindLabel"
                    KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
                    KeybindLabel.BackgroundTransparency = 1
                    KeybindLabel.Text = bindText
                    KeybindLabel.TextColor3 = Theme.TextDim
                    KeybindLabel.Font = Enum.Font.GothamMedium
                    KeybindLabel.TextSize = 12
                    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                    KeybindLabel.Parent = KeybindContainer
                    
                    local ShortcutButton = Instance.new("TextButton")
                    ShortcutButton.Name = "ShortcutButton"
                    ShortcutButton.Size = UDim2.new(0.35, 0, 0.8, 0)
                    ShortcutButton.Position = UDim2.new(0.65, 0, 0.1, 0)
                    ShortcutButton.BackgroundColor3 = Theme.StrokeInner
                    ShortcutButton.Text = currentKey and currentKey.Name or "[ NONE ]"
                    ShortcutButton.TextColor3 = Theme.Text
                    ShortcutButton.Font = Enum.Font.GothamBold
                    ShortcutButton.TextSize = 10
                    ShortcutButton.Parent = KeybindContainer
                    
                    local ShortcutCorner = Instance.new("UICorner")
                    ShortcutCorner.CornerRadius = UDim.new(0, 4)
                    ShortcutCorner.Parent = ShortcutButton
                    
                    local binding = false
                    ShortcutButton.MouseButton1Click:Connect(function()
                        binding = true
                        ShortcutButton.Text = "... БИНД"
                        ShortcutButton.TextColor3 = Theme.Accent
                    end)
                    
                    UserInputService.InputBegan:Connect(function(input, gp)
                        if binding then
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                binding = false
                                currentKey = input.KeyCode
                                ShortcutButton.Text = currentKey.Name
                                ShortcutButton.TextColor3 = Theme.Text
                                callback(currentKey)
                            end
                        else
                            if not gp and currentKey and input.KeyCode == currentKey then
                                callback(currentKey)
                            end
                        end
                    end)
                end
                
                return Section
            end
            
            return TabController
        end
        
        UI:Notify("deadhub loaded", "Horizontal navigation menu successfully loaded!", 4)
        
        return UI
    end
end

return Library
