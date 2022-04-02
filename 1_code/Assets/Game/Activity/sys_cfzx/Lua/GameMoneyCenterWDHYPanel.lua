-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterWDHYPanel = basefunc.class()

local C = GameMoneyCenterWDHYPanel

C.name = "GameMoneyCenterWDHYPanel"

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
    self.lister["model_query_my_son_main_info_response"] = basefunc.handler(self, self.RefreshFriend)
    self.lister["AssetChange"] = basefunc.handler(self, self.RefreshMoney)
    self.lister["model_goldpig_profit_cache_change"] = basefunc.handler(self, self.model_goldpig_profit_cache_change)
    self.lister["model_search_son_by_id_response"] = basefunc.handler(self, self.model_search_son_by_id_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:ClearCellList()
	self:MyExit()
end

function C:MyExit()
    GameMoneyCenterModel.ClearSearchSonInfoData()
	self:RemoveListener()
    GameMoneyCenterIncomeSpendingPanel.Close()
    destroy(self.gameObject) 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.HYButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        local share_cfg = basefunc.deepcopy(share_link_config.img_money_center_wdsy)
        share_cfg.isCircleOfFriends = false
        GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = share_cfg})
    end)
    self.PYQButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        local share_cfg = basefunc.deepcopy(share_link_config.img_money_center_wdsy)
        share_cfg.isCircleOfFriends = true
        GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = share_cfg})
    end)
    self.PYQButton_btn.gameObject:SetActive(false)
    self.HYButton_btn.transform.localPosition = Vector3.New(0, -57, 0)

    self.Scroll = self.ScrollView:GetComponent("ScrollRect")
    EventTriggerListener.Get(self.Scroll.gameObject).onEndDrag = basefunc.handler(self, self.ScrollOnEndDrag)
    self.moneyinfo_btn.onClick:AddListener(
		function (  )
			GameMoneyCenterIncomeSpendingPanel.Create()
		end
	)
	self.shareType = "moneycenter"
	self.TX_btn.onClick:AddListener(
        function (  )
            if not GameMoneyCenterModel.CheckIsNewPlayerSys() then
                --检查支付宝
                MainModel.GetBindZFB(function(  )
                    if table_is_null(MainModel.UserInfo.zfbData) or MainModel.UserInfo.zfbData.name == "" then
                        LittleTips.Create("请先绑定支付宝")
                        GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
                    else
                        MainLogic.Withdraw(self:RefreshMoney())
                    end
                end)
                return
            end
			MainLogic.Withdraw(self:RefreshMoney())
		end
    )
    self.bing_zfb_btn.onClick:AddListener(
		function (  )
			GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
		end
    )
    if not GameMoneyCenterModel.CheckIsNewPlayerSys() then
        self.bing_zfb_btn.gameObject:SetActive(true)
    end
    self.goldpig_cache_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnGoldPigCacheClick()
    end)
    self:InitSearchFriend()

    self.page_index = 1
    self.sort_type = 4
    self.isQuery = true
    self.CellList = {}
    self:InitUI()
end

function C:InitUI()
    local num = 0
    if GameMoneyCenterModel.data then
        num = GameMoneyCenterModel.data.my_all_son_count
    end
    self.all_friend_num_txt.text = string.format( "（%s人）", num)
    --3月23日，不显示人数（需求提出：王海涛）
    self.all_friend_num_txt.gameObject:SetActive(false)
	self:RefreshMoney()
    GameMoneyCenterModel.GetSCZDFriend(self.page_index, self.sort_type)
    self:UpdateGoldPigProfitCache()
    self:UpdateSearchFriend()
end

function C:RefreshMoney()
	self.redpacket_txt.text = StringHelper.ToRedNum(MainModel.UserInfo.cash/100)
end

function C:ScrollOnEndDrag()
    print("<color=white>分页请求</color>", self.isQuery,self.page_index)
    local VNP = self.Scroll.verticalNormalizedPosition
    if VNP <= 0 then
		if self.isQuery then
			GameMoneyCenterModel.GetSCZDFriend(self.page_index, self.sort_type)
		end
    end
end

function C:RefreshFriend(data, is_clear_old_data)
	if is_clear_old_data == 1 then
		self:ClearCellList()
        self.page_index = 1
	end
	if data and next(data) then
		self.page_index = self.page_index + 1
		self:UpdateItem(data)
	else
		self.isQuery = false
		if self.page_index == 1 then
			self.friend_nil_rect.gameObject:SetActive(true)
		end
	end
