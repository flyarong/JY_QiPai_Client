-- 创建时间:2019-05-29
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

 FishingStarPanel = basefunc.class()
 local C = FishingStarPanel
 C.name = "FishingStarPanel"
 
 function C.Create(parent)
	 return C.New(parent)
 end
 
 function C:AddMsgListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.AddListener(proto_name, func)
	 end
 end
 
 function C:MakeLister()
	 self.lister = {}
	 self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
	 self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)
 end
 
 function C:RemoveListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.RemoveListener(proto_name, func)
	 end
	 self.lister = {}
 end
 
 function C:MyExit()
	 self:RemoveListener()
 end
 
 
function C:OnDestroy()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

 function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	 parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	 local obj = newObject(C.name, parent)
	 local tran = obj.transform
	 self.transform = tran
	 self.gameObject = obj
 
	 self:MakeLister()
	 self:AddMsgListener()
	 LuaHelper.GeneratingVar(obj.transform, self)
 
	 self.back_btn.onClick:AddListener(function ()
		 ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		 self:OnBackClick()
	 end)
	 self.goto_btn.onClick:AddListener(function ()
		 ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		 self:OnGotoClick()
	 end)
	 self.help_btn.onClick:AddListener(function ()
		 ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		 self:OnHelpClick()
	 end)
 
	 self.rank_btn.onClick:AddListener(function ()
		 ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		 self:OnRankClick()
	 end)
 
	 self.sv = self.ScrollView:GetComponent("ScrollRect")
	 self.sv.enabled = true
	 self:InitUI()
 end
 
 function C:InitUI()
	 if MainModel.myLocation ~= "game_Hall" then
		 self.goto_btn.gameObject:SetActive(false)
	 else
		 self.goto_btn.gameObject:SetActive(true)
	 end
 
	 self:ClearCellList()
	 dump(FishingManager.Config.zz_list, "<color=red>FishingManager.Config.zz_list</color>")
	 for k,v in ipairs(FishingManager.Config.zz_list) do
		 local pre = FishingActivityZongziPrefab.Create(self.content, v, C.OnDHClick, self)
		 self.CellList[#self.CellList + 1] = pre
	 end
	 self:onAssetChange()
	 local s1 = os.date("%m月%d日%H点", FishingManager.Config.zz_parm.begin_time)
	 local e1 = os.date("%m月%d日%H点", FishingManager.Config.zz_parm.end_time)
	 self.activity_time_txt.text = string.format("活动时间：%s—%s", s1, e1)
	 --self:RefreshRankInfoMy()
	 self:RefreshRankHit()
	 self:query_activity_exchange()
 end
 
 function C:ClearCellList()
	 if self.CellList then
		 for k,v in ipairs(self.CellList) do
			 v:OnDestroy()
		 end
	 end
	 self.CellList = {}
 end
 function C:OnDHClick(id)
	 Network.SendRequest("activity_exchange", {type="duanwujie_fishgame_zongzi", id=id}, "请求兑换", function (data)
		 dump(data)
		 if data.result == 0 then
			 if FishingManager.Config.zz_map[id] and FishingManager.Config.zz_map[id].is_sw == 1 then
				RealAwardPanel.Create({text=FishingManager.Config.zz_map[id].award_name,image=FishingManager.Config.zz_map[id].award_icon})
			 end
			 self:query_activity_exchange()
		 else
			 HintPanel.ErrorMsg(data.result)
		 end
	 end)
 end
 function C:MyRefresh()
 end
 
 function C:OnBackClick()
	 self:MyExit()
	 destroy(self.gameObject)
 end
 function C:OnGotoClick()
	GameManager.GotoUI({gotoui="game_FishingHall"})
 end
 function C:OnHelpClick()
	 IllustratePanel.Create({self.introduce_txt})
 end
 
 function C:onAssetChange()
	 local zz = GameItemModel.GetItemCount("prop_zongzi")
	 self.myzz_txt.text = zz .. "个"
 end
 function C:onExitScene()
	 self:MyExit()
 end
 
 function C:OnRankClick()
	 PlayerPrefs.SetInt("fish_activity_rank" .. MainModel.UserInfo.user_id, os.time())
	 FishingActivityZongziRankPanel.Create()
	 self.rank_hint.gameObject:SetActive(false)
 end
 
 function C:RefreshRankInfoMy()
	 Network.SendRequest("query_watermelon_rank_base_info", {},"请求数据",function(data)
		 dump(data, "<color=yellow>我的排名</color>")
		 if data.result == 0 then
			 if data.rank == -1 then
				 self.rank_txt.text = "未上榜"
			 else
				 self.rank_txt.text = "（第" .. data.rank .. "名）"
			 end
		 else
			 self.rank_txt.text = "未上榜"
			 HintPanel.ErrorMsg(data.result)
		 end 
	 end)
 end
 
 function C:RefreshRankHit()
	 local opent = PlayerPrefs.GetInt("fish_activity_rank" .. MainModel.UserInfo.user_id, 0)
	 local is_show_hit = false
	 if opent == 0 then
		 is_show_hit = true
	 else
		 local newtime = tonumber(os.date("%Y%m%d", os.time()))
		 local oldtime = tonumber(os.date("%Y%m%d", opent))
		 if oldtime ~= newtime then
			 is_show_hit = true
		 end
	 end
	 self.rank_hint.gameObject:SetActive(is_show_hit)
 end
 
 function C:query_activity_exchange()
	 Network.SendRequest("query_activity_exchange", {type = "duanwujie_fishgame_zongzi"},"请求数据",function(data)
		 dump(data, "<color=yellow>data11</color>")
		 if data.result == 0 then
			 for i,v in ipairs(data.data) do
				 local obj = self.CellList[i]
				 if IsEquals(obj.gameObject) then
					 local l_txt = obj.transform:Find("@award_num_txt"):GetComponent("Text")
					 if v == -1 then
						 l_txt.text = string.format( "不限兑换次数")
					 else
						 l_txt.text = string.format( "剩余兑换%s次",v)
					 end
					 local btn = obj.transform:Find("@dh_not_btn")
					 btn.gameObject:SetActive(v == 0)
				 end
			 end
		 else
			 HintPanel.ErrorMsg(data.result)
		 end 
	 end)
 end

 function C.CheckActivityState()
	if  SYSACTBASEManager.CheckRedPointActive(19,SYSACTBASEManager.RedPointType.Red_Day) then
        SYSACTBASEManager.on_ui_activity_state_msg({id=19,state=ACTIVITY_HINT_STATUS_ENUM.AT_Red})    
    end 
	if  GameItemModel.GetItemCount("prop_zongzi") >= 100 then
		SYSACTBASEManager.on_ui_activity_state_msg({id=19,state=ACTIVITY_HINT_STATUS_ENUM.AT_Get})
	else
		SYSACTBASEManager.on_ui_activity_state_msg({id=19,state=ACTIVITY_HINT_STATUS_ENUM.AT_Nor})
	end  
 end