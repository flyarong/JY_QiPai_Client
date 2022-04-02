-- 创建时间:2021-03-16

RXCQMiniGameDie = {}
local C = RXCQMiniGameDie
local _self = {}
function C.Die(__self,skill_name)
    _self = __self
    C.ZhuanChang()
    RXCQModel.IsDuringMiniGame = true
    RXCQModel.DelayCall(
        function()
            if skill_name == "ShenBinTianJiang" then
                ExtendSoundManager.PlaySceneBGM(audio_config.rxcq.rxcq_sbtj_background.audio_name)
                local show = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_SBTJ_Show"],_self.transform.parent.parent.parent)
                RXCQModel.DelayCall(
                    function()
                        RXCQSBTJManager.Start(_self)
                    end 
                ,3.1)
                GameObject.Destroy(show,3.1)
            elseif skill_name == "TianRenHeYi" then
                ExtendSoundManager.PlaySceneBGM(audio_config.rxcq.rxcq_trhy_background.audio_name)
                local show = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_TRHY_Show"],_self.transform.parent.parent.parent)
                RXCQModel.DelayCall(
                    function()
                        RXCQTRHYManager.Start(_self)
                    end
                ,3.2)
                GameObject.Destroy(show,3.2)
            elseif skill_name == "JueZhanShaCheng" then
                RXCQModel.GetRegisterObj("RXCQGamePanel_JZSC").gameObject:SetActive(true)
                RXCQModel.GetRegisterObj("RXCQGamePanel_Fight").gameObject:SetActive(false)
                ExtendSoundManager.PlaySceneBGM(audio_config.rxcq.rxcq_jzsc_background.audio_name)
                local panel = RXCQJZSCPanel2.Create(RXCQModel.GetRegisterObj("RXCQGamePanel_JZSC").transform)
                local show = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_JZSC_Show"],_self.transform.parent.parent.parent)
                RXCQModel.DelayCall(
                    function()
                        Event.Brocast("rxcq_jzsc_in")
                        RXCQJZSCManager2.Start(_self,panel)
                    end
                ,3.2)
                GameObject.Destroy(show,3.2)
                dump(show,"<color=red> JueZhanShaCheng  </color>")
            end
        end,
    0.4)
end

function C.ReSetUI(backcall)
    RXCQModel.DelayCall(
        function()
            --RXCQModel.GetRegisterObj("RXCQGamePanel_Fight_UI").gameObject:SetActive(true)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_help_btn").gameObject.transform.localPosition = Vector3.New(-653,-33)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_back_btn").gameObject:SetActive(true)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_history_btn").gameObject.transform.localPosition = Vector3.New(-653,91)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_player_info").gameObject.transform.localPosition = Vector3.New(-512,237)
            RXCQModel.GetRegisterObj("RXCQGamePanel_Lottery").gameObject:SetActive(true)
            RXCQModel.GetRegisterObj("RXCQFightPrefab_Mask").enabled = true
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_bet").gameObject:SetActive(true)
            RXCQLotteryAnim.ReSetShow()
            RXCQModel.GetRegisterObj("RXCQGamePanel_JZSC").gameObject:SetActive(false)
            RXCQModel.GetRegisterObj("RXCQGamePanel_Fight").gameObject:SetActive(true)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_mini").gameObject:SetActive(true)
            if backcall then
                backcall()
            end
        end,0.16
    )
    RXCQModel.GetRegisterObj("RXCQGamePanel_ShanGuang").gameObject:SetActive(false)
    RXCQModel.GetRegisterObj("RXCQGamePanel_ShanGuang").gameObject:SetActive(true)
    RXCQModel.IsDuringMiniGame = false
end

function C.ZhuanChang(call)
    RXCQModel.GetRegisterObj("RXCQGamePanel_ShanGuang").gameObject:SetActive(false)
    RXCQModel.GetRegisterObj("RXCQGamePanel_ShanGuang").gameObject:SetActive(true)
    RXCQModel.DelayCall(
        function()
            --RXCQModel.GetRegisterObj("RXCQGamePanel_Fight_UI").gameObject:SetActive(false)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_help_btn").gameObject.transform.localPosition = Vector3.New(-859,178)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_back_btn").gameObject:SetActive(false)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_history_btn").gameObject.transform.localPosition = Vector3.New(-859,302)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_player_info").gameObject.transform.localPosition = Vector3.New(-718,448)
	        RXCQModel.GetRegisterObj("RXCQGamePanel_Lottery").gameObject:SetActive(false)
            RXCQModel.GetRegisterObj("RXCQFightPrefab_Mask").enabled = false
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_bet").gameObject:SetActive(false)
            RXCQModel.GetRegisterObj("RXCQFightUIPrefab_mini").gameObject:SetActive(false)
            if call then
                call()
            end
        end,
    0.16)
end