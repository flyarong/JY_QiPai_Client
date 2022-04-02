local basefunc = require "Game.Common.basefunc"
FishingDRPlayer = basefunc.class()
local C = FishingDRPlayer
C.name = "FishingDRPlayer"
function C.Create(data)
	return C.New(data)
end

function C:FrameUpdate(time_elapsed)
    
end

function C:MyExit()
    self.data = nil
    self.transform = nil
    self.playertran_ybh = nil
    self.playertran_ytt = nil
end

function C:ctor(data)
    self.data = data
end

function C:GetTrans()
    if not self.data then return end
    self.transform_player = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel/UINode/Player" .. self.data.id).transform
    self.transform_gunNode = GameObject.Find("FishingDR2DUI/GunNode/Node" .. self.data.id.."/GunAnim").transform
    self.playertran_ybh = self.transform_gunNode:Find("ybh").gameObject
    self.playertran_ytt = self.transform_player:Find("ytt").gameObject
end

function C:MyRefresh()
    if not self.transform then self:GetTrans() end
    local m_data =  FishingDRModel.GetData()
    if self.data.id == 8 then
        self.playertran_ybh:SetActive(false)
        return 
    end
    if m_data and m_data.model_status ~= FishingDRModel.Model_Status.gaming then
        self.playertran_ybh:SetActive(false)
        self.playertran_ytt:SetActive(false)
        return
    end

    if m_data and m_data.game_data and m_data.game_data.game_state == FishingDRModel.Model_Status.gaming then 
        local b = FishingDRModel.get_fish(self.data.id)
        if b then
            if b.is_dead ==1 then 
                self.playertran_ybh:SetActive(true)
            else
                self.playertran_ybh:SetActive(false)
            end 
            if FishingDRModel.check_fish_is_reale_flee(self.data.id)  then 
                self.playertran_ytt:SetActive(true)
            else
                self.playertran_ytt:SetActive(false)
            end
        end 
    else
        self.playertran_ybh:SetActive(false)
        self.playertran_ytt:SetActive(false)
    end 
end