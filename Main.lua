-- [[ DEADHUB STEALTH UI LIBRARY ]] --

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

    local C_BG      = Color3.fromRGB(10,10,12)
    local C_CARD    = Color3.fromRGB(15,15,18)
    local C_HEADER  = Color3.fromRGB(13,13,15)
    local C_BORDER  = Color3.fromRGB(28,28,32)
    local C_ACCENT  = Color3.fromRGB(235,35,55)
    local C_TEXT    = Color3.fromRGB(255,255,255)
    local C_DIM     = Color3.fromRGB(140,140,150)
    local UIS       = game:GetService("UserInputService")

    -- ScreenGui
    local SG = Instance.new("ScreenGui")
    SG.Name = rn(); SG.ResetOnSpawn = false; SG.Parent = parentContainer

    -- MainFrame
    local MF = Instance.new("Frame")
    MF.Name = rn(); MF.Size = UDim2.new(0,720,0,450)
    MF.Position = UDim2.new(0.5,-360,0.5,-225)
    MF.BackgroundColor3 = C_BG; MF.BorderSizePixel = 0; MF.Parent = SG
    local mStroke = Instance.new("UIStroke")
    mStroke.Color = C_ACCENT; mStroke.Thickness = 1.2; mStroke.Parent = MF

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = rn(); Header.Size = UDim2.new(1,0,0,35)
    Header.BackgroundColor3 = C_HEADER; Header.BorderSizePixel = 0; Header.Parent = MF
    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(1,0,0,1); hLine.Position = UDim2.new(0,0,1,0)
    hLine.BackgroundColor3 = C_BORDER; hLine.BorderSizePixel = 0; hLine.Parent = Header

    -- Logo box
    local LogoBg = Instance.new("Frame")
    LogoBg.Name = rn(); LogoBg.Size = UDim2.new(0,100,0,20)
    LogoBg.Position = UDim2.new(0.5,-50,0.5,-10)
    LogoBg.BackgroundColor3 = C_HEADER; LogoBg.BorderSizePixel = 0; LogoBg.Parent = Header
    local lStroke = Instance.new("UIStroke")
    lStroke.Color = C_ACCENT; lStroke.Thickness = 1; lStroke.Parent = LogoBg
    local LogoLbl = Instance.new("TextLabel")
    LogoLbl.Size = UDim2.new(1,0,1,0); LogoLbl.BackgroundTransparency = 1
    LogoLbl.Text = "DEADHUB"; LogoLbl.TextColor3 = C_ACCENT
    LogoLbl.TextSize = 11; LogoLbl.Font = Enum.Font.GothamBold
    LogoLbl.TextXAlignment = Enum.TextXAlignment.Center; LogoLbl.Parent = LogoBg

    -- TabBar
    local TabBar = Instance.new("Frame")
    TabBar.Name = rn(); TabBar.Size = UDim2.new(1,0,0,32)
    TabBar.Position = UDim2.new(0,0,0,35)
    TabBar.BackgroundColor3 = C_HEADER; TabBar.BorderSizePixel = 0; TabBar.Parent = MF
    local tbLine = Instance.new("Frame")
    tbLine.Size = UDim2.new(1,0,0,1); tbLine.Position = UDim2.new(0,0,0,67)
    tbLine.BackgroundColor3 = C_BORDER; tbLine.BorderSizePixel = 0; tbLine.Parent = MF

    -- TabsScroll (обычные вкладки)
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = rn(); TabsScroll.Size = UDim2.new(1,-125,1,0)
    TabsScroll.Position = UDim2.new(0,5,0,0)
    TabsScroll.BackgroundTransparency = 1; TabsScroll.BorderSizePixel = 0
    TabsScroll.ScrollBarThickness = 0; TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
    TabsScroll.CanvasSize = UDim2.new(0,0,0,0)
    TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X; TabsScroll.Parent = TabBar
    local TLL = Instance.new("UIListLayout"); TLL.Parent = TabsScroll
    TLL.FillDirection = Enum.FillDirection.Horizontal
    TLL.SortOrder = Enum.SortOrder.LayoutOrder
    TLL.VerticalAlignment = Enum.VerticalAlignment.Center
    TLL.Padding = UDim.new(0,8)

    -- PageContainer
    local PC = Instance.new("Frame")
    PC.Name = rn(); PC.Size = UDim2.new(1,-20,1,-85)
    PC.Position = UDim2.new(0,10,0,75)
    PC.BackgroundTransparency = 1; PC.Parent = MF

    -- Static divider lines (1/3 и 2/3)
    local function makeDivLine(xScale, xOffset)
        local d = Instance.new("Frame")
        d.Name = rn(); d.Size = UDim2.new(0,1,1,0)
        d.Position = UDim2.new(xScale, xOffset, 0, 0)
        d.BackgroundColor3 = C_BORDER; d.BorderSizePixel = 0; d.ZIndex = 2; d.Parent = PC
    end
    makeDivLine(1/3, -1)
    makeDivLine(2/3,  1)

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

    -- RightShift toggle
    local visible = true
    track(UIS.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.RightShift then
            visible = not visible; MF.Visible = visible
        end
    end))

    local activeTab = nil

    -- ───────────────── SETTINGS TAB (постоянная вкладка) ─────────────────
    local SBtn = Instance.new("TextButton")
    SBtn.Name = rn(); SBtn.Size = UDim2.new(0,110,1,0)
    SBtn.Position = UDim2.new(1,-115,0,0)
    SBtn.BackgroundTransparency = 1; SBtn.Text = ""; SBtn.Parent = TabBar

    local SIco = Instance.new("ImageLabel")
    SIco.Name = rn(); SIco.Size = UDim2.new(0,14,0,14)
    SIco.Position = UDim2.new(0,8,0.5,-7)
    SIco.BackgroundTransparency = 1
    SIco.Image = "rbxassetid://11932591062"
    SIco.ImageColor3 = C_DIM; SIco.Parent = SBtn

    local SLbl = Instance.new("TextLabel")
    SLbl.Name = rn(); SLbl.Size = UDim2.new(1,-28,1,0)
    SLbl.Position = UDim2.new(0,26,0,0)
    SLbl.BackgroundTransparency = 1; SLbl.Text = "Settings"
    SLbl.TextColor3 = C_DIM; SLbl.TextSize = 11
    SLbl.Font = Enum.Font.GothamBold
    SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.Parent = SBtn

    local SInd = Instance.new("Frame")
    SInd.Size = UDim2.new(1,0,0,2); SInd.Position = UDim2.new(0,0,1,-2)
    SInd.BackgroundColor3 = C_ACCENT; SInd.BorderSizePixel = 0
    SInd.Visible = false; SInd.Parent = SBtn

    local SPage = Instance.new("ScrollingFrame")
    SPage.Name = rn(); SPage.Size = UDim2.new(1,0,1,0)
    SPage.BackgroundTransparency = 1; SPage.BorderSizePixel = 0
    SPage.Visible = false; SPage.ScrollBarThickness = 0
    SPage.ScrollingDirection = Enum.ScrollingDirection.Y; SPage.Parent = PC

    -- 3 колонки Settings
    local sL = Instance.new("Frame"); sL.Name = rn()
    sL.Size = UDim2.new(1/3,-8,0,0); sL.Position = UDim2.new(0,0,0,0)
    sL.BackgroundTransparency = 1; sL.Parent = SPage
    local sM = Instance.new("Frame"); sM.Name = rn()
    sM.Size = UDim2.new(1/3,-8,0,0); sM.Position = UDim2.new(1/3,4,0,0)
    sM.BackgroundTransparency = 1; sM.Parent = SPage
    local sR = Instance.new("Frame"); sR.Name = rn()
    sR.Size = UDim2.new(1/3,-8,0,0); sR.Position = UDim2.new(2/3,8,0,0)
    sR.BackgroundTransparency = 1; sR.Parent = SPage
    local sLL = Instance.new("UIListLayout"); sLL.Parent = sL
    sLL.SortOrder = Enum.SortOrder.LayoutOrder; sLL.Padding = UDim.new(0,10)
    local sML = Instance.new("UIListLayout"); sML.Parent = sM
    sML.SortOrder = Enum.SortOrder.LayoutOrder; sML.Padding = UDim.new(0,10)
    local sRL = Instance.new("UIListLayout"); sRL.Parent = sR
    sRL.SortOrder = Enum.SortOrder.LayoutOrder; sRL.Padding = UDim.new(0,10)
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
        if not (activeTab and activeTab.Btn == SBtn) then SLbl.TextColor3=C_TEXT; SIco.ImageColor3=C_TEXT end
    end))
    track(SBtn.MouseLeave:Connect(function()
        if not (activeTab and activeTab.Btn == SBtn) then SLbl.TextColor3=C_DIM; SIco.ImageColor3=C_DIM end
    end))

    -- ───────────────── WINDOW BUILDER ─────────────────
    local function buildWindow(title, col, LC, MC, RC)
        local tgt = LC
        if col=="Middle" or col==2 then tgt=MC
        elseif col=="Right" or col==3 then tgt=RC end

        local WF = Instance.new("Frame")
        WF.Name = rn(); WF.Size = UDim2.new(1,0,0,40)
        WF.BackgroundColor3 = C_CARD; WF.BorderSizePixel = 0; WF.Parent = tgt
        local ws = Instance.new("UIStroke")
        ws.Color = Color3.fromRGB(35,35,40); ws.Thickness = 1; ws.Parent = WF

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Name = rn(); TitleLbl.Size = UDim2.new(1,-20,0,26)
        TitleLbl.Position = UDim2.new(0,10,0,0)
        TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = title:upper()
        TitleLbl.TextColor3 = C_ACCENT; TitleLbl.TextSize = 10
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = WF

        local Sep = Instance.new("Frame")
        Sep.Size = UDim2.new(1,0,0,1); Sep.Position = UDim2.new(0,0,0,26)
        Sep.BackgroundColor3 = C_BORDER; Sep.BorderSizePixel = 0; Sep.Parent = WF

        local CF = Instance.new("Frame")
        CF.Name = rn(); CF.Size = UDim2.new(1,0,1,-27)
        CF.Position = UDim2.new(0,0,0,27)
        CF.BackgroundTransparency = 1; CF.Parent = WF

        local CL = Instance.new("UIListLayout"); CL.Parent = CF
        CL.SortOrder = Enum.SortOrder.LayoutOrder
        CL.Padding = UDim.new(0,6)
        CL.HorizontalAlignment = Enum.HorizontalAlignment.Center

        CL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            WF.Size = UDim2.new(1,0,0, CL.AbsoluteContentSize.Y+27+10)
        end)

        local W = {}

        -- BUTTON
        function W:CreateButton(txt, cb)
            local BF = Instance.new("Frame")
            BF.Name=rn(); BF.Size=UDim2.new(1,-20,0,24)
            BF.BackgroundColor3=C_BG; BF.BorderSizePixel=0; BF.Parent=CF
            local bs=Instance.new("UIStroke"); bs.Color=Color3.fromRGB(38,38,44); bs.Thickness=1; bs.Parent=BF
            local TB=Instance.new("TextButton")
            TB.Name=rn(); TB.Size=UDim2.new(1,0,1,0)
            TB.BackgroundTransparency=1; TB.Text=txt
            TB.TextColor3=C_DIM; TB.TextSize=11; TB.Font=Enum.Font.GothamBold; TB.Parent=BF
            track(TB.MouseEnter:Connect(function() bs.Color=C_ACCENT; TB.TextColor3=C_ACCENT end))
            track(TB.MouseLeave:Connect(function() bs.Color=Color3.fromRGB(38,38,44); TB.TextColor3=C_DIM end))
            track(TB.MouseButton1Click:Connect(function() TB.TextColor3=C_TEXT; task.wait(0.1); TB.TextColor3=C_DIM; cb() end))
        end

        -- TOGGLE (Toggle / Hold / Always)
        function W:CreateToggle(txt, default, style, cb)
            -- style: "Toggle" | "Hold" | "Always"
            style = style or "Toggle"
            local state = (style == "Always") and true or (default or false)

            local TW = Instance.new("Frame")
            TW.Name=rn(); TW.Size=UDim2.new(1,-20,0,24)
            TW.BackgroundTransparency=1; TW.Parent=CF

            local TLabel = Instance.new("TextLabel")
            TLabel.Name=rn(); TLabel.Size=UDim2.new(1,-70,1,0)
            TLabel.BackgroundTransparency=1; TLabel.Text=txt
            TLabel.TextColor3=C_TEXT; TLabel.TextSize=12; TLabel.Font=Enum.Font.Gotham
            TLabel.TextXAlignment=Enum.TextXAlignment.Left; TLabel.Parent=TW

            -- Стиль метка
            local StyleLbl = Instance.new("TextLabel")
            StyleLbl.Size=UDim2.new(0,40,1,0); StyleLbl.Position=UDim2.new(1,-60,0,0)
            StyleLbl.BackgroundTransparency=1; StyleLbl.Text=style
            StyleLbl.TextColor3=C_DIM; StyleLbl.TextSize=9; StyleLbl.Font=Enum.Font.Gotham
            StyleLbl.TextXAlignment=Enum.TextXAlignment.Right; StyleLbl.Parent=TW

            local Box = Instance.new("TextButton")
            Box.Name=rn(); Box.Size=UDim2.new(0,16,0,16)
            Box.Position=UDim2.new(1,-16,0.5,-8)
            Box.BackgroundColor3=C_BG; Box.BorderSizePixel=0
            Box.Text=""; Box.AutoButtonColor=false; Box.Parent=TW
            local BoxStroke=Instance.new("UIStroke"); BoxStroke.Color=Color3.fromRGB(38,38,44); BoxStroke.Thickness=1; BoxStroke.Parent=Box
            local Inner=Instance.new("Frame")
            Inner.Name=rn(); Inner.Size=UDim2.new(0,10,0,10)
            Inner.Position=UDim2.new(0.5,-5,0.5,-5)
            Inner.BackgroundColor3=C_ACCENT; Inner.BorderSizePixel=0
            Inner.Visible=state; Inner.Parent=Box

            local function setState(v)
                state = v; Inner.Visible = state; cb(state)
            end

            if style == "Toggle" then
                track(Box.MouseButton1Click:Connect(function() setState(not state) end))
            elseif style == "Hold" then
                track(Box.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then setState(true) end
                end))
                track(Box.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then setState(false) end
                end))
            elseif style == "Always" then
                setState(true)
            end

            track(TW.MouseEnter:Connect(function() BoxStroke.Color=C_ACCENT; TLabel.TextColor3=C_ACCENT end))
            track(TW.MouseLeave:Connect(function() BoxStroke.Color=Color3.fromRGB(38,38,44); TLabel.TextColor3=C_TEXT end))

            task.spawn(function() cb(state) end)
        end

        -- SLIDER
        function W:CreateSlider(txt, min, max, default, cb)
            local val = default or min
            local SW = Instance.new("Frame")
            SW.Name=rn(); SW.Size=UDim2.new(1,-20,0,42)
            SW.BackgroundTransparency=1; SW.Parent=CF
            local SLabel=Instance.new("TextLabel")
            SLabel.Name=rn(); SLabel.Size=UDim2.new(1,0,0,18)
            SLabel.BackgroundTransparency=1; SLabel.Text=txt
            SLabel.TextColor3=C_TEXT; SLabel.TextSize=12; SLabel.Font=Enum.Font.Gotham
            SLabel.TextXAlignment=Enum.TextXAlignment.Left; SLabel.Parent=SW
            local SBar=Instance.new("TextButton")
            SBar.Name=rn(); SBar.Size=UDim2.new(1,0,0,18)
            SBar.Position=UDim2.new(0,0,0,20)
            SBar.BackgroundColor3=C_BG; SBar.BorderSizePixel=0
            SBar.Text=""; SBar.AutoButtonColor=false; SBar.Parent=SW
            local SS=Instance.new("UIStroke"); SS.Color=Color3.fromRGB(38,38,44); SS.Thickness=1; SS.Parent=SBar
            local Fill=Instance.new("Frame")
            Fill.Name=rn(); Fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            Fill.BackgroundColor3=C_ACCENT; Fill.BorderSizePixel=0; Fill.Parent=SBar
            local VLbl=Instance.new("TextLabel")
            VLbl.Size=UDim2.new(1,0,1,0); VLbl.BackgroundTransparency=1
            VLbl.Text=tostring(val); VLbl.TextColor3=C_TEXT; VLbl.TextSize=11
            VLbl.Font=Enum.Font.GothamBold; VLbl.TextXAlignment=Enum.TextXAlignment.Center; VLbl.Parent=SBar

            track(SW.MouseEnter:Connect(function() SS.Color=C_ACCENT; SLabel.TextColor3=C_ACCENT end))
            track(SW.MouseLeave:Connect(function() SS.Color=Color3.fromRGB(38,38,44); SLabel.TextColor3=C_TEXT end))

            local sliding=false
            local function upd(inp)
                local p=math.clamp((inp.Position.X-SBar.AbsolutePosition.X)/SBar.AbsoluteSize.X,0,1)
                val=math.floor(min+(max-min)*p)
                Fill.Size=UDim2.new(p,0,1,0); VLbl.Text=tostring(val); cb(val)
            end
            track(SBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; upd(i) end end))
            track(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end))
            track(UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end))
            task.spawn(function() cb(val) end)
        end

        -- DROPDOWN
        function W:CreateDropdown(txt, opts, default, cb)
            local sel = default or opts[1] or ""
            local opened = false
            local DW = Instance.new("Frame")
            DW.Name=rn(); DW.Size=UDim2.new(1,-20,0,42)
            DW.BackgroundTransparency=1; DW.Parent=CF
            local DLabel=Instance.new("TextLabel")
            DLabel.Name=rn(); DLabel.Size=UDim2.new(1,0,0,18)
            DLabel.BackgroundTransparency=1; DLabel.Text=txt
            DLabel.TextColor3=C_TEXT; DLabel.TextSize=12; DLabel.Font=Enum.Font.Gotham
            DLabel.TextXAlignment=Enum.TextXAlignment.Left; DLabel.Parent=DW
            local DBt=Instance.new("TextButton")
            DBt.Name=rn(); DBt.Size=UDim2.new(1,0,0,18)
            DBt.Position=UDim2.new(0,0,0,20)
            DBt.BackgroundColor3=C_BG; DBt.BorderSizePixel=0
            DBt.Text="  "..sel; DBt.TextColor3=C_TEXT; DBt.TextSize=11
            DBt.Font=Enum.Font.Gotham; DBt.TextXAlignment=Enum.TextXAlignment.Left; DBt.Parent=DW
            local DS=Instance.new("UIStroke"); DS.Color=Color3.fromRGB(38,38,44); DS.Thickness=1; DS.Parent=DBt
            local Arrow=Instance.new("TextLabel")
            Arrow.Size=UDim2.new(0,18,1,0); Arrow.Position=UDim2.new(1,-18,0,0)
            Arrow.BackgroundTransparency=1; Arrow.Text="v"; Arrow.TextColor3=C_DIM
            Arrow.TextSize=10; Arrow.Font=Enum.Font.GothamBold; Arrow.Parent=DBt
            local OList=Instance.new("Frame")
            OList.Name=rn(); OList.Size=UDim2.new(1,0,0,0)
            OList.Position=UDim2.new(0,0,0,38)
            OList.BackgroundColor3=C_CARD; OList.BorderSizePixel=0
            OList.Visible=false; OList.ZIndex=5; OList.Parent=DW
            local OS=Instance.new("UIStroke"); OS.Color=C_BORDER; OS.Thickness=1; OS.Parent=OList
            local OLL=Instance.new("UIListLayout"); OLL.Parent=OList; OLL.SortOrder=Enum.SortOrder.LayoutOrder

            local function toggle()
                opened=not opened; OList.Visible=opened; Arrow.Text=opened and "^" or "v"
                DW.Size=opened and UDim2.new(1,-20,0,42+#opts*18) or UDim2.new(1,-20,0,42)
                OList.Size=opened and UDim2.new(1,0,0,#opts*18) or UDim2.new(1,0,0,0)
            end
            for _,o in ipairs(opts) do
                local OB=Instance.new("TextButton")
                OB.Size=UDim2.new(1,0,0,18); OB.BackgroundColor3=C_BG; OB.BorderSizePixel=0
                OB.Text="  "..o; OB.TextColor3=(o==sel) and C_ACCENT or C_DIM
                OB.TextSize=10; OB.Font=Enum.Font.Gotham
                OB.TextXAlignment=Enum.TextXAlignment.Left; OB.ZIndex=6; OB.Parent=OList
                OB.MouseEnter:Connect(function() OB.TextColor3=C_ACCENT end)
                OB.MouseLeave:Connect(function() if o~=sel then OB.TextColor3=C_DIM end end)
                OB.MouseButton1Click:Connect(function()
                    sel=o; DBt.Text="  "..o
                    for _,ch in ipairs(OList:GetChildren()) do
                        if ch:IsA("TextButton") then ch.TextColor3=(ch.Text=="  "..o) and C_ACCENT or C_DIM end
                    end
                    toggle(); cb(o)
                end)
            end
            track(DBt.MouseButton1Click:Connect(toggle))
            track(DW.MouseEnter:Connect(function() DS.Color=C_ACCENT; DLabel.TextColor3=C_ACCENT end))
            track(DW.MouseLeave:Connect(function() DS.Color=Color3.fromRGB(38,38,44); DLabel.TextColor3=C_TEXT end))
            task.spawn(function() cb(sel) end)
        end

        -- MULTISELECT
        function W:CreateMultiSelect(txt, opts, defaults, cb)
            local sel = defaults or {}
            local opened = false
            local DW=Instance.new("Frame")
            DW.Name=rn(); DW.Size=UDim2.new(1,-20,0,42)
            DW.BackgroundTransparency=1; DW.Parent=CF
            local DLabel=Instance.new("TextLabel")
            DLabel.Name=rn(); DLabel.Size=UDim2.new(1,0,0,18)
            DLabel.BackgroundTransparency=1; DLabel.Text=txt
            DLabel.TextColor3=C_TEXT; DLabel.TextSize=12; DLabel.Font=Enum.Font.Gotham
            DLabel.TextXAlignment=Enum.TextXAlignment.Left; DLabel.Parent=DW
            local function getStr()
                local t={}
                for k,v in pairs(sel) do if v then table.insert(t,k) end end
                return #t==0 and "None" or table.concat(t,", ")
            end
            local DBt=Instance.new("TextButton")
            DBt.Name=rn(); DBt.Size=UDim2.new(1,0,0,18)
            DBt.Position=UDim2.new(0,0,0,20)
            DBt.BackgroundColor3=C_BG; DBt.BorderSizePixel=0
            DBt.Text="  "..getStr(); DBt.TextColor3=C_TEXT; DBt.TextSize=11
            DBt.Font=Enum.Font.Gotham; DBt.TextXAlignment=Enum.TextXAlignment.Left; DBt.Parent=DW
            local DS=Instance.new("UIStroke"); DS.Color=Color3.fromRGB(38,38,44); DS.Thickness=1; DS.Parent=DBt
            local Arrow=Instance.new("TextLabel")
            Arrow.Size=UDim2.new(0,18,1,0); Arrow.Position=UDim2.new(1,-18,0,0)
            Arrow.BackgroundTransparency=1; Arrow.Text="v"; Arrow.TextColor3=C_DIM
            Arrow.TextSize=10; Arrow.Font=Enum.Font.GothamBold; Arrow.Parent=DBt
            local OList=Instance.new("Frame")
            OList.Name=rn(); OList.Size=UDim2.new(1,0,0,0)
            OList.Position=UDim2.new(0,0,0,38)
            OList.BackgroundColor3=C_CARD; OList.BorderSizePixel=0
            OList.Visible=false; OList.ZIndex=5; OList.Parent=DW
            local OS=Instance.new("UIStroke"); OS.Color=C_BORDER; OS.Thickness=1; OS.Parent=OList
            local OLL=Instance.new("UIListLayout"); OLL.Parent=OList; OLL.SortOrder=Enum.SortOrder.LayoutOrder

            local function toggle()
                opened=not opened; OList.Visible=opened; Arrow.Text=opened and "^" or "v"
                DW.Size=opened and UDim2.new(1,-20,0,42+#opts*18) or UDim2.new(1,-20,0,42)
                OList.Size=opened and UDim2.new(1,0,0,#opts*18) or UDim2.new(1,0,0,0)
            end
            for _,o in ipairs(opts) do
                local OB=Instance.new("TextButton")
                OB.Size=UDim2.new(1,0,0,18); OB.BackgroundColor3=C_BG; OB.BorderSizePixel=0
                OB.Text="  "..o; OB.TextColor3=sel[o] and C_ACCENT or C_DIM
                OB.TextSize=10; OB.Font=Enum.Font.Gotham
                OB.TextXAlignment=Enum.TextXAlignment.Left; OB.ZIndex=6; OB.Parent=OList
                OB.MouseEnter:Connect(function() OB.TextColor3=C_ACCENT end)
                OB.MouseLeave:Connect(function() if not sel[o] then OB.TextColor3=C_DIM end end)
                OB.MouseButton1Click:Connect(function()
                    sel[o]=not sel[o]; OB.TextColor3=sel[o] and C_ACCENT or C_DIM
                    DBt.Text="  "..getStr(); cb(sel)
                end)
            end
            track(DBt.MouseButton1Click:Connect(toggle))
            track(DW.MouseEnter:Connect(function() DS.Color=C_ACCENT; DLabel.TextColor3=C_ACCENT end))
            track(DW.MouseLeave:Connect(function() DS.Color=Color3.fromRGB(38,38,44); DLabel.TextColor3=C_TEXT end))
            task.spawn(function() cb(sel) end)
        end

        -- COLORPICKER (PixelColor)
        function W:CreateColorPicker(txt, default, cb)
            local color = default or Color3.fromRGB(235,35,55)
            local opened = false
            local PW=Instance.new("Frame")
            PW.Name=rn(); PW.Size=UDim2.new(1,-20,0,24)
            PW.BackgroundTransparency=1; PW.Parent=CF
            local PLbl=Instance.new("TextLabel")
            PLbl.Name=rn(); PLbl.Size=UDim2.new(1,-50,1,0)
            PLbl.BackgroundTransparency=1; PLbl.Text=txt
            PLbl.TextColor3=C_TEXT; PLbl.TextSize=12; PLbl.Font=Enum.Font.Gotham
            PLbl.TextXAlignment=Enum.TextXAlignment.Left; PLbl.Parent=PW
            local CBox=Instance.new("TextButton")
            CBox.Name=rn(); CBox.Size=UDim2.new(0,30,0,16)
            CBox.Position=UDim2.new(1,-30,0.5,-8)
            CBox.BackgroundColor3=color; CBox.BorderSizePixel=0; CBox.Text=""; CBox.Parent=PW
            local CS=Instance.new("UIStroke"); CS.Color=Color3.fromRGB(38,38,44); CS.Thickness=1; CS.Parent=CBox
            local Panel=Instance.new("Frame")
            Panel.Size=UDim2.new(1,0,0,56); Panel.Position=UDim2.new(0,0,0,24)
            Panel.BackgroundColor3=C_CARD; Panel.BorderSizePixel=0
            Panel.Visible=false; Panel.ZIndex=5; Panel.Parent=PW
            local PS=Instance.new("UIStroke"); PS.Color=C_BORDER; PS.Thickness=1; PS.Parent=Panel

            local r,g,b=color.R,color.G,color.B
            local function upd() color=Color3.new(r,g,b); CBox.BackgroundColor3=color; cb(color) end

            local function mkSlider(label, initVal, yOff, setter)
                local Sl=Instance.new("TextButton")
                Sl.Size=UDim2.new(1,-10,0,12); Sl.Position=UDim2.new(0,5,0,yOff)
                Sl.BackgroundColor3=C_BG; Sl.BorderSizePixel=0; Sl.Text=""; Sl.ZIndex=6; Sl.Parent=Panel
                local SSt=Instance.new("UIStroke"); SSt.Color=Color3.fromRGB(38,38,44); SSt.Thickness=1; SSt.Parent=Sl
                local F=Instance.new("Frame"); F.Size=UDim2.new(initVal,0,1,0)
                F.BackgroundColor3=C_ACCENT; F.BorderSizePixel=0; F.Parent=Sl
                local L=Instance.new("TextLabel"); L.Size=UDim2.new(1,0,1,0)
                L.BackgroundTransparency=1; L.Text=label..": "..tostring(math.floor(initVal*255))
                L.TextColor3=C_TEXT; L.TextSize=8; L.Font=Enum.Font.GothamBold; L.ZIndex=7; L.Parent=Sl
                local sliding=false
                local function sv(i)
                    local p=math.clamp((i.Position.X-Sl.AbsolutePosition.X)/Sl.AbsoluteSize.X,0,1)
                    F.Size=UDim2.new(p,0,1,0); L.Text=label..": "..tostring(math.floor(p*255))
                    setter(p); upd()
                end
                Sl.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; sv(i) end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
                UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then sv(i) end end)
            end

            mkSlider("R", r, 4,  function(v) r=v end)
            mkSlider("G", g, 20, function(v) g=v end)
            mkSlider("B", b, 36, function(v) b=v end)

            CBox.MouseButton1Click:Connect(function()
                opened=not opened; Panel.Visible=opened
                PW.Size=opened and UDim2.new(1,-20,0,84) or UDim2.new(1,-20,0,24)
            end)
            track(PW.MouseEnter:Connect(function() CS.Color=C_ACCENT; PLbl.TextColor3=C_ACCENT end))
            track(PW.MouseLeave:Connect(function() CS.Color=Color3.fromRGB(38,38,44); PLbl.TextColor3=C_TEXT end))
            task.spawn(function() cb(color) end)
        end

        -- KEYBIND
        function W:CreateKeybind(txt, default, cb)
            local key = default or Enum.KeyCode.Unknown
            local binding = false

            local KW=Instance.new("Frame")
            KW.Name=rn(); KW.Size=UDim2.new(1,-20,0,24)
            KW.BackgroundTransparency=1; KW.Parent=CF
            local KLbl=Instance.new("TextLabel")
            KLbl.Name=rn(); KLbl.Size=UDim2.new(1,-70,1,0)
            KLbl.BackgroundTransparency=1; KLbl.Text=txt
            KLbl.TextColor3=C_TEXT; KLbl.TextSize=12; KLbl.Font=Enum.Font.Gotham
            KLbl.TextXAlignment=Enum.TextXAlignment.Left; KLbl.Parent=KW

            local KBtn=Instance.new("TextButton")
            KBtn.Name=rn(); KBtn.Size=UDim2.new(0,60,0,18)
            KBtn.Position=UDim2.new(1,-60,0.5,-9)
            KBtn.BackgroundColor3=C_BG; KBtn.BorderSizePixel=0
            KBtn.Text=(key==Enum.KeyCode.Unknown) and "None" or key.Name
            KBtn.TextColor3=C_DIM; KBtn.TextSize=10; KBtn.Font=Enum.Font.GothamBold; KBtn.Parent=KW
            local KS=Instance.new("UIStroke"); KS.Color=Color3.fromRGB(38,38,44); KS.Thickness=1; KS.Parent=KBtn

            track(KBtn.MouseButton1Click:Connect(function()
                binding=true; KBtn.Text="..."; KBtn.TextColor3=C_ACCENT; KS.Color=C_ACCENT
            end))
            track(UIS.InputBegan:Connect(function(inp, proc)
                if binding and not proc and inp.UserInputType==Enum.UserInputType.Keyboard then
                    key=inp.KeyCode; binding=false
                    KBtn.Text=key.Name; KBtn.TextColor3=C_DIM; KS.Color=Color3.fromRGB(38,38,44)
                    cb(key)
                end
            end))
            track(KW.MouseEnter:Connect(function() KS.Color=C_ACCENT; KLbl.TextColor3=C_ACCENT end))
            track(KW.MouseLeave:Connect(function() if not binding then KS.Color=Color3.fromRGB(38,38,44) end; KLbl.TextColor3=C_TEXT end))
            task.spawn(function() if key~=Enum.KeyCode.Unknown then cb(key) end end)
        end

        -- INPUT (TextBox)
        function W:CreateInput(txt, placeholder, cb)
            local IW=Instance.new("Frame")
            IW.Name=rn(); IW.Size=UDim2.new(1,-20,0,42)
            IW.BackgroundTransparency=1; IW.Parent=CF
            local ILbl=Instance.new("TextLabel")
            ILbl.Name=rn(); ILbl.Size=UDim2.new(1,0,0,18)
            ILbl.BackgroundTransparency=1; ILbl.Text=txt
            ILbl.TextColor3=C_TEXT; ILbl.TextSize=12; ILbl.Font=Enum.Font.Gotham
            ILbl.TextXAlignment=Enum.TextXAlignment.Left; ILbl.Parent=IW
            local IBg=Instance.new("Frame")
            IBg.Name=rn(); IBg.Size=UDim2.new(1,0,0,18)
            IBg.Position=UDim2.new(0,0,0,20)
            IBg.BackgroundColor3=C_BG; IBg.BorderSizePixel=0; IBg.Parent=IW
            local IS=Instance.new("UIStroke"); IS.Color=Color3.fromRGB(38,38,44); IS.Thickness=1; IS.Parent=IBg
            local ITB=Instance.new("TextBox")
            ITB.Name=rn(); ITB.Size=UDim2.new(1,-10,1,0)
            ITB.Position=UDim2.new(0,5,0,0)
            ITB.BackgroundTransparency=1; ITB.PlaceholderText=placeholder or "..."
            ITB.PlaceholderColor3=C_DIM; ITB.Text=""
            ITB.TextColor3=C_TEXT; ITB.TextSize=11; ITB.Font=Enum.Font.Gotham
            ITB.TextXAlignment=Enum.TextXAlignment.Left
            ITB.ClearTextOnFocus=false; ITB.Parent=IBg
            track(ITB.Focused:Connect(function() IS.Color=C_ACCENT; ILbl.TextColor3=C_ACCENT end))
            track(ITB.FocusLost:Connect(function(enter) IS.Color=Color3.fromRGB(38,38,44); ILbl.TextColor3=C_TEXT; cb(ITB.Text, enter) end))
            track(IW.MouseEnter:Connect(function() IS.Color=C_ACCENT; ILbl.TextColor3=C_ACCENT end))
            track(IW.MouseLeave:Connect(function() if not ITB:IsFocused() then IS.Color=Color3.fromRGB(38,38,44); ILbl.TextColor3=C_TEXT end end))
        end

        -- LABEL
        function W:CreateLabel(txt)
            local LF=Instance.new("Frame")
            LF.Name=rn(); LF.Size=UDim2.new(1,-20,0,18)
            LF.BackgroundTransparency=1; LF.Parent=CF
            local LL2=Instance.new("TextLabel")
            LL2.Name=rn(); LL2.Size=UDim2.new(1,0,1,0)
            LL2.BackgroundTransparency=1; LL2.Text=txt
            LL2.TextColor3=C_DIM; LL2.TextSize=11; LL2.Font=Enum.Font.Gotham
            LL2.TextXAlignment=Enum.TextXAlignment.Left; LL2.Parent=LF
            local function SetText(newTxt) LL2.Text=newTxt end
            return {SetText=SetText}
        end

        return W
    end

    -- Settings API
    local SettingsAPI={}
    function SettingsAPI:CreateWindow(t,c) return buildWindow(t,c,sL,sM,sR) end
    UI.Settings = SettingsAPI

    -- CreateTab
    function UI:CreateTab(tabName)
        local TB=Instance.new("TextButton")
        TB.Name=rn(); TB.Size=UDim2.new(0,115,1,0)
        TB.BackgroundTransparency=1; TB.Text=""; TB.Parent=TabsScroll

        local TIco=Instance.new("ImageLabel")
        TIco.Name=rn(); TIco.Size=UDim2.new(0,14,0,14)
        TIco.Position=UDim2.new(0,8,0.5,-7)
        TIco.BackgroundTransparency=1; TIco.ImageColor3=C_DIM
        local ln=tabName:lower()
        if ln:find("aim") or ln:find("combat") then TIco.Image=TabIcons.Combat
        elseif ln:find("move") or ln:find("speed") or ln:find("fly") then TIco.Image=TabIcons.Movement
        elseif ln:find("visual") or ln:find("esp") then TIco.Image=TabIcons.Visuals
        elseif ln:find("world") then TIco.Image=TabIcons.World
        elseif ln:find("auto") or ln:find("farm") then TIco.Image=TabIcons.Auto
        elseif ln:find("gun") or ln:find("weapon") then TIco.Image=TabIcons.Guns
        elseif ln:find("skin") then TIco.Image=TabIcons.Skins
        else TIco.Image=TabIcons.Misc end
        TIco.Parent=TB

        local TLbl=Instance.new("TextLabel")
        TLbl.Name=rn(); TLbl.Size=UDim2.new(1,-28,1,0)
        TLbl.Position=UDim2.new(0,26,0,0)
        TLbl.BackgroundTransparency=1; TLbl.Text=tabName
        TLbl.TextColor3=C_DIM; TLbl.TextSize=11; TLbl.Font=Enum.Font.GothamBold
        TLbl.TextXAlignment=Enum.TextXAlignment.Left; TLbl.Parent=TB

        local TInd=Instance.new("Frame")
        TInd.Size=UDim2.new(1,0,0,2); TInd.Position=UDim2.new(0,0,1,-2)
        TInd.BackgroundColor3=C_ACCENT; TInd.BorderSizePixel=0; TInd.Visible=false; TInd.Parent=TB

        local Page=Instance.new("ScrollingFrame")
        Page.Name=rn(); Page.Size=UDim2.new(1,0,1,0)
        Page.BackgroundTransparency=1; Page.BorderSizePixel=0
        Page.Visible=false; Page.ScrollBarThickness=0
        Page.ScrollingDirection=Enum.ScrollingDirection.Y; Page.Parent=PC

        local L=Instance.new("Frame"); L.Name=rn()
        L.Size=UDim2.new(1/3,-8,0,0); L.Position=UDim2.new(0,0,0,0)
        L.BackgroundTransparency=1; L.Parent=Page
        local M=Instance.new("Frame"); M.Name=rn()
        M.Size=UDim2.new(1/3,-8,0,0); M.Position=UDim2.new(1/3,4,0,0)
        M.BackgroundTransparency=1; M.Parent=Page
        local R=Instance.new("Frame"); R.Name=rn()
        R.Size=UDim2.new(1/3,-8,0,0); R.Position=UDim2.new(2/3,8,0,0)
        R.BackgroundTransparency=1; R.Parent=Page

        local LL=Instance.new("UIListLayout"); LL.Parent=L
        LL.SortOrder=Enum.SortOrder.LayoutOrder; LL.Padding=UDim.new(0,10)
        local ML=Instance.new("UIListLayout"); ML.Parent=M
        ML.SortOrder=Enum.SortOrder.LayoutOrder; ML.Padding=UDim.new(0,10)
        local RL=Instance.new("UIListLayout"); RL.Parent=R
        RL.SortOrder=Enum.SortOrder.LayoutOrder; RL.Padding=UDim.new(0,10)

        local function updCanvas()
            local mh=math.max(LL.AbsoluteContentSize.Y, ML.AbsoluteContentSize.Y, RL.AbsoluteContentSize.Y)
            Page.CanvasSize=UDim2.new(0,0,0,mh+10)
            L.Size=UDim2.new(1/3,-8,0,LL.AbsoluteContentSize.Y)
            M.Size=UDim2.new(1/3,-8,0,ML.AbsoluteContentSize.Y)
            R.Size=UDim2.new(1/3,-8,0,RL.AbsoluteContentSize.Y)
        end
        LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updCanvas)
        ML:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updCanvas)
        RL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updCanvas)

        track(TB.MouseEnter:Connect(function()
            if not(activeTab and activeTab.Btn==TB) then TLbl.TextColor3=C_TEXT; TIco.ImageColor3=C_TEXT end
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

        local TabAPI={}
        function TabAPI:CreateWindow(t,c) return buildWindow(t,c,L,M,R) end
        return TabAPI
    end

    -- ───────────────── NOTIFICATION SYSTEM ─────────────────
    local notifQueue = 0
    local TweenService = game:GetService("TweenService")

    function UI:Notification(title, text, duration)
        notifQueue = notifQueue + 1
        duration = duration or 3
        local yOffset = -10 - (notifQueue - 1) * 76

        local NF = Instance.new("Frame")
        NF.Name = rn()
        NF.Size = UDim2.new(0, 260, 0, 60)
        NF.Position = UDim2.new(1, 10, 1, yOffset)
        NF.BackgroundColor3 = C_CARD
        NF.BorderSizePixel = 0
        NF.ZIndex = 20
        NF.Parent = SG
        local NS = Instance.new("UIStroke")
        NS.Color = C_ACCENT; NS.Thickness = 1; NS.Parent = NF
        -- Accent bar left
        local NBar = Instance.new("Frame")
        NBar.Size = UDim2.new(0, 3, 1, 0)
        NBar.BackgroundColor3 = C_ACCENT; NBar.BorderSizePixel = 0; NBar.ZIndex = 21; NBar.Parent = NF
        -- Title
        local NTitle = Instance.new("TextLabel")
        NTitle.Size = UDim2.new(1, -14, 0, 20)
        NTitle.Position = UDim2.new(0, 10, 0, 6)
        NTitle.BackgroundTransparency = 1; NTitle.Text = title
        NTitle.TextColor3 = C_ACCENT; NTitle.TextSize = 11; NTitle.Font = Enum.Font.GothamBold
        NTitle.TextXAlignment = Enum.TextXAlignment.Left; NTitle.ZIndex = 21; NTitle.Parent = NF
        -- Body
        local NBody = Instance.new("TextLabel")
        NBody.Size = UDim2.new(1, -14, 0, 30)
        NBody.Position = UDim2.new(0, 10, 0, 24)
        NBody.BackgroundTransparency = 1; NBody.Text = text
        NBody.TextColor3 = C_DIM; NBody.TextSize = 10; NBody.Font = Enum.Font.Gotham
        NBody.TextXAlignment = Enum.TextXAlignment.Left
        NBody.TextWrapped = true; NBody.ZIndex = 21; NBody.Parent = NF

        -- Slide in
        TweenService:Create(NF, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -270, 1, yOffset)
        }):Play()

        task.spawn(function()
            task.wait(duration)
            local tw = TweenService:Create(NF, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 10, 1, yOffset)
            })
            tw:Play()
            tw.Completed:Wait()
            NF:Destroy()
            notifQueue = math.max(0, notifQueue - 1)
        end)
    end

    function UI:Destroy()
        for _,c in ipairs(conns) do if c and c.Connected then c:Disconnect() end end
        conns={}; if SG then SG:Destroy() end
    end

    return UI
end

return DeadHub
