--[[
ganshuangfeng spine管理器
2018-4-26
]]
SpineManager = {}
local DDZPlayerSpine = {}
SpineManager.TrackIndex = 0

function SpineManager.AddDDZPlayerSpine(spine, seatNum)
	DDZPlayerSpine[seatNum] = spine
end
function SpineManager.RemoveDDZPlayerSpine(seatNum)
	if DDZPlayerSpine[seatNum] then
		destroy(DDZPlayerSpine[seatNum].gameObject)
	end
end
function SpineManager.RemoveAllDDZPlayerSpine()
	for k,v in pairs(DDZPlayerSpine) do
		if IsEquals(v) then
			destroy(v.gameObject)
		end
	end
    DDZPlayerSpine = {}
end

function SpineManager.GetSpine(seatNum)
	return DDZPlayerSpine[seatNum]
end

function SpineManager.SwitchAnimation(spine, animation, animation2)
	if not spine or not spine.AnimationState then return end
	DDZPlayerSpine[seatNum].skeleton:SetSlotsToSetupPose()
    local spineEvent = spine.AnimationState:SetAnimation(0, animation, false)
    spineEvent.Complete = spineEvent.Complete + function()
            OBJ.AnimationState:SetAnimation(0, animation2, true)
    end
end

function SetSortingOrder(seatNum, sorting_num)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
    local m_Mr = spine:GetComponent("MeshRenderer")
    m_Mr.sortingOrder = sorting_num
end

function SpineManager.ChuPai(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "chupai" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "chupai", false)
	spineEvent.Complete = spineEvent.Complete + function()
			-- spine.skeleton:SetSlotsToSetupPose()
			spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "daiji", true)
        end
end

function SpineManager.BeiZha(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "beizha" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "beizha", false)
	spineEvent.Complete = spineEvent.Complete + function()
			-- spine.skeleton:SetSlotsToSetupPose()
			spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "daiji", true)
        end
end

function SpineManager.ZhaBieRen(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "zha_bie_ren" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "zha_bie_ren", false)
	spineEvent.Complete = spineEvent.Complete + function()
			-- spine.skeleton:SetSlotsToSetupPose()
			spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "daiji", true)
        end
end

function SpineManager.YaoBuQi(seatNum)
	--屏蔽要不起动画
	if true then return end
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "yao_bu_qi" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	--spine.AnimationState:ClearTracks()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "yao_bu_qi", false)
end

function SpineManager.Win(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "win" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	--spine.AnimationState:ClearTracks()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "win", true)
end

function SpineManager.Lose(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "lose" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	--spine.AnimationState:ClearTracks()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "lose", true)
end

function SpineManager.DaiJi(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "daiji" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	--spine.AnimationState:ClearTracks()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "daiji", true)
end

function SpineManager.CSDDZ(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "DDZ" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	--spine.AnimationState:ClearTracks()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "DDZ", true)
end

function SpineManager.CSMJ(seatNum)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
	if spine.AnimationName == "MJ" then return end
	-- spine.skeleton:SetSlotsToSetupPose()
	--spine.AnimationState:ClearTracks()
	local spineEvent = spine.AnimationState:SetAnimation(SpineManager.TrackIndex, "MJ", true)
end