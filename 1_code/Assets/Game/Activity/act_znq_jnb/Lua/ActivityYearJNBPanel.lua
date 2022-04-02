-- 创建时间:2019-08-22
-- Panel:ActivityYearJNBPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

package.loaded["Game.CommonPrefab.Lua.ActivityYearJNBAwardPoolPanel"] = nil
require "Game.CommonPrefab.Lua.ActivityYearJNBAwardPoolPanel"
package.loaded["Game.CommonPrefab.Lua.ActivityYearJNBGetAwardListPanel"] = nil
require "Game.CommonPrefab.Lua.ActivityYearJNBGetAwardListPanel"
package.loaded["Game.CommonPrefab.Lua.ActivityYearJNBAwardPanel"] = nil
require "Game.CommonPrefab.Lua.ActivityYearJNBAwardPanel"


ActivityYearJNBPanel = basefunc.class()
local C = ActivityYearJNBPanel
C.name = "ActivityYearJNBPanel"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end
function C.CheckActivityState()
	ActivityYearModel.GetJNBData()
	local cfg_parm = ActivityYearModel.UIConfig.jnb_config_parm
	if not cfg_parm then return end
	local jnb = GameItemModel.GetItemCount("prop_jinianbi")
	local jpq = GameItemModel.GetItemCount("prop_znq_dhq")
	local data
	if jnb >= cfg_parm.dh_num then
		data = {id=cfg_parm.activity_id, state = ACTIVITY_HINT_STATUS_ENUM.AT_Get}
	else
		local curt = os.time()
		if cfg_parm.gf_begin_time <= curt and curt <= cfg_parm.gf_end_time and jpq > 0 then
			data = {id=cfg_parm.activity_id, state = ACTIVITY_HINT_STATUS_ENUM.AT_Get}
		else
			data = {id=cfg_parm.activity_id, state = ACTIVITY_HINT_STATUS_ENUM.AT_Nor}
		end
	end
	if data then
		SYSACTBASEManager.on_ui_activity_state_msg(data)
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["znq_exchange_dhq_response"] = basefunc.handler(self, self.on_znq_exchange_dhq)
    self.lister["znq_exchange_award_pool_response"] = basefunc.handler(self, self.on_znq_exchange_award_pool)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent, cfg)

	ExtPanel.ExtMsg(self)

	self.data = cfg
	ActivityYearModel.GetJNBData()
	self.cfg_parm = ActivityYearModel.UIConfig.jnb_config_parm

	local obj
	if parent~=nil then 
		obj = newObject(C.name, parent)
	else
		obj= newObject(C.name, GameObject.Find("Canvas/LayerLv5").transform)
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	if parent~=nil then 
		self.MB.gameObject:SetActive(false)
	else
		self.MB.gameObject:SetActive(true)
	end
	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnHelpClick()
	end)
	self.dh_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnDHClick()
	end)
	self.get_award_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetAwardClick()
	end)
	self.jpxq_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnJPXQClick()
	end)
	self.hjmd_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnHJMDClick()
	end)
	self.get_jnb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGotoJNBClick()
	end)


	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.award_icon_img.sprite = GetTexture(self.cfg_parm.award_icon)
	self:OnAssetChange()

	self.act_time_txt.text = self.cfg_parm.gf_time_desc

	self.introduce_txt.text = self.cfg_parm.desc or ""

	local curt = os.time()
	if self.cfg_parm.gf_begin_time <= curt and curt <= self.cfg_parm.gf_end_time then
		self.hjmd_btn.gameObject:SetActive(true)
	else
		self.hjmd_btn.gameObject:SetActive(false)
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:OnAssetChange()
	local jnb = GameItemModel.GetItemCount("prop_jinianbi")
	local jpq = GameItemModel.GetItemCount("prop_znq_dhq")
	self.jnb_num_txt.text = string.format("我的纪念币： %s个", jnb)
	self.jpq_num_txt.text = string.format("我的奖品券： %s个", jpq)	
