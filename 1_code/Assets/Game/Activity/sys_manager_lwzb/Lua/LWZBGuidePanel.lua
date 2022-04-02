-- 创建时间:2020-01-15
-- Panel:LWZBGuidePanel
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

LWZBGuidePanel = basefunc.class()
local C = LWZBGuidePanel
C.name = "LWZBGuidePanel"  
local M = LWZBModel

-- 引导步骤
local GuideStepConfig = {
    [1] = {
        id = 1,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        szPos={x=38, y=11, z=0},
        desc="点击这里可以选择充能档次",
        descRot={x=0, y=0, z=180},
        descPos={x=10, y=84, z=0},
        headPos={x=0, y=0},
    },
    [2] = {
        id = 2,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        szPos={x=-26, y=-26, z=0},
        desc="点击充能此神兽,获胜后可以获得高倍奖励哦~",
        descRot={x=0, y=0, z=180},
        descPos={x=0, y=80, z=0},
        headPos={x=0, y=0},
    },
    [3] = {
        id = 3,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        desc="这里是龙王的牌",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=150, z=0},
        headPos={x=0, y=0},
    },
    [4] = {
        id = 4,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        desc="这是龙王的牌型",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=150, z=0},
        headPos={x=0, y=0},
    },
    [5] = {
        id = 5,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        desc="这是龙王的牌型倍率",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=150, z=0},
        headPos={x=0, y=0},
    },
    [6] = {
        id = 6,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        desc="这是神兽的牌",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=150, z=0},
        headPos={x=0, y=0},
    },
    [7] = {
        id = 7,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        desc="这是神兽的牌型",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=150, z=0},
        headPos={x=0, y=0},
    },
    [8] = {
        id = 8,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        desc="恭喜你,牌型比龙王大,将得10倍奖励!",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=150, z=0},
        headPos={x=0, y=0},
    },
    [9] = {
        id = 9,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        szPos={x=-162, y=-320, z=0},
        desc="点击退出,完成龙王争霸新手引导",
        descPos={x=0, y=-184, z=0},
        headPos={x=0, y=0},
    },
    --[[[6] = {
        id = 6,
        type="GuideStyle1",
        isHideBG=false, 
        isHideSZ = true,
        desc="又获得一个A，形成了三条牌型",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=150, z=0},
        headPos={x=0, y=0},
    },
    [7] = {
        id = 7,
        type="GuideStyle1",
        isHideBG=false, 
        isHideSZ = true,
        desc="让我们用一种更简单的方式来砸蛋吧",
        descRot={x=180, y=0, z=0},
        descPos={x=-348, y=144, z=0},
        headPos={x=0, y=0},
    },
    [8] = {
        id = 8,
        type="GuideStyle1",
        isHideBG=false, 
        isHideSZ = true,
        desc="又得到一张A，我们形成了很大的【炸弹】牌型",
        descRot={x=180, y=0, z=0},
        descPos={x=-74, y=220, z=0},
        headPos={x=0, y=0},
    },
    [9] = {
        id = 9,
        type="GuideStyle1",
        isHideBG=false, 
        isHideSZ = true,
        desc="对手已经有一对Q，不可能是同花顺，\n我们的牌型肯定大过他",
        descPos={x=0, y=-144, z=0},
        headPos={x=0, y=0},
    },
    [10] = {
        id = 10,
        type="GuideStyle1",
        isHideBG=false, 
        isHideSZ = true,
        desc="你已经学会怎么砸蛋了，来自己操作一下吧",
        descRot={x=180, y=0, z=0},
        descPos={x=-390, y=220, z=0},
        headPos={x=0, y=0},
    },
    [11] = {
        id = 11,
        type="GuideStyle1",
        isHideBG=false, 
        isHideSZ = true,
        desc="对方名牌有三张Q，加上暗牌，有可能是【炸弹】，\n有可能是【三条】，也有可能是【葫芦】",
        descPos={x=-390, y=260, z=0},
        headPos={x=0, y=0},
    },
    [12] = {
        id = 12,
        type="GuideStyle1",
        isHideBG=false, 
        isHideSZ = true,
        desc="我们牌型为A炸弹，比对方所有有可能出现的牌型都大",
        descRot={x=180, y=0, z=0},
        descPos={x=-430, y=-210, z=0},
        headPos={x=0, y=0},
    },--]]
}

