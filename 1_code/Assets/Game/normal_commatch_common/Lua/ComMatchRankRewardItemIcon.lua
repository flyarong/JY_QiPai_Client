local basefunc = require "Game.Common.basefunc"

ComMatchRankRewardItemIcon = basefunc.class()
ComMatchRankRewardItemIcon.name = "ComMatchRankRewardItemIcon"

function ComMatchRankRewardItemIcon.Create(data, parent)
    return ComMatchRankRewardItemIcon.New(data, parent)
end

function ComMatchRankRewardItemIcon:ctor(data, parent)
    --log("IconBg:" .. imgBg .. ", Icon:" .. imgIcon .. ", Desc:" .. desc .. ", Rank:" .. imgRank)
    if parent then
        self.parent = parent
        self.config = data
        self.Icon = newObject("ComMatchRankRewardItemIcon", self.parent.transform)
        self.transform = self.Icon.transform
        LuaHelper.GeneratingVar(self.Icon.transform, self)

        self:SetBg("jbs_icon_jt")
        self:SetDesc(self.config.award_desc)
        self:SetIconImage(self.config.award_icon[1])
    else
        self:Close()
    end
end

function ComMatchRankRewardItemIcon:SetScale(scale)
    if self.Icon then
        self.Icon.transform.localScale = scale
    end
end

function ComMatchRankRewardItemIcon:SetBg(imgBg)
    local config = self.config
    if config.rank == "第1名" then
        imgBg = imgBg .. "1"
    elseif config.rank == "第2名" then
        imgBg = imgBg .. "2"
    elseif config.rank == "第3名" then
        imgBg = imgBg .. "3"
    end

    if self.stage_img and imgBg then
        local cImg = self.stage_img.gameObject:GetComponent("Image")
        if cImg then
            local sp = GetTexture(imgBg)
	    if not sp then
	    	--default
	    	sp = GetTexture("jbs_icon_jt1")
	    end
            cImg.sprite = sp
            cImg:SetNativeSize()
        end
    end
end

function ComMatchRankRewardItemIcon:SetDesc(desc)
    if desc and self.desc_txt then
        local s = ""
        for i=1,#desc do
            if i ~= 1 then
                s = s .. "\n"
            end
            s = s .. desc[i]
        end
        self.desc_txt.text = s     
    end
end

function ComMatchRankRewardItemIcon:SetIconSize(w, h)
    if self.item_img then
        local rt = self.item_img.gameObject:GetComponent("RectTransform")
        if rt then
            rt.sizeDelta = {x = w, y = h}
        end
    end
end

function ComMatchRankRewardItemIcon:SetIconLocation(x, y)
    if self.item_img then
        local rt = self.item_img.gameObject:GetComponent("RectTransform")
        if rt then
            rt.localPosition = Vector2.New(x, y)
        end
    end
end

function ComMatchRankRewardItemIcon:SetIconImage(imgIcon)
    local config = self.config
    local setSize = function ()
        -- self.item_img:SetNativeSize()
        if config.rank == "第1名" then
            if self.item_img then
                self.item_img.transform.localScale = Vector3.New(1,1,1)
                self.item_img.transform.localPosition = Vector3.New(0,160,0)
            end
        elseif config.rank == "第2名" then
            if self.item_img then
                self.item_img.transform.localScale = Vector3.New(0.8,0.8,1)
                self.item_img.transform.localPosition = Vector3.New(20,100,0)
            end
            if self.desc_txt then
                -- self.desc_txt.color = Color.New(63/255,71/255,81/255)
                self.desc_txt.fontSize = 30
                self.desc_txt.transform.localPosition = Vector3.New(20,30,0)
            end
        elseif config.rank == "第3名" then
            if self.item_img then
                self.item_img.transform.localScale = Vector3.New(0.8,0.8,1)
                self.item_img.transform.localPosition = Vector3.New(-25,80,0)
            end
            if self.desc_txt then
                -- self.desc_txt.color = Color.New(108/255,67/255,18/255)
                self.desc_txt.fontSize = 30
                self.desc_txt.transform.localPosition = Vector3.New(-20,15,0)
            end
        end
    end
    if imgIcon and self.item_img then
        self.item_img.sprite = GetTexture(imgIcon)
        setSize()
    end
end

function ComMatchRankRewardItemIcon:SetLocation(x, y)
    if self.Icon then
        local rt = self.Icon.gameObject:GetComponent("RectTransform")
        if rt then
            rt.localPosition = Vector2.New(x, y)
        end
    end
end

function ComMatchRankRewardItemIcon:SetSize(w, h)
    if self.Icon then
        local rt = self.Icon.gameObject:GetComponent("RectTransform")
        if rt then
            rt.sizeDelta = {x = w, y = h}
        end
    end
end

function ComMatchRankRewardItemIcon:SetDescSize(w, h)
    if self.desc_txt then
        local rt = self.desc_txt.gameObject:GetComponent("RectTransform")
        if rt then
            rt.sizeDelta = {x = w, y = h}
        end
    end
end

function ComMatchRankRewardItemIcon:SetDescLocation(x, y)
    if self.desc_txt then
        local rt = self.desc_txt.gameObject:GetComponent("RectTransform")
        if rt then
            rt.localPosition = Vector2.New(x, y)
        end
    end
end

function ComMatchRankRewardItemIcon:Close()
    if self.Icon then
        destroy(self.Icon.gameObject)
    end
    closePanel(ComMatchRankRewardItemIcon.name)
end

--[[
    GetTexture("jbs_icon_jt1")
    GetTexture("jbs_icon_jt2")
    GetTexture("jbs_icon_jt3")
]]