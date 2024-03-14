local _, SRH = ...;

S_Roulette_Char_DB = S_Roulette_Char_DB or {};
S_Roulette_DB = S_Roulette_DB or {};
if(not Custom_RouletteFrame) then
    return false;
end
if(not S_Roulette_Char_DB.TOTAL) then
    S_Roulette_Char_DB.TOTAL = 0
end


local function tsize(t)
    local result = 0;
    for _,_ in pairs(t or {}) do
        result = result + 1
    end
    return result;
end

local frames = {};
local events = {};
local frame = CreateFrame("Frame", "SRH_MainFrame", Custom_RouletteFrame);
do
    if(not Custom_RouletteFrame.closeButton.isSkinned) then
        Custom_RouletteFrame:SetScale(0.75);
    end
    local point, relativeFrame, relativePoint, ofsx, ofsy = Custom_RouletteFrame:GetPoint();
    Custom_RouletteFrame:ClearAllPoints();

    Custom_RouletteFrame:SetPoint(point, relativeFrame, relativePoint, ofsx - 100, ofsy)
    frame:SetSize(Custom_RouletteFrame:GetWidth()/2.3, Custom_RouletteFrame:GetHeight()*0.65);
    if(frame.CreateBackdrop) then
        frame:CreateBackdrop("Transparent");
    else
        frame:SetBackdrop({
            bgFile = [[Interface\TutorialFrame\TutorialFrameBackground]],
            edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
            tile = true,
            edgeSize = 4,
            tileSize = 5
        });
        frame:SetBackdropColor(.3, .3, .3, 1);
        frame:SetBackdropBorderColor(0.1, 0.1, 0.1);
    end
    frame:SetPoint("LEFT", Custom_RouletteFrame, "RIGHT", 0 ,0)
    local title = frame:CreateFontString(nil,"OVERLAY","GameFontNormal");
    title:SetText("История рулетки");
    title:SetPoint("TOP",0,-5);
    local totalTextPerChar = frame:CreateFontString(nil,"OVERLAY","GameFontNormal");
    totalTextPerChar:SetPoint("BOTTOMLEFT",5,35);
    totalTextPerChar :SetSize(frame:GetHeight()*0.8, 20);
    totalTextPerChar :SetJustifyH("LEFT")
    local totalTextPerAccount = frame:CreateFontString(nil,"OVERLAY","GameFontNormal");
    totalTextPerAccount:SetPoint("TOP",totalTextPerChar, "BOTTOM", 0 , -5 );
    totalTextPerAccount:SetSize(frame:GetHeight()*0.8, 20);
    totalTextPerAccount:SetJustifyH("LEFT")
    function frame:SetTotalPerChar(value)
        totalTextPerChar:SetText(string.format("Всего прокрутов на персонаже: %i", value));
    end
    function frame:SetTotalPerAccount(value)
        totalTextPerAccount:SetText(string.format("Всего прокрутов на аккаунте: %i", value));
    end
    frame:Hide();
    frame:SetAlpha(0);

    local btn_show_hide = CreateFrame("Button", nil, Custom_RouletteFrame);
    btn_show_hide:SetSize(30, 30);
    btn_show_hide.texture = btn_show_hide:CreateTexture();
    btn_show_hide.texture:SetAllPoints(btn_show_hide);
    btn_show_hide.texture:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47");
    btn_show_hide:ClearAllPoints();
    btn_show_hide:SetPoint("RIGHT", Custom_RouletteFrameCloseButton, "RIGHT", -55 ,0);
    btn_show_hide:SetScript("OnClick", function (self)
        if(frame:IsShown()) then
            C_Timer:NewTicker(0.05, function ()
                if(frame:GetAlpha() > 0.2) then
                    frame:SetAlpha(frame:GetAlpha() - 0.2);
                else
                    frame:SetAlpha(frame:GetAlpha() - 0.2);
                    frame:Hide();
                end
            end, 10);
        else
            C_Timer:NewTicker(0.05, function ()
                if(frame:GetAlpha() < 0.2) then
                    frame:Show();
                    frame:SetAlpha(frame:GetAlpha() + 0.2);
                else
                    frame:SetAlpha(frame:GetAlpha() + 0.2);
                end
            end, 10);
        end
    end)

    local btn_wipe_DB = CreateFrame("Button", "SRH_WIPE", frame);
    btn_wipe_DB:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true,
        edgeSize = .3,
        tileSize = .3
    });
    btn_wipe_DB:SetBackdropColor(.3, .3, .3, 1);
    btn_wipe_DB:SetBackdropBorderColor(0.1, 0.1, 0.1);
    btn_wipe_DB:SetSize(100, 20)
    btn_wipe_DB:SetPoint("RIGHT", frame, "BOTTOMRIGHT",-2,20);
    btn_wipe_DB.Text = btn_wipe_DB:CreateFontString(nil,"OVERLAY","GameFontNormal");
    btn_wipe_DB.Text:SetText("Очистить историю")
    btn_wipe_DB.Text:SetPoint("CENTER",0,0);
    btn_wipe_DB:SetScript("OnClick", function (self)
        local temp = S_Roulette_Char_DB;
        table.wipe(S_Roulette_Char_DB);
        for k,v in pairs(temp) do
            S_Roulette_Char_DB[k] = 0;
        end
        S_Roulette_DB[UnitName("Player")] = S_Roulette_Char_DB;

        for _,v in pairs(frames) do
            v:UpdateValue();
        end
        frame:SetTotalPerChar(S_Roulette_Char_DB.TOTAL);
        local total = 0;
        for _,v in pairs(S_Roulette_DB or {}) do
            total = total + (v.TOTAL or 0);
        end
        frame:SetTotalPerAccount(total);

    end)

    --cb_roulette = SRH.UI.ComboBox("SpinCounters", Custom_RouletteFrameSpinButton, {Height = 30, Width = 100}, nil, {1,2,3,4,5,6}, "Test", function(self) print(self:GetIndex()) end);
    

    btn_show_hide:SetScript("OnEnter", function (self)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
        GameTooltip:AddLine("Показать/Скрыть историю рулетки.")
        GameTooltip:Show();
    end)
    btn_show_hide:SetScript("OnLeave", function (self)
        GameTooltip:Hide();
    end)


