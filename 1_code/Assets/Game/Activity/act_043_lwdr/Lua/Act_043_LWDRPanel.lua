-- 创建时间:2020-09-28
-- Panel:JjcyXxlbdPanel
--[[ *      ┌─┐       ┌─┐
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]
 local basefunc = require "Game/Common/basefunc"

 Act_043_LWDRPanel = basefunc.class()
 local C = Act_043_LWDRPanel
 C.name = "Act_043_LWDRPanel"
 
 local M = Act_043_LWDRManager

 function C.Create(parent)
	 return C.New(parent)
 end
 
 function C:AddMsgListener()
	 for proto_name, func in pairs(self.lister) do
		 Event.AddListener(proto_name, func)
	 end
 end
 
 function C:MakeLister()
	 self.lister = {}
	 self.lister[M.key.."_rank_base_info_get"] = basefunc.handler(self, self.on_rank_base_info_get)
	 self.lister[M.key.."_rank_info_get"] = basefunc.handler(self, self.on_rank_info_get)
	 self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
 end
 
 function C:RemoveListener()
	 for proto_name, func in pairs(self.lister) do
		 Event.RemoveListener(proto_name, func)
	 end
	 self.lister = {}
 end
 
 function C:MyExit()
	 self:RemoveListener()
	 destroy(self.gameObject)
 end
 
 function C:ctor(parent)
	 ExtPanel.ExtMsg(self)
	 local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	 local obj = newObject(C.name, parent)
	 local tran = obj.transform
	 self.transform = tran
	 self.gameObject = obj
	 LuaHelper.GeneratingVar(self.transform, self)
	 dump(self)
	 self:MakeLister()
	 self:AddMsgListener()
	 self:InitUI()
 end
 
 function C:InitUI()
	 M.GetBaseDataFromNet()
	 M.GetRankDataFromNet()

	 self.rule_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OpenRule()
    end)
 end
 
 function C:MyRefresh()

 end
 
 function C:InitRanklis()
	 local lis = M.GetRankData()
	 self:AddToRankLis(lis)
 end
 
 function C:AddToRankLis(_add_rank_data)
	 for i = 1, #_add_rank_data do
		 local b = GameObject.Instantiate(self.rank_lis_item, self.Content)
		 b.gameObject:SetActive(true)
		 local temp_ui = {}
		 LuaHelper.GeneratingVar(b.transform, temp_ui)
		 if _add_rank_data[i].ranking_num <= 3 then
			 temp_ui.ranking_img.gameObject:SetActive(true)
			 temp_ui.ranking_txt.gameObject:SetActive(false)
			 temp_ui.ranking_img.transform:GetComponent("Image").sprite = GetTexture(M.GetHGList(_add_rank_data[i].ranking_num))
			 temp_ui.rank_gogame_btn.gameObject:SetActive(true)
		 else
			 temp_ui.ranking_img.gameObject:SetActive(false)
			 temp_ui.ranking_txt.gameObject:SetActive(true)
			 temp_ui.ranking_txt.text = _add_rank_data[i].ranking_num
			 temp_ui.rank_gogame_btn.gameObject:SetActive(false)
		 end
		 temp_ui.rank_name_txt.text = _add_rank_data[i].name
		 temp_ui.rank_lis_mybg.gameObject:SetActive(false)
		 
		 if _add_rank_data[i].player_id == MainModel.UserInfo.user_id then
			 temp_ui.rank_lis_mybg.gameObject:SetActive(true)
		 else
			 if i % 2 == 0 then
				 temp_ui.rank_lis_bg.gameObject:SetActive(false)
			 else
				 temp_ui.rank_lis_bg.gameObject:SetActive(true)
			 end
		 end
 
		 temp_ui.rank_num_txt.text = _add_rank_data[i].rank_score
 
		 if _add_rank_data[i].rank_award == nil then
			 temp_ui.rank_award_txt.text = "- -"
		 else
			 temp_ui.rank_award_txt.text = _add_rank_data[i].rank_award
		 end
		 temp_ui.rank_gogame_btn.onClick:RemoveAllListeners()
		 temp_ui.rank_gogame_btn.onClick:AddListener(
		 function()
			 self:GotoGameUI()
		 end)
 
	 end
 end
 
 function C:GotoGameUI()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui="game_FishingHall"})
 end
 
 function C:InitRankUser()
	 local user_dataUI = M.GetUserRankData()
	 if table_is_null(user_dataUI) then return end
	 if user_dataUI.ranking_num <= 3 and user_dataUI.ranking_num ~= -1 then
		 self.user_ranking_img.gameObject:SetActive(true)
		 self.user_rank_num_txt.gameObject:SetActive(false)
		 self.user_ranking_img.transform:GetComponent("Image").sprite = GetTexture(M.GetHGList(user_dataUI.ranking_num))
		 self.user_rank_num_txt.text = ""
	 else
		 self.user_ranking_img.gameObject:SetActive(false)
		 self.user_rank_num_txt.gameObject:SetActive(true)
		 if user_dataUI.ranking_num == -1 then
			 self.user_rank_num_txt.text = "未上榜"
		 else
			 self.user_rank_num_txt.text = user_dataUI.ranking_num
		 end
	 end
	 self.user_name_txt.text = user_dataUI.name
	 self.user_rank_score_txt.text = user_dataUI.rank_score
	 if user_dataUI.rank_award == nil then
		 self.user_rank_award_txt.text = "- -"
	 else
		 self.user_rank_award_txt.text = user_dataUI.rank_award
	 end
	 user_dataUI = {}
 end
 
 function C:on_rank_base_info_get(_, data)
	self:InitRanklis()
 end

 function C:on_rank_info_get(_, data)
	self:InitRankUser()
 end
 
 function C:OnDestroy()
	 self:MyExit()
 end

 function C:OpenRule()
	local str = M.help_info[1]
    for i = 2, #M.help_info do
        str = str .. "\n" .. M.help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
 end