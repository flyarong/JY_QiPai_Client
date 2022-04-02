-- 创建时间:2020-03-09
-- Panel:Act_002HBFXPanel
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

Act_002HBFXPanel = basefunc.class()
local C = Act_002HBFXPanel
C.name = "Act_002HBFXPanel"
local M = Act_002HBFXManager
local help_info = {
	[1]=
	{
		id = 1,
		text = "1.活动期间，您可以将活动分享给微信好友，邀请好友前来挑战;",
	},
	[2]=
	{
		id = 2,
		text = "2.每2位好友通过您的分享下载游戏，<color=#BB301FFF>完成新手引导后，参与本活动的斗地主挑战取胜即为组队挑战成功</color>，届时您可以获得8元现金福卡，2位好友各获得1元;",
	},
	[3]=
	{
		id = 3,
		text = "3.每位玩家仅有1次帮好友挑战的机会，进入斗地主挑战场次开始发牌即算消耗挑战机会，无论对局胜负，均会消耗挑战机会;",
	},
	[4]=
	{
		id = 4,
		text = "4.组队有效期为24小时，即当您的一位好友挑战成功后，另一位好友必须在24小时内挑战成功，成功则完成组队，失败则组队会超时失败;",
	},
	[5]=
	{
		id = 5,
		text = "5.本活动中获得的现金福卡可在活动页面“我的福卡”中进行提现，请于活动结束前提取，活动结束后未提取的福卡视为放弃奖励;",
	},
	[6]=
	{
		id = 6,
		text = "6.本公司拥有对上述活动规则的最终解释权利。",
	},

}
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_query_npca_main_data_got"] = basefunc.handler(self,self.on_model_query_npca_main_data_got)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end
	self:RemoveListener()
	Network.SendRequest("query_npca_main_data")
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.my_head_img)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.boxAnimator = self.OpenBox_btn.gameObject.transform:GetComponent("Animator")
	self.shareBtnAnimator = self.share_btn.gameObject.transform:GetComponent("Animator")
	Network.SendRequest("query_npca_main_data")
	self.SZAnim1.gameObject:SetActive(true)
	-- Act_002HBFXInvitePanel.Create()
end

function C:InitUI()
	self.share_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if self.canLj  then
				Network.SendRequest("get_npca_master_award",nil,"",function (data)
					if data and data.result == 0 then 
						self.canLj = false
						self.share_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("yhy_btn_yqhy")
						Act_002HBFXTZZDTZCG2Panel.Create()
					end
				end)
			else
				local share_cfg = basefunc.deepcopy(share_link_config.img_yql48)
			GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "panel",share_cfg = share_cfg})
			end
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.wallet_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			Act_002HBFXWalletPanel.Create()
		end
	)
	self.history_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			Act_002HBFXHistoryPanel.Create()
		end
	)
	self.lxkf_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			--sdkMgr:CallUp("400-8882620")
			Event.Brocast("callup_service_center", "400-8882620")
		end
	)
	self.hdgz_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.zdgl_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			Act_002HBFXGLPanel.Create()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:OpenHelpPanel()
	local str = help_info[1].text
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_model_query_npca_main_data_got()
	local data = M.getMainData()
	dump(data,"<color=red>福卡分享主数据=================</color>")
	local now_time = os.time()
	if data then 
		--刷新相关界面
		--IsEquals(self.share_btn.gameObject) 出现了一个bug，self.box_txt在，self.share_btn 也在，但是self.share_btn.gameObject不在了
		if data.result == 0 and self.share_btn and IsEquals(self.share_btn.gameObject) then 
			self.box_txt.text = data.can_box_award_num
			--self.challenging_time = data.challenging_time
			for i = 1,#data.challenging_player_info do 
				self["xwyd"..i.."_txt"].text = data.challenging_player_info[i].name
				self["head"..i.."_img"].gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data.challenging_player_info[i].head_image,self["head"..i.."_img"])
			end
			for i = 1,#data.box_player_info do 
				URLImageManager.UpdateHeadImage(data.box_player_info[i].head_image,self["OnInvitehead"..i.."_img"])
			end
			local img = self.share_btn.gameObject.transform:GetComponent("Image")
			if data.challenging_num > 0 then 
				img.sprite = GetTexture("yhy_btn_yqhy")
				self.share_btn.enabled = true
			else
				img.sprite = GetTexture("yhy_btn_yddsx")
				self.SZAnim1.gameObject:SetActive(false)
				self.shareBtnAnimator.enabled = false
				self.share_btn.enabled = false
			end
			if #data.challenging_player_info >= 2 then 
				self.canLj = true
				img.sprite = GetTexture("yhy_btn_lqbyjl")
				self.share_btn.enabled = true
			end 
			if data.challenging_time and tonumber(data.challenging_time) + 86400 >= now_time then 
				self:InitTimer(data.challenging_time + 86400 - now_time)
			else
				self.outTime_txt.text = " "
			end
			self.OpenBox_btn.onClick:RemoveAllListeners()
			self.OpenBox_btn.enabled = data.can_box_award_num > 0 
			self.boxAnimator.enabled = data.can_box_award_num > 0 
			self.OpenBox_btn.onClick:AddListener(
				function ()
					Network.SendRequest("get_npca_box_award")
					if data.can_box_award_num - 1 <= 0 then 
						self.OpenBox_btn.enabled = false
					end
				end
			)
			self.zyq_txt.text ="再邀"..(5 - #data.box_player_info).."人可开宝箱" 
		end
	end
end

function C:InitTimer(time)
	--"挑战倒计时：23:59:59"
	self.main_time = time
	if self.main_timer then 
		self.main_timer:Stop()
	end
	self.outTime_txt.text = "挑战倒计时： "..StringHelper.formatTimeDHMS2(self.main_time)
	self.main_timer = Timer.New(function()
		self.main_time = self.main_time - 1
		if self.main_time <= 0 then 
			self.outTime_txt.text = " "
			self.head1_img.gameObject:SetActive(false)
			self.xwyd1_txt.gameObject:SetActive(false)
			if self.main_timer then 
				self.main_timer:Stop()
			end
		end
		self.outTime_txt.text = "挑战倒计时： "..StringHelper.formatTimeDHMS2(self.main_time)
	end,1,-1)
	self.main_timer:Start()
end

function C:OnExitScene(  )
	self:MyExit()
end