-- 创建时间:2020-3-30
local basefunc = require "Game.Common.basefunc"

ZPGGamePanel = basefunc.class()
local C = ZPGGamePanel
C.name = "ZPGGamePanel"
local M = ZPGModel
local listerRegisterName = "ZPGFreeGameListerRegister"

local countdown = 0
local countdownTimer

local pointerDownTimer
local checkPointerDown = false
local PointerDown = false


local function CloseTimer()
    if countdownTimer then
        countdownTimer:Stop()
        countdownTimer = nil
    end
end

local function StartCountDown(timeout,targetTxt,callback,HighLightObj)
    countdown = timeout
    if countdownTimer then
        CloseTimer()
    end

    targetTxt.text = countdown .. ""
    targetTxt.gameObject:SetActive(true)
    HighLightObj.gameObject:SetActive(false)
    if countdown <= 5 then
        targetTxt.gameObject:SetActive(false)
        HighLightObj.gameObject:SetActive(true)
        HighLightObj.gameObject:GetComponent("Animator"):Play("game_count_daojishi",-1,5 - countdown)
    end
    countdownTimer = Timer.New(function()
        if countdown <= 0 then
            countdown = -1
            CloseTimer()
            targetTxt.gameObject:SetActive(false)
            HighLightObj.gameObject:SetActive(false)
            if callback then callback() end
            return
        end
        countdown = countdown - 1
        if countdown <= 5 then
            ExtendSoundManager.PlaySound(audio_config.pgdz.bgm_pgdz_daojishi.audio_name)
            targetTxt.gameObject:SetActive(false)
            HighLightObj.gameObject:SetActive(true)
        else
            targetTxt.text = countdown .. ""
            targetTxt.gameObject:SetActive(true)
            HighLightObj.gameObject:SetActive(false)
        end
    end,1,-1,true)
    countdownTimer:Start()
end


local function CaculateItemIndexByTotal(total)
    local config = ZPGModel.UIConfig.bet_config

    local ret = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0
    }
    if total == 0 then return ret end
    --只添加一个水滴
    if total < config[1] and total > 0 then
        ret[1] = 1 
        return ret
    end
    for i = 5,1,-1 do
        local item_cost = config[i]
        if total > item_cost then 
            ret[i] = math.floor(total / item_cost)
            total = total - (item_cost * ret[i])
        end
    end
    if total > 0 then ret[1] = ret[1] + 1 end
    return ret
end

local function CaculateItemIndexForShow(total)
    --线性减少显示的数量
    local ret = CaculateItemIndexByTotal(total)
    local limit = ZPGModel.UIConfig.bet_item_limit
    for i = 5,1,-1 do
        if ret[i] > limit[i] then
            if i == 1 then
                ret[1] = limit[1]
                return ret
            end
            local reduce = ret[i] - limit[i]
            ret[i] = limit[i]
            ret[i - 1] = ret[i - 1] + math.floor(ZPGModel.UIConfig.bet_config[i]/ZPGModel.UIConfig.bet_config[i - 1]) * reduce
        end
    end
    return ret
end

local function CalculateAppleShowByCount(count)
    count = count or 0
    return  ZPGModel.UIConfig.apple_config[count]
end