function C.Create(panelSelf)
    return C.New(panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["lwzb_guide_check"] = basefunc.handler(self, self.CheckGuide)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
end
function C:OnEnterBackGround()
    self:StopRunTime()
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.com_guide then
        self.com_guide:MyExit()
        self.com_guide = nil
    end
    self:RemoveListener()
end

function C:ctor(panelSelf)  
    self:MakeLister()
    self:AddMsgListener()

    -- 游戏面板
    self.panelSelf = panelSelf
    self:InitUI()
end

function C:InitUI()
    self.com_guide = ComGuideToolPanel.Create()
    local sz = self.com_guide.transform:Find("Canvas/SZAnim1/SZAnim1")
	sz.transform.localPosition = Vector3.New(-216.9,-302.4,0)
    self.com_guide:SetSkipButtonActive(false)
    self.bet_step = 1
    self.game_step = 1
end
function C:StopRunTime()
    if self.guide_t then
        self.guide_t:Stop()
    end
    self.guide_t = nil
end

function C:CheckGuide()
        if not LWZBModel.GetCurStatus() then
        elseif LWZBModel.GetCurStatus() == LWZBModel.Model_Status.bet then
            if self.bet_step == 1 then
                self.bet_step = 2
                self.com_guide:RunGuide(GuideStepConfig[1], self.panelSelf.gun1_btn.gameObject)
            elseif self.bet_step == 2 then
                self.bet_step = 3
                self.com_guide:RunGuide(GuideStepConfig[2], self.panelSelf.tg_node3.gameObject)
            end
        elseif LWZBModel.GetCurStatus() == LWZBModel.Model_Status.game then
            if self.game_step == 1 then
                self.game_step = 2
                self.com_guide:RunGuide(GuideStepConfig[3], self.panelSelf.lw_pre:GetOBJ_pai())
            elseif self.game_step == 2 then
                self.game_step = 3
                self.com_guide:RunGuide(GuideStepConfig[4], self.panelSelf.lw_pre:GetOBJ_type())
            elseif self.game_step == 3 then
                self.game_step = 4
                self.com_guide:RunGuide(GuideStepConfig[5], self.panelSelf.lw_pre:GetOBJ_rate())
            elseif self.game_step == 4 then
                self.game_step = 5
                self.com_guide:RunGuide(GuideStepConfig[6], self.panelSelf.ss_pre_list[3]:GetOBJ_pai())
            elseif self.game_step == 5 then
                self.game_step = 6
                self.com_guide:RunGuide(GuideStepConfig[7], self.panelSelf.ss_pre_list[3]:GetOBJ_type())
            elseif self.game_step == 6 then
                self.game_step = 7
                self.com_guide:RunGuide(GuideStepConfig[8], self.panelSelf.ss_pre_list[3]:GetOBJ_rate())
            elseif self.game_step == 7 then
                LWZBModel.GetGuideData("settle")
            end
        elseif LWZBModel.GetCurStatus() == LWZBModel.Model_Status.settle then
            --[[local hint_pre = HintPanel.Create(1,"您已经完成新手引导,请前往更高级场赢取更多金币吧!",function ()
                if LWZBManager.GetLwzbGuideOnOff() then
                    Network.SendRequest("set_xsyd_status", {status = 1, xsyd_type="xsyd_lwzb"},function (data)
                        dump(data,"<color=yellow>++++++++++set_xsyd_status+++++++++</color>")
                        MainModel.UserInfo.xsyd_status = 1
                        LWZBManager.SetLwzbGuideOnOff()
                        GameManager.GotoSceneName("game_LWZBHall",nil,function ()
                            LWZBManager.Sign(1)
                        end)
                    end)

                end
            end)
            hint_pre:SetButtonText(nil,"前往")--]]
        end
end