end

function C:UpdateItem(data)
    for k,v in ipairs(data) do
         --3月23日，显示人数最多50个（需求提出：王海涛）
        if #self.CellList + 1 > 50 then 
            return 
        end
		local pre = MoneyCenterWDHYPrefab.Create(self.Content.transform, v)
		self.CellList[#self.CellList + 1] = pre
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:UpdateUI()
    self:ClearCellList()
	self.page_index = 1
    self.sort_type = 4
    self.isQuery = true
    self:InitUI()
    self:UpdateGoldPigProfitCache()
    self:UpdateSearchFriend()
end

function C:MyRefresh()
	self:UpdateUI()
end

function C:WeChatShareImage(isCircleOfFriends)

end

function C:UpdateGoldPigProfitCache()
    if true then return end
    local profit_cache = GameMoneyCenterModel.GetGoldPigCacheData()
	if profit_cache and profit_cache ~= 0 then
		self.goldpig_cache_txt.text = StringHelper.ToRedNum(profit_cache  / 100)
		self.goldpig_cache = profit_cache
		self.goldpig_cache_btn.gameObject:SetActive(true)
	else
		self.goldpig_cache_btn.gameObject:SetActive(false)
		self.goldpig_cache_txt.text = 0
		self.goldpig_cache = 0
	end
end

function C:OnGoldPigCacheClick()
	local goldpig_cache = self.goldpig_cache and self.goldpig_cache or 0
	local str = string.format( "购买金猪礼包后可领取%s元奖金，是否立刻前往购买",StringHelper.ToRedNum(goldpig_cache / 100))
	HintPanel.Create(2,str,function(  )
		Event.Brocast("open_golden_pig")
	end)
end

function C:model_goldpig_profit_cache_change()
	self:UpdateGoldPigProfitCache()
end

function C:model_search_son_by_id_response()
    local search_son_info = GameMoneyCenterModel.GetSearchSonInfoData()
    dump(search_son_info,"<color=red>子信息------------</color>")
    if not search_son_info or not next(search_son_info) then
        local input_str = self.input_id_txt.text
        if not input_str or input_str == "" then
            LittleTips.Create("请输入好友ID")
        else
            LittleTips.Create(string.format( "没有找到玩家：%s",input_str))
            self.search_friend_ipf.text = ""
        end
    end
    self:UpdateSearchFriend()
end

function C:UpdateSearchFriend()
    local search_son_info = GameMoneyCenterModel.GetSearchSonInfoData()
    if search_son_info and next(search_son_info) then
        destroyChildren(self.SearchFriendContent)
        self.Scroll.gameObject:SetActive(false)
        for i= 1, #search_son_info do 
            MoneyCenterWDHYPrefab.Create(self.SearchFriendContent.transform, search_son_info[i])
        end 
        self.SearchFrieadView.gameObject:SetActive(true)
        self.search_friend_ipf.text = ""
    else
        self.Scroll.gameObject:SetActive(true)
        self.SearchFrieadView.gameObject:SetActive(false)
        self.search_friend_ipf.text = ""
    end
end

function C:InitSearchFriend()
    self.SearchFrieadView.gameObject:SetActive(false)
    self.search_friend_btn.onClick:AddListener(
		function ()
			self:OnClickSearchFriendBtn()
		end
    )
    self.reset_search_friend_btn.onClick:AddListener(
		function ()
			self.SearchFrieadView.gameObject:SetActive(false)
            self.search_friend_ipf.text = ""
            -- LittleTips.Create("好友列表已刷新")
		end
    )
    self.search_friend_ipf.onValidateInput = function (text, charIndex, addedChar)
        local str = text
        -- if utf8.len(str) == 11 then
        --     LittleTips.Create("输入的ID不可超过11位数")
        -- end
        return addedChar
    end
end

function C:OnClickSearchFriendBtn()
    local input_str = self.input_id_txt.text
    local num = tonumber(input_str)
    -- if not num and input_str ~= "" then
    --     self.search_friend_ipf.text = ""
    --     LittleTips.Create("只能输入数字")
    --     return
    -- end
    Network.SendRequest("search_son_by_id", {id = tostring(input_str)}, "请求数据")
end