function C.Create(parm)
	return C.New(parm)
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)
    self.dot_del_obj = true

	self.parm = parm
    local parent = GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject(C.name,parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform,self)
    self.AreaObject = {[1] = {},[2] = {},[3] = {}}
    for i = 1,3 do
        local BetArea = self["BetArea"..i]
        self.AreaObject[i].BetArea = self["BetArea"..i]
        self.AreaObject[i].PointerNode = self["PointerNode_" .. i]
        self.AreaObject[i].AppleNode = BetArea.transform:Find("tree/shu/AppleNode")
        self.AreaObject[i].Anim = BetArea.transform:GetComponent("Animator")
        self.AreaObject[i].AppleList = {}
        if i == 1 or i ==3 then
            for j = 1,9 do
                self.AreaObject[i].AppleList[j] = self.AreaObject[i].AppleNode.transform:Find("Apple" .. j)
            end
        elseif i == 2 then 
            self.AreaObject[i].AppleList[1] = self.AreaObject[i].AppleNode.transform:Find("Apple1")
        end
        self.AreaObject[i].TotalText = BetArea.transform:Find("TotalText"):GetComponent("Text")
        self.AreaObject[i].MyBet = BetArea.transform:Find("MyBet")
        self.AreaObject[i].MyBetTxt = BetArea.transform:Find("MyBet/my_bet_txt"):GetComponent("Text")
        self.AreaObject[i].BetItemRect = BetArea.transform:Find("BetItemRect")
        self:AddAreaButtonClick(self["BetArea" .. i]:GetComponent(typeof(PolygonClick)),i)
    end
    for i =1,5 do
        local BetButton = self["item_"..i.."_btn"]
        self:AddItemButtonOnClick(BetButton,i)
    end
    self.set_btn.onClick:AddListener(function()
        local callback = function(  )
            Network.SendRequest("guess_apple_quit_room",nil,"请求退出",function()
                ZPGLogic.change_panel(ZPGLogic.panelNameMap.hall)
            end)
        end
    
        local a,b = GameButtonManager.RunFun({gotoui="cpl_ljyjcfk",callback = callback}, "CheckMiniGame")
        if a and b then
            return
        end
    
        callback()
    end)

    self.help_btn.onClick:AddListener(function()
        ZPGHelpPanel.Create()
    end)

    self.add_money_btn.onClick:AddListener(function()
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end)

    self.BetItemMap = {}

    self.layer2 = GameObject.Find("Canvas/LayerLv2").transform
    SpineManager.RemoveAllDDZPlayerSpine()
    SpineManager.AddDDZPlayerSpine(self.zpg_spine_dz_nan.transform:GetComponent("SkeletonAnimation"),1)
    SpineManager.AddDDZPlayerSpine(self.zpg_spine_nm_nan.transform:GetComponent("SkeletonAnimation"),3)

    
    self:MakeLister()
    ZPGLogic.setViewMsgRegister(self.lister, listerRegisterName)
	ExtendSoundManager.PlaySceneBGM(audio_config.pgdz.bgm_pgdz_beijing.audio_name)

    self.undo_btn.onClick:AddListener(function()
        if ZPGModel.data.game_status == "bet" then
            Network.SendRequest("guess_apple_cancel_bet",nil,"取消下注")
        end
    end)
    self:InitUI()
    ZPGModel.data.current_bet_index = CheckNormalIndexByMoneyAndVip(self.player_gold)
    self:RefreshButtons()

    local bg = self.transform:Find("bg")
    MainModel.SetGameBGScale(bg)
    self:OnAssetChange()
    local btn_map = {}
	btn_map["left_top"] = {self.btnnode}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "zpg_game")
end

function CheckNormalIndexByMoneyAndVip(gold)
    local index
    local limit,desc = ZPGModel.CheckLimitByPermission()
    local vipTotal = limit.limit_total
    local vipRecomment = math.floor(vipTotal/25)
    local goldRecomment = math.floor(gold/25)
    local recomment = math.min(vipRecomment,goldRecomment)    
    for i = 1,4 do 
        if recomment <= ZPGModel.UIConfig.bet_config[i] then
            index = i - 1
            if index == 0 then index = 1 end
            break
        end
    end
    index = index or 5
    return index
end

function C:AddAreaButtonClick(polygonClick,index)
    --押注区按钮逻辑
    polygonClick.PointerDown:AddListener(basefunc.handler(self,function()
        --押注时间间隔一秒
        if ZPGModel.data.limitDealMsg then return end
        if ZPGModel.data.game_status ~= "bet" then return end
        if countdown < 0 then return end
        if not PointerDown then
            PointerDown = true
            if self:OnAreaButtonClick(index) then
                if (countdown > 1 or ZPGLogic.is_test) then
                    --开始计时三秒后开始
                    checkPointerDown = false
                    pointerDownTimer = Timer.New(function()
                        checkPointerDown = true
                        if pointerDownTimer then
                            pointerDownTimer:Stop()
                            pointerDownTimer = nil
                        end
                        self:CreatePointerPrefab(index)
                    end,1,1,true)
                    pointerDownTimer:Start()
                end
            end
        end
    end))

    polygonClick.PointerUp:AddListener(basefunc.handler(self,function()
        PointerDown = false
        if checkPointerDown then 
            self:ClosePointerPrefab(index)
        else 
            if pointerDownTimer then
                pointerDownTimer:Stop()
                pointerDownTimer = nil
            end
            return
        end
    end))
end

function C:AddItemButtonOnClick(button,index)
    button.onClick:AddListener(function()
        self:ChangeCurBetIndex(index)
        self:RefreshButtons()
    end)
end

function C:RefreshButtons()
    local index = ZPGModel.data.current_bet_index
    for i = 1,5 do
        local BetButton = self["item_"..i.."_btn"]
        local normal = BetButton.gameObject.transform:Find("normal")
        local selected = BetButton.gameObject.transform:Find("selected")
        if index == i then
            normal.gameObject:SetActive(false)
            selected.gameObject:SetActive(true)
        else 
            normal.gameObject:SetActive(true)
            selected.gameObject:SetActive(false)
        end
    end
end

