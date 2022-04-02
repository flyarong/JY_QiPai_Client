local basefunc = require "Game.Common.basefunc"

CPL_LJYJCFKPanel_wuziqi = basefunc.class()
local C = CPL_LJYJCFKPanel_wuziqi
C.name = "CPL_LJYJCFKPanel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
	local ui
	ui = base_self.transform:Find("Image (7)")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
	end
	ui = nil

	local lv1 = base_self.UIconfig.base[1].total
	local lv2 = base_self.UIconfig.base[2].total

	local  rate =  (lv2-1000)/(lv2-lv1)

	base_self.RefreshCurrText = function (base_self,data,show_hb)
		--dump(data,"<color=white>dtaaaaaaaaaaa</color>")
		--dump(lv1, "<color=white>lv1</color>")
        --dump(lv2, "<color=white>lv2</color>")

		local re = basefunc.parse_activity_data(data.other_data_str)
		if (tonumber(re.is_first_game) == 1 and data.now_lv == 1) or (tonumber(re.is_first_game) == 2 and data.now_lv == 2) then
			local  rate = (lv2-1000)/(lv2-lv1)
			if data.now_total_process < lv1 then
				base_self.curr_txt.text = "再赢金<color=#d52e2bff>".. StringHelper.ToCash((data.need_process - data.now_process)/30) .. "</color>，可抽取<color=#d52e2bff>" .. show_hb .. "福卡！</color>"
			elseif data.now_total_process >= lv1 and data.now_total_process < lv2 then
				base_self.curr_txt.text = "再赢金<color=#d52e2bff>".. StringHelper.ToCash(data.need_process +lv1 -1000 - (data.now_total_process - lv1)*rate) .. "</color>，可抽取<color=#d52e2bff>" .. show_hb .. "福卡！</color>"
			else
				base_self.curr_txt.text = "再赢金<color=#d52e2bff>".. StringHelper.ToCash(data.need_process - data.now_process) .. "</color>，可抽取<color=#d52e2bff>" .. show_hb .. "福卡！</color>"
			end
		else 
			base_self.curr_txt.text = "再赢金<color=#d52e2bff>".. StringHelper.ToCash(data.need_process - data.now_process) .. "</color>，可抽取<color=#d52e2bff>" .. show_hb .. "福卡！</color>"
		end
	end

	base_self.RefreshTempUIs = function (base_self,data,now_max_level,show_hb)
		local re = basefunc.parse_activity_data(data.other_data_str)
		if (tonumber(re.is_first_game) == 1 and data.now_lv == 1) or (tonumber(re.is_first_game) == 2 and data.now_lv == 2) then  
			if data.now_total_process <lv1 then
				base_self.temp_uis[now_max_level].qipao_txt.text = "再赢"..StringHelper.ToCash((data.need_process - data.now_process)/30) .."可抽取" .. show_hb .. "福卡"
			elseif data.now_total_process >= lv1 and data.now_total_process < lv2 then
				base_self.temp_uis[now_max_level].qipao_txt.text = "再赢"..StringHelper.ToCash(data.need_process +lv1 -1000 - (data.now_total_process - lv1)*rate) .."可抽取" .. show_hb .. "福卡"
			else
				base_self.temp_uis[now_max_level].qipao_txt.text = "再赢"..StringHelper.ToCash(data.need_process - data.now_process) .."可抽取" .. show_hb .. "福卡"
			end
		else 
			base_self.temp_uis[now_max_level].qipao_txt.text = "再赢"..StringHelper.ToCash(data.need_process - data.now_process) .."可抽取" .. show_hb .. "福卡"
		end
	end

	base_self.RefreshJUText = function (base_self,data,i,total)
		local re = basefunc.parse_activity_data(data.other_data_str)
		--dump(total)
		if i == 1 and ((tonumber(re.is_first_game) == 1 and data.now_lv == 1) or(tonumber(re.is_first_game) == 2 and data.now_lv == 2)) then   
			base_self.temp_uis[i].ju_txt.text = StringHelper.ToCash(total / 30)
		else 
			base_self.temp_uis[i].ju_txt.text = StringHelper.ToCash(total)
		end
	end
	base_self.MyRefresh(base_self)
	Event.Brocast("WZQGuide_Check",{guide = 3 ,guide_step =2})
end

return C.HandleInit