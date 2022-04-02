-- 创建时间:2019-03-18
-- Panel:Fishing3DHallGamePanel
local basefunc = require "Game/Common/basefunc"

Fishing3DHallGamePanel = basefunc.class()
local C = Fishing3DHallGamePanel
C.name = "Fishing3DHallGamePanel"

local instance
function C.Create(parm)
	DSM.PushAct({panel = C.name})
	instance = C.New(parm)
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DSM.PopAct()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	self:RemoveListener()

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true

	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.config = Fishing3DHallModel.GetHallCfg()
	self.parm = parm
	dump(self.config, "<color=yellow>配置</color>")
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.set_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		SettingPanel.Create()
	end)
	self.add_jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddGold()
	end)
	self.duihuan_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnDHClick()
	end)
	self.wiki_btn.onClick:AddListener(function ()
		self:OnWikiClick()
	end)
	self.duihuan_btn.gameObject:SetActive(false)

	self:InitUI()
end

function C:InitUI()
	self.jb_txt.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.yb_txt.text = StringHelper.ToCash(MainModel.UserInfo.fish_coin or 0)
	self.red_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())

	local btn_map = {}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "fishing3d_hall")
	self.game_rect_list = {}
	self.game_rect_list[#self.game_rect_list + 1] = {obj=self.game_rect1}
	self.game_rect_list[#self.game_rect_list].ui = {}
	LuaHelper.GeneratingVar(self.game_rect1, self.game_rect_list[#self.game_rect_list].ui)
	self.game_rect_list[#self.game_rect_list + 1] = {obj=self.game_rect2}
	self.game_rect_list[#self.game_rect_list].ui = {}
	LuaHelper.GeneratingVar(self.game_rect2, self.game_rect_list[#self.game_rect_list].ui)
	self.game_rect_list[#self.game_rect_list + 1] = {obj=self.game_rect3}
	self.game_rect_list[#self.game_rect_list].ui = {}
	LuaHelper.GeneratingVar(self.game_rect3, self.game_rect_list[#self.game_rect_list].ui)

	for k,v in ipairs(self.game_rect_list) do
		v.ui.enter_btn.onClick:AddListener(function ()
			self:OnItemBtnClick(k)
		end)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:UpdateAssetInfo()
	if IsEquals(self.jb_txt) and  IsEquals(self.yb_txt) and IsEquals(self.red_txt) then
		self.jb_txt.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		self.yb_txt.text = StringHelper.ToCash(MainModel.UserInfo.fish_coin)
		self.red_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	end
end

-- 关闭
function C:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "game_MiniGame"})	
end

function C:OnAddGold()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function C:OnAddDiamond()
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

function C:OnDHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainModel.OpenDH()
end

function C:OnWikiClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Fishing3DBKPanel.Create()
end

function C:OnItemBtnClick(game_id)
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..game_id}, "CheckCondition")
    if a and not b then
    	return
    end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local cfg = Fishing3DHallModel.GetGameCfg(game_id)
	local gold =  Fishing3DHallModel.GetFishCoinAndJingBi()
	self:CheckSign(cfg,gold,game_id,"你的太富有了，请前往对应场")
end

function C:SendSign(g_id)
	-- g_id = 1
	Network.SendRequest("fsg_3d_signup", {id = g_id}, "请求报名", function (data)
		dump(data, "<color=red>fsg_3d_signup</color>")
		if data.result == 0 then
			PlayerPrefs.SetInt(Fishing3DHallModel.FishRapidBeginKey, g_id)
			GameManager.GotoUI({gotoui = "game_Fishing3D",goto_scene_parm = {game_id = g_id}})
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function C:CheckSign(cfg,gold,game_id,hint_desc)
	local can_sign, check_result = Fishing3DHallModel.CheckCanBeginGameIDByGold(cfg, gold)
	if can_sign then
		--报名
		self:SendSign(game_id)
	else
		if check_result == 1 then
			PayPanel.Create(GOODS_TYPE.jing_bi)
		elseif check_result == 2 then
			LittleTips.Create(hint_desc)
		end
	end
end
