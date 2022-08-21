local _, SRH = ...
SRH.UI = SRH.UI or {};

local function tsize(t)
    local result = 0;
    for _,_ in pairs(t or {}) do
        result = result + 1
    end
    return result;
end

function SRH.UI.CreateDGV(parent, columnDB, rowDB)
    -- assert(type(parent) == "table", "Parent not found");
    -- assert(type(header) == "table", "Header not found");
    -- assert(tsize(header) > 0, "Header keys a nil value");

    local f = CreateFrame("Frame", nil, parent or UIParent);
    local header = CreateFrame("Frame", "SRH_Header", f);
    local rows_mf = CreateFrame("Frame", "SRH_Rows_MF", f);
    local last_sort_key = nil;
    local x,y = 0, -3
    do
        f:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true,
            edgeSize = .3,
            tileSize = .3
        });
        f:SetBackdropColor(.3, .3, .3, .0);
        f:SetBackdropBorderColor(0.1, 0.1, 0.1);
        f:SetPoint("CENTER",0,0)
        f:SetSize(0, 20)
        f:SetScript("OnSizeChanged", function(self, w, h)
            header:SetWidth(w);
            rows_mf:SetSize(w,h - header:GetHeight());
            for k,v in pairs(self.Rows or {}) do
                v:SetWidth(w);
            end
        end);
        
        header:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true,
            edgeSize = 1,
            tileSize = 5
        });
        header:SetBackdropColor(.2, .2, .2, .3);
        header:SetBackdropBorderColor(0.1, 0.1, 0.1);
        header:SetPoint("TOP", f, "TOP",0,0)
        header:SetSize(f:GetWidth(), 20)
        if(rows_mf.CreateBackdrop) then
            rows_mf:CreateBackdrop("Transparent");
        else
            rows_mf:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
                tile = true,
                edgeSize = .7,
                tileSize = 1
            });
            rows_mf:SetBackdropColor(.2, .2, .2, .3);
            rows_mf:SetBackdropBorderColor(0.1, 0.1, 0.1);
        end
        
        
        rows_mf:SetHeight(f:GetHeight() - header:GetHeight());
        rows_mf:SetPoint("TOP", header, "BOTTOM", 0 ,0)
    end
    f.Columns = {};
    f.Rows = {};

    function f:AddColumn(...)
        local param1, param2 = ...
        assert(type(param1) == "table" or (type(param1) == "string" and type(param2) == "string"), "invalid params");
        local key, name
        if(type(param1) == "table") then
            key = param1.Key or param1.Name or nil;
            name = param1.Name or param1.Key or nil;
        else
            key = param1;
            name = param2;
        end
        assert(key and name, "Incorrect params");

        local btn = CreateFrame("Button", "Column"..key, header)
        btn.JustifyH = "CENTER";
        btn.JustifyW = "CENTER";
        btn.Key = key;
        btn:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true,
            edgeSize = .5,
            tileSize = 1
        });
        btn:SetBackdropColor(.2, .2, .2, .7);
        btn:SetBackdropBorderColor(.1, .1, .1);
        btn.text = btn:CreateFontString(nil,"OVERLAY","GameFontNormal");

        btn.text:SetText(name or "Unnamed");
        btn:SetSize(20,20);
        btn.text:SetPoint("CENTER",btn,"CENTER", 0,0);
        btn:SetWidth(btn.text:GetStringWidth() + 10);
        btn.text:SetJustifyH("CENTER");
        btn.text:SetSize(btn:GetWidth() - 4, btn:GetHeight() - 4);
        self:SetWidth(self:GetWidth() + btn:GetWidth())


        if(tsize(self.Columns) == 0) then
            btn:SetPoint("LEFT", header, "LEFT", 0,0);
        else
            btn:SetPoint("LEFT", self.Columns[#self.Columns] , "RIGHT", 0,0);
        end
        function btn:SetJustifyHAllRows(value)
            self.JustifyH = value;
            for _,v in pairs(f.Rows) do
                v[self.Key]:SetJustifyH(self.JustifyH);
            end
        end
        function btn:SetJustifyWAllRows(value)
            self.JustifyW = value;
            for _,v in pairs(f.Rows) do
                v[self.Key]:SetJustifyW(self.JustifyW);
            end
        end
        btn:SetScript("OnSizeChanged", function (self, w, h)
            local width = 0;
            for _, v in pairs(f.Columns) do
                width = width + v:GetWidth();
            end
            f:SetWidth(width);
            for _,v in pairs(f.Rows) do
                v[self.Key]:SetWidth(w);
            end
        end)
        btn:SetScript("OnClick", function (self)
            f:Sort(self.Key);
        end)

        table.insert(self.Columns, btn);
        return btn;
    end
    function f:AddRow(params)
        local name = self:GetParent():GetName() .."Row" .. #self.Rows + 1
        local r = CreateFrame("Button", name, rows_mf);
        r:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true,
            tileEdge = true,
            tileSize = 0,
            edgeSize = .1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        });
        r:SetBackdropColor(.15, .15, .15, .4);
        r:SetBackdropBorderColor(.4, .4, .4, 0);
        
        r.Name = name
        local rows_count = #self.Rows;
        r:SetSize(rows_mf:GetWidth()-2, 20);
        if(rows_count == 0) then
            r:SetPoint("TOP", rows_mf, "TOP",x,y);
        else
            r:SetPoint("TOP", self.Rows[rows_count], "BOTTOM",x,y);
        end
        
        
        local nextPoint = r;
        for i = 1, #self.Columns do
            local key = self.Columns[i].Key;
            r[key] = r:CreateFontString(nil,"OVERLAY","GameFontNormal");
            if(r.CreateBackdrop) then 
                r[key]:SetFont("Fonts\\FRIZQT__.TTF", 10);
            else
                r[key]:SetFont("Fonts\\FRIZQT__.TTF", 10);
            end
            r[key]:SetWidth(self.Columns[i]:GetWidth())
            r[key]:SetText(params[key]);
            r[key]:SetJustifyH(self.Columns[i].JustifyH);
            r[key].Value = params[key]
            if(r == nextPoint) then
                r[key]:SetPoint("LEFT", nextPoint, "LEFT", 0, 0);
            else
                r[key]:SetPoint("LEFT", nextPoint, "RIGHT", 0, 0);
            end
            nextPoint = r[key];
        end
        function r:SetValue(key, value, format)
            local format = format or "%s";
            self[key].Value = value;
            self[key]:SetText(string.format(format, value));
        end
        f:SetHeight(f:GetHeight()+23)
        table.insert(self.Rows, r);
        return r;
    end
    function f:Sort(keyparam)
        local isFind = false;
        for _,v in pairs(self.Columns) do
            if(v.Key == keyparam) then
                isFind = true;
                break
            end
        end
        if(not isFind) then return end;
        local isRevers = keyparam == last_sort_key;
        last_sort_key = keyparam;
        if(isRevers) then
            table.sort(self.Rows, function(a,b) return a[keyparam] and b[keyparam] and a[keyparam].Value > b[keyparam].Value end);
            last_sort_key = nil
        else
            table.sort(self.Rows, function(a,b) return a[keyparam] and b[keyparam] and a[keyparam].Value < b[keyparam].Value end);
        end
        for i = 1, #self.Rows do
            self.Rows[i]:ClearAllPoints();
            if(i == 1) then
                self.Rows[i]:SetPoint("TOP", rows_mf, "TOP", x, y);
            else
                self.Rows[i]:SetPoint("TOP", self.Rows[i-1], "BOTTOM", x, y);
            end
        end

    end
    function f:GetColumnByKey(key)
        for _, v in pairs(f.Columns) do
            if(v.Key == key) then
                return v;
            end
        end
    end

    for k,v in pairs(columnDB or {}) do
        f:AddColumn(v);
    end
    for k,v in pairs(rowDB or {}) do
        f:AddRow(v);
    end
    f:Sort(#f.Columns> 0 and f.Columns[1].Key or false);
    return f;
end






-- local myStruct = {
--     {Name = "#", Key = "Index"},
--     {Name = "Наименование предмета", Key = "ItemName"},
--     {Name = "Кол-во", Key = "Count"},
--     {Name = "Шанс", Key = "Percent"},
-- }





-- local myStructDB = {
--     {Index = 1, ItemName = "TestName", Count = 1, Percent = .3},
--     {Index = 2, ItemName = "TestName", Count = 5, Percent = .2},
--     {Index = 3, ItemName = "TestName", Count = 10, Percent = .1},
--     {Index = 4, ItemName = "TestName", Count = 1, Percent = .8},

-- }
-- ab = CreateDGV(nil, myStruct, myStructDB)
-- --/run ab = CreateDGV()