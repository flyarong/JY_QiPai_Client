-- 创建时间:2018-12-19

local basefunc = require "Game/Common/basefunc"

OneYuanGift = basefunc.class()

OneYuanGift.name = "OneYuanGift"

OneYuanGift.instance = nil
-- 什么都没有执行的回调 no_run_call
-- 已经写成这样了，我就不改了wqp
function OneYuanGift.Create(cb, no_run_call)
    if not GameGlobalOnOff.LIBAO then
        if no_run_call then no_run_call() end
        return
    end

    if not OneYuanGift.instance then
        OneYuanGift.New(cb, no_run_call)
    else
        print("<color=red>sssssssssssssssssssssssssssssss</color>")
    end
	return OneYuanGift.instance
end

--启动事件--
function OneYuanGift:ctor(cb, no_run_call)
    OneYuanGift.instance = self
    self.queryFinished = false
    self.shareCount = 0
    self.canBuy = false
    self.doShareOrBuy = false
    self.reqCallBack = cb
    self.no_run_call = no_run_call

    self:MakeListener()
    self:AddMsgListener()

    self:InitUI()
end

function OneYuanGift:OnExitScene()
    self:OnDestroy()
end

function OneYuanGift:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function OneYuanGift:MakeListener()
    self.lister = {}
    self.lister["query_broke_subsidy_num_response"] = basefunc.handler(self, self.query_broke_subsidy_num)
    self.lister["query_free_broke_subsidy_num_response"] = basefunc.handler(self, self.query_free_broke_subsidy_num_response)

    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
    self.lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
    self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function OneYuanGift:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function OneYuanGift:InitUI()
    dump({MainModel.UserInfo.freeSubsidyNum,MainModel.UserInfo.shareCount}, "<color=yellow>一元礼包》？》》》》</color>")
    if MainModel.UserInfo.freeSubsidyNum then
        if MainModel.UserInfo.shareCount then
            self:OnQueryFinished()
        else
            Network.SendRequest("query_broke_subsidy_num", nil, "请求数据")
        end
    else
        Network.SendRequest("query_free_broke_subsidy_num", nil, "请求数据")
    end
end
function OneYuanGift:query_free_broke_subsidy_num_response(_, data)
    dump(data, "<color=white>query_free_broke_subsidy_num_response</color>")
    MainModel.UserInfo.freeSubsidyNum = data.num or 0
    if MainModel.UserInfo.shareCount then
        self:OnQueryFinished()
    else
        Network.SendRequest("query_broke_subsidy_num", nil, "请求数据")
    end
end
function OneYuanGift:query_broke_subsidy_num(_, data)
    dump(data, "<color=white>query_broke_subsidy_num</color>")
    MainModel.UserInfo.shareCount = data.num or 0
    self.queryFinished = true
    self:OnQueryFinished()
end
--去掉现有的3元福利礼包，将现有的1元福利进行调整：
--(1)礼包价格改为3元；
--(2)礼包内容改为3.5万鲸+0.1元至10元随机福卡
--(3)福卡随机概率，进行2次随机：
--因此现在的status1yuan是三元礼包了  11.6.2019
function OneYuanGift:OnQueryFinished()
    MainModel.UserInfo.shareCount = MainModel.UserInfo.shareCount or 0
    MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum or 0
    self.status1yuan = MainModel.GetGiftShopStatusByID(10)
    self.status3yuan = 0--MainModel.GetGiftShopStatusByID(72)
    dump({ self.status1yuan, self.status3yuan}, "<color=white>一元礼包礼包状态</color>")
    -- 不能购买一元礼包 没有新手特权 没有转运金
    if self.status1yuan == 0 and self.status3yuan == 0 and MainModel.UserInfo.freeSubsidyNum <= 0 and MainModel.UserInfo.shareCount <= 0 then
        if self.no_run_call then
            self.no_run_call()
        end
        self:OnDestroy()
    else
        if self.status1yuan == 1 then
            GameShop1YuanPanel.Create(nil, function ()
                self.status1yuan = MainModel.GetGiftShopStatusByID(10)
                if self.status1yuan == 1 then
                    self:ShowFreeSubsidy()
                else
                    self:OnDestroy()
                end
            end)
        elseif self.status3yuan == 1 then
            GameShop3YuanPanel.Create(nil, function ()
                self.status3yuan = MainModel.GetGiftShopStatusByID(72)
                if self.status3yuan == 1 then
                    self:ShowFreeSubsidy()
                else
                    self:OnDestroy()
                end
            end)            
        else
            self:ShowFreeSubsidy()
        end
    end
end
-- 发送请求 领取免费津贴
function OneYuanGift:ShowFreeSubsidy()
    dump(MainModel.UserInfo.freeSubsidyNum, "<color=white>一元礼包ShowFreeSubsidy</color>")
    if MainModel.UserInfo.freeSubsidyNum and MainModel.UserInfo.freeSubsidyNum > 0 and MainModel.UserInfo.jing_bi < 3000 then
        Network.SendRequest("free_broke_subsidy", nil, "请求数据",function(data)
            dump(data, "<color=white>free_broke_subsidy</color>")
            if data.result ~= 0 then
                LittleTips.Create(errorCode[data.result])
                return
            end
            MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum - 1
        end)
        self:OnDestroy()
    else
        self:ShowSharePanel()
    end