function C:CreatePointerPrefab(index)
    if self.pointerPrefab then self.pointerPrefab:MyExit() end
    self.pointerPrefab = ZPGPointerPrefab.Create(self.AreaObject[index].PointerNode.transform)
end

function C:ClosePointerPrefab(pos)
    local check = false
    if self.pointerPrefab then 
        check = self.pointerPrefab:MyExit()
        self.pointerPrefab = nil
    end
    if check then
        self:SendJinZhunShiFei(pos)
    end
end
-- # 精准限制
-- guess_apple_accurate_bet @ {
--   request {
--     bet_pos $ : integer    # 精准培育的位置 1,3 左右两边
--   }
--   response {
--     result $ : integer                # 0 成功
--   }
-- }
function C:CreateJinZhunShiFei(pos)
    local parent = self.AreaObject[pos].PointerNode.transform
    if self.jinzhun_prefab then
        self.jinzhun_prefab:MyExit()
    end
    self.jinzhun_prefab = ZPGJinZhunTipsPrefab.Create(parent)

end
function C:SendJinZhunShiFei(pos)
    if pos == 2 then 
        self:CreateJinZhunShiFei(pos) 
        return
    end
    Network.SendRequest("guess_apple_accurate_bet",{bet_pos = pos},"请求精准施肥",function(data)
        if data.result == 0 then
            self:CreateJinZhunShiFei(pos)
        else
            return
        end
    end)
end

