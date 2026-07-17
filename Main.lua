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

-- Ссылки на текстурные иконки табов из нашего прошлого проекта VoltEclipse
local TabIcons = {
    Combat   = "rbxassetid://12614416478",      
    Movement = "rbxassetid://136160678435000", 
    Visuals  = "rbxassetid://102976018150012", 
    Misc     = "rbxassetid://137382232901580", 
    World    = "rbxassetid://122563205713088", -- earth white
    Auto     = "rbxassetid://102927017461693", -- loading v2
    Guns     = "rbxassetid://84647432170503",  -- iconarma
    Skins    = "rbxassetid://101708694952341"  -- Pencil Icon
}

-- Инициализация меню
function DeadHub:Init()
    local UI = {}
    
    -- Основные цвета (Красно-Черная палитра с обводками)
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

    -- Главный фрейм (720x450)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = getStealthName()
    MainFrame.Size = UDim2.new(0, 720, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -225)
    MainFrame.BackgroundColor3 = Color_BG
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- FIX: Дополнительная внешняя обводка вокруг всего меню изменена на КРАСНЫЙ цвет (по просьбе пользователя)
    local MenuStroke = Instance.new("UIStroke")
    MenuStroke.Color = Color_Accent -- Красная рамка
    MenuStroke.Thickness = 1.2
    MenuStroke.Parent = MainFrame

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

    -- Логотип/Заголовок (Строго по центру)
    local Logo = Instance.new("TextLabel")
    Logo.Name = getStealthName()
    Logo.Size = UDim2.new(1, 0, 1, 0)
    Logo.Position = UDim2.new(0, 0, 0, 0)
    Logo.BackgroundTransparency = 1
    Logo.Text = "DEADHUB"
    Logo.TextColor3 = Color_Accent
    Logo.TextSize = 13
    Logo.Font = Enum.Font.GothamBold
    Logo.TextXAlignment = Enum.TextXAlignment.Center
    Logo.TextYAlignment = Enum.TextYAlignment.Center
    Logo.Parent = Header

    -- ПАНЕЛЬ ВКЛАДОК (Сверху в ряд)
    local TabBar = Instance.new("Frame")
    TabBar.Name = getStealthName()
    TabBar.Size = UDim2.new(1, 0, 0, 32)
    TabBar.Position = UDim2.new(0, 0, 0, 35)
    TabBar.BackgroundColor3 = Color_Header
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame

    local TabBarBottomLine = Instance.new("Frame")
    TabBarBottomLine.Size = UDim2.new(1, 0, 0, 1)
    TabBarBottomLine.Position = UDim2.new(0, 0, 0, 67)
    TabBarBottomLine.BackgroundColor3 = Color_Border
    TabBarBottomLine.BorderSizePixel = 0
    TabBarBottomLine.Parent = MainFrame

    -- ScrollingFrame для вкладок во избежание выхода за края
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = getStealthName()
    TabsScroll.Size = UDim2.new(1, -125, 1, 0)
    TabsScroll.Position = UDim2.new(0, 5, 0, 0)
    TabsScroll.BackgroundTransparency = 1
    TabsScroll.BorderSizePixel = 0
    TabsScroll.ScrollBarThickness = 0
    TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
    TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabsScroll.Parent = TabBar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabsScroll
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 8)

    -- Контейнер для страниц контента
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = getStealthName()
    PageContainer.Size = UDim2.new(1, -20, 1, -85)
    PageContainer.Position = UDim2.new(0, 10, 0, 75)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- FIX: Вертикальные линии-разделители перенесены на уровень PageContainer.
    -- Они статичны и ВСЕГДА идут до нижнего края меню, не корректируясь под высоту функций!
    local DivLine1 = Instance.new("Frame")
    DivLine1.Name = getStealthName()
    DivLine1.Size = UDim2.new(0, 1, 1, 0) -- Высота 100% от контейнера
    DivLine1.Position = UDim2.new(0.33, 2, 0, 0)
    DivLine1.BackgroundColor3 = Color_Border
    DivLine1.BorderSizePixel = 0
    DivLine1.ZIndex = 2
    DivLine1.Parent = PageContainer

    local DivLine2 = Instance.new("Frame")
    DivLine2.Name = getStealthName()
    DivLine2.Size = UDim2.new(0, 1, 1, 0) -- Высота 100% от контейнера
    DivLine2.Position = UDim2.new(0.66, 4, 0, 0)
    DivLine2.BackgroundColor3 = Color_Border
    DivLine2.BorderSizePixel = 0
    DivLine2.ZIndex = 2
    DivLine2.Parent = PageContainer

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

    -- Функция скрытия/показа меню (на клавишу RightShift)
    local isVisible = true
    local function toggleMenu()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end

    local toggleKeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleMenu()
        end
    end)
    trackConnection(toggleKeyConnection)

    -- Списки вкладок и страниц
    local activeTab = nil

    -- Вспомогательная функция создания окон, чтобы не дублировать код для Settings и обычных вкладок
    local function createGenericWindow(windowTitle, column, LeftCol, MidCol, RightCol)
        local targetColumn = LeftCol
        if column == "Middle" or column == "middle" or column == 2 or column == "Center" then
            targetColumn = MidCol
        elseif column == "Right" or column == "right" or column == 3 or column == "Settings" then
            targetColumn = RightCol
        end

        local WindowFrame = Instance.new("Frame")
        WindowFrame.Name = getStealthName()
        WindowFrame.Size = UDim2.new(1, 0, 0, 40)
        WindowFrame.BackgroundColor3 = Color_Card
        WindowFrame.BorderSizePixel = 0
        WindowFrame.Parent = targetColumn

        -- Элегантная обводка для окон
        local WindowStroke = Instance.new("UIStroke")
        WindowStroke.Color = Color3.fromRGB(35, 35, 40)
        WindowStroke.Thickness = 1
        WindowStroke.Parent = WindowFrame

        local WindowTitleLabel = Instance.new("TextLabel")
        WindowTitleLabel.Name = getStealthName()
        WindowTitleLabel.Size = UDim2.new(1, -20, 0, 26)
        WindowTitleLabel.Position = UDim2.new(0, 10, 0, 0)
        WindowTitleLabel.BackgroundTransparency = 1
        WindowTitleLabel.Text = windowTitle:upper()
        WindowTitleLabel.TextColor3 = Color_Accent
        WindowTitleLabel.TextSize = 10
        WindowTitleLabel.Font = Enum.Font.GothamBold
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

        -- Авто-подстройка высоты секции
        local paddingOffset = 10
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            WindowFrame.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y + 27 + paddingOffset)
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
            ToggleLabel.TextSize = 12
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleWrapper

            -- Квадратная кнопка
            local SquareBox = Instance.new("TextButton")
            SquareBox.Name = getStealthName()
            SquareBox.Size = UDim2.new(0, 16, 0, 16)
            SquareBox.Position = UDim2.new(1, -16, 0.5, -8)
            SquareBox.BackgroundColor3 = Color_BG
            SquareBox.BorderSizePixel = 0
            SquareBox.Text = ""
            SquareBox.AutoButtonColor = false
            SquareBox.Parent = ToggleWrapper

            -- Тонкая обводка вокруг бокса тоггла
            local ToggleBoxStroke = Instance.new("UIStroke")
            ToggleBoxStroke.Color = Color3.fromRGB(38, 38, 44)
            ToggleBoxStroke.Thickness = 1
            ToggleBoxStroke.Parent = SquareBox

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

            -- Ховер-эффект при наведении НА WRAPPER подсвечивает текст и бокс красным
            local wrapperHover = ToggleWrapper.MouseEnter:Connect(function()
                ToggleBoxStroke.Color = Color_Accent
                ToggleLabel.TextColor3 = Color_Accent
            end)
            local wrapperLeave = ToggleWrapper.MouseLeave:Connect(function()
                ToggleBoxStroke.Color = Color3.fromRGB(38, 38, 44)
                ToggleLabel.TextColor3 = Color_Text
            end)
            trackConnection(wrapperHover)
            trackConnection(wrapperLeave)

            local toggleClick = SquareBox.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                updateToggle()
            end)
            trackConnection(toggleClick)

            task.spawn(function() callback(toggleState) end)
        end

        -- Кнопка (Button)
        function WindowAPI:CreateButton(btnText, callback)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = getStealthName()
            ButtonFrame.Size = UDim2.new(1, -20, 0, 24)
            ButtonFrame.BackgroundColor3 = Color_BG
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = ContentFrame

            -- Обводка для кнопок
            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Color = Color3.fromRGB(38, 38, 44)
            ButtonStroke.Thickness = 1
            ButtonStroke.Parent = ButtonFrame

            local TextButton = Instance.new("TextButton")
            TextButton.Name = getStealthName()
            TextButton.Size = UDim2.new(1, 0, 1, 0)
            TextButton.BackgroundTransparency = 1
            TextButton.Text = btnText
            TextButton.TextColor3 = Color_TextDim
            TextButton.TextSize = 11
            TextButton.Font = Enum.Font.GothamBold
            TextButton.Parent = ButtonFrame

            -- Ховер-эффект подсвечивает текст и рамку красным при наведении
            local btnHover = TextButton.MouseEnter:Connect(function()
                ButtonStroke.Color = Color_Accent
                TextButton.TextColor3 = Color_Accent
            end)
            local btnLeave = TextButton.MouseLeave:Connect(function()
                ButtonStroke.Color = Color3.fromRGB(38, 38, 44)
                TextButton.TextColor3 = Color_TextDim
            end)
            trackConnection(btnHover)
            trackConnection(btnLeave)

            local btnClick = TextButton.MouseButton1Click:Connect(function()
                TextButton.TextColor3 = Color_Text
                task.wait(0.1)
                TextButton.TextColor3 = Color_TextDim
                callback()
            end)
            trackConnection(btnClick)
        end

        -- 4. СОЗДАНИЕ СЛАЙДЕРА (Квадратный, значение по центру)
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
            SliderLabel.TextSize = 12
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderWrapper

            -- Квадратный контейнер слайдера
            local SliderBar = Instance.new("TextButton")
            SliderBar.Name = getStealthName()
            SliderBar.Size = UDim2.new(1, 0, 0, 18)
            SliderBar.Position = UDim2.new(0, 0, 0, 20)
            SliderBar.BackgroundColor3 = Color_BG
            SliderBar.BorderSizePixel = 0
            SliderBar.Text = ""
            SliderBar.AutoButtonColor = false
            SliderBar.Parent = SliderWrapper

            -- Обводка для слайдеров
            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = Color3.fromRGB(38, 38, 44)
            SliderStroke.Thickness = 1
            SliderStroke.Parent = SliderBar

            -- Заполняющая полоса
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
            ValueLabel.TextSize = 11
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Center
            ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
            ValueLabel.Parent = SliderBar

            -- Ховер-эффект при наведении НА СЛАЙДЕР подсвечивает текст и обводку красным
            local sliderHover = SliderWrapper.MouseEnter:Connect(function()
                SliderStroke.Color = Color_Accent
                SliderLabel.TextColor3 = Color_Accent
            end)
            local sliderLeave = SliderWrapper.MouseLeave:Connect(function()
                SliderStroke.Color = Color3.fromRGB(38, 38, 44)
                SliderLabel.TextColor3 = Color_Text
            end)
            trackConnection(sliderHover)
            trackConnection(sliderLeave)

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

    -- Создание ПОСТОЯННОЙ вкладки Settings в правом углу
    local SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Name = getStealthName()
    SettingsBtn.Size = UDim2.new(0, 110, 1, 0)
    SettingsBtn.Position = UDim2.new(1, -115, 0, 0)
    SettingsBtn.BackgroundTransparency = 1
    SettingsBtn.Text = ""
    SettingsBtn.Parent = TabBar

    local SettingsIcon = Instance.new("ImageLabel")
    SettingsIcon.Name = getStealthName()
    SettingsIcon.Size = UDim2.new(0, 14, 0, 14)
    SettingsIcon.Position = UDim2.new(0, 8, 0.5, -7)
    SettingsIcon.BackgroundTransparency = 1
    SettingsIcon.Image = "rbxassetid://11932591062" -- FIX: Заменена иконка настроек на новую рабочую (11932591062)
    SettingsIcon.ImageColor3 = Color_TextDim
    SettingsIcon.Parent = SettingsBtn

    local SettingsLabel = Instance.new("TextLabel")
    SettingsLabel.Name = getStealthName()
    SettingsLabel.Size = UDim2.new(1, -28, 1, 0)
    SettingsLabel.Position = UDim2.new(0, 26, 0, 0)
    SettingsLabel.BackgroundTransparency = 1
    SettingsLabel.Text = "Settings"
    SettingsLabel.TextColor3 = Color_TextDim
    SettingsLabel.TextSize = 11
    SettingsLabel.Font = Enum.Font.GothamBold
    SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    SettingsLabel.Parent = SettingsBtn

    local SettingsIndicator = Instance.new("Frame")
    SettingsIndicator.Size = UDim2.new(1, 0, 0, 2)
    SettingsIndicator.Position = UDim2.new(0, 0, 1, -2)
    SettingsIndicator.BackgroundColor3 = Color_Accent
    SettingsIndicator.BorderSizePixel = 0
    SettingsIndicator.Visible = false
    SettingsIndicator.Parent = SettingsBtn

    local SettingsPage = Instance.new("ScrollingFrame")
    SettingsPage.Name = getStealthName()
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.BorderSizePixel = 0
    SettingsPage.Visible = false
    SettingsPage.ScrollBarThickness = 3
    SettingsPage.ScrollBarImageColor3 = Color_Border
    SettingsPage.ScrollingDirection = Enum.ScrollingDirection.Y
    SettingsPage.Parent = PageContainer

    -- Колонки для SettingsPage
    local sLeftColumn = Instance.new("Frame")
    sLeftColumn.Name = getStealthName()
    sLeftColumn.Size = UDim2.new(0.33, -6, 0, 0)
    sLeftColumn.Position = UDim2.new(0, 0, 0, 0)
    sLeftColumn.BackgroundTransparency = 1
    sLeftColumn.Parent = SettingsPage

    local sMiddleColumn = Instance.new("Frame")
    sMiddleColumn.Name = getStealthName()
    sMiddleColumn.Size = UDim2.new(0.33, -6, 0, 0)
    sMiddleColumn.Position = UDim2.new(0.33, 5, 0, 0)
    sMiddleColumn.BackgroundTransparency = 1
    sMiddleColumn.Parent = SettingsPage

    local sRightColumn = Instance.new("Frame")
    sRightColumn.Name = getStealthName()
    sRightColumn.Size = UDim2.new(0.34, -8, 0, 0)
    sRightColumn.Position = UDim2.new(0.66, 10, 0, 0)
    sRightColumn.BackgroundTransparency = 1
    sRightColumn.Parent = SettingsPage

    local sLeftList = Instance.new("UIListLayout")
    sLeftList.Parent = sLeftColumn
    sLeftList.SortOrder = Enum.SortOrder.LayoutOrder
    sLeftList.Padding = UDim.new(0, 10)

    local sMiddleList = Instance.new("UIListLayout")
    sMiddleList.Parent = sMiddleColumn
    sMiddleList.SortOrder = Enum.SortOrder.LayoutOrder
    sMiddleList.Padding = UDim.new(0, 10)

    local sRightList = Instance.new("UIListLayout")
    sRightList.Parent = sRightColumn
    sRightList.SortOrder = Enum.SortOrder.LayoutOrder
    sRightList.Padding = UDim.new(0, 10)

    local function updateSettingsCanvas()
        local lh = sLeftList.AbsoluteContentSize.Y
        local mh = sMiddleList.AbsoluteContentSize.Y
        local rh = sRightList.AbsoluteContentSize.Y
        local maxH = math.max(lh, mh, rh)
        SettingsPage.CanvasSize = UDim2.new(0, 0, 0, maxH + 10)
        sLeftColumn.Size = UDim2.new(0.33, -6, 0, lh)
        sMiddleColumn.Size = UDim2.new(0.33, -6, 0, mh)
        sRightColumn.Size = UDim2.new(0.34, -8, 0, rh)
    end
    sLeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSettingsCanvas)
    sMiddleList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSettingsCanvas)
    sRightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSettingsCanvas)

    local settingsSelect = SettingsBtn.MouseButton1Click:Connect(function()
        if activeTab then
            activeTab.Label.TextColor3 = Color_TextDim
            activeTab.Icon.ImageColor3 = Color_TextDim
            activeTab.Indicator.Visible = false
            activeTab.Page.Visible = false
        end
        SettingsLabel.TextColor3 = Color_Text
        SettingsIcon.ImageColor3 = Color_Text
        SettingsIndicator.Visible = true
        SettingsPage.Visible = true
        activeTab = {Btn = SettingsBtn, Label = SettingsLabel, Icon = SettingsIcon, Indicator = SettingsIndicator, Page = SettingsPage}
    end)
    trackConnection(settingsSelect)

    local settingsHover = SettingsBtn.MouseEnter:Connect(function()
        if activeTab and activeTab.Btn ~= SettingsBtn then
            SettingsLabel.TextColor3 = Color_Text
            SettingsIcon.ImageColor3 = Color_Text
        end
    end)
    local settingsLeave = SettingsBtn.MouseLeave:Connect(function()
        if activeTab and activeTab.Btn ~= SettingsBtn then
            SettingsLabel.TextColor3 = Color_TextDim
            SettingsIcon.ImageColor3 = Color_TextDim
        end
    end)
    trackConnection(settingsHover)
    trackConnection(settingsLeave)

    -- Экспортируем API управления вкладкой Settings
    local SettingsTabAPI = {}
    function SettingsTabAPI:CreateWindow(windowTitle, column)
        return createGenericWindow(windowTitle, column, sLeftColumn, sMiddleColumn, sRightColumn)
    end
    UI.Settings = SettingsTabAPI


    function UI:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = getStealthName()
        TabBtn.Size = UDim2.new(0, 115, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabsScroll

        -- Иконка таба
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = getStealthName()
        TabIcon.Size = UDim2.new(0, 14, 0, 14)
        TabIcon.Position = UDim2.new(0, 8, 0.5, -7)
        TabIcon.BackgroundTransparency = 1
        TabIcon.ImageColor3 = Color_TextDim
        
        -- Автоматический выбор иконки по имени вкладки (с поддержкой всех иконок VoltEclipse)
        local lowerName = tabName:lower()
        if lowerName:find("aim") or lowerName:find("combat") then
            TabIcon.Image = TabIcons.Combat
        elseif lowerName:find("move") or lowerName:find("speed") or lowerName:find("fly") then
            TabIcon.Image = TabIcons.Movement
        elseif lowerName:find("visual") or lowerName:find("esp") then
            TabIcon.Image = TabIcons.Visuals
        elseif lowerName:find("world") then
            TabIcon.Image = TabIcons.World
        elseif lowerName:find("auto") or lowerName:find("farm") or lowerName:find("fish") then
            TabIcon.Image = TabIcons.Auto
        elseif lowerName:find("gun") or lowerName:find("weapon") or lowerName:find("shoot") or lowerName:find("combat") then
            TabIcon.Image = TabIcons.Guns
        elseif lowerName:find("skin") or lowerName:find("paint") or lowerName:find("cosmetic") then
            TabIcon.Image = TabIcons.Skins
        else
            TabIcon.Image = TabIcons.Misc
        end
        TabIcon.Parent = TabBtn

        -- Текст вкладки
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = getStealthName()
        TabLabel.Size = UDim2.new(1, -28, 1, 0)
        TabLabel.Position = UDim2.new(0, 26, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.TextColor3 = Color_TextDim
        TabLabel.TextSize = 11
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

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
        Page.ScrollingDirection = Enum.ScrollingDirection.Y -- Строго вертикальный скролл
        Page.Parent = PageContainer

        -- ТРИ КОЛОНКИ (ESP - WORLD - MISC)
        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = getStealthName()
        LeftColumn.Size = UDim2.new(0.33, -6, 0, 0)
        LeftColumn.Position = UDim2.new(0, 0, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = Page

        local MiddleColumn = Instance.new("Frame")
        MiddleColumn.Name = getStealthName()
        MiddleColumn.Size = UDim2.new(0.33, -6, 0, 0)
        MiddleColumn.Position = UDim2.new(0.33, 5, 0, 0)
        MiddleColumn.BackgroundTransparency = 1
        MiddleColumn.Parent = Page

        local RightColumn = Instance.new("Frame")
        RightColumn.Name = getStealthName()
        RightColumn.Size = UDim2.new(0.34, -8, 0, 0)
        RightColumn.Position = UDim2.new(0.66, 10, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = Page

        local LeftList = Instance.new("UIListLayout")
        LeftList.Parent = LeftColumn
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Padding = UDim.new(0, 10)

        local MiddleList = Instance.new("UIListLayout")
        MiddleList.Parent = MiddleColumn
        MiddleList.SortOrder = Enum.SortOrder.LayoutOrder
        MiddleList.Padding = UDim.new(0, 10)

        local RightList = Instance.new("UIListLayout")
        RightList.Parent = RightColumn
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Padding = UDim.new(0, 10)

        -- Функция авто-подстройки высоты
        local function updateCanvasSize()
            local leftHeight = LeftList.AbsoluteContentSize.Y
            local middleHeight = MiddleList.AbsoluteContentSize.Y
            local rightHeight = RightList.AbsoluteContentSize.Y
            local maxHeight = math.max(leftHeight, middleHeight, rightHeight)
            
            Page.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 10)
            
            LeftColumn.Size = UDim2.new(0.33, -6, 0, leftHeight)
            MiddleColumn.Size = UDim2.new(0.33, -6, 0, middleHeight)
            RightColumn.Size = UDim2.new(0.34, -8, 0, rightHeight)
        end

        LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        MiddleList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        -- Эффект наведения на кнопки табов (Ховер-подсветка)
        local hoverConnection = TabBtn.MouseEnter:Connect(function()
            if activeTab and activeTab.Btn ~= TabBtn then
                TabLabel.TextColor3 = Color_Text
                TabIcon.ImageColor3 = Color_Text
            end
        end)
        local leaveConnection = TabBtn.MouseLeave:Connect(function()
            if activeTab and activeTab.Btn ~= TabBtn then
                TabLabel.TextColor3 = Color_TextDim
                TabIcon.ImageColor3 = Color_TextDim
            end
        end)
        trackConnection(hoverConnection)
        trackConnection(leaveConnection)

        local tabSelect = TabBtn.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Label.TextColor3 = Color_TextDim
                activeTab.Icon.ImageColor3 = Color_TextDim
                activeTab.Indicator.Visible = false
                activeTab.Page.Visible = false
            end
            
            TabLabel.TextColor3 = Color_Text
            TabIcon.ImageColor3 = Color_Text
            TabIndicator.Visible = true
            Page.Visible = true
            activeTab = {Btn = TabBtn, Label = TabLabel, Icon = TabIcon, Indicator = TabIndicator, Page = Page}
        end)
        trackConnection(tabSelect)

        if not activeTab then
            TabLabel.TextColor3 = Color_Text
            TabIcon.ImageColor3 = Color_Text
            TabIndicator.Visible = true
            Page.Visible = true
            activeTab = {Btn = TabBtn, Label = TabLabel, Icon = TabIcon, Indicator = TabIndicator, Page = Page}
        end

        local TabAPI = {}

        -- 2. СОЗДАНИЕ ОКОН ВО ВКЛАДКАХ
        function TabAPI:CreateWindow(windowTitle, column)
            return createGenericWindow(windowTitle, column, LeftColumn, MiddleColumn, RightColumn)
        end

        return TabAPI
    end

    -- Уничтожение UI для сборщика мусора
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