end
-- 显示分享 分享可获取转运金
function OneYuanGift:ShowSharePanel()
    dump({MainModel.UserInfo.shareCoun,MainModel.UserInfo.jing_bi}, "<color=white>一元礼包ShowSharePanel</color>")
    if MainModel.UserInfo.shareCount and MainModel.UserInfo.shareCount > 0 and MainModel.UserInfo.jing_bi < 3000 then
        ReliefGoldPanel.Create(function ()
            self:OnDestroy()
        end)
    else
        if self.status1yuan == 1 or self.status3yuan == 1 then
            self:OnDestroy()
            -- 捕鱼不提示去比赛场
            if MainModel.myLocation ~= "game_Fishing" then
                GameManager.GotoUI({gotoui = "guide_to_match",goto_scene_parm = "panel"})
            end
        else
            if self.no_run_call then
                self.no_run_call()
            end
            self:OnDestroy()
        end
    end
end
function OneYuanGift:OnDestroy()
    print("<color=yellow>一元礼包OnDestroy</color>")
    self:RemoveListener()
    OneYuanGift.instance = nil
end

function OneYuanGift:Close()
    if self.reqCallBack then
        self.reqCallBack()
    end
    self:OnDestroy()
end


function OneYuanGift.IsCanGetBrokeAward()
    if MainModel.UserInfo.jing_bi < 3000 then
        if MainModel.UserInfo.freeSubsidyNum and MainModel.UserInfo.shareCount then
            return MainModel.UserInfo.freeSubsidyNum + MainModel.UserInfo.shareCount > 0
        end
    end
    return false
end

--检查低保
function OneYuanGift.ChekcBroke(callback)
    dump("<color=white>检查低保</color>")
    if MainModel.UserInfo.jing_bi >= 3000 then
		if callback ~= nil then
			callback()
		end
		return
	end
    Network.SendRequest("query_free_broke_subsidy_num", nil, "请求数据",function(data)
        dump(data, "<color=white>query_free_broke_subsidy_num</color>")
        if data.result ~= 0 then
            LittleTips.Create(errorCode[data.result])
            return
        end
        MainModel.UserInfo.freeSubsidyNum = data.num or 0
        MainModel.UserInfo.freeSubsidyAllNum = data.all_num or 0
        if (Sys_011_YuekaManager and not Sys_011_YuekaManager.IsBuySmallYueKa()) and (MainModel.UserInfo.freeSubsidyNum 
        and MainModel.UserInfo.freeSubsidyNum ~= 0 and MainModel.UserInfo.freeSubsidyAllNum
        and MainModel.UserInfo.freeSubsidyAllNum ~= 0 and MainModel.UserInfo.freeSubsidyAllNum == MainModel.UserInfo.freeSubsidyNum
        ) -- 含义是如果请求到了数据，并且免费破产救济金没有领取过，这个时候又没有购买一级月卡
        then
            Network.SendRequest("query_broke_subsidy_is_can_get",nil,function (data)

                if data.result ~= 0 then
                    LittleTips.Create(errorCode[data.result])
                    return
                end
                MainModel.UserInfo.query_broke_subsidy_is_can_get = data.is_can == 1
                if MainModel.UserInfo.query_broke_subsidy_is_can_get then
                    if MainModel.UserInfo.jing_bi >= 3000 then
                        return
                    end
                    Sys_011_YueKa_NewNoticePanel.Create()
                else
                    PayPanel.Create(GOODS_TYPE.jing_bi)
                end
            end)
        else
            OneYuanGift.GetBrokeAward(callback)
        end
    end)
end

function OneYuanGift.GetBrokeAward(callback)
    if MainModel.UserInfo.jing_bi >= 3000 then 
        if callback ~= nil then
			callback()
		end
        return 
    end
    local function show_share_panel()
        if MainModel.UserInfo.shareCount > 0 then
            ReliefGoldPanel.Create()
        else
            PayPanel.Create(GOODS_TYPE.jing_bi)
        end
    end

    local function query_finished()
        MainModel.UserInfo.shareCount = MainModel.UserInfo.shareCount or 0
        MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum or 0
        if MainModel.UserInfo.freeSubsidyNum and MainModel.UserInfo.freeSubsidyNum > 0 then
            Network.SendRequest("free_broke_subsidy", nil, "请求数据",function(data)
                dump(data, "<color=white>free_broke_subsidy</color>")
                if data.result ~= 0 then
                    LittleTips.Create(errorCode[data.result])
                    return
                end
            end)
            MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum - 1
        else
            show_share_panel()
        end
    end

    local function query_broke_subsidy_num()
        Network.SendRequest("query_broke_subsidy_num", nil, "请求数据",function(data)
            dump(data, "<color=white>query_broke_subsidy_num</color>")
            if data.result ~= 0 then
                LittleTips.Create(errorCode[data.result])
                return
            end
            MainModel.UserInfo.shareCount = data.num or 0
            query_finished()
        end)
    end

    if MainModel.UserInfo.freeSubsidyNum then
        if MainModel.UserInfo.shareCount then
            query_finished()
        else
            query_broke_subsidy_num()
        end
    else
        Network.SendRequest("query_free_broke_subsidy_num", nil, "请求数据",function(data)
            dump(data, "<color=white>query_free_broke_subsidy_num</color>")
            if data.result ~= 0 then
                LittleTips.Create(errorCode[data.result])
                return
            end
            MainModel.UserInfo.freeSubsidyNum = data.num or 0
            if MainModel.UserInfo.shareCount then
                query_finished()
            else
                query_broke_subsidy_num()
            end
        end)
    end
end