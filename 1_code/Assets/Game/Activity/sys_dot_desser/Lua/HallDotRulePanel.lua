-- 创建时间:2018-11-08

local basefunc = require "Game.Common.basefunc"

HallDotRulePanel = basefunc.class()

HallDotRulePanel.name = "HallDotRulePanel"


local instance
function HallDotRulePanel.Create(parent)
	instance = HallDotRulePanel.New(parent)
	return instance
end

function HallDotRulePanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallDotRulePanel:MakeLister()
    self.lister = {}
end

function HallDotRulePanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallDotRulePanel:MyClose()
	self:MyExit()
    instance = nil
end

function HallDotRulePanel:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
end

function HallDotRulePanel:ctor(parent)

	ExtPanel.ExtMsg(self)

    self.parent = parent and parent or GameObject.Find("Canvas/LayerLv4/PersonalInfoPanel").transform
    self.game_honor_config = GameHonorModel.GetHonorDataByID()
	local obj = newObject(HallDotRulePanel.name, self.parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform,self)

	self:MakeLister()
	self:AddMsgListener()

    self:InitUI()
end

function HallDotRulePanel:InitUI()
    self.back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:MyClose()
        end
    )

    self:InitHonor()
end

function HallDotRulePanel:MyRefresh()
end

function HallDotRulePanel:InitHonor()
    for i=#self.game_honor_config,0,-1 do
        local v = self.game_honor_config[i]
        local item = newObject("HonorLevelRuleBiaoItem",self.level_table_content)
        local item_table = {}
        LuaHelper.GeneratingVar(item.transform,item_table)
        item_table.name_txt.text = v.level
        local award = ""
        if v.item_tips then
            for k,v_award in pairs(v.item_tips) do
                award = award .. v_award .. " "
            end
        end
        item_table.award_txt.text = award
    end
end