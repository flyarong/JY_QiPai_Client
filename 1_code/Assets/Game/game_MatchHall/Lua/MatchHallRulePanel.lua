local basefunc = require "Game.Common.basefunc"
MatchHallRulePanel = basefunc.class()
local M = MatchHallRulePanel

local instance
function M.Create(cfg, parent)
    if instance then
        M.Close()
    end
    instance = M.New(cfg, parent)
    return instance
end

-- isOpenType 打开方式 normal正常打开 其余是货币不足打开
function M:ctor(cfg, parent)
	ExtPanel.ExtMsg(self)
    self.cfg = cfg
    self.parent = parent or GameObject.Find("Canvas/LayerLv3")
    self.gameObject = newObject("MatchHallRulePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self:Init()

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function M:MyExit()
    if instance then
        destroy(self.gameObject)
        instance = nil
    end	 
end

-- 关闭
function M.Close()
    if instance then
        instance:MyExit()
    end
end

function M:Init()
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRuleBack)
    --规则
    if self.cfg.match_type == MatchModel.MatchType.sws then
        self.rule_txt.text = string.format( "赛事规则：\n\n使用定局积分赛制。\n\n每轮比赛结束后，按积分排名决出晋级玩家，剩余玩家被淘汰。\n\n多副牌情况则完成规定牌局后按积分排名晋级。\n\n斗地主排名同分情况：发到手的手牌都会有隐藏分，手牌越大（如炸弹，王、2、A）那么隐藏分越高，排名同分情况下隐藏分大的玩家胜出。" )
    elseif self.cfg.match_type == MatchModel.MatchType.qydjs then
        if self.cfg.type_id == 1 or self.cfg.type_id == 2 then
            self.rule_txt.text = string.format( "赛事规则：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加。\n\n打立出局十轮后，如出局人数未满，强制进行排名晋级。打立出局阶段可复活三次，强制排名时不可复活。斗地主32倍封顶。\n\n剩余人数小于或等于决赛人数后，剩余玩家进入决赛。\n\n决赛使用定局积分赛制。\n\n前三名请联系客服领取奖励。\n\n斗地主排名同分情况：发到手的手牌都会有隐藏分，手牌越大（如炸弹，王、2、A）那么隐藏分越高，排名同分情况下隐藏分大的玩家胜出。" )
        else
            self.rule_txt.text = string.format( "明星赛说明：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加。打立出局三轮后，如出局人数未满，强制排名晋级，前96名晋级。斗地主32倍封顶。" )
        end
    elseif self.cfg.match_type == MatchModel.MatchType.ges then
        --self.rule_txt.text = string.format( "赛事介绍：\n\n鲸鱼斗地主月末福利赛\n\n赛事规则：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加，最多12轮。打立出局三轮后，如出局人数未满，强制排名晋级，前258名晋级。斗地主32倍封顶。" )
        self.rule_txt.text = string.format( "赛事介绍：\n\n鲸鱼斗地主"..self.cfg.ui_match_name .."\n\n赛事规则：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加，最多12轮。打立出局三轮后，如出局人数未满，强制排名晋级，前258名晋级。斗地主32倍封顶。" )
    else
        self.rule_txt.text = string.format( "赛事规则：\n\n使用定局积分赛制。\n每轮比赛结束后，按积分排名决出晋级玩家，剩余玩家被淘汰。\n多副牌情况则完成规定牌局后按积分排名晋级。\n\n斗地主排名同分情况：发到手的手牌都会有隐藏分，手牌越大（如炸弹，王、2、A）那么隐藏分越高，排名同分情况下隐藏分大的玩家胜出。" )
    end
end


function M:OnClickRuleBack(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:MyExit()
end