end
local dgv = SRH.UI.CreateDGV(SRH_MainFrame,{}, {});
dgv:SetPoint("TOPLEFT", SRH_MainFrame, "TOPLEFT", 2, -25);

local colums ={};
colums.Index = dgv:AddColumn({Name = "#", Key = "Index"});
colums.Item = dgv:AddColumn({Name = "   Название предмета   ", Key = "Item"});
colums.Count = dgv:AddColumn({Name = "  ШТ  ", Key = "Count"});
colums.Percnt = dgv:AddColumn({Name = "  Шанс  ", Key = "Percent"});

colums.Item:SetWidth(frame:GetWidth() - colums.Count:GetWidth() - colums.Percnt:GetWidth() - colums.Index:GetWidth() - 4);
colums.Index:SetJustifyHAllRows("RIGHT")
colums.Item:SetJustifyHAllRows("LEFT");
colums.Percnt:SetJustifyHAllRows("RIGHT")




frame:SetScript("OnShow", function (self)
   
    if(not S_Roulette_DB[UnitName("Player")]) then
        S_Roulette_DB[UnitName("Player")] = S_Roulette_Char_DB;
    end
    self:SetTotalPerChar(S_Roulette_Char_DB.TOTAL or 0);
    local total = 0;
    for _,v in pairs(S_Roulette_DB or {}) do
        total = total + (v.TOTAL or 0);
    end
    self:SetTotalPerAccount(total);
    if(tsize(frames) > 0) then
        for _,v in pairs(frames) do
            v:UpdateValue();
        end
        return;
    end
    
    for k, v in pairs(Custom_RouletteFrame.rewardData or {}) do
        if(v and type(v) == "table" and v.amountMin) then
            local key = string.format("%i:%i:%i",v.itemID, v.amountMin and v.amountMin or 0, v.isJackpot and 1 or 0);
            if(not S_Roulette_Char_DB[key]) then
                S_Roulette_Char_DB[key] = 0;
            end
            local itemName, itemLink = GetItemInfo(v.itemID);
            if(v.amountMin > 1) then
                itemLink = itemLink.." x"..v.amountMin;
            end
            local f = dgv:AddRow({Index = k, ItemName = itemName, ItemId = v.itemID, Item = itemLink , Count = 0, Percent = 0});
            f.ID = key;
            f.Item.Value = itemName;
            S_Roulette_Char_DB[key] = S_Roulette_Char_DB[key] or 0;
            S_Roulette_Char_DB.TOTAL = S_Roulette_Char_DB.TOTAL or 0;
            function f:UpdateValue()
                self:SetValue("Count", S_Roulette_Char_DB[key] or 0);
                if(S_Roulette_Char_DB and S_Roulette_Char_DB.TOTAL and S_Roulette_Char_DB.TOTAL > 0) then
                    
                    self:SetValue("Percent", (S_Roulette_Char_DB[key] or 0) / S_Roulette_Char_DB.TOTAL *100 , "%.2f%%");
                else
                    S_Roulette_Char_DB.TOTAL = 0;
                    self:SetValue("Percent", 0, "%.2f%%");
                end
            end
            f:UpdateValue()
            f:SetScript("OnEnter", function (self)
                GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
                GameTooltip:SetHyperlink(itemLink);
                GameTooltip:AddDoubleLine("|cffFFFFFFВыиграно:|r", string.format("|cffFFFFFF%i|r раз(а).", S_Roulette_Char_DB[f.ID] or 0));
                if(S_Roulette_Char_DB.TOTAL > 0) then
                    if(S_Roulette_Char_DB[self.ID] and S_Roulette_Char_DB[self.ID] > 0) then
                        GameTooltip:AddDoubleLine("|cffFFFFFFШанс выиграть:|r", string.format("|cffFFFFFF%.3f%%|r", S_Roulette_Char_DB[f.ID] /S_Roulette_Char_DB.TOTAL*100));
                    else
                        GameTooltip:AddDoubleLine("|cffFFFFFFШанс выиграть:|r", "|cffFF3333НЕИЗВЕСТНО|r");
                    end
                end

                local globals = {count = 0, total = 0};
                for _, v in pairs(S_Roulette_DB) do
                    globals.count = globals.count + (v[f.ID] or 0);
                    globals.total = globals.total + (v.TOTAL or 0);
                end
                if(globals.total > 0) then
                    GameTooltip:AddLine("Информация по всем персонажам:");
                    GameTooltip:AddDoubleLine("|cffFFFFFFВыиграно:|r", string.format("|cffFFFFFF%i|r раз(а).", globals.count));
                    if(globals.count == 0) then
                        GameTooltip:AddDoubleLine("|cffFFFFFFШанс выиграть:|r", "|cffFF3333НЕИЗВЕСТНО|r");
                    else
                        GameTooltip:AddDoubleLine("|cffFFFFFFШанс выиграть:|r", string.format("|cffFFFFFF%.3f%%|r", globals.count  / globals.total*100));
                    end
                end
                GameTooltip:Show();
            end)
            f:SetScript("OnLeave", function (self)
                GameTooltip:Hide();
            end)
            frames[key] = f;
        end
    end
end)

