-- 创建时间:2020-08-31
-- Panel:LWZBSettlePanel
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

LWZBSettlePanel = basefunc.class()
local C = LWZBSettlePanel
C.name = "LWZBSettlePanel"
local M = LWZBModel
function C.Create(fun,remain_time)
	return C.New(fun,remain_time)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["EnterBackGround"] = basefunc.handler(self,self.on_background_msg)--切到后台
    self.lister["lwzb_force_exit_qlcf_or_settel_msg"] = basefunc.handler(self,self.on_lwzb_force_exit_qlcf_or_settel_msg)
    self.lister["lwzb_cskjpanel_has_create_msg"] = basefunc.handler(self,self.on_lwzb_cskjpanel_has_create_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.comhuxi then
		CommonHuxiAnim.Stop(self.comhuxi)	
		self.comhuxi = nil
	end
	self:StopTimerGuideBtnNext()
	self:StopAutoExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(fun,remain_time)
	self.fun = fun
	self.remain_time = remain_time or 4
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.all_info = M.GetAllInfo()
	if M.CheckIisLW() then
		self.lei_02.gameObject:SetActive(false)
	else
		self.lei_02.gameObject:SetActive(true)
	end
	self.animator = self.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.next_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnNextClick()
	end)

	local data = self.all_info.game_data.monster_pai
	local count_win = 0
	local count_lose = 0
	dump(data,"<color=yellow>++++++++++++++++++++++</color>")
	for i=1,#data do
		if data[i].is_win == 1 then
			count_win = count_win + 1
		else
			count_lose = count_lose + 1
		end
	end
	if count_win == 0 then--龙王完胜
		--self.title_img.sprite = GetTexture("lwzb_imgf_lwqs")
		self.animator:Play("LWZBSettlePanel_LWQS")
	elseif count_lose == 0 then--屠龙
		--self.title_img.sprite = GetTexture("lwzb_imgf_tl")
		self.animator:Play("LWZBSettlePanel_TL")
	else--普通结果
		--self.title_img.sprite = GetTexture("lwzb_imgf_jsxx")
		self.animator:Play("LWZBSettlePanel")
	end
	--self.title_img:SetNativeSize()

	self.lwaward_txt.text = self.all_info.settle_data.dragon_award
	if tonumber(self.all_info.settle_data.dragon_award) < 0 then
		self.lwaward_txt.material = GetMaterial("imageGrey")
	else
		self.lwaward_txt.material = nil
	end
	if self.all_info.settle_data.dragon_status == -1 then
		self.pc.gameObject:SetActive(true)
	elseif self.all_info.settle_data.dragon_status == -1 then
		self.pc.gameObject:SetActive(false)
	elseif self.all_info.settle_data.dragon_status == -1 then
		self.pc.gameObject:SetActive(false)
	end
	URLImageManager.UpdateHeadImage(self.all_info.dragon_info.player_info.head_image, self.lwhead_img)
	self.lwname_txt.text = self.all_info.dragon_info.player_info.player_name
	if self.all_info.dragon_info.player_info.vip_level then
		VIPManager.set_vip_text(self.lwvip_txt, self.all_info.dragon_info.player_info.vip_level) 
	else
		self.lwvip_txt.gameObject:SetActive(false)
	end
	local lwpx_type = self.all_info.game_data.long_wang_pai.pai_type
	if lwpx_type == 1 or lwpx_type == 2 then
		self.lwpx_txt.text = LWZBManager.CheckPaiType(lwpx_type)
		self.lwpx_txt.gameObject:SetActive(true)
		self.lwpx_img.gameObject:SetActive(false)
	else
		self.lwpx_img.sprite = GetTexture(LWZBManager.CheckPaiType(lwpx_type))
		self.lwpx_img:SetNativeSize()
		self.lwpx_txt.gameObject:SetActive(false)
		self.lwpx_img.gameObject:SetActive(true)
	end


	self.myname_txt.text = MainModel.UserInfo.name
	VIPManager.set_vip_text(self.myvip_txt)
	local temp = 0
	dump(self.all_info.settle_data.award_value,"<color=red>////////////////////</color>")
	for i=1,#self.all_info.settle_data.award_value do
		temp = temp + tonumber(self.all_info.settle_data.award_value[i])
	end
	self.myaward_txt.text = temp
	if temp < 0 then
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_jiesuan_1.audio_name)
		self.myaward_txt.material = GetMaterial("imageGrey")
	elseif temp > 0 then
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_jiesuan_2.audio_name)
		self.myaward_txt.material = nil
	else
		self.myaward_txt.material = nil
	end
	if self.all_info.settle_data.wj_status == -1 then
		self.mypc.gameObject:SetActive(true)
		self.yfd.gameObject:SetActive(false)
	elseif self.all_info.settle_data.wj_status == 0 then
		self.mypc.gameObject:SetActive(false)
		self.yfd.gameObject:SetActive(false)
	elseif self.all_info.settle_data.wj_status == 1 then
		self.mypc.gameObject:SetActive(false)
		self.yfd.gameObject:SetActive(true)
	end
	local myxz_data = self.all_info.bet_data.my_bet_data
	for i=1,#myxz_data do
		self["ss"..i.."yz_txt"].text = "充能:"..myxz_data[i]
	end
	local sspx_data = self.all_info.game_data.monster_pai
	for i=1,#sspx_data do
		local sspx_type = sspx_data[i].pai_type
		if sspx_type == 1 or sspx_type == 2 then
			self["ss"..i.."px_txt"].text = LWZBManager.CheckPaiType(sspx_type)
			self["ss"..i.."px_txt"].gameObject:SetActive(true)
			self["ss"..i.."px_img"].gameObject:SetActive(false)
		else
			self["ss"..i.."px_img"].sprite = GetTexture(LWZBManager.CheckPaiType(sspx_type))
			self["ss"..i.."px_img"]:SetNativeSize()
			self["ss"..i.."px_img"].transform.localScale = Vector3.New(0.6,0.6,0.6)
			for j=3,10 do
				if sspx_type == j then
					self["ss"..i.."px_img"].transform.localScale = Vector3.New(0.7,0.7,0.7)
				end
			end
			self["ss"..i.."px_txt"].gameObject:SetActive(false)
			self["ss"..i.."px_img"].gameObject:SetActive(true)
		end
	end
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.myhead_img)
	if LWZBManager.GetLwzbGuideOnOff() then
		self:TimerGuideBtnNext(true)
	end
	self:AutoExit()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:AutoExit()
	self:StopAutoExit()
	self:RefreshDownCount()
	self.AutoExit_timer = Timer.New(function ()
		self:RefreshDownCount()
		if LWZBManager.GetLwzbGuideOnOff() then
			--Event.Brocast("lwzb_guide_check")
			--self:MyExit()
		else
			if self.fun and ("function" == type(self.fun)) then
				self.fun()
				self:MyExit()
			else
				if not LWZBManager.CheckMoneyIsEnoughOnSettle() then
					M.CreateHint()
				end
			end
		end
		--self:MyExit()
	end,self.remain_time,1)
	self.AutoExit_timer:Start()