function C:InitUI()
    self.player_gold = MainModel.UserInfo.jing_bi
    self:RefreshPlayerMoney()
    self.player_name_txt.text = MainModel.UserInfo.name
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.head_img)
    VIPManager.set_vip_text(self.vip_txt)
    for i = 1,5 do
        local text = self["item_" .. i .. "_btn"].gameObject.transform:Find("Text"):GetComponent("Text")
        text.text = StringHelper.ToCash(ZPGModel.UIConfig.bet_config[i])
    end
    for i = 1,3 do
        if i == 2 then
            self.AreaObject[i].Anim:Play("@BetArea2_shu",-1,0)
        else 
            self.AreaObject[i].Anim:Play("@BetArea3_shu",-1,0)
        end
        self.AreaObject[i].Anim.speed = 0
    end
    self:RefreshButtons()
    self:RefreshBetData()
    self:RefreshApple()
    self:RefreshBetItem()
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_fg_all_info"] = basefunc.handler(self, self.on_model_fg_all_info)
    self.lister["model_guess_apple_status_data"] = basefunc.handler(self,self.on_model_guess_apple_status_data)
    self.lister["model_guess_apple_bet_data"] = basefunc.handler(self,self.on_model_apple_bet_data)
    self.lister["model_guess_apple_game_data"] = basefunc.handler(self,self.on_model_guess_apple_game_data)
    self.lister["model_guess_apple_settle_data"] = basefunc.handler(self,self.on_model_guess_apple_settle_data)
    self.lister["model_guess_apple_bet_response"] = basefunc.handler(self,self.on_model_guess_apple_bet_response)
    self.lister["model_guess_apple_add_kaijiang_log"] = basefunc.handler(self,self.on_model_guess_apple_add_kaijiang_log)
    self.lister["model_player_money_change"] = basefunc.handler(self,self.on_model_player_money_change)
    self.lister["model_guess_apple_cancel_bet_response"] = basefunc.handler(self,self.on_model_guess_apple_cancel_bet_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:on_model_fg_all_info()
    ZPGAnimManager.EndAreaGlow()
    self:MyRefresh()
end

function C:on_model_guess_apple_status_data()
    self:RefreshNowPlayerCount()
    if ZPGModel.data.game_status == "bet" then
        --动画1
        --种植开始
        ZPGAnimManager.PlayPlantStart(self.layer2)
        StartCountDown(ZPGModel.data.time_out,self.time_count_txt,nil,self.game_count_daojishi)
        SpineManager.DaiJi(1)
        SpineManager.DaiJi(3)
        --清空所有的苹果等数据
        self:InitUI()
    elseif ZPGModel.data.game_status == "game" then
        --动画2
        --种植结束
        if self.pointerPrefab then
            self.pointerPrefab:MyExit()
            self.pointerPrefab = nil
        end
        ZPGAnimManager.PlayPlantEnd(self.layer2,function()
            ZPGAnimManager.PlayAppleAnim(self.AreaObject,self.layer2,function() 
                ZPGAnimManager.PlayAreaGlow(self)
                if ZPGModel and ZPGModel.data and ZPGModel.data.winner then
                    local winner = ZPGModel.data.winner
                    for i = 1,3,2 do
                        if winner == 2 then
                            SpineManager.Lose(1)
                            SpineManager.Lose(3)
                            break
                        end

                        if winner == i then
                            SpineManager.Win(i)
                        else
                            SpineManager.Lose(i)
                        end
                    end
                end
            end)
        end)
    elseif ZPGModel.data.game_status == "settle" then
        -- ZPGAnimManager.EndAreaGlow()
    end
end

function C:on_model_apple_bet_data()
    --播放苹果动画
    local total =  basefunc.deepcopy(ZPGModel.data.add_bet_value)
    local total_time = 2.5
    if countdown <= 0.5 then
        total_time = 0.5
    end
    local prefab_pos = self.nowplayer_icon.transform.position
    local total_index_list = {}
    for i = 1,3 do
        total_index_list[i] = CaculateItemIndexForShow(total[i])
    end
    local AddBet = function (bet_list)
        self:AddBetValue(bet_list)
        for pos = 1,3 do
            -- local index_list = CaculateItemIndexByTotal(bet_list[pos])
            -- for index,v in pairs(index_list)do
            --     if v > 0 then
            --         for j = 1, v do
            --             self:PlayBetItemToArea(index,pos,prefab_pos)
            --         end
            --     end
            -- end
            if bet_list[pos] > 0 then
                local index_total_count = 0
                for i = 1,5 do
                    index_total_count = total_index_list[pos][i] + index_total_count
                end
                local randomPos
                -- if pos == 2 then
                --     randomPos = math.random(1,index_total_count)
                -- else
                --     randomPos = math.random(1,index_total_count * 3)
                -- end
                randomPos = math.random(1,index_total_count)
                local index
                for i = 1,5 do
                    if randomPos > total_index_list[pos][i] then 
                        randomPos = randomPos - total_index_list[pos][i]
                    else
                        index = i
                        total_index_list[pos][i] = total_index_list[pos][i] - 1
                        break
                    end
                end
                if index then
                    self:PlayBetItemToArea(index,pos,prefab_pos)
                    local sound_rdn = math.random()
                    local weight = 0.25
                    if sound_rdn < weight then
                        ExtendSoundManager.PlaySound(audio_config.pgdz.bgm_pgdz_zhongzhi.audio_name)
                    end
                    -- local rdn = math.random()
                    -- local weight = 0.1
                    -- if rdn < weight then
                    --     self:CreateJinZhunShiFei(pos)
                    -- end
                end
            end
        end
    end

    local split_list = {}
    --将本次增加分为连续不断的一个表

    while true do
        if total[1] <= 0 and total[2] <= 0 and total[3] <= 0 then
            break
        end
        local randomPos
        local pos_total_count = (total[1] > 0 and 1 or 0) + (total[2] > 0 and 1 or 0) + (total[3] > 0 and 1 or 0)
        if pos_total_count == 3 then
            randomPos = math.random(1,3)
        elseif pos_total_count == 2 then
            if total[1] <= 0 then
                randomPos = math.random(2,3)
            elseif total[2] <= 0 then
                randomPos = math.floor(math.random(1,2) * 1.5)
            elseif total[3] <= 0 then
                randomPos = math.random(1,2)
            end
        elseif pos_total_count == 1 then
            for i=1,3 do
                if total[i] > 0 then randomPos = i end
            end
        end
        if total[randomPos] > ZPGModel.UIConfig.bet_config[5] then
            local rdnIndex = math.random(1,5)
            total[randomPos] = total[randomPos] - ZPGModel.UIConfig.bet_config[rdnIndex]
            split_list[#split_list+1] = {pos = randomPos,value = ZPGModel.UIConfig.bet_config[rdnIndex]}
        else
            local remain_list = CaculateItemIndexByTotal(total[randomPos])
            for k,v in pairs (remain_list) do
                for count = 1,v do
                    local rdnInsert = math.random(1,#split_list)
                    table.insert(split_list,rdnInsert, {pos = randomPos,value = ZPGModel.UIConfig.bet_config[k]})
                end
            end
            total[randomPos] = 0
        end
    end

    local seq = DoTweenSequence.Create()
    local length = #split_list
    for i = 1,#split_list do
        seq:AppendInterval(total_time/#split_list)
        seq:AppendCallback(function()
            local list = {}
            local split_obj = split_list[i]
            for j = 1, 3 do
                if split_obj.pos == j then
                    list[j] = split_obj.value
                else
                    list[j] = 0
                end
            end
            AddBet(list)
        end)
    end
end

function C:AddBetValue(bet_list)
    for i = 1,3 do
        self.AreaObject[i].TotalText.text = tonumber(self.AreaObject[i].TotalText.text) + bet_list[i]
        self.AreaObject[i].TotalText.gameObject:SetActive(true)
    end
end

function C:on_model_guess_apple_game_data()
    local left_count = ZPGModel.data.apple_data.left_apple
    local right_count = ZPGModel.data.apple_data.right_apple
    local is_gold_coin = ZPGModel.data.apple_data.is_gold_coin
    self:RefreshApple(left_count,right_count,is_gold_coin)
    if ZPGModel.data.my_bet_list then
        self:RefreshBetData()
    end
end

function C:RefreshApple(left_count,right_count,is_gold_coin)
    local left_list = CalculateAppleShowByCount(left_count)
    local right_list = CalculateAppleShowByCount(right_count)
    local winner = ZPGModel.data.winner
    local is_gold = is_gold_coin == 1
    local gold_icon = "zpg_icon_jyb"
    local apple_icon = "zpg_icon_hpg"
    for k,v in pairs (left_list) do
        local Apple = self.AreaObject[1].AppleList[k]
        Apple.gameObject:SetActive(v == 1)
        if is_gold and winner == 1 then
            Apple:GetComponent("Image").sprite = GetTexture(gold_icon)
        else
            Apple:GetComponent("Image").sprite = GetTexture(apple_icon)
        end
    end
    for k,v in pairs (right_list)do
        local Apple = self.AreaObject[3].AppleList[k]
        Apple.gameObject:SetActive(v == 1)
        if is_gold and winner == 3 then
            Apple:GetComponent("Image").sprite = GetTexture(gold_icon)
        else
            Apple:GetComponent("Image").sprite = GetTexture(apple_icon)
        end
    end

    if winner == 2 and left_count and right_count then
        local Apple = self.AreaObject[2].AppleList[1]
        Apple.gameObject:SetActive(true)
    else
        local Apple = self.AreaObject[2].AppleList[1]
        Apple.gameObject:SetActive(false)
    end
end

function C:on_model_guess_apple_settle_data()
    --播放奖励
    --从押注中挑选一部分给玩家

    --先生成属于玩家的奖励
    local award_index_list = CaculateItemIndexByTotal(ZPGModel.data.award_value)

    --生成一大堆肥料
    -- for i = 1,50 do
    --     self:PlayBetItemSetArea(5,ZPGModel.data.winner)
    -- end

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.5)
    seq:AppendCallback(function()
        for index,v in pairs(award_index_list) do
            if(v > 0) then
                for j = 1,v do
                    --直接生成自己的奖励到rect里
                    self:PlayBetItemSetArea(index,ZPGModel.data.winner)
                end
            end
        end
        self:PlayBetItemBackToPlayer(ZPGModel.data.winner,award_index_list)
    end)
        seq:AppendInterval(0.3)
        seq:AppendCallback(function()
            if ZPGModel.data.award_value > 0 then
                self.player_gold = self.player_gold + ZPGModel.data.award_value
                self:RefreshPlayerMoney()
                self:PlayPlayerGoldAdd(ZPGModel.data.award_value)
                ExtendSoundManager.PlaySound(audio_config.pgdz.bgm_pgdz_shouhuo.audio_name)
            end
        end)
        seq:AppendInterval(0.5)
        seq:OnKill(function()
            local total_award = ZPGModel.data.total_bet_list[ZPGModel.data.winner]
            if ZPGModel.data.winner == 2 then
                total_award = total_award * 8
            else total_award = total_award * 2 end
            if ZPGModel.data.apple_data.is_gold_coin == 1 then
                total_award = total_award * 2
            end
            self:PlayPlayerGoldAddOther(total_award)
        end)
end

function C:PlayBetItemBackToPlayer(bet_pos,my_award_list)
    if self.BetItemMap[bet_pos] and next(self.BetItemMap[bet_pos]) then
        local my_pos = self.head_img.gameObject.transform.position
        local players_pos = self.nowplayer_icon.transform.position
        for k,v in pairs (self.BetItemMap[bet_pos]) do
            if my_award_list and my_award_list[v.index] > 0 then
                v:PlayFlyToPlayer(my_pos)
                my_award_list[v.index] = my_award_list[v.index] - 1
            else
                v:PlayFlyToPlayer(players_pos)
            end
        end
        self.BetItemMap[bet_pos] = {}
    end
end

function C:PlayPlayerGoldAdd(value)
    local tran = self.add_money_node.gameObject.transform
    local start_pos = tran.localPosition
    self.add_money_txt.text = "+" .. StringHelper.ToCash(value)
    local seq = DoTweenSequence.Create()
    tran.gameObject:SetActive(true)
    seq:Append(tran:DOLocalMoveY(100,1))
    seq:OnForceKill(function()
        tran.gameObject:SetActive(false)
        tran.localPosition = start_pos
    end)
end

function C:PlayPlayerGoldAddOther(value)
    local tran = self.add_money_other_txt.gameObject.transform
    local start_pos = tran.localPosition
    self.add_money_other_txt.text = "+" .. StringHelper.ToCash(value)
    local seq = DoTweenSequence.Create()
    tran.gameObject:SetActive(true)
    seq:Append(tran:DOLocalMoveY(50,1))
    seq:OnForceKill(function()
        tran.gameObject:SetActive(false)
        tran.localPosition = start_pos
    end)
end

function C:on_model_guess_apple_bet_response(data)
    --添加我的押注数据
    --服务器是两秒发一次 前端稍微分割一下让押注的人数平缓一点
    self:RefreshBetData(true)
    if data then
        local prefab_pos = self.head_img.gameObject.transform.position
        self:PlayBetItemToArea(data.index,data.pos,prefab_pos)
    end
end

function C:PlayBetItemToArea(index,bet_pos,prefab_pos)
    local item_prefab = ZPGBetItemPrefab.Create(index,prefab_pos,self.AreaObject[bet_pos].BetItemRect)
    self.BetItemReconnect = self.BetItemReconnect or {}
    self.BetItemReconnect[index] = self.BetItemReconnect[index] or {}
    self.BetItemReconnect[index][bet_pos] = self.BetItemReconnect[index][bet_pos] or 0
    
    local bet_item_limit_pos
    if bet_pos == 2 then
        bet_item_limit_pos = math.floor(ZPGModel.UIConfig.bet_item_limit_reconnect[index] * (1/7))
    else
        bet_item_limit_pos = math.floor(ZPGModel.UIConfig.bet_item_limit_reconnect[index] * (3/7))
    end
    if self.BetItemReconnect[index][bet_pos] < bet_item_limit_pos then
        self.BetItemReconnect[index][bet_pos] = self.BetItemReconnect[index][bet_pos] + 1
        self.BetItemMap[bet_pos] = self.BetItemMap[bet_pos] or {}
        self.BetItemMap[bet_pos][#self.BetItemMap[bet_pos]+1] = item_prefab
        item_prefab:PlayFlyToRect()
    else
        item_prefab:PlayFlyToRect(true)
    end
--[[
    GetTexture("zpg_icon_jyb")
    GetTexture("zpg_icon_hpg")
    GetTexture("zpg_icon_ping")
    GetTexture("zpg_icon_di")
    GetTexture("zpg_icon_nong")
]]--
end

function C:PlayBetItemSetArea(index,bet_pos)
    self.BetItemReconnect = self.BetItemReconnect or {}
    self.BetItemReconnect[index] = self.BetItemReconnect[index] or {}
    self.BetItemReconnect[index][bet_pos] = self.BetItemReconnect[index][bet_pos] or 0
    local bet_item_limit_pos
    if bet_pos == 2 then
        bet_item_limit_pos = math.floor(ZPGModel.UIConfig.bet_item_limit_reconnect[index] * (1/7))
    else
        bet_item_limit_pos = math.floor(ZPGModel.UIConfig.bet_item_limit_reconnect[index] * (3/7))
    end
    if self.BetItemReconnect[index][bet_pos] < bet_item_limit_pos then
        local item_prefab = ZPGBetItemPrefab.Create(index,nil,self.AreaObject[bet_pos].BetItemRect)
        self.BetItemMap[bet_pos] = self.BetItemMap[bet_pos] or {}
        self.BetItemMap[bet_pos][#self.BetItemMap[bet_pos]+1] = item_prefab
        self.BetItemReconnect[index][bet_pos] = self.BetItemReconnect[index][bet_pos] + 1
        item_prefab:SetPosToRect()
    end
end

function C:on_model_guess_apple_add_kaijiang_log(history_data)
    self:AddHistoryDataByAnim(history_data)
    self:CheckLianShen(history_data)
end

function C:CheckLianShen(winner)
    winner = winner or ZPGModel.data.history_data[#ZPGModel.data.history_data]
    local ls_count = ZPGModel.data.liansheng_number
    self.ls_1_txt.gameObject:SetActive(false)
    self.ls_3_txt.gameObject:SetActive(false)
    if winner ~= 1 and winner ~= 3 then return end
    if ls_count >= 1 then
        local ls_txt = self["ls_" .. winner .. "_txt"]
        ls_txt.text = ls_count .. "连胜"
        ls_txt.gameObject:SetActive(true)
    end
end

function C:on_model_player_money_change()
    self.player_gold = MainModel.UserInfo.jing_bi
    self:RefreshPlayerMoney()
end

function C:on_model_guess_apple_cancel_bet_response()
    self.player_gold = MainModel.UserInfo.jing_bi
    self:RefreshPlayerMoney()
    self:RefreshBetData(true)
end

function C:AddHistoryData(history)
    local icon_map = {
        [1] = "zpg_icon_di",
        [2] = "zpg_icon_ping",
        [3] = "zpg_icon_nong"
    }

    self.history_list = self.history_list or {}
    local history_obj = GameObject.Instantiate(self.history_image,self.history_node)
    history_obj:GetComponent("Image").sprite = GetTexture(icon_map[history])
    history_obj.gameObject:SetActive(true)
    if #self.history_list >= 50 then
        Destroy(table.remove(self.history_list,#self.history_list).gameObject)
    end
    self.history_list[#self.history_list+1] = history_obj
end

function C:AddHistoryDataByAnim(history)
    local icon_map = {
        [1] = "zpg_icon_di",
        [2] = "zpg_icon_ping",
        [3] = "zpg_icon_nong"
    }

    self.history_list = self.history_list or {}
    if self.history_list[1] then 
        self.history_list[1].transform:Find("zpg_bg_xin").gameObject:SetActive(false)
    end
    local history_obj = GameObject.Instantiate(self.history_image,self.history_node)
    history_obj:GetComponent("Image").sprite = GetTexture(icon_map[history])
    history_obj.gameObject:SetActive(true)
    history_obj.transform:Find("zpg_bg_xin").gameObject:SetActive(true)
    if #self.history_list >= 50 then
        Destroy(table.remove(self.history_list,#self.history_list).gameObject)
    end
    self.ScrollView.transform:GetComponent("ScrollRect").enabled = false
    table.insert(self.history_list,1,ZPGAnimManager.PlayHistroyItem(self.history_node,history_obj,function()
        self.ScrollView.transform:GetComponent("ScrollRect").enabled = true
    end))
end

function C:RefreshHistoryItem()
    if self.history_list and next(self.history_list)then
        for k,v in pairs(self.history_list)do
            Destroy(v.gameObject)
        end
    end
    self.history_list = {}
    for i = #ZPGModel.data.history_data,1,-1 do
        --反着添加
        local v = ZPGModel.data.history_data[i]
        self:AddHistoryData(v)
    end
    if self.history_list[1] then
        self.history_list[1].transform:Find("zpg_bg_xin").gameObject:SetActive(true)
    end
end

function C:RefreshBetData(is_my)
    for i = 1,3 do
        if ZPGModel.data.my_bet_list[i] and ZPGModel.data.my_bet_list[i] > 0 then
            self.AreaObject[i].MyBet.gameObject:SetActive(true)
            self.AreaObject[i].MyBetTxt.text = ZPGModel.data.my_bet_list[i]
        else
            self.AreaObject[i].MyBetTxt.text = 0
            self.AreaObject[i].MyBet.gameObject:SetActive(false)
        end

        if not is_my then
            if ZPGModel.data.total_bet_list[i] and ZPGModel.data.total_bet_list[i] > 0 then
                self.AreaObject[i].TotalText.gameObject:SetActive(true)
                self.AreaObject[i].TotalText.text = ZPGModel.data.total_bet_list[i]
            else
                self.AreaObject[i].TotalText.text = 0
                self.AreaObject[i].TotalText.gameObject:SetActive(false)
            end
        end
    end
end

function C:RefreshBetItem()

    self.BetItemReconnect = {}

    for i = 1,3 do
        if self.BetItemMap and self.BetItemMap[i] and next(self.BetItemMap[i]) then
            for k,v in pairs(self.BetItemMap[i]) do
                v:MyExit()
            end
            self.BetItemMap[i] = {}
        end

        if ZPGModel.data.total_bet_list and ZPGModel.data.total_bet_list[i] and ZPGModel.data.total_bet_list[i] > 0 then
            local index_list = CaculateItemIndexForShow(ZPGModel.data.total_bet_list[i])
            local totalLimit = 0
            for j = 1,5 do
                totalLimit = totalLimit + ZPGModel.UIConfig.bet_item_limit[j] * ZPGModel.UIConfig.bet_config[j]
            end
            local count = math.floor(ZPGModel.data.total_bet_list[i]/totalLimit)
            if count <= 0 then count = 1 end
            for k = 1,count do
                for index,v in pairs (index_list) do
                    if v > 0 then
                        for j = 1,v do
                            self:PlayBetItemSetArea(index,i)
                        end
                    end
                end
            end
        end
    end
end

function C:RefreshPlayerMoney()
    self.gold_txt.text = StringHelper.ToCash(self.player_gold)
end

function C:RefreshNowPlayerCount()
    self.nowplayer_count_txt.text = ZPGModel.data.player_num
end

function C:MyRefresh()
    self:RefreshHistoryItem()
    self:RefreshNowPlayerCount()
    self:RefreshBetItem()
    self:RefreshBetData()
    self:CheckLianShen()
    if ZPGModel.data.game_status == "bet" then
        if ZPGModel.data.time_out and not ZPGLogic.is_test then
            StartCountDown(ZPGModel.data.time_out,self.time_count_txt,nil,self.game_count_daojishi)
        end
    else
        self.time_count_txt.gameObject:SetActive(false)
        --把苹果露出来
        if ZPGModel.data.apple_data then
            self:RefreshApple(ZPGModel.data.apple_data.left_apple,ZPGModel.data.apple_data.right_apple,ZPGModel.data.apple_data.is_gold_coin)
            ZPGAnimManager.ShowApple(self.AreaObject,ZPGModel.data.winner)
        end
        if ZPGModel.data.game_status == "game" then
            ZPGAnimManager.PlayAreaGlow(self,2.7)
        elseif ZPGModel.data.game_status == "settle" then
            ZPGAnimManager.PlayAreaGlow(self,0.9)
        end
    end
end

function C:OnAreaButtonClick(index)
    if ZPGModel.data.game_status == ZPGModel.Status.bet then
        self:ChangeCurBetPos(index)
        if not self:CheckCanBetByMoney() then
            return
        end
        if ZPGModel.SendBet() then
            dump(MainModel.UserInfo["prop_guess_apple_bet_" .. ZPGModel.data.current_bet_index],"<color=red>个人数据</color>")
            if MainModel.UserInfo["prop_guess_apple_bet_" .. ZPGModel.data.current_bet_index] and MainModel.UserInfo["prop_guess_apple_bet_" .. ZPGModel.data.current_bet_index] > 0 then

            else
                self.player_gold = self.player_gold - ZPGModel.UIConfig.bet_config[ZPGModel.data.current_bet_index]
                self:RefreshPlayerMoney()
            end
            ExtendSoundManager.PlaySound(audio_config.pgdz.bgm_pgdz_zhongzhi.audio_name)
            return true
        end
        --播放地区改变动画
    else 
        return false
    end
end

function C:CheckCanBetByMoney()
    local bet_money = ZPGModel.UIConfig.bet_config[ZPGModel.data.current_bet_index]
    local bet_item_count = GameItemModel.GetItemCount("prop_guess_apple_bet_" .. ZPGModel.data.current_bet_index)
    dump(bet_item_count,"????????????????")
    if bet_money > self.player_gold and bet_item_count == 0 then
        Event.Brocast("show_gift_panel")
        return false
    end
    local total_bet_money = bet_money
    for k,v in pairs(ZPGModel.data.my_bet_list) do
        total_bet_money = total_bet_money + v
    end
    local limit,desc = ZPGModel.CheckLimitByPermission()
    if limit then
        if limit.limit_total < total_bet_money then
            GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc=desc}})
            return false
        end
        local current_bet_pos = ZPGModel.data.current_bet_pos
        local pos_bet_limit = limit["limit_" .. current_bet_pos]
        local current_bet = ZPGModel.data.my_bet_list[current_bet_pos] + bet_money
        if current_bet > pos_bet_limit then
            GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc=desc}})
            return false
        end
    end
    return true
end

function C:ChangeCurBetPos(index)
    ZPGModel.data.current_bet_pos = index
    --动画
end

function C:ChangeCurBetIndex(index)
    ZPGModel.data.current_bet_index = index
    --动画
end


function C:MyExit()
    ZPGLogic.clearViewMsgRegister(listerRegisterName)
    CloseTimer()
    SpineManager.RemoveAllDDZPlayerSpine()
    self:ClosePointerPrefab()
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
end

function C:OnAssetChange()
    self.t1_node.gameObject:SetActive(GameItemModel.GetItemCount("prop_guess_apple_bet_1") >= 1)
    self.t1_txt.text = GameItemModel.GetItemCount("prop_guess_apple_bet_1")

    self.t2_node.gameObject:SetActive(GameItemModel.GetItemCount("prop_guess_apple_bet_2") >= 1)
    self.t2_txt.text = GameItemModel.GetItemCount("prop_guess_apple_bet_2")

    self.t3_node.gameObject:SetActive(GameItemModel.GetItemCount("prop_guess_apple_bet_3") >= 1)
    self.t3_txt.text = GameItemModel.GetItemCount("prop_guess_apple_bet_3")

    self.t4_node.gameObject:SetActive(GameItemModel.GetItemCount("prop_guess_apple_bet_4") >= 1)
    self.t4_txt.text = GameItemModel.GetItemCount("prop_guess_apple_bet_4")

    self.t5_node.gameObject:SetActive(GameItemModel.GetItemCount("prop_guess_apple_bet_5") >= 1)
    self.t5_txt.text = GameItemModel.GetItemCount("prop_guess_apple_bet_5")

end