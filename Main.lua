-- [[ deadhub UI Library — LinoriaLib Style Wide Horizontal Edition ]] --
-- Разработано в стиле LinoriaLib: строгий угловатый дизайн,SourceSans шрифт, классические группы (Groupboxes)
-- Все функции и переменные локальны для обхода getgc()
-- Исправлена критическая ошибка с TextAlignment (заменено на TextXAlignment)

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

-- Цветовая схема: Классический Linoria-стиль (Серый, Черный, Красный)
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),      -- Основной фон (темно-серый)
    Header = Color3.fromRGB(15, 15, 15),          -- Задник заголовков и вкладок
    Card = Color3.fromRGB(24, 24, 24),            -- Внутренний фон групп (Groupboxes)
    StrokeOuter = Color3.fromRGB(229, 9, 20),     -- Яркий красный внешний контур
    StrokeInner = Color3.fromRGB(40, 40, 40),     -- Границы элементов и групп
    Accent = Color3.fromRGB(229, 9, 20),          -- Акцентный красный
    Text = Color3.fromRGB(255, 255, 255),         -- Белый текст
    TextDim = Color3.fromRGB(160, 160, 160)       -- Серый вспомогательный текст
}

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
        -- КЛАССИЧЕСКИЙ LINORIA GUI РЕЖИМ (УГЛОВАТЫЙ)
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
        
        -- Главное окно (Строгий прямоугольник)
        local InventoryFrame = Instance.new("Frame")
        InventoryFrame.Name = "InventoryFrame"
        InventoryFrame.Size = UDim2.new(0, 780, 0, 500)
        InventoryFrame.Position = UDim2.new(0.5, -390, 0.5, -250)
        InventoryFrame.BackgroundColor3 = Theme.Background
        InventoryFrame.BorderSizePixel = 1
        InventoryFrame.BorderColor3 = Theme.StrokeOuter
        InventoryFrame.Active = true
        InventoryFrame.Parent = ScreenGui
        
        -- Внутренний контейнер для двойного бордера
        local InnerContainer = Instance.new("Frame")
        InnerContainer.Name = "InnerContainer"
        InnerContainer.Size = UDim2.new(1, -6, 1, -6)
        InnerContainer.Position = UDim2.new(0, 3, 0, 3)
        InnerContainer.BackgroundColor3 = Theme.Background
        InnerContainer.BorderSizePixel = 1
        InnerContainer.BorderColor3 = Theme.StrokeInner
        InnerContainer.Parent = InventoryFrame
        
        -- Верхняя панель (Header)
        local HeaderFrame = Instance.new("Frame")
        HeaderFrame.Name = "HeaderFrame"
        HeaderFrame.Size = UDim2.new(1, 0, 0, 78)
        HeaderFrame.BackgroundColor3 = Theme.Header
        HeaderFrame.BorderSizePixel = 1
        HeaderFrame.BorderColor3 = Theme.StrokeInner
        HeaderFrame.Parent = InnerContainer
        
        -- Заголовок по центру (SourceSansBold)
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(0, 300, 0, 25)
        TitleLabel.Position = UDim2.new(0.5, -150, 0, 6)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = "deadhub"
        TitleLabel.TextColor3 = Theme.Accent
        TitleLabel.Font = Enum.Font.SourceSansBold
        TitleLabel.TextSize = 21
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
        TitleLabel.Parent = HeaderFrame
        
        -- Кнопка закрытия [X]
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 24, 0, 24)
        CloseButton.Position = UDim2.new(1, -28, 0, 6)
        CloseButton.BackgroundTransparency = 1
        CloseButton.Text = "[X]"
        CloseButton.TextColor3 = Theme.TextDim
        CloseButton.Font = Enum.Font.SourceSansBold
        CloseButton.TextSize = 16
        CloseButton.Parent = HeaderFrame
        
        CloseButton.MouseEnter:Connect(function() CloseButton.TextColor3 = Theme.Accent end)
        CloseButton.MouseLeave:Connect(function() CloseButton.TextColor3 = Theme.TextDim end)
        CloseButton.MouseButton1Click:Connect(function()
            UI.Visible = false
            InventoryFrame.Visible = false
        end)
        
        makeDraggable(InventoryFrame, HeaderFrame)
        
        -- Горизонтальный ряд вкладок (Tabs)
        local TabButtonContainer = Instance.new("ScrollingFrame")
        TabButtonContainer.Name = "TabButtonContainer"
        TabButtonContainer.Size = UDim2.new(1, -20, 0, 28)
        TabButtonContainer.Position = UDim2.new(0, 10, 0, 38)
        TabButtonContainer.BackgroundTransparency = 1
        TabButtonContainer.BorderSizePixel = 0
        TabButtonContainer.ScrollBarThickness = 0
        TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabButtonContainer.Parent = HeaderFrame
        
        local TabListLayout = Instance.new("UIListLayout")
        TabListLayout.Parent = TabButtonContainer
        TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabListLayout.FillDirection = Enum.FillDirection.Horizontal
        TabListLayout.Padding = UDim.new(0, 4)
        
        -- Контейнер страниц
        local PageList = Instance.new("Frame")
        PageList.Name = "PageList"
        PageList.Size = UDim2.new(1, -20, 1, -92)
        PageList.Position = UDim2.new(0, 10, 0, 84)
        PageList.BackgroundTransparency = 1
        PageList.Parent = InnerContainer
        
        -- Переключатель видимости
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
            Toast.Size = UDim2.new(0, 240, 0, 52)
            Toast.Position = UDim2.new(1, -250, 1, -65)
            Toast.BackgroundColor3 = Theme.Background
            Toast.BorderSizePixel = 1
            Toast.BorderColor3 = Theme.StrokeOuter
            Toast.Parent = ScreenGui
            
            local InnerToast = Instance.new("Frame")
            InnerToast.Size = UDim2.new(1, -4, 1, -4)
            InnerToast.Position = UDim2.new(0, 2, 0, 2)
            InnerToast.BackgroundColor3 = Theme.Background
            InnerToast.BorderSizePixel = 1
            InnerToast.BorderColor3 = Theme.StrokeInner
            InnerToast.Parent = Toast
            
            local ToastTitle = Instance.new("TextLabel")
            ToastTitle.Name = "Title"
            ToastTitle.Size = UDim2.new(1, -16, 0, 18)
            ToastTitle.Position = UDim2.new(0, 8, 0, 4)
            ToastTitle.BackgroundTransparency = 1
            ToastTitle.Text = title
            ToastTitle.TextColor3 = Theme.Accent
            ToastTitle.Font = Enum.Font.SourceSansBold
            ToastTitle.TextSize = 14
            ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToastTitle.Parent = InnerToast
            
            local ToastDesc = Instance.new("TextLabel")
            ToastDesc.Name = "Desc"
            ToastDesc.Size = UDim2.new(1, -16, 0, 18)
            ToastDesc.Position = UDim2.new(0, 8, 0, 22)
            ToastDesc.BackgroundTransparency = 1
            ToastDesc.Text = text
            ToastDesc.TextColor3 = Theme.Text
            ToastDesc.Font = Enum.Font.SourceSans
            ToastDesc.TextSize = 13
            ToastDesc.TextXAlignment = Enum.TextXAlignment.Left
            ToastDesc.Parent = InnerToast
            
            task.delay(duration, function()
                Toast:Destroy()
            end)
        end
        
        -- Создание Вкладки
        function UI:CreateTab(tabName)
            local Tab = { Selected = false, CategoryButton = nil, SubFrame = nil, SectionsCount = 0 }
            
            -- Кнопка вкладки в стиле Linoria (аккуратные вкладки с рамкой)
            local CategoryButton = Instance.new("TextButton")
            CategoryButton.Name = "CategoryButton"
            CategoryButton.Size = UDim2.new(0, 95, 1, 0)
            CategoryButton.BackgroundColor3 = Theme.Background
            CategoryButton.BorderSizePixel = 1
            CategoryButton.BorderColor3 = Theme.StrokeInner
            CategoryButton.Text = tabName
            CategoryButton.TextColor3 = Theme.TextDim
            CategoryButton.Font = Enum.Font.SourceSansBold
            CategoryButton.TextSize = 13
            CategoryButton.Parent = TabButtonContainer
            
            -- Горизонтальный скролл страницы
            local SubFrame = Instance.new("ScrollingFrame")
            SubFrame.Name = "SubFrame"
            SubFrame.Size = UDim2.new(1, 0, 1, 0)
            SubFrame.BackgroundTransparency = 1
            SubFrame.BorderSizePixel = 0
            SubFrame.ScrollBarThickness = 3
            SubFrame.ScrollBarImageColor3 = Theme.StrokeOuter
            SubFrame.Visible = false
            SubFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            SubFrame.Parent = PageList
            
            -- Двухколоночный макет
            local LeftColumn = Instance.new("Frame")
            LeftColumn.Name = "LeftColumn"
            LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
            LeftColumn.BackgroundTransparency = 1
            LeftColumn.Parent = SubFrame
            
            local LeftLayout = Instance.new("UIListLayout")
            LeftLayout.Parent = LeftColumn
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftLayout.Padding = UDim.new(0, 14)
            
            local RightColumn = Instance.new("Frame")
            RightColumn.Name = "RightColumn"
            RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
            RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
            RightColumn.BackgroundTransparency = 1
            RightColumn.Parent = SubFrame
            
            local RightLayout = Instance.new("UIListLayout")
            RightLayout.Parent = RightColumn
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 14)
            
            local function updateScroll()
                local leftHeight = LeftLayout.AbsoluteContentSize.Y
                local rightHeight = RightLayout.AbsoluteContentSize.Y
                local maxHeight = math.max(leftHeight, rightHeight)
                SubFrame.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 30)
            end
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
            
            local function select()
                for _, otherTab in ipairs(UI.Tabs) do
                    otherTab.Selected = false
                    otherTab.SubFrame.Visible = false
                    otherTab.CategoryButton.BackgroundColor3 = Theme.Background
                    otherTab.CategoryButton.TextColor3 = Theme.TextDim
                    otherTab.CategoryButton.BorderColor3 = Theme.StrokeInner
                end
                Tab.Selected = true
                SubFrame.Visible = true
                CategoryButton.BackgroundColor3 = Theme.Card
                CategoryButton.TextColor3 = Theme.Text
                CategoryButton.BorderColor3 = Theme.StrokeOuter
            end
            
            CategoryButton.MouseButton1Click:Connect(select)
            table.insert(UI.Tabs, Tab)
            
            if #UI.Tabs == 1 then select() end
            
            local TabController = {}
            
            -- Создание Секции (в стиле классического Groupbox с заголовком на верхней границе)
            function TabController:CreateSection(secName)
                Tab.SectionsCount = Tab.SectionsCount + 1
                local targetColumn = (Tab.SectionsCount % 2 == 1) and LeftColumn or RightColumn
                
                local Section = {}
                
                -- Главная рамка Groupbox
                local CardFrame = Instance.new("Frame")
                CardFrame.Name = "CardFrame"
                CardFrame.Size = UDim2.new(1, 0, 0, 40)
                CardFrame.BackgroundColor3 = Theme.Card
                CardFrame.BorderSizePixel = 1
                CardFrame.BorderColor3 = Theme.StrokeInner
                CardFrame.Parent = targetColumn
                
                local CardList = Instance.new("UIListLayout")
                CardList.Parent = CardFrame
                CardList.SortOrder = Enum.SortOrder.LayoutOrder
                CardList.Padding = UDim.new(0, 8)
                
                local CardPadding = Instance.new("UIPadding")
                CardPadding.PaddingLeft = UDim.new(0, 10)
                CardPadding.PaddingRight = UDim.new(0, 10)
                CardPadding.PaddingTop = UDim.new(0, 12)
                CardPadding.PaddingBottom = UDim.new(0, 10)
                CardPadding.Parent = CardFrame
                
                -- Заголовок группы, перекрывающий рамку (как в LinoriaLib)
                local GroupHeader = Instance.new("Frame")
                GroupHeader.Name = "GroupHeader"
                GroupHeader.Size = UDim2.new(0, 0, 0, 14)
                GroupHeader.Position = UDim2.new(0, 8, 0, -18) -- Сдвиг вверх на границу
                GroupHeader.BackgroundColor3 = Theme.Background
                GroupHeader.BorderSizePixel = 0
                GroupHeader.Parent = CardFrame
                
                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "CardLabel"
                CardLabel.Size = UDim2.new(0, 0, 1, 0)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Text = " " .. string.upper(secName) .. " "
                CardLabel.TextColor3 = Theme.Accent
                CardLabel.Font = Enum.Font.SourceSansBold
                CardLabel.TextSize = 13
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Parent = GroupHeader
                
                -- Авто-ширина подложки под текст
                CardLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    GroupHeader.Size = UDim2.new(0, CardLabel.TextBounds.X, 0, 14)
                    CardLabel.Size = UDim2.new(1, 0, 1, 0)
                end)
                
                local function resizeCard()
                    CardFrame.Size = UDim2.new(1, 0, 0, CardList.AbsoluteContentSize.Y + 22)
                end
                CardList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeCard)
                
                -- ==========================================
                -- ЭЛЕМЕНТЫ ВВОДА (LINORIA STYLE)
                -- ==========================================
                
                -- 1. Кнопка (Button)
                function Section:CreateButton(btnText, callback, keybind)
                    local ActionButton = Instance.new("TextButton")
                    ActionButton.Name = "ActionButton"
                    ActionButton.Size = UDim2.new(1, 0, 0, 24)
                    ActionButton.BackgroundColor3 = Theme.Background
                    ActionButton.BorderSizePixel = 1
                    ActionButton.BorderColor3 = Theme.StrokeInner
                    ActionButton.Text = btnText
                    ActionButton.TextColor3 = Theme.Text
                    ActionButton.Font = Enum.Font.SourceSans
                    ActionButton.TextSize = 13
                    ActionButton.Parent = CardFrame
                    
                    ActionButton.MouseEnter:Connect(function()
                        ActionButton.BorderColor3 = Theme.StrokeOuter
                    end)
                    ActionButton.MouseLeave:Connect(function()
                        ActionButton.BorderColor3 = Theme.StrokeInner
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
                
                -- 2. Переключатель (Toggle - Квадратная галочка слева)
                function Section:CreateToggle(toggleText, default, callback, keybind)
                    local state = default or false
                    
                    local SettingsButton = Instance.new("TextButton")
                    SettingsButton.Name = "SettingsButton"
                    SettingsButton.Size = UDim2.new(1, 0, 0, 20)
                    SettingsButton.BackgroundTransparency = 1
                    SettingsButton.Text = ""
                    SettingsButton.Parent = CardFrame
                    
                    -- Квадратный бокс
                    local CheckBox = Instance.new("Frame")
                    CheckBox.Name = "CheckBox"
                    CheckBox.Size = UDim2.new(0, 13, 0, 13)
                    CheckBox.Position = UDim2.new(0, 0, 0.5, -6)
                    CheckBox.BackgroundColor3 = state and Theme.Accent or Theme.Background
                    CheckBox.BorderSizePixel = 1
                    CheckBox.BorderColor3 = state and Theme.Accent or Theme.StrokeInner
                    CheckBox.Parent = SettingsButton
                    
                    local ToggleLabel = Instance.new("TextLabel")
                    ToggleLabel.Name = "ToggleLabel"
                    ToggleLabel.Size = UDim2.new(1, -22, 1, 0)
                    ToggleLabel.Position = UDim2.new(0, 20, 0, 0)
                    ToggleLabel.BackgroundTransparency = 1
                    ToggleLabel.Text = toggleText
                    ToggleLabel.TextColor3 = state and Theme.Text or Theme.TextDim
                    ToggleLabel.Font = Enum.Font.SourceSans
                    ToggleLabel.TextSize = 13
                    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    ToggleLabel.Parent = SettingsButton
                    
                    local function update()
                        CheckBox.BackgroundColor3 = state and Theme.Accent or Theme.Background
                        CheckBox.BorderColor3 = state and Theme.Accent or Theme.StrokeInner
                        ToggleLabel.TextColor3 = state and Theme.Text or Theme.TextDim
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
                
                -- 3. Ползунок (Slider - Тонкая полоска под текстом)
                function Section:CreateSlider(sliderText, min, max, default, callback)
                    local current = default or min
                    
                    local SliderContainer = Instance.new("Frame")
                    SliderContainer.Name = "SliderContainer"
                    SliderContainer.Size = UDim2.new(1, 0, 0, 32)
                    SliderContainer.BackgroundTransparency = 1
                    SliderContainer.Parent = CardFrame
                    
                    local SliderLabel = Instance.new("TextLabel")
                    SliderLabel.Name = "SliderLabel"
                    SliderLabel.Size = UDim2.new(0.7, 0, 0, 16)
                    SliderLabel.BackgroundTransparency = 1
                    SliderLabel.Text = sliderText
                    SliderLabel.TextColor3 = Theme.TextDim
                    SliderLabel.Font = Enum.Font.SourceSans
                    SliderLabel.TextSize = 13
                    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SliderLabel.Parent = SliderContainer
                    
                    local ValueLabel = Instance.new("TextLabel")
                    ValueLabel.Name = "ValueLabel"
                    ValueLabel.Size = UDim2.new(0.28, 0, 0, 16)
                    ValueLabel.Position = UDim2.new(0.72, 0, 0, 0)
                    ValueLabel.BackgroundTransparency = 1
                    ValueLabel.Text = tostring(current)
                    ValueLabel.TextColor3 = Theme.Text
                    ValueLabel.Font = Enum.Font.SourceSansBold
                    ValueLabel.TextSize = 13
                    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValueLabel.Parent = SliderContainer
                    
                    local Track = Instance.new("TextButton")
                    Track.Name = "Track"
                    Track.Size = UDim2.new(1, 0, 0, 8)
                    Track.Position = UDim2.new(0, 0, 0, 18)
                    Track.BackgroundColor3 = Theme.Background
                    Track.BorderSizePixel = 1
                    Track.BorderColor3 = Theme.StrokeInner
                    Track.Text = ""
                    Track.Parent = SliderContainer
                    
                    local ProgressBar = Instance.new("Frame")
                    ProgressBar.Name = "ProgressBar"
                    ProgressBar.Size = UDim2.new((current - min)/(max - min), 0, 1, 0)
                    ProgressBar.BackgroundColor3 = Theme.Accent
                    ProgressBar.BorderSizePixel = 0
                    ProgressBar.Parent = Track
                    
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
                
                -- 4. Текстовое поле (Textbox)
                function Section:CreateTextbox(textName, placeholder, callback)
                    local TextboxContainer = Instance.new("Frame")
                    TextboxContainer.Name = "TextboxContainer"
                    TextboxContainer.Size = UDim2.new(1, 0, 0, 42)
                    TextboxContainer.BackgroundTransparency = 1
                    TextboxContainer.Parent = CardFrame
                    
                    local TextboxLabel = Instance.new("TextLabel")
                    TextboxLabel.Name = "TextboxLabel"
                    TextboxLabel.Size = UDim2.new(1, 0, 0, 16)
                    TextboxLabel.BackgroundTransparency = 1
                    TextboxLabel.Text = textName
                    TextboxLabel.TextColor3 = Theme.TextDim
                    TextboxLabel.Font = Enum.Font.SourceSans
                    TextboxLabel.TextSize = 13
                    TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                    TextboxLabel.Parent = TextboxContainer
                    
                    local InputField = Instance.new("TextBox")
                    InputField.Name = "InputField"
                    InputField.Size = UDim2.new(1, 0, 0, 22)
                    InputField.Position = UDim2.new(0, 0, 0, 18)
                    InputField.BackgroundColor3 = Theme.Background
                    InputField.BorderSizePixel = 1
                    InputField.BorderColor3 = Theme.StrokeInner
                    InputField.Text = ""
                    InputField.PlaceholderText = placeholder or "Введите текст..."
                    InputField.PlaceholderColor3 = Theme.TextDim
                    InputField.TextColor3 = Theme.Text
                    InputField.Font = Enum.Font.SourceSans
                    InputField.TextSize = 13
                    InputField.TextXAlignment = Enum.TextXAlignment.Left
                    InputField.ClearTextOnFocus = false
                    InputField.Parent = TextboxContainer
                    
                    local InputPadding = Instance.new("UIPadding")
                    InputPadding.PaddingLeft = UDim.new(0, 6)
                    InputPadding.PaddingRight = UDim.new(0, 6)
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
                    DropdownContainer.Size = UDim2.new(1, 0, 0, 42)
                    DropdownContainer.BackgroundTransparency = 1
                    DropdownContainer.Parent = CardFrame
                    
                    local DropdownLabel = Instance.new("TextLabel")
                    DropdownLabel.Name = "DropdownLabel"
                    DropdownLabel.Size = UDim2.new(1, 0, 0, 16)
                    DropdownLabel.BackgroundTransparency = 1
                    DropdownLabel.Text = dropText
                    DropdownLabel.TextColor3 = Theme.TextDim
                    DropdownLabel.Font = Enum.Font.SourceSans
                    DropdownLabel.TextSize = 13
                    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                    DropdownLabel.Parent = DropdownContainer
                    
                    local ComboSelector = Instance.new("TextButton")
                    ComboSelector.Name = "ComboSelector"
                    ComboSelector.Size = UDim2.new(1, 0, 0, 22)
                    ComboSelector.Position = UDim2.new(0, 0, 0, 18)
                    ComboSelector.BackgroundColor3 = Theme.Background
                    ComboSelector.BorderSizePixel = 1
                    ComboSelector.BorderColor3 = Theme.StrokeInner
                    ComboSelector.Text = "  " .. tostring(current)
                    ComboSelector.TextColor3 = Theme.Text
                    ComboSelector.Font = Enum.Font.SourceSans
                    ComboSelector.TextSize = 13
                    ComboSelector.TextXAlignment = Enum.TextXAlignment.Left
                    ComboSelector.Parent = DropdownContainer
                    
                    local Arrow = Instance.new("TextLabel")
                    Arrow.Name = "Arrow"
                    Arrow.Size = UDim2.new(0, 20, 1, 0)
                    Arrow.Position = UDim2.new(1, -22, 0, 0)
                    Arrow.BackgroundTransparency = 1
                    Arrow.Text = "▼"
                    Arrow.TextColor3 = Theme.TextDim
                    Arrow.Font = Enum.Font.SourceSans
                    Arrow.TextSize = 11
                    Arrow.Parent = ComboSelector
                    
                    local SelectionList = Instance.new("ScrollingFrame")
                    SelectionList.Name = "SelectionList"
                    SelectionList.Size = UDim2.new(1, 0, 0, 0)
                    SelectionList.Position = UDim2.new(0, 0, 1, 2)
                    SelectionList.BackgroundColor3 = Theme.Background
                    SelectionList.BorderSizePixel = 1
                    SelectionList.BorderColor3 = Theme.StrokeOuter
                    SelectionList.ZIndex = 5
                    SelectionList.Visible = false
                    SelectionList.ScrollBarThickness = 2
                    SelectionList.ScrollBarImageColor3 = Theme.StrokeInner
                    SelectionList.Parent = ComboSelector
                    
                    local ListLayout = Instance.new("UIListLayout")
                    ListLayout.Parent = SelectionList
                    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    
                    local function toggleDropdown()
                        open = not open
                        Arrow.Text = open and "▲" or "▼"
                        SelectionList.Visible = open
                        if open then
                            local size = math.min(#list * 22, 88)
                            SelectionList.Size = UDim2.new(1, 0, 0, size)
                            SelectionList.CanvasSize = UDim2.new(0, 0, 0, #list * 22)
                            DropdownContainer.Size = UDim2.new(1, 0, 0, 42 + size)
                        else
                            DropdownContainer.Size = UDim2.new(1, 0, 0, 42)
                        end
                        resizeCard()
                    end
                    
                    ComboSelector.MouseButton1Click:Connect(toggleDropdown)
                    
                    for i, option in ipairs(list) do
                        local OptionBtn = Instance.new("TextButton")
                        OptionBtn.Name = "OptionBtn"
                        OptionBtn.Size = UDim2.new(1, 0, 0, 22)
                        OptionBtn.BackgroundColor3 = Theme.Background
                        OptionBtn.BorderSizePixel = 0
                        OptionBtn.Text = "  " .. tostring(option)
                        OptionBtn.TextColor3 = Theme.TextDim
                        OptionBtn.Font = Enum.Font.SourceSans
                        OptionBtn.TextSize = 13
                        OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptionBtn.ZIndex = 6
                        OptionBtn.Parent = SelectionList
                        
                        OptionBtn.MouseEnter:Connect(function()
                            OptionBtn.BackgroundColor3 = Theme.StrokeInner
                            OptionBtn.TextColor3 = Theme.Text
                        end)
                        OptionBtn.MouseLeave:Connect(function()
                            OptionBtn.BackgroundColor3 = Theme.Background
                            OptionBtn.TextColor3 = Theme.TextDim
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
                
                -- 6. Хоткей биндер (Keybind - маленькие скобки [Key] в углу)
                function Section:CreateKeybind(bindText, default, callback)
                    local currentKey = default
                    
                    local KeybindContainer = Instance.new("Frame")
                    KeybindContainer.Name = "KeybindContainer"
                    KeybindContainer.Size = UDim2.new(1, 0, 0, 22)
                    KeybindContainer.BackgroundTransparency = 1
                    KeybindContainer.Parent = CardFrame
                    
                    local KeybindLabel = Instance.new("TextLabel")
                    KeybindLabel.Name = "KeybindLabel"
                    KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
                    KeybindLabel.BackgroundTransparency = 1
                    KeybindLabel.Text = bindText
                    KeybindLabel.TextColor3 = Theme.TextDim
                    KeybindLabel.Font = Enum.Font.SourceSans
                    KeybindLabel.TextSize = 13
                    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                    KeybindLabel.Parent = KeybindContainer
                    
                    local ShortcutButton = Instance.new("TextButton")
                    ShortcutButton.Name = "ShortcutButton"
                    ShortcutButton.Size = UDim2.new(0.35, 0, 0.9, 0)
                    ShortcutButton.Position = UDim2.new(0.65, 0, 0.05, 0)
                    ShortcutButton.BackgroundColor3 = Theme.Background
                    ShortcutButton.BorderSizePixel = 1
                    ShortcutButton.BorderColor3 = Theme.StrokeInner
                    ShortcutButton.Text = currentKey and ("[" .. currentKey.Name .. "]") or "[ NONE ]"
                    ShortcutButton.TextColor3 = Theme.Text
                    ShortcutButton.Font = Enum.Font.SourceSansBold
                    ShortcutButton.TextSize = 12
                    ShortcutButton.Parent = KeybindContainer
                    
                    local binding = false
                    ShortcutButton.MouseButton1Click:Connect(function()
                        binding = true
                        ShortcutButton.Text = "[ ... ]"
                        ShortcutButton.TextColor3 = Theme.Accent
                    end)
                    
                    UserInputService.InputBegan:Connect(function(input, gp)
                        if binding then
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                binding = false
                                currentKey = input.KeyCode
                                ShortcutButton.Text = "[" .. currentKey.Name .. "]"
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
        
        UI:Notify("deadhub loaded", "SourceSans UI successfully loaded!", 3)
        
        return UI
    end
end

return Library
