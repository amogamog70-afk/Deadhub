-- [[ DEADHUB STEALTH UI LIBRARY — RED/BLACK EDITION ]] --
-- Разработано для обхода детектов античита Trident v5

local DeadHub = {}

-- 1. Скрытый контейнер (gethui)
local parentContainer = nil
if gethui then
    parentContainer = gethui()
else
    parentContainer = game:GetService("CoreGui")
    warn("[DeadHub] gethui() не поддерживается. Использование CoreGui небезопасно!")
end

-- Словарь легальных игровых элементов для маскировки имен объектов в Explorer
local legalNames = {
    "InventoryFrame", "SettingsButton", "CraftingMenu", "HudLayout", 
    "MainFrame", "QuickBar", "LootPanel", "StatusHUD", "ClientHUD",
    "InteractivePrompt", "MapContainer", "ChatLayout", "PlayerList",
    "LeaderboardFrame", "NotificationCenter", "QuestTracker", "HealthBar",
    "StaminaIndicator", "InteractButton", "ItemSlot", "QuickAccessContainer"
}

local function getStealthName()
    return legalNames[math.random(1, #legalNames)] .. "_" .. tostring(math.random(100, 999))
end

local activeConnections = {}
local function trackConnection(connection)
    table.insert(activeConnections, connection)
    return connection
end

-- Инициализация меню
function DeadHub:Init()
    local UI = {}
    
    -- Основные цвета (Красно-Черная палитра)
    local Color_BG = Color3.fromRGB(10, 10, 12)       -- Глубокий черный
    local Color_Card = Color3.fromRGB(15, 15, 18)     -- Черно-серый для окон/карточек
    local Color_Header = Color3.fromRGB(13, 13, 15)   -- Цвет шапки и табов
    local Color_Border = Color3.fromRGB(28, 28, 32)   -- Граница рамки
    local Color_Accent = Color3.fromRGB(235, 35, 55)   -- Насыщенный красный
    local Color_Text = Color3.fromRGB(255, 255, 255)   -- Белый текст
    local Color_TextDim = Color3.fromRGB(140, 140, 150) -- Серый текст

    -- Создаем скрытый ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = getStealthName()
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentContainer

    -- Главный фрейм (Широкое меню для множества функций)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = getStealthName()
    MainFrame.Size = UDim2.new(0, 650, 0, 420) -- Увеличенная ширина
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
    MainFrame.BackgroundColor3 = Color_BG
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color_Border
    MainFrame.Parent = ScreenGui

    -- Шапка меню (Header)
    local Header = Instance.new("Frame")
    Header.Name = getStealthName()
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color_Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderBottomLine = Instance.new("Frame")
    HeaderBottomLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderBottomLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderBottomLine.BackgroundColor3 = Color_Border
    HeaderBottomLine.BorderSizePixel = 0
    HeaderBottomLine.Parent = Header

    -- Логотип/Заголовок (Визуально DeadHub, но имя объекта скрыто)
    local Logo = Instance.new("TextLabel")
    Logo.Name = getStealthName()
    Logo.Size = UDim2.new(0, 150, 1, 0)
    Logo.Position = UDim2.new(0, 15, 0, 0)
    Logo.BackgroundTransparency = 1
    Logo.Text = "DEADHUB"
    Logo.TextColor3 = Color_Accent
    Logo.TextSize = 14
    Logo.Font = Enum.Font.SourceSansBold
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.Parent = Header

    -- Кнопка закрытия меню
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = getStealthName()
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color_TextDim
    CloseBtn.TextSize = 13
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.Parent = Header

    -- ПАНЕЛЬ ВКЛАДОК (Сверху в ряд от левого до правого края)
    local TabBar = Instance.new("Frame")
    TabBar.Name = getStealthName()
    TabBar.Size = UDim2.new(1, 0, 0, 32)
    TabBar.Position = UDim2.new(0, 0, 0, 35)
    TabBar.BackgroundColor3 = Color_Header
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame

    local TabBarBottomLine = Instance.new("Frame")
    TabBarBottomLine.Size = UDim2.new(1, 0, 0, 1)
    TabBarBottomLine.Position = UDim2.new(0, 0, 1, 0)
    TabBarBottomLine.BackgroundColor3 = Color_Border
    TabBarBottomLine.BorderSizePixel = 0
    TabBarBottomLine.Parent = TabBar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabBar
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 0)

    -- Контейнер для страниц контента
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = getStealthName()
    PageContainer.Size = UDim2.new(1, -20, 1, -85)
    PageContainer.Position = UDim2.new(0, 10, 0, 75)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- Логика перетаскивания (Drag)
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local dragBegan = Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    trackConnection(dragBegan)

    local dragChanged = Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    trackConnection(dragChanged)

    local inputBegan = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.Width.Scale, startPos.Width.Offset + delta.X, startPos.Height.Scale, startPos.Height.Offset + delta.Y)
        end
    end)
    trackConnection(inputBegan)

    -- Функция скрытия/показа меню (на клавишу Insert)
    local isVisible = true
    local function toggleMenu()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end

    local toggleKeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            toggleMenu()
        end
    end)
    trackConnection(toggleKeyConnection)

    local closeClick = CloseBtn.MouseButton1Click:Connect(function()
        toggleMenu()
    end)
    trackConnection(closeClick)

    -- Списки вкладок и страниц
    local tabs = {}
    local activeTab = nil

    function UI:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = getStealthName()
        TabBtn.Size = UDim2.new(0, 110, 1, 0) -- Фиксированная ширина для вкладок
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color_TextDim
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.SourceSansBold
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = TabBar

        -- Тонкая красная полоска внизу активного таба
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(1, 0, 0, 2)
        TabIndicator.Position = UDim2.new(0, 0, 1, -2)
        TabIndicator.BackgroundColor3 = Color_Accent
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = false
        TabIndicator.Parent = TabBtn

        -- Прокручиваемый фрейм для содержимого вкладки
        local Page = Instance.new("ScrollingFrame")
        Page.Name = getStealthName()
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Visible = false
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Color_Border
        Page.Parent = PageContainer

        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 10)

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        local tabSelect = TabBtn.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Btn.TextColor3 = Color_TextDim
                activeTab.Indicator.Visible = false
                activeTab.Page.Visible = false
            end
            
            TabBtn.TextColor3 = Color_Text
            TabIndicator.Visible = true
            Page.Visible = true
            activeTab = {Btn = TabBtn, Indicator = TabIndicator, Page = Page}
        end)
        trackConnection(tabSelect)

        if not activeTab then
            TabBtn.TextColor3 = Color_Text
            TabIndicator.Visible = true
            Page.Visible = true
            activeTab = {Btn = TabBtn, Indicator = TabIndicator, Page = Page}
        end

        local TabAPI = {}

        -- 2. СОЗДАНИЕ ОКОН (СЕКЦИЙ) ВО ВКЛАДКАХ
        function TabAPI:CreateWindow(windowTitle)
            local WindowFrame = Instance.new("Frame")
            WindowFrame.Name = getStealthName()
            WindowFrame.Size = UDim2.new(1, -10, 0, 40) -- Динамически растет
            WindowFrame.BackgroundColor3 = Color_Card
            WindowFrame.BorderSizePixel = 1
            WindowFrame.BorderColor3 = Color_Border
            WindowFrame.Parent = Page

            local WindowTitleLabel = Instance.new("TextLabel")
            WindowTitleLabel.Name = getStealthName()
            WindowTitleLabel.Size = UDim2.new(1, -20, 0, 26)
            WindowTitleLabel.Position = UDim2.new(0, 10, 0, 0)
            WindowTitleLabel.BackgroundTransparency = 1
            WindowTitleLabel.Text = windowTitle:upper()
            WindowTitleLabel.TextColor3 = Color_Accent
            WindowTitleLabel.TextSize = 11
            WindowTitleLabel.Font = Enum.Font.SourceSansBold
            WindowTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            WindowTitleLabel.Parent = WindowFrame

            local Separator = Instance.new("Frame")
            Separator.Size = UDim2.new(1, 0, 0, 1)
            Separator.Position = UDim2.new(0, 0, 0, 26)
            Separator.BackgroundColor3 = Color_Border
            Separator.BorderSizePixel = 0
            Separator.Parent = WindowFrame

            local ContentFrame = Instance.new("Frame")
            ContentFrame.Name = getStealthName()
            ContentFrame.Size = UDim2.new(1, 0, 1, -27)
            ContentFrame.Position = UDim2.new(0, 0, 0, 27)
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.Parent = WindowFrame

            local ContentList = Instance.new("UIListLayout")
            ContentList.Parent = ContentFrame
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentList.Padding = UDim.new(0, 6)
            ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center

            -- Авто-подстройка высоты окна под количество элементов
            local paddingOffset = 10
            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                WindowFrame.Size = UDim2.new(1, -10, 0, ContentList.AbsoluteContentSize.Y + 27 + paddingOffset)
            end)

            local WindowAPI = {}

            -- 3. СОЗДАНИЕ КНОПОК ВКЛЮЧЕНИЯ/ВЫКЛЮЧЕНИЯ (Квадратные Toggle)
            function WindowAPI:CreateToggle(toggleText, defaultState, callback)
                local toggleState = defaultState or false
                
                local ToggleWrapper = Instance.new("Frame")
                ToggleWrapper.Name = getStealthName()
                ToggleWrapper.Size = UDim2.new(1, -20, 0, 24)
                ToggleWrapper.BackgroundTransparency = 1
                ToggleWrapper.Parent = ContentFrame

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = getStealthName()
                ToggleLabel.Size = UDim2.new(1, -30, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = toggleText
                ToggleLabel.TextColor3 = Color_Text
                ToggleLabel.TextSize = 13
                ToggleLabel.Font = Enum.Font.SourceSans
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleWrapper

                -- Квадратная кнопка
                local SquareBox = Instance.new("TextButton")
                SquareBox.Name = getStealthName()
                SquareBox.Size = UDim2.new(0, 16, 0, 16)
                SquareBox.Position = UDim2.new(1, -16, 0.5, -8)
                SquareBox.BackgroundColor3 = Color_BG
                SquareBox.BorderSizePixel = 1
                SquareBox.BorderColor3 = Color_Border
                SquareBox.Text = ""
                SquareBox.AutoButtonColor = false
                SquareBox.Parent = ToggleWrapper

                -- Красный квадрат внутри для индикации ВКЛ
                local InnerSquare = Instance.new("Frame")
                InnerSquare.Name = getStealthName()
                InnerSquare.Size = UDim2.new(0, 10, 0, 10)
                InnerSquare.Position = UDim2.new(0.5, -5, 0.5, -5)
                InnerSquare.BackgroundColor3 = Color_Accent
                InnerSquare.BorderSizePixel = 0
                InnerSquare.Visible = toggleState
                InnerSquare.Parent = SquareBox

                local function updateToggle()
                    InnerSquare.Visible = toggleState
                    callback(toggleState)
                end

                local toggleClick = SquareBox.MouseButton1Click:Connect(function()
                    toggleState = not toggleState
                    updateToggle()
                end)
                trackConnection(toggleClick)

                task.spawn(function() callback(toggleState) end)
            end

            -- 4. СОЗДАНИЕ СЛАЙДЕРОВ (Квадратные, значение по центру)
            function WindowAPI:CreateSlider(sliderText, min, max, default, callback)
                local sliderValue = default or min
                
                local SliderWrapper = Instance.new("Frame")
                SliderWrapper.Name = getStealthName()
                SliderWrapper.Size = UDim2.new(1, -20, 0, 42)
                SliderWrapper.BackgroundTransparency = 1
                SliderWrapper.Parent = ContentFrame

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = getStealthName()
                SliderLabel.Size = UDim2.new(1, 0, 0, 18)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = sliderText
                SliderLabel.TextColor3 = Color_Text
                SliderLabel.TextSize = 13
                SliderLabel.Font = Enum.Font.SourceSans
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderWrapper

                -- Квадратный контейнер слайдера
                local SliderBar = Instance.new("TextButton")
                SliderBar.Name = getStealthName()
                SliderBar.Size = UDim2.new(1, 0, 0, 18)
                SliderBar.Position = UDim2.new(0, 0, 0, 20)
                SliderBar.BackgroundColor3 = Color_BG
                SliderBar.BorderSizePixel = 1
                SliderBar.BorderColor3 = Color_Border
                SliderBar.Text = ""
                SliderBar.AutoButtonColor = false
                SliderBar.Parent = SliderWrapper

                -- Заполняющая полоса (Квадратная)
                local Fill = Instance.new("Frame")
                Fill.Name = getStealthName()
                Fill.Size = UDim2.new((sliderValue - min)/(max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color_Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = SliderBar

                -- ЗНАЧЕНИЕ СЛАЙДЕРА (Строго по центру внутри слайдера)
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = getStealthName()
                ValueLabel.Size = UDim2.new(1, 0, 1, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(sliderValue)
                ValueLabel.TextColor3 = Color_Text
                ValueLabel.TextSize = 12
                ValueLabel.Font = Enum.Font.SourceSansBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Center
                ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
                ValueLabel.Parent = SliderBar

                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    sliderValue = math.floor(min + (max - min) * pos)
                    ValueLabel.Text = tostring(sliderValue)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    callback(sliderValue)
                end

                local sliding = false
                
                local barDown = SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        updateSlider(input)
                    end
                end)
                trackConnection(barDown)

                local barUp = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)
                trackConnection(barUp)

                local barMove = UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)
                trackConnection(barMove)

                task.spawn(function() callback(sliderValue) end)
            end

            return WindowAPI
        end

        return TabAPI
    end

    -- Уничтожение UI для сборщика мусора (getgc-bypass)
    function UI:Destroy()
        for _, conn in ipairs(activeConnections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        activeConnections = {}

        if ScreenGui then
            ScreenGui:Destroy()
        end

        ScreenGui = nil
        MainFrame = nil
        Header = nil
        PageContainer = nil
        TabBar = nil
        activeTab = nil
    end

    return UI
end

return DeadHub
