-- 创建时间:2020-08-26
-- Panel:LWZBHallGamePanel
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


LWZBHallGamePanel = basefunc.class()
local C = LWZBHallGamePanel
C.name = "LWZBHallGamePanel"
local help_info = {
"基本规则",
"1.游戏采用一龙四神兽百人参与的方式。龙王和四兽分别进行比牌，参与者选择四神兽进行充能，可以同时充能多个神兽。",
"2.游戏使用一副牌（不含大小王）共52张牌进行游戏。J、Q、K都是10点，其它按照牌面的点数计算。",
"3.无龙：没有任意三张牌能加起来成为10的倍数。" ,
"4.有龙：从龙一到龙九。任意三张牌相加是10的倍数，剩余两张牌相加不是10的倍数，然后取个位数，个位数是几，就是龙几。",
"5.神兽：任意三张牌相加是10的倍数，剩余两张牌相加也是10的倍数。",
"6.四方神兽：五张牌中有四张一样的牌即为四方神兽，此时不需要有兽。",
"7.五爪金龙：手上五张牌全部是J、Q、K组成的特殊神兽牌型为五彩神兽",
"8.充能结束后进行发牌，开牌后龙王和四兽进行牌型比较，牌大的赢。四兽不进行相互比较",
"大小规则",
"单张大小：从大到小排序为：K > Q > J >10 > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2 > 1",
"牌型大小：从大到小排序为：五爪金龙> 四方神兽 > 神龙 > 有龙 > 没龙。",
"有龙大小：当都为有龙时，从大到小排序为：龙九 > 龙八 > 龙七 > 龙六 > 龙五 > 龙四 > 龙三 > 龙二 > 龙一。",
"牌型相同：龙王和神兽相同牌型时，挑出最大的一张牌进行比较，如果最大的牌点数一样，则龙王获胜。（特例：当有多个四方神兽时，比较四张相同的牌的点数大小）",
"赔率规则",
"低倍场房间： ",
"无龙到龙六：1倍",
"龙七到龙九：2倍",
"神龙：3倍",
"四方神兽：4倍",
"五爪金龙：5倍",
"高倍场房间：",
"无龙、龙一：1倍。",
"龙二到龙九的赔率依次为：2倍、3倍、4倍、5倍、6倍、7倍、8倍、9倍",
"神龙、四方神兽、五爪金龙均为10倍",
"财神大奖",
"房间内会随机触发财神赐福，在房间放出财神大奖，发放巨奖",
"对当前房间内的所有玩家随机抽取，幸运星、富豪NO1、龙王获得的概率略高于其他玩家（系统神龙除外）",
"玩家赢金的5%进入奖池",
"上座规则",
"幸运星为上局净盈利最高的玩家（龙王除外）",
"富豪榜按近10局充能总量排名（龙王和幸运星除外）",
"每局结算后，刷新幸运星与富豪榜",
"幸运星、富豪榜1-5可于场上就座",
"每个玩家只能有一个座位，获得幸运星则当局不进入富豪榜",
"幸运星充能的神兽，增加星星标记",
"其他规则",
"为了游戏公平，如果玩家在一局游戏失败后，按照游戏规则应输100金币，但是他身上只有50金币，那么赢家只能从该玩家身上得到50金币，如果有多个赢家，则赢家按照各自倍数分别按比例分配这50金币。",
"基于上一条，玩家在一局游戏胜利后，赢得的金币总额不会超过身上携带的金币，如某玩家按照游戏规则计算应该赢100金币，但是因为他身上只携带了50金币，所以本局该玩家只能赢取50金币。输家按照对应比例相应减少所输的金币。",
"龙王剩余金币≤成为龙王条件的50%，将被屠龙",
"玩家个人充能的总金币不能高于龙王的金币并且不能超过自身携带金币的30%",
}
function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["AssetChange"] = basefunc.handler(self, self.on_AssetChange)
    self.lister["lwzb_query_qlcf_info_response"] = basefunc.handler(self,self.on_lwzb_query_qlcf_info_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	self:StopSendTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local btn_map = {}
	btn_map["left_top"] = {self.hall_btn_top}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "lwzb_game_hall", self.transform)


	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddGold()
	end)
	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnHelpClick()
	end)
	self.Setup_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnSetupClick()
	end)

	self.enter1_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnEnterClick(1)
	end)
	self.enter2_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnEnterClick(2)
	end)


	self:RefreshJBandFK()
	self:RefreshEnterTXT()
	self:MyRefresh()
	self:ShowCSDJUIInC()
	LWZBManager.SetLwzbGuideOnOff()