end
function C:on_znq_exchange_dhq(_, data)
	dump(data, "<color=red>on_znq_exchange_dhq</color>")
	if data.result == 0 then
	else
		HintPanel.ErrorMsg(data.result)
	end
end
function C:on_znq_exchange_award_pool(_, data)
	dump(data, "<color=red>on_znq_exchange_award_pool</color>")
	if data.result == 0 then
		self.cfg_award = ActivityYearModel.UIConfig.jnb_config_award
		-- award_id 0 : integer                 #奖励id
		-- num 1 : integer  					  #奖励数量
		local award_list = {}
		local is_sw = false
		for k,v in ipairs(data.awards) do
			if self.cfg_award[v.award_id] then
				if self.cfg_award[v.award_id].is_sw and self.cfg_award[v.award_id].is_sw == 1 then
					is_sw = true
				end
				local d = {}
				d.icon = self.cfg_award[v.award_id].icon
				d.name = self.cfg_award[v.award_id].name .. " x" .. v.num
				d.order = self.cfg_award[v.award_id].order
				award_list[#award_list + 1] = d
			else
				dump(v, "<color=red>请解释，这是什么情况</color>")
			end
		end
		MathExtend.SortList(award_list, "order", true)
		ActivityYearJNBAwardPanel.Create(award_list, is_sw)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

-- Btn
-- 帮助
function C:OnHelpClick()
	IllustratePanel.Create({self.introduce_txt})
end
-- 兑换
function C:OnDHClick()
	local jnb = GameItemModel.GetItemCount("prop_jinianbi")
	if jnb >= self.cfg_parm.dh_num then
		Network.SendRequest("znq_exchange_dhq", nil, "兑换")
	else
		HintPanel.Create(1, "您的纪念币数量不足")
	end
end
-- 瓜分奖池
function C:OnGetAwardClick()
	local jpq = GameItemModel.GetItemCount("prop_znq_dhq")
	local curt = os.time()
	if self.cfg_parm.gf_begin_time <= curt and curt <= self.cfg_parm.gf_end_time then
		if jpq > 0 then
			Network.SendRequest("znq_exchange_award_pool", nil, "兑换")	
		else
			HintPanel.Create(1, "您的奖品券数量不足")
		end
	else
		HintPanel.Create(1, "兑换活动不在时间范围内")
	end
end
-- 奖品详情
function C:OnJPXQClick()
	ActivityYearJNBAwardPoolPanel.Create()
end
-- 获奖名单
function C:OnHJMDClick()
	ActivityYearJNBGetAwardListPanel.Create()
end
-- 跳转纪念币
function C:OnGotoJNBClick()
	GameManager.GotoUI({gotoui=self.cfg_parm.gotoUI[1], goto_scene_parm=self.cfg_parm.gotoUI[2]})
end

-- 纪念币 缓存获奖名单
function C.CacheAwardListData(list, index)
	if not C.award_list_data then
	C.award_list_data = {}
end
C.award_list_data[index] = list

end
function C.GetAwardListData(index)
if not C.award_list_data then
	return
end
return C.award_list_data[index]
end

-- 获取对应的纪念币参数
function C.GetJNBData()
for k,v in pairs(UIConfig.config) do
	if v.parmData == "jnb" and ((os.time() >= v.beginTime and os.time() <= v.endTime) or (v.beginTime == -1 and v.endTime == -1)) then
		activity_jnb_parm_config = HotUpdateConfig("Game.CommonPrefab.Lua." .. v.activity_config)
		C.UIConfig.jnb_config_parm = {}
		C.UIConfig.jnb_config_award = {}
		for k, v in ipairs(activity_jnb_parm_config.config) do
			C.UIConfig.jnb_config_parm[v.parm_key] = v.parm_value
		end
		C.UIConfig.jnb_config_award = activity_jnb_parm_config.award
	end
end
end