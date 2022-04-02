RXCQSBTJManager = {}
local C = RXCQSBTJManager
local _self = {}
--防止因为卡顿丢失关键的动画，导致界面卡死
local is_over = false
function C.Start(__self)
    _self = __self
    _self.playerAction.player.RXCQShowMoneyItem:ReSetMoney()
    _self.playerAction.player.RXCQShowMoneyItem:Show("sbtj")
    local all_money = RXCQModel.game_data.award
    local all_money_list = RXCQNormalDie.get_money_num()
    dump(all_money_list,"<color=red>all_money_listall_money_list</color>")
    local guaiwu_list = {}
    for i = 1,#RXCQModel.game_data.monster do
        if RXCQModel.game_data.monster[i] > 0 then
            guaiwu_list[#guaiwu_list + 1] = RXCQModel.game_data.monster[i]
        end
    end
    local temp_index = 1
    local main_timer 
    local sb_anim = M.CreateSB()
    sb_anim.Start()
    main_timer = Timer.New(
        function()
            local guaiwu = RXCQGuaiWuManager.GetGuaiWuByPos(guaiwu_list[temp_index])
            if guaiwu then
                ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_sbtj_bom.audio_name)
                C.GuaiWuDie(guaiwu,guaiwu_list[temp_index],all_money_list[temp_index],temp_index == #guaiwu_list)
                temp_index = temp_index + 1
            end
            if temp_index > #guaiwu_list then
                main_timer:Stop()
                sb_anim.Stop()
                RXCQModel.DelayCall(
                    function()
                        if is_over == false then
                            RXCQMiniGameDie.ReSetUI(function()
                                is_over = true
                                _self.playerAction.player.RXCQShowMoneyItem:Hide()
                                Event.Brocast("rxcq_call_next_anim")
                            end)
                        end
                    end
                ,5)
            end
        end
    ,0.2,-1,nil,true)
    RXCQModel.AddTimers(main_timer)
    main_timer:Start()
    --RXCQMiniGameDie.ReSetUI()
end

function C.GuaiWuDie(guaiwu,guaiwu_pos,money,is_last)
    dump(money,"<color=red>总价格</color>")
    is_over = false
    guaiwu:Hit(function()
        guaiwu:Death(
            function()
                local map = RXCQNormalDie.create_jb_map(guaiwu,guaiwu_pos)
                local zero = RXCQNormalDie.get_zero_pos({guaiwu})
                local money_list = RXCQNormalDie.get_one_guaiwu_money_list(guaiwu_pos,money)
                local t = 0
                for i = 1,#money_list do
                    t = t + money_list[i] 
                end
                dump(t,"<color=red>总价格的和</color>")
                local max_finsh = #money_list
                local finsh_index = 0
                for i = 1,#money_list do
                    local b = RXCQMoneyItem.Create(_self.guaiwu_node,money_list[i],RXCQFightPrefab.player_zero_pos,
                        function()
                            finsh_index = finsh_index + 1
                            if finsh_index == max_finsh then
                                _self.playerAction.player.RXCQShowMoneyItem:DoPopAnim(money,is_last,
                                function()
                                    is_over = true
                                    RXCQMiniGameDie.ReSetUI(function()
                                        _self.playerAction.player.RXCQShowMoneyItem:Hide()
                                        Event.Brocast("rxcq_call_next_anim")
                                    end)
                                end
                            )
                            end                        
                        end,
                    Vector3.New(map[i].x,map[i].y,0))
                    b.transform.localPosition = zero
                    b.transform:SetSiblingIndex(0)
                end
                local new_guaiwu = RXCQGuaiWuManager.CreateGuaiWu(nil,guaiwu_pos)
                new_guaiwu:ShowChuanSong(
                    function()
                        new_guaiwu:Stand()
                    end
                )
                end      
        ,2)
    end)
end

function M.CreateSB()
    local zero = {x = 0,y = 282}
    local SB = {}
    local timer = Timer.New(
        function()
            local pos = Vector3.New(zero.x + math.random(-300,300),zero.y + math.random(-300,300))
            local _sb = GameObject.Instantiate(RXCQPrefabManager.Prefabs["tjsb_rxcq"],_self.transform)
            _sb.transform.localPosition = pos
            _sb.transform.localScale = Vector3.New(0.8,0.8,0.8)
            GameObject.Destroy(_sb,2)
        end,
    0.2,-1,nil,true)
    RXCQModel.AddTimers(timer)
    SB.Start = function()
        timer:Start()
    end
    SB.Stop = function()
        timer:Stop()
    end
    return SB
end
--0xa04a9d50