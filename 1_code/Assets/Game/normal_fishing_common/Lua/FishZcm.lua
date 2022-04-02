-- 创建时间:2021-11-13
local basefunc = require "Game/Common/basefunc"
FishZcm  = basefunc.class(Fish)
local C = FishZcm

function C.Create(...)
    return C.New(...)
end

function C:FrameUpdate(time_elapsed)
	FishZcm.super.FrameUpdate(self, time_elapsed)
    if not self.timeIndex then
        ExtendSoundManager.PlaySound("sod_game_fish_zcm")
        self.timeIndex = 0
    else
        self.timeIndex = self.timeIndex + time_elapsed
        if self.timeIndex > 30 then
            self.timeIndex = 0
        end    
    end
end

