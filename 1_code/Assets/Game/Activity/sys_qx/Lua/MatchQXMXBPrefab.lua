-- 创建时间:2019-12-02
-- 明星杯权限对应逻辑

MatchQXMXBPrefab = {}
local C = MatchQXMXBPrefab

function C.ExtLogic(parm)
    if parm.key == "match_hall" then
        if parm.panelSelf then
            if IsEquals(parm.panelSelf.enter_hint_txt) then
                parm.panelSelf.enter_hint_txt.text = "VIP4免费"
            end
        end
    elseif parm.key == "match_detail" then
        if parm.panelSelf then
            if IsEquals(parm.panelSelf.selected_txt) then
                parm.panelSelf.selected_txt.text = "VIP4及以上"
            end
            if IsEquals(parm.panelSelf.rule_txt) then
                parm.panelSelf.rule_txt.text = string.format( "VIP4回馈赛说明：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加。打立出局五轮后，如出局人数未满，强制排名晋级，前96名晋级。斗地主32倍封顶，麻将4番封顶。" )
            end
            if IsEquals(parm.panelSelf.ticketCount_txt) then
                parm.panelSelf.ticketCount_txt.text = "VIP4及以上"
            end
        end
    end
end