end

function C:MyRefresh()
end

-- btn
function C:OnBackClick()
	GameManager.GotoUI({gotoui = "game_Hall"})
end
function C:OnAddGold()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end
function C:OnEnterClick(index)
	LWZBManager.Sign(index)
end

function C:RefreshJBandFK()
	self.red_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi) or "0"
end

function C:OnHelpClick()
	self:OpenHelpPanel()
end

function C:OnSetupClick()
	SettingPanel.Create()
end

function C:RefreshEnterTXT()
	local sign_data = LWZBManager.hall_config.sign
	--[[if sign_data[1].limit_max ~= -1 then
		self.limit1_txt.text = StringHelper.ToCash(sign_data[1].limit_min).."-"..StringHelper.ToCash(sign_data[1].limit_max)
	else
		self.limit1_txt.text = StringHelper.ToCash(sign_data[1].limit_min)
	end
	if sign_data[2].limit_max ~= -1 then
		self.limit2_txt.text = StringHelper.ToCash(sign_data[2].limit_min).."-"..StringHelper.ToCash(sign_data[2].limit_max)
	else
		self.limit1_txt.text = StringHelper.ToCash(sign_data[2].limit_min)
	end--]]
	--self.lw_limit1_txt.text = StringHelper.ToCash(sign_data[1].lw_limit)
	self.limit1_txt.text = StringHelper.ToCash(sign_data[1].limit_min).."以上"
	self.limit2_txt.text = StringHelper.ToCash(sign_data[2].limit_min).."以上"
	self.lw_limit2_txt.text = StringHelper.ToCash(sign_data[2].lw_limit)
end

function C:OpenHelpPanel()
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	LWZBHelpPanel.Create(self.introduce_txt.text)
	-- IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_AssetChange()
	self:RefreshJBandFK()
end


function C:ShowCSDJUIInC()
    self:StopSendTime()
    --local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "zjd_level", is_on_hint = true}, "CheckCondition")
    --if a and b then
       self.csdj_node.gameObject:SetActive(true)
       if MainModel.myLocation == "game_LWZBHall" then
            self:SendCSDJData()
            send_time = Timer.New(function ()
                    self:SendCSDJData()
                end, 10, -1, nil, true)
                send_time:Start()
            --this.m_data.is_one = true
        end
    --else
        --self.csdj_node.gameObject:SetActive(false)
    --end

end

function C:StopSendTime()
    if send_time then
        send_time:Stop()
        send_time = nil
    end
end


function C:SendCSDJData()
    Network.SendRequest("lwzb_query_qlcf_info",{game_id = 2})
end

--local award_pool = 0
function C:on_lwzb_query_qlcf_info_response(_,data)
    dump(data,"<color=red>on_lwzb_query_qlcf_info_response</color>")

    if data.result == 0 then
        self.award_pool = data.value 
        -- award_pool = award_pool + 100000
        -- self.award_pool = award_pool
        if not self.cur_num then
        	self.cur_num = math.floor(self.award_pool* 0.4)
    	end
    	self:RunChange()
    end
   
end

function C:RunChange()
    if self.is_animing then
        return
    end
    self.mb_num = self.award_pool
    GameComAnimTool.stop_number_change_anim(self.anim_tab)
    if not self.cur_num or not self.mb_num or self.cur_num == self.mb_num then
        return
    end
    self.is_animing = true
    self.anim_tab = GameComAnimTool.play_number_change_anim(self.award_txt, self.cur_num, self.mb_num, 40, function ()
        self.cur_num = self.mb_num
        self.is_animing = false
        self:RunChange()
    end)
end
