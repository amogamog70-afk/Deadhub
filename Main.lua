-- [[ DEADHUB STEALTH UI LIBRARY v2.1 ]] --

local DeadHub = {}

local parentContainer = gethui and gethui() or game:GetService("CoreGui")

local legalNames = {
    "InventoryFrame","SettingsButton","CraftingMenu","HudLayout","MainFrame",
    "QuickBar","LootPanel","StatusHUD","ClientHUD","InteractivePrompt",
    "MapContainer","ChatLayout","PlayerList","LeaderboardFrame","NotificationCenter"
}
local function rn()
    return legalNames[math.random(1,#legalNames)].."_"..tostring(math.random(100,999))
end

local conns = {}
local function track(c) table.insert(conns, c) return c end

local TabIcons = {
    Combat   = "rbxassetid://12614416478",
    Movement = "rbxassetid://136160678435000",
    Visuals  = "rbxassetid://102976018150012",
    Misc     = "rbxassetid://137382232901580",
    World    = "rbxassetid://122563205713088",
    Auto     = "rbxassetid://102927017461693",
    Guns     = "rbxassetid://84647432170503",
    Skins    = "rbxassetid://101708694952341",
}

function DeadHub:Init()
    local UI = {}

    -- ── Цвета ──
    local C_BG      = Color3.fromRGB(9, 9, 11)
    local C_CARD    = Color3.fromRGB(14, 14, 17)
    local C_HEADER  = Color3.fromRGB(11, 11, 14)
    local C_BORDER  = Color3.fromRGB(30, 30, 36)
    local C_ACCENT  = Color3.fromRGB(220, 30, 50)
    local C_TEXT    = Color3.fromRGB(220, 220, 225)
    local C_DIM     = Color3.fromRGB(100, 100, 110)
    local C_BOX     = Color3.fromRGB(22, 22, 27)
    local TweenService = game:GetService("TweenService")
    local UIS = game:GetService("UserInputService")

    -- ── ScreenGui ──
    local SG = Instance.new("ScreenGui")
    SG.Name = rn(); SG.ResetOnSpawn = false; SG.Parent = parentContainer

    -- ── MainFrame ──
    local MF = Instance.new("Frame")
    MF.Name = rn(); MF.Size = UDim2.new(0,720,0,450)
    MF.Position = UDim2.new(0.5,-360,0.5,-225)
    MF.BackgroundColor3 = C_BG; MF.BorderSizePixel = 0; MF.Parent = SG
    local mStroke = Instance.new("UIStroke")
    mStroke.Color = C_ACCENT; mStroke.Thickness = 1; mStroke.Parent = MF

    -- ── Header ──
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1,0,0,36)
    Header.BackgroundColor3 = C_HEADER; Header.BorderSizePixel = 0; Header.Parent = MF
    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(1,0,0,1); hLine.Position = UDim2.new(0,0,1,-1)
    hLine.BackgroundColor3 = C_BORDER; hLine.BorderSizePixel = 0; hLine.Parent = Header

    -- Logo
    local LogoBg = Instance.new("Frame")
    LogoBg.Size = UDim2.new(0,96,0,20); LogoBg.Position = UDim2.new(0.5,-48,0.5,-10)
    LogoBg.BackgroundColor3 = C_HEADER; LogoBg.BorderSizePixel = 0; LogoBg.Parent = Header
    local lStr = Instance.new("UIStroke"); lStr.Color = C_ACCENT; lStr.Thickness = 1; lStr.Parent = LogoBg
    local LogoLbl = Instance.new("TextLabel")
    LogoLbl.Size = UDim2.new(1,0,1,0); LogoLbl.BackgroundTransparency = 1
    LogoLbl.Text = "DEADHUB"; LogoLbl.TextColor3 = C_ACCENT
    LogoLbl.TextSize = 11; LogoLbl.Font = Enum.Font.GothamBold
    LogoLbl.TextXAlignment = Enum.TextXAlignment.Center; LogoLbl.Parent = LogoBg

    -- ── TabBar ──
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1,0,0,30)
    TabBar.Position = UDim2.new(0,0,0,36)
    TabBar.BackgroundColor3 = C_HEADER; TabBar.BorderSizePixel = 0; TabBar.Parent = MF
    local tbLine = Instance.new("Frame")
    tbLine.Size = UDim2.new(1,0,0,1); tbLine.Position = UDim2.new(0,0,0,66)
    tbLine.BackgroundColor3 = C_BORDER; tbLine.BorderSizePixel = 0; tbLine.Parent = MF

    -- TabsScroll (обычные вкладки)
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Size = UDim2.new(1,-118,1,0); TabsScroll.Position = UDim2.new(0,4,0,0)
    TabsScroll.BackgroundTransparency = 1; TabsScroll.BorderSizePixel = 0
    TabsScroll.ScrollBarThickness = 0; TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
    TabsScroll.CanvasSize = UDim2.new(0,0,0,0)
    TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X; TabsScroll.Parent = TabBar
    local TLL = Instance.new("UIListLayout"); TLL.Parent = TabsScroll
    TLL.FillDirection = Enum.FillDirection.Horizontal
    TLL.SortOrder = Enum.SortOrder.LayoutOrder
    TLL.VerticalAlignment = Enum.VerticalAlignment.Center
    TLL.Padding = UDim.new(0,2)

    -- PageContainer
    local PC = Instance.new("Frame")
    PC.Name = rn(); PC.Size = UDim2.new(1,-16,1,-78)
    PC.Position = UDim2.new(0,8,0,70)
    PC.BackgroundTransparency = 1; PC.Parent = MF

    -- Разделительные линии колонок (статичные)
    local function makeDivLine(xScale, xOffset)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0,1,1,0); d.Position = UDim2.new(xScale,xOffset,0,0)
        d.BackgroundColor3 = C_BORDER; d.BorderSizePixel = 0; d.ZIndex = 2; d.Parent = PC
    end
    makeDivLine(1/3,-1); makeDivLine(2/3,1)

    -- Drag
    local dragging, dragInput, dragStart, startPos
    track(Header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = inp.Position; startPos = MF.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end))
    track(Header.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
    end))
    track(UIS.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local d = inp.Position - dragStart
            MF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end))

    track(UIS.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.RightShift then
            MF.Visible = not MF.Visible
        end
    end))

    local activeTab = nil

    -- ──────────────────── SETTINGS TAB ────────────────────
    local SBtn = Instance.new("TextButton")
    SBtn.Size = UDim2.new(0,108,1,0); SBtn.Position = UDim2.new(1,-112,0,0)
    SBtn.BackgroundTransparency = 1; SBtn.Text = ""; SBtn.Parent = TabBar

    local SIco = Instance.new("ImageLabel")
    SIco.Size = UDim2.new(0,13,0,13); SIco.Position = UDim2.new(0,8,0.5,-6)
    SIco.BackgroundTransparency = 1; SIco.Image = "rbxassetid://11932591062"
    SIco.ImageColor3 = C_DIM; SIco.Parent = SBtn

    local SLbl = Instance.new("TextLabel")
    SLbl.Size = UDim2.new(1,-26,1,0); SLbl.Position = UDim2.new(0,24,0,0)
    SLbl.BackgroundTransparency = 1; SLbl.Text = "Settings"
    SLbl.TextColor3 = C_DIM; SLbl.TextSize = 11; SLbl.Font = Enum.Font.GothamBold
    SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.Parent = SBtn

    local SInd = Instance.new("Frame")
    SInd.Size = UDim2.new(1,0,0,2); SInd.Position = UDim2.new(0,0,1,-2)
    SInd.BackgroundColor3 = C_ACCENT; SInd.BorderSizePixel = 0; SInd.Visible = false; SInd.Parent = SBtn

    local SPage = Instance.new("ScrollingFrame")
    SPage.Size = UDim2.new(1,0,1,0); SPage.BackgroundTransparency = 1
    SPage.BorderSizePixel = 0; SPage.Visible = false
    SPage.ScrollBarThickness = 0; SPage.ScrollingDirection = Enum.ScrollingDirection.Y; SPage.Parent = PC

    local sL = Instance.new("Frame"); sL.Size = UDim2.new(1/3,-8,0,0); sL.Position = UDim2.new(0,0,0,0); sL.BackgroundTransparency = 1; sL.Parent = SPage
    local sM = Instance.new("Frame"); sM.Size = UDim2.new(1/3,-8,0,0); sM.Position = UDim2.new(1/3,4,0,0); sM.BackgroundTransparency = 1; sM.Parent = SPage
    local sR = Instance.new("Frame"); sR.Size = UDim2.new(1/3,-8,0,0); sR.Position = UDim2.new(2/3,8,0,0); sR.BackgroundTransparency = 1; sR.Parent = SPage
    local sLL = Instance.new("UIListLayout"); sLL.Parent = sL; sLL.SortOrder = Enum.SortOrder.LayoutOrder; sLL.Padding = UDim.new(0,8)
    local sML = Instance.new("UIListLayout"); sML.Parent = sM; sML.SortOrder = Enum.SortOrder.LayoutOrder; sML.Padding = UDim.new(0,8)
    local sRL = Instance.new("UIListLayout"); sRL.Parent = sR; sRL.SortOrder = Enum.SortOrder.LayoutOrder; sRL.Padding = UDim.new(0,8)
    local function updateSCanvas()
        local mh = math.max(sLL.AbsoluteContentSize.Y, sML.AbsoluteContentSize.Y, sRL.AbsoluteContentSize.Y)
        SPage.CanvasSize = UDim2.new(0,0,0,mh+10)
        sL.Size = UDim2.new(1/3,-8,0,sLL.AbsoluteContentSize.Y)
        sM.Size = UDim2.new(1/3,-8,0,sML.AbsoluteContentSize.Y)
        sR.Size = UDim2.new(1/3,-8,0,sRL.AbsoluteContentSize.Y)
    end
    sLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSCanvas)
    sML:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSCanvas)
    sRL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSCanvas)

    track(SBtn.MouseButton1Click:Connect(function()
        if activeTab then
            activeTab.Lbl.TextColor3 = C_DIM; activeTab.Ico.ImageColor3 = C_DIM
            activeTab.Ind.Visible = false; activeTab.Page.Visible = false
        end
        SLbl.TextColor3 = C_TEXT; SIco.ImageColor3 = C_TEXT
        SInd.Visible = true; SPage.Visible = true
        activeTab = {Btn=SBtn, Lbl=SLbl, Ico=SIco, Ind=SInd, Page=SPage}
    end))
    track(SBtn.MouseEnter:Connect(function()
        if not (activeTab and activeTab.Btn == SBtn) then SLbl.TextColor3=C_ACCENT; SIco.ImageColor3=C_ACCENT end
    end))
    track(SBtn.MouseLeave:Connect(function()
        if not (activeTab and activeTab.Btn == SBtn) then SLbl.TextColor3=C_DIM; SIco.ImageColor3=C_DIM end
    end))

    -- ──────────────────── WINDOW BUILDER ────────────────────
    local function buildWindow(title, col, LC, MC, RC)
        local tgt = LC
        if col=="Middle" or col==2 then tgt=MC
        elseif col=="Right" or col==3 then tgt=RC end

        local WF = Instance.new("Frame")
        WF.Size = UDim2.new(1,0,0,36); WF.BackgroundColor3 = C_CARD; WF.BorderSizePixel = 0; WF.Parent = tgt
        local ws = Instance.new("UIStroke"); ws.Color = C_BORDER; ws.Thickness = 1; ws.Parent = WF

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1,-16,0,24); TitleLbl.Position = UDim2.new(0,8,0,0)
        TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = title:upper()
        TitleLbl.TextColor3 = C_ACCENT; TitleLbl.TextSize = 9; TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = WF

        local Sep = Instance.new("Frame")
        Sep.Size = UDim2.new(1,-16,0,1); Sep.Position = UDim2.new(0,8,0,23)
        Sep.BackgroundColor3 = C_BORDER; Sep.BorderSizePixel = 0; Sep.Parent = WF

        local CF = Instance.new("Frame")
        CF.Size = UDim2.new(1,0,1,-28); CF.Position = UDim2.new(0,0,0,28)
        CF.BackgroundTransparency = 1; CF.Parent = WF

        local CL = Instance.new("UIListLayout"); CL.Parent = CF
        CL.SortOrder = Enum.SortOrder.LayoutOrder; CL.Padding = UDim.new(0,4)
        CL.HorizontalAlignment = Enum.HorizontalAlignment.Center

        CL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            WF.Size = UDim2.new(1,0,0, CL.AbsoluteContentSize.Y+28+8)
        end)

        local W = {}

        -- ── BUTTON ──
        function W:CreateButton(txt, cb)
            local BF = Instance.new("Frame")
            BF.Size = UDim2.new(1,-16,0,22); BF.BackgroundColor3 = C_BOX; BF.BorderSizePixel = 0; BF.Parent = CF
            local bs = Instance.new("UIStroke"); bs.Color = C_BORDER; bs.Thickness = 1; bs.Parent = BF
            local TB = Instance.new("TextButton")
            TB.Size = UDim2.new(1,0,1,0); TB.BackgroundTransparency = 1
            TB.Text = txt; TB.TextColor3 = C_DIM; TB.TextSize = 11; TB.Font = Enum.Font.GothamBold; TB.Parent = BF
            track(TB.MouseEnter:Connect(function() TB.TextColor3 = C_ACCENT end))
            track(TB.MouseLeave:Connect(function() TB.TextColor3 = C_DIM end))
            track(TB.MouseButton1Click:Connect(function()
                TB.TextColor3 = C_TEXT
                task.spawn(function() task.wait(0.08); TB.TextColor3 = C_DIM end)
                cb()
            end))
        end

        -- ── TOGGLE ── (режим [T]/[H]/[A] — компактный, циклится по клику)
        function W:CreateToggle(txt, default, style, cb)
            local modes = {"Toggle", "Hold", "Always"}
            local mShort = {Toggle="T", Hold="H", Always="A"}
            style = style or "Toggle"
            local mIdx = 1
            for i,s in ipairs(modes) do if s==style then mIdx=i break end end
            local currentMode = style
            local state = (style=="Always") and true or (default or false)

            local TW = Instance.new("Frame")
            TW.Size = UDim2.new(1,-16,0,22); TW.BackgroundTransparency = 1; TW.Parent = CF

            -- Чекбокс (левый)
            local Box = Instance.new("TextButton")
            Box.Size = UDim2.new(0,14,0,14); Box.Position = UDim2.new(0,4,0.5,-7)
            Box.BackgroundColor3 = C_BOX; Box.BorderSizePixel = 0; Box.Text = ""; Box.AutoButtonColor = false; Box.Parent = TW
            local BoxStr = Instance.new("UIStroke"); BoxStr.Color = C_BORDER; BoxStr.Thickness = 1; BoxStr.Parent = Box
            local Inner = Instance.new("Frame")
            Inner.Size = UDim2.new(0,8,0,8); Inner.Position = UDim2.new(0.5,-4,0.5,-4)
            Inner.BackgroundColor3 = C_ACCENT; Inner.BorderSizePixel = 0; Inner.Visible = state; Inner.Parent = Box

            -- Имя функции
            local TLbl = Instance.new("TextLabel")
            TLbl.Size = UDim2.new(1,-46,1,0); TLbl.Position = UDim2.new(0,24,0,0)
            TLbl.BackgroundTransparency = 1; TLbl.Text = txt
            TLbl.TextColor3 = C_DIM; TLbl.TextSize = 11; TLbl.Font = Enum.Font.Gotham
            TLbl.TextXAlignment = Enum.TextXAlignment.Left; TLbl.Parent = TW

            -- Бейдж режима [T/H/A]
            local MBtn = Instance.new("TextButton")
            MBtn.Size = UDim2.new(0,18,0,14); MBtn.Position = UDim2.new(1,-20,0.5,-7)
            MBtn.BackgroundColor3 = C_BG; MBtn.BorderSizePixel = 0
            MBtn.Text = mShort[currentMode]; MBtn.TextColor3 = C_DIM
            MBtn.TextSize = 9; MBtn.Font = Enum.Font.GothamBold; MBtn.Parent = TW
            local MStr = Instance.new("UIStroke"); MStr.Color = C_BORDER; MStr.Thickness = 1; MStr.Parent = MBtn

            local function applyMode(m)
                currentMode = m; MBtn.Text = mShort[m]
                if m == "Always" then
                    state = true; Inner.Visible = true; cb(true)
                else
                    state = false; Inner.Visible = false; cb(false)
                end
            end

            track(MBtn.MouseButton1Click:Connect(function()
                mIdx = (mIdx % #modes) + 1
                applyMode(modes[mIdx])
            end))
            track(MBtn.MouseEnter:Connect(function() MBtn.TextColor3 = C_ACCENT end))
            track(MBtn.MouseLeave:Connect(function() MBtn.TextColor3 = C_DIM end))

            track(Box.MouseButton1Down:Connect(function()
                if currentMode == "Toggle" then
                    state = not state; Inner.Visible = state; cb(state)
                elseif currentMode == "Hold" then
                    state = true; Inner.Visible = true; cb(true)
                end
            end))
            track(Box.MouseButton1Up:Connect(function()
                if currentMode == "Hold" then
                    state = false; Inner.Visible = false; cb(false)
                end
            end))

            track(TW.MouseEnter:Connect(function() TLbl.TextColor3 = C_ACCENT end))
            track(TW.MouseLeave:Connect(function() TLbl.TextColor3 = C_DIM end))

            task.spawn(function() cb(state) end)
        end

        -- ── SLIDER ──
        function W:CreateSlider(txt, min, max, default, cb)
            local val = default or min
            local SW = Instance.new("Frame")
            SW.Size = UDim2.new(1,-16,0,38); SW.BackgroundTransparency = 1; SW.Parent = CF
            local SLbl = Instance.new("TextLabel")
            SLbl.Size = UDim2.new(1,0,0,16); SLbl.BackgroundTransparency = 1; SLbl.Text = txt
            SLbl.TextColor3 = C_DIM; SLbl.TextSize = 11; SLbl.Font = Enum.Font.Gotham
            SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.Parent = SW
            local SBar = Instance.new("TextButton")
            SBar.Size = UDim2.new(1,0,0,18); SBar.Position = UDim2.new(0,0,0,18)
            SBar.BackgroundColor3 = C_BOX; SBar.BorderSizePixel = 0; SBar.Text = ""; SBar.AutoButtonColor = false; SBar.Parent = SW
            local SS = Instance.new("UIStroke"); SS.Color = C_BORDER; SS.Thickness = 1; SS.Parent = SBar
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
            Fill.BackgroundColor3 = C_ACCENT; Fill.BorderSizePixel = 0; Fill.Parent = SBar
            local VLbl = Instance.new("TextLabel")
            VLbl.Size = UDim2.new(1,0,1,0); VLbl.BackgroundTransparency = 1
            VLbl.Text = tostring(val); VLbl.TextColor3 = C_TEXT; VLbl.TextSize = 10
            VLbl.Font = Enum.Font.GothamBold; VLbl.TextXAlignment = Enum.TextXAlignment.Center; VLbl.Parent = SBar
            track(SW.MouseEnter:Connect(function() SLbl.TextColor3 = C_ACCENT end))
            track(SW.MouseLeave:Connect(function() SLbl.TextColor3 = C_DIM end))
            local sliding = false
            local function upd(inp)
                local p = math.clamp((inp.Position.X-SBar.AbsolutePosition.X)/SBar.AbsoluteSize.X,0,1)
                val = math.floor(min+(max-min)*p)
                Fill.Size = UDim2.new(p,0,1,0); VLbl.Text = tostring(val); cb(val)
            end
            track(SBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; upd(i) end end))
            track(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end))
            track(UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end))
            task.spawn(function() cb(val) end)
        end

        -- ── DROPDOWN ──
        function W:CreateDropdown(txt, opts, default, cb)
            local sel = default or opts[1] or ""
            local opened = false
            local DW = Instance.new("Frame")
            DW.Size = UDim2.new(1,-16,0,38); DW.BackgroundTransparency = 1; DW.Parent = CF
            local DLbl = Instance.new("TextLabel")
            DLbl.Size = UDim2.new(1,0,0,16); DLbl.BackgroundTransparency = 1; DLbl.Text = txt
            DLbl.TextColor3 = C_DIM; DLbl.TextSize = 11; DLbl.Font = Enum.Font.Gotham
            DLbl.TextXAlignment = Enum.TextXAlignment.Left; DLbl.Parent = DW
            local DBt = Instance.new("TextButton")
            DBt.Size = UDim2.new(1,0,0,18); DBt.Position = UDim2.new(0,0,0,18)
            DBt.BackgroundColor3 = C_BOX; DBt.BorderSizePixel = 0
            DBt.Text = "  "..sel; DBt.TextColor3 = C_TEXT; DBt.TextSize = 10
            DBt.Font = Enum.Font.Gotham; DBt.TextXAlignment = Enum.TextXAlignment.Left; DBt.Parent = DW
            local DS = Instance.new("UIStroke"); DS.Color = C_BORDER; DS.Thickness = 1; DS.Parent = DBt
            local Arr = Instance.new("TextLabel")
            Arr.Size = UDim2.new(0,16,1,0); Arr.Position = UDim2.new(1,-16,0,0)
            Arr.BackgroundTransparency = 1; Arr.Text = "▾"; Arr.TextColor3 = C_DIM
            Arr.TextSize = 10; Arr.Font = Enum.Font.GothamBold; Arr.Parent = DBt
            local OList = Instance.new("Frame")
            OList.Size = UDim2.new(1,0,0,0); OList.Position = UDim2.new(0,0,0,36)
            OList.BackgroundColor3 = C_CARD; OList.BorderSizePixel = 0; OList.Visible = false; OList.ZIndex = 5; OList.Parent = DW
            local OStr = Instance.new("UIStroke"); OStr.Color = C_BORDER; OStr.Thickness = 1; OStr.Parent = OList
            local OLL = Instance.new("UIListLayout"); OLL.Parent = OList; OLL.SortOrder = Enum.SortOrder.LayoutOrder
            local function toggle()
                opened = not opened; OList.Visible = opened; Arr.Text = opened and "▴" or "▾"
                DW.Size = opened and UDim2.new(1,-16,0,38+#opts*18) or UDim2.new(1,-16,0,38)
                OList.Size = opened and UDim2.new(1,0,0,#opts*18) or UDim2.new(1,0,0,0)
            end
            for _,o in ipairs(opts) do
                local OB = Instance.new("TextButton")
                OB.Size = UDim2.new(1,0,0,18); OB.BackgroundColor3 = C_BG; OB.BorderSizePixel = 0
                OB.Text = "  "..o; OB.TextColor3 = (o==sel) and C_ACCENT or C_DIM
                OB.TextSize = 10; OB.Font = Enum.Font.Gotham; OB.TextXAlignment = Enum.TextXAlignment.Left; OB.ZIndex = 6; OB.Parent = OList
                OB.MouseEnter:Connect(function() OB.TextColor3 = C_ACCENT end)
                OB.MouseLeave:Connect(function() if o~=sel then OB.TextColor3 = C_DIM end end)
                OB.MouseButton1Click:Connect(function()
                    sel = o; DBt.Text = "  "..o
                    for _,ch in ipairs(OList:GetChildren()) do
                        if ch:IsA("TextButton") then ch.TextColor3 = (ch.Text=="  "..o) and C_ACCENT or C_DIM end
                    end
                    toggle(); cb(o)
                end)
            end
            track(DBt.MouseButton1Click:Connect(toggle))
            track(DW.MouseEnter:Connect(function() DLbl.TextColor3 = C_ACCENT end))
            track(DW.MouseLeave:Connect(function() DLbl.TextColor3 = C_DIM end))
            task.spawn(function() cb(sel) end)
        end

        -- ── MULTISELECT ──
        function W:CreateMultiSelect(txt, opts, defaults, cb)
            local sel = defaults or {}
            local opened = false
            local DW = Instance.new("Frame")
            DW.Size = UDim2.new(1,-16,0,38); DW.BackgroundTransparency = 1; DW.Parent = CF
            local DLbl = Instance.new("TextLabel")
            DLbl.Size = UDim2.new(1,0,0,16); DLbl.BackgroundTransparency = 1; DLbl.Text = txt
            DLbl.TextColor3 = C_DIM; DLbl.TextSize = 11; DLbl.Font = Enum.Font.Gotham
            DLbl.TextXAlignment = Enum.TextXAlignment.Left; DLbl.Parent = DW
            local function getStr()
                local t={}
                for k,v in pairs(sel) do if v then table.insert(t,k) end end
                return #t==0 and "None" or table.concat(t,", ")
            end
            local DBt = Instance.new("TextButton")
            DBt.Size = UDim2.new(1,0,0,18); DBt.Position = UDim2.new(0,0,0,18)
            DBt.BackgroundColor3 = C_BOX; DBt.BorderSizePixel = 0
            DBt.Text = "  "..getStr(); DBt.TextColor3 = C_TEXT; DBt.TextSize = 10
            DBt.Font = Enum.Font.Gotham; DBt.TextXAlignment = Enum.TextXAlignment.Left; DBt.Parent = DW
            local DS = Instance.new("UIStroke"); DS.Color = C_BORDER; DS.Thickness = 1; DS.Parent = DBt
            local Arr = Instance.new("TextLabel")
            Arr.Size = UDim2.new(0,16,1,0); Arr.Position = UDim2.new(1,-16,0,0)
            Arr.BackgroundTransparency = 1; Arr.Text = "▾"; Arr.TextColor3 = C_DIM
            Arr.TextSize = 10; Arr.Font = Enum.Font.GothamBold; Arr.Parent = DBt
            local OList = Instance.new("Frame")
            OList.Size = UDim2.new(1,0,0,0); OList.Position = UDim2.new(0,0,0,36)
            OList.BackgroundColor3 = C_CARD; OList.BorderSizePixel = 0; OList.Visible = false; OList.ZIndex = 5; OList.Parent = DW
            local OStr = Instance.new("UIStroke"); OStr.Color = C_BORDER; OStr.Thickness = 1; OStr.Parent = OList
            local OLL = Instance.new("UIListLayout"); OLL.Parent = OList; OLL.SortOrder = Enum.SortOrder.LayoutOrder
            local function toggle()
                opened = not opened; OList.Visible = opened; Arr.Text = opened and "▴" or "▾"
                DW.Size = opened and UDim2.new(1,-16,0,38+#opts*18) or UDim2.new(1,-16,0,38)
                OList.Size = opened and UDim2.new(1,0,0,#opts*18) or UDim2.new(1,0,0,0)
            end
            for _,o in ipairs(opts) do
                local OB = Instance.new("TextButton")
                OB.Size = UDim2.new(1,0,0,18); OB.BackgroundColor3 = C_BG; OB.BorderSizePixel = 0
                OB.Text = "  "..o; OB.TextColor3 = sel[o] and C_ACCENT or C_DIM
                OB.TextSize = 10; OB.Font = Enum.Font.Gotham; OB.TextXAlignment = Enum.TextXAlignment.Left; OB.ZIndex = 6; OB.Parent = OList
                OB.MouseEnter:Connect(function() OB.TextColor3 = C_ACCENT end)
                OB.MouseLeave:Connect(function() if not sel[o] then OB.TextColor3 = C_DIM end end)
                OB.MouseButton1Click:Connect(function()
                    sel[o] = not sel[o]; OB.TextColor3 = sel[o] and C_ACCENT or C_DIM
                    DBt.Text = "  "..getStr(); cb(sel)
                end)
            end
            track(DBt.MouseButton1Click:Connect(toggle))
            track(DW.MouseEnter:Connect(function() DLbl.TextColor3 = C_ACCENT end))
            track(DW.MouseLeave:Connect(function() DLbl.TextColor3 = C_DIM end))
            task.spawn(function() cb(sel) end)
        end

        -- ── COLORPICKER — [■] слева от имени, RGB слайдеры ──
        function W:CreateColorPicker(txt, default, cb)
            local color = default or Color3.fromRGB(220,30,50)
            local opened = false
            local PW = Instance.new("Frame")
            PW.Size = UDim2.new(1,-16,0,22); PW.BackgroundTransparency = 1; PW.Parent = CF
            -- Цветной квадрат СЛЕВА
            local CBox = Instance.new("TextButton")
            CBox.Size = UDim2.new(0,18,0,14); CBox.Position = UDim2.new(0,2,0.5,-7)
            CBox.BackgroundColor3 = color; CBox.BorderSizePixel = 0; CBox.Text = ""; CBox.Parent = PW
            local CS = Instance.new("UIStroke"); CS.Color = C_BORDER; CS.Thickness = 1; CS.Parent = CBox
            -- Имя справа от квадрата
            local PLbl = Instance.new("TextLabel")
            PLbl.Size = UDim2.new(1,-28,1,0); PLbl.Position = UDim2.new(0,24,0,0)
            PLbl.BackgroundTransparency = 1; PLbl.Text = txt
            PLbl.TextColor3 = C_DIM; PLbl.TextSize = 11; PLbl.Font = Enum.Font.Gotham
            PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.Parent = PW
            -- RGB панель
            local Panel = Instance.new("Frame")
            Panel.Size = UDim2.new(1,0,0,60); Panel.Position = UDim2.new(0,0,0,22)
            Panel.BackgroundColor3 = C_CARD; Panel.BorderSizePixel = 0; Panel.Visible = false; Panel.ZIndex = 5; Panel.Parent = PW
            local PS = Instance.new("UIStroke"); PS.Color = C_BORDER; PS.Thickness = 1; PS.Parent = Panel
            local r,g,b = color.R, color.G, color.B
            local function upd() color = Color3.new(r,g,b); CBox.BackgroundColor3=color; cb(color) end
            local function mkRGB(label, initVal, yOff, setter)
                local SL = Instance.new("TextButton")
                SL.Size = UDim2.new(1,-12,0,14); SL.Position = UDim2.new(0,6,0,yOff)
                SL.BackgroundColor3 = C_BOX; SL.BorderSizePixel = 0; SL.Text = ""; SL.ZIndex = 6; SL.Parent = Panel
                local SS = Instance.new("UIStroke"); SS.Color = C_BORDER; SS.Thickness = 1; SS.Parent = SL
                local F = Instance.new("Frame"); F.Size = UDim2.new(initVal,0,1,0); F.BackgroundColor3 = C_ACCENT; F.BorderSizePixel = 0; F.Parent = SL
                local L = Instance.new("TextLabel"); L.Size = UDim2.new(1,0,1,0)
                L.BackgroundTransparency = 1; L.Text = label..": "..tostring(math.floor(initVal*255))
                L.TextColor3 = C_TEXT; L.TextSize = 8; L.Font = Enum.Font.GothamBold; L.ZIndex = 7; L.Parent = SL
                local sl = false
                local function sv(i)
                    local p = math.clamp((i.Position.X-SL.AbsolutePosition.X)/SL.AbsoluteSize.X,0,1)
                    F.Size = UDim2.new(p,0,1,0); L.Text = label..": "..tostring(math.floor(p*255))
                    setter(p); upd()
                end
                SL.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true; sv(i) end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
                UIS.InputChanged:Connect(function(i) if sl and i.UserInputType==Enum.UserInputType.MouseMovement then sv(i) end end)
            end
            mkRGB("R", r, 4,  function(v) r=v end)
            mkRGB("G", g, 22, function(v) g=v end)
            mkRGB("B", b, 40, function(v) b=v end)
            CBox.MouseButton1Click:Connect(function()
                opened = not opened; Panel.Visible = opened
                PW.Size = opened and UDim2.new(1,-16,0,86) or UDim2.new(1,-16,0,22)
                CS.Color = opened and C_ACCENT or C_BORDER
            end)
            track(PW.MouseEnter:Connect(function() PLbl.TextColor3 = C_ACCENT end))
            track(PW.MouseLeave:Connect(function() PLbl.TextColor3 = C_DIM end))
            task.spawn(function() cb(color) end)
        end

        -- ── KEYBIND — компактная [KEY] кнопка справа от имени, клавиатура + мышь ──
        function W:CreateKeybind(txt, default, cb)
            local keyName = (default and default ~= Enum.KeyCode.Unknown) and default.Name or "None"
            local binding = false

            local KW = Instance.new("Frame")
            KW.Size = UDim2.new(1,-16,0,22); KW.BackgroundTransparency = 1; KW.Parent = CF
            local KLbl = Instance.new("TextLabel")
            KLbl.Size = UDim2.new(1,-64,1,0); KLbl.BackgroundTransparency = 1; KLbl.Text = txt
            KLbl.TextColor3 = C_DIM; KLbl.TextSize = 11; KLbl.Font = Enum.Font.Gotham
            KLbl.TextXAlignment = Enum.TextXAlignment.Left; KLbl.Parent = KW
            local KBtn = Instance.new("TextButton")
            KBtn.Size = UDim2.new(0,58,0,16); KBtn.Position = UDim2.new(1,-60,0.5,-8)
            KBtn.BackgroundColor3 = C_BOX; KBtn.BorderSizePixel = 0
            KBtn.Text = "["..keyName.."]"; KBtn.TextColor3 = C_DIM; KBtn.TextSize = 9; KBtn.Font = Enum.Font.GothamBold; KBtn.Parent = KW
            local KStr = Instance.new("UIStroke"); KStr.Color = C_BORDER; KStr.Thickness = 1; KStr.Parent = KBtn

            track(KBtn.MouseButton1Click:Connect(function()
                binding = true; KBtn.Text = "[...]"; KBtn.TextColor3 = C_ACCENT; KStr.Color = C_ACCENT
            end))

            -- Клавиатура + кнопки мыши
            track(UIS.InputBegan:Connect(function(inp)
                if not binding then return end
                local t = inp.UserInputType
                local name = nil
                if t == Enum.UserInputType.Keyboard then
                    name = inp.KeyCode.Name
                elseif t == Enum.UserInputType.MouseButton1 then name = "MB1"
                elseif t == Enum.UserInputType.MouseButton2 then name = "MB2"
                elseif t == Enum.UserInputType.MouseButton3 then name = "MB3"
                end
                if name then
                    binding = false; keyName = name
                    KBtn.Text = "["..name.."]"; KBtn.TextColor3 = C_TEXT; KStr.Color = C_BORDER
                    cb(inp.KeyCode, t)
                end
            end))

            track(KW.MouseEnter:Connect(function() KLbl.TextColor3 = C_ACCENT end))
            track(KW.MouseLeave:Connect(function()
                KLbl.TextColor3 = C_DIM
                if not binding then KStr.Color = C_BORDER end
            end))

            if default and default ~= Enum.KeyCode.Unknown then
                task.spawn(function() cb(default, Enum.UserInputType.Keyboard) end)
            end
        end

        -- ── INPUT (TextBox) ──
        function W:CreateInput(txt, placeholder, cb)
            local IW = Instance.new("Frame")
            IW.Size = UDim2.new(1,-16,0,38); IW.BackgroundTransparency = 1; IW.Parent = CF
            local ILbl = Instance.new("TextLabel")
            ILbl.Size = UDim2.new(1,0,0,16); ILbl.BackgroundTransparency = 1; ILbl.Text = txt
            ILbl.TextColor3 = C_DIM; ILbl.TextSize = 11; ILbl.Font = Enum.Font.Gotham
            ILbl.TextXAlignment = Enum.TextXAlignment.Left; ILbl.Parent = IW
            local IBg = Instance.new("Frame")
            IBg.Size = UDim2.new(1,0,0,18); IBg.Position = UDim2.new(0,0,0,18)
            IBg.BackgroundColor3 = C_BOX; IBg.BorderSizePixel = 0; IBg.Parent = IW
            local IS = Instance.new("UIStroke"); IS.Color = C_BORDER; IS.Thickness = 1; IS.Parent = IBg
            local ITB = Instance.new("TextBox")
            ITB.Size = UDim2.new(1,-10,1,0); ITB.Position = UDim2.new(0,5,0,0)
            ITB.BackgroundTransparency = 1; ITB.PlaceholderText = placeholder or "..."
            ITB.PlaceholderColor3 = C_DIM; ITB.Text = ""
            ITB.TextColor3 = C_TEXT; ITB.TextSize = 11; ITB.Font = Enum.Font.Gotham
            ITB.TextXAlignment = Enum.TextXAlignment.Left; ITB.ClearTextOnFocus = false; ITB.Parent = IBg
            track(ITB.Focused:Connect(function() IS.Color = C_ACCENT; ILbl.TextColor3 = C_ACCENT end))
            track(ITB.FocusLost:Connect(function(enter) IS.Color = C_BORDER; ILbl.TextColor3 = C_DIM; cb(ITB.Text, enter) end))
            track(IW.MouseEnter:Connect(function() if not ITB:IsFocused() then ILbl.TextColor3 = C_ACCENT end end))
            track(IW.MouseLeave:Connect(function() if not ITB:IsFocused() then ILbl.TextColor3 = C_DIM end end))
        end

        -- ── LABEL ──
        function W:CreateLabel(txt)
            local LF = Instance.new("Frame")
            LF.Size = UDim2.new(1,-16,0,16); LF.BackgroundTransparency = 1; LF.Parent = CF
            local LL = Instance.new("TextLabel")
            LL.Size = UDim2.new(1,0,1,0); LL.BackgroundTransparency = 1; LL.Text = txt
            LL.TextColor3 = C_DIM; LL.TextSize = 10; LL.Font = Enum.Font.Gotham
            LL.TextXAlignment = Enum.TextXAlignment.Left; LL.Parent = LF
            return {SetText = function(t) LL.Text = t end}
        end

        return W
    end

    -- Settings API
    local SettingsAPI = {}
    function SettingsAPI:CreateWindow(t,c) return buildWindow(t,c,sL,sM,sR) end
    UI.Settings = SettingsAPI

    -- ──────────────────── CREATETAB ────────────────────
    function UI:CreateTab(tabName)
        local TB = Instance.new("TextButton")
        TB.Size = UDim2.new(0,112,1,0); TB.BackgroundTransparency = 1; TB.Text = ""; TB.Parent = TabsScroll

        local TIco = Instance.new("ImageLabel")
        TIco.Size = UDim2.new(0,13,0,13); TIco.Position = UDim2.new(0,7,0.5,-6)
        TIco.BackgroundTransparency = 1; TIco.ImageColor3 = C_DIM
        local ln = tabName:lower()
        if ln:find("aim") or ln:find("combat") then TIco.Image = TabIcons.Combat
        elseif ln:find("move") or ln:find("speed") or ln:find("fly") then TIco.Image = TabIcons.Movement
        elseif ln:find("visual") or ln:find("esp") then TIco.Image = TabIcons.Visuals
        elseif ln:find("world") then TIco.Image = TabIcons.World
        elseif ln:find("auto") or ln:find("farm") then TIco.Image = TabIcons.Auto
        elseif ln:find("gun") or ln:find("weapon") then TIco.Image = TabIcons.Guns
        elseif ln:find("skin") then TIco.Image = TabIcons.Skins
        else TIco.Image = TabIcons.Misc end
        TIco.Parent = TB

        local TLbl = Instance.new("TextLabel")
        TLbl.Size = UDim2.new(1,-24,1,0); TLbl.Position = UDim2.new(0,22,0,0)
        TLbl.BackgroundTransparency = 1; TLbl.Text = tabName
        TLbl.TextColor3 = C_DIM; TLbl.TextSize = 11; TLbl.Font = Enum.Font.GothamBold
        TLbl.TextXAlignment = Enum.TextXAlignment.Left; TLbl.Parent = TB

        local TInd = Instance.new("Frame")
        TInd.Size = UDim2.new(1,0,0,2); TInd.Position = UDim2.new(0,0,1,-2)
        TInd.BackgroundColor3 = C_ACCENT; TInd.BorderSizePixel = 0; TInd.Visible = false; TInd.Parent = TB

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,0,1,0); Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0
        Page.Visible = false; Page.ScrollBarThickness = 0
        Page.ScrollingDirection = Enum.ScrollingDirection.Y; Page.Parent = PC

        local L = Instance.new("Frame"); L.Size = UDim2.new(1/3,-8,0,0); L.Position = UDim2.new(0,0,0,0); L.BackgroundTransparency = 1; L.Parent = Page
        local M = Instance.new("Frame"); M.Size = UDim2.new(1/3,-8,0,0); M.Position = UDim2.new(1/3,4,0,0); M.BackgroundTransparency = 1; M.Parent = Page
        local R = Instance.new("Frame"); R.Size = UDim2.new(1/3,-8,0,0); R.Position = UDim2.new(2/3,8,0,0); R.BackgroundTransparency = 1; R.Parent = Page

        local LL = Instance.new("UIListLayout"); LL.Parent = L; LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Padding = UDim.new(0,8)
        local ML = Instance.new("UIListLayout"); ML.Parent = M; ML.SortOrder = Enum.SortOrder.LayoutOrder; ML.Padding = UDim.new(0,8)
        local RL = Instance.new("UIListLayout"); RL.Parent = R; RL.SortOrder = Enum.SortOrder.LayoutOrder; RL.Padding = UDim.new(0,8)

        local function updCanvas()
            local mh = math.max(LL.AbsoluteContentSize.Y, ML.AbsoluteContentSize.Y, RL.AbsoluteContentSize.Y)
            Page.CanvasSize = UDim2.new(0,0,0,mh+10)
            L.Size = UDim2.new(1/3,-8,0,LL.AbsoluteContentSize.Y)
            M.Size = UDim2.new(1/3,-8,0,ML.AbsoluteContentSize.Y)
            R.Size = UDim2.new(1/3,-8,0,RL.AbsoluteContentSize.Y)
        end
        LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updCanvas)
        ML:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updCanvas)
        RL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updCanvas)

        track(TB.MouseEnter:Connect(function()
            if not(activeTab and activeTab.Btn==TB) then TLbl.TextColor3=C_ACCENT; TIco.ImageColor3=C_ACCENT end
        end))
        track(TB.MouseLeave:Connect(function()
            if not(activeTab and activeTab.Btn==TB) then TLbl.TextColor3=C_DIM; TIco.ImageColor3=C_DIM end
        end))
        track(TB.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Lbl.TextColor3=C_DIM; activeTab.Ico.ImageColor3=C_DIM
                activeTab.Ind.Visible=false; activeTab.Page.Visible=false
            end
            TLbl.TextColor3=C_TEXT; TIco.ImageColor3=C_TEXT
            TInd.Visible=true; Page.Visible=true
            activeTab={Btn=TB,Lbl=TLbl,Ico=TIco,Ind=TInd,Page=Page}
        end))

        if not activeTab then
            TLbl.TextColor3=C_TEXT; TIco.ImageColor3=C_TEXT
            TInd.Visible=true; Page.Visible=true
            activeTab={Btn=TB,Lbl=TLbl,Ico=TIco,Ind=TInd,Page=Page}
        end

        local TabAPI = {}
        function TabAPI:CreateWindow(t,c) return buildWindow(t,c,L,M,R) end
        return TabAPI
    end

    -- ──────────────────── NOTIFICATION ────────────────────
    local notifStack = 0
    function UI:Notification(title, text, duration)
        notifStack = notifStack + 1
        duration = duration or 3
        local yOff = -12 - (notifStack-1)*72

        local NF = Instance.new("Frame")
        NF.Size = UDim2.new(0,250,0,58); NF.Position = UDim2.new(1,10,1,yOff)
        NF.BackgroundColor3 = C_CARD; NF.BorderSizePixel = 0; NF.ZIndex = 20; NF.Parent = SG
        local NS = Instance.new("UIStroke"); NS.Color = C_BORDER; NS.Thickness = 1; NS.Parent = NF
        local NBar = Instance.new("Frame")
        NBar.Size = UDim2.new(0,2,1,0); NBar.BackgroundColor3 = C_ACCENT; NBar.BorderSizePixel = 0; NBar.ZIndex = 21; NBar.Parent = NF
        local NT = Instance.new("TextLabel")
        NT.Size = UDim2.new(1,-14,0,20); NT.Position = UDim2.new(0,10,0,6)
        NT.BackgroundTransparency = 1; NT.Text = title; NT.TextColor3 = C_ACCENT
        NT.TextSize = 11; NT.Font = Enum.Font.GothamBold; NT.TextXAlignment = Enum.TextXAlignment.Left; NT.ZIndex = 21; NT.Parent = NF
        local NB = Instance.new("TextLabel")
        NB.Size = UDim2.new(1,-14,0,26); NB.Position = UDim2.new(0,10,0,26)
        NB.BackgroundTransparency = 1; NB.Text = text; NB.TextColor3 = C_DIM
        NB.TextSize = 10; NB.Font = Enum.Font.Gotham; NB.TextXAlignment = Enum.TextXAlignment.Left
        NB.TextWrapped = true; NB.ZIndex = 21; NB.Parent = NF

        TweenService:Create(NF, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Position=UDim2.new(1,-260,1,yOff)}):Play()
        task.spawn(function()
            task.wait(duration)
            local tw = TweenService:Create(NF, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                {Position=UDim2.new(1,10,1,yOff)})
            tw:Play(); tw.Completed:Wait(); NF:Destroy()
            notifStack = math.max(0, notifStack-1)
        end)
    end

    function UI:Destroy()
        for _,c in ipairs(conns) do if c and c.Connected then c:Disconnect() end end
        conns={}; if SG then SG:Destroy() end
    end

    return UI
end

return DeadHub