end

function C:StopAutoExit()
	if self.AutoExit_timer then
		self.AutoExit_timer:Stop()
		self.AutoExit_timer = nil
	end
end

function C:RefreshDownCount()
	--self.continue_txt.text = "继续("..self.remain_time..")"
end

function C:on_background_msg()
	self:MyExit()
end


function C:on_lwzb_force_exit_qlcf_or_settel_msg()
	self:MyExit()
end

function C:TimerGuideBtnNext(b)
	self:StopTimerGuideBtnNext()
	if b then
		self.guidetiemr = Timer.New(function ()
			self.next_btn.gameObject:SetActive(true)
			if self.comhuxi then
				CommonHuxiAnim.Stop(self.comhuxi)	
				self.comhuxi = nil
			end
			self.comhuxi = CommonHuxiAnim.Start(self.next_btn.gameObject,1)
		end,2,1,false)
		self.guidetiemr:Start()
	end
end

function C:StopTimerGuideBtnNext()
	if self.guidetiemr then
		self.guidetiemr:Stop()
		self.guidetiemr = nil
	end
end

function C:OnNextClick()
	LWZBManager.SetXsydSataus(1)
	if LWZBManager.GetLwzbGuideOnOff() then
        Network.SendRequest("set_xsyd_status", {status = 1, xsyd_type="xsyd_lwzb"},function (data)
            dump(data,"<color=yellow>++++++++++set_xsyd_status+++++++++</color>")
            MainModel.UserInfo.xsyd_status = 1
			LWZBManager.SetLwzbGuideOnOff()
			local parm = {
				enterSceneCall = function ()
					LWZBManager.Sign(1)
				end
			}
			LWZBLogic.change_panel(LWZBLogic.panelNameMap.hall,parm)
        end)
    end
end

function C:on_lwzb_cskjpanel_has_create_msg()
	self:MyExit()
end