do  -- Events
    function events:CHAT_MSG_ADDON(prefix, msg)
        if(prefix == "ASMSG_LOTTERY_REWARD" and #msg > 0) then
            if(not S_Roulette_Char_DB[msg]) then
                S_Roulette_Char_DB[msg] = 0;
            end
            if(not S_Roulette_Char_DB.TOTAL) then
                S_Roulette_Char_DB.TOTAL = 0
            end
            S_Roulette_Char_DB[msg] = S_Roulette_Char_DB[msg] + 1;
            S_Roulette_Char_DB.TOTAL = S_Roulette_Char_DB.TOTAL + 1;
            S_Roulette_DB[UnitName("Player")] = S_Roulette_Char_DB;

        elseif(prefix == "ACMSG_LOTTERY_REWARD" and frame:IsShown()) then
            for _,v in pairs(frames) do
                v:UpdateValue();
            end
            frame:SetTotalPerChar(S_Roulette_Char_DB.TOTAL);
            local total = 0;
            for _,v in pairs(S_Roulette_DB or {}) do
                total = total + (v.TOTAL or 0);
            end
            frame:SetTotalPerAccount(total);
        end
    end
end

for k, _ in pairs(events or {}) do
    frame:RegisterEvent(k);
end
frame:SetScript("OnEvent", function (_, event, ...)
    -- if(not events[event]) then return end;
    events[event](_, ...);
end)