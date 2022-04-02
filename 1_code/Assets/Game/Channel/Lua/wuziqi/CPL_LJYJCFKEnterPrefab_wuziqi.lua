local basefunc = require "Game.Common.basefunc"

CPL_LJYJCFKEnterPrefab_wuziqi = basefunc.class()
local C = CPL_LJYJCFKEnterPrefab_wuziqi
C.name = "CPL_LJYJCFKEnterPrefab_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    base_self.RefreshNumText = function(base_self, data , base1 ,base2)
        --dump(data, "<color=white>dataaaaaaaaaaaaaaaaaaa</color>")
        local re = basefunc.parse_activity_data(data.other_data_str)

        local lv1 = base1.total
        local lv2 = base2.total


        -- dump(lv1, "<color=white>lv1</color>")
        -- dump(lv2, "<color=white>lv2</color>")

        local rate = (lv2-1000)/(lv2-lv1)

        local cur_score_mormal = StringHelper.ToCash(data.now_total_process)
        local cur_score_1 = StringHelper.ToCash( StringHelper.GetPreciseDecimal(Mathf.Floor(data.now_total_process  / 30 + 0.5),1))
        local cur_score_2 = StringHelper.ToCash( StringHelper.GetPreciseDecimal(Mathf.Floor((data.now_total_process - lv1)*rate + lv1/ 30 + 0.5 ),1))

        local cur_need_normal = StringHelper.ToCash(data.need_process + data.now_total_process - data.now_process)
        local cur_need_1 =StringHelper.ToCash(StringHelper.GetPreciseDecimal((data.need_process + data.now_total_process - data.now_process) / 30,0))

        local cur_need
        local cur_score

        cur_need = (tonumber(re.is_first_game) == 1 and data.now_lv == 1) and cur_need_1 or cur_need_normal

        if (tonumber(re.is_first_game) == 1 and data.now_lv == 1) or  (tonumber(re.is_first_game) == 2 and data.now_lv == 2) then
            if data.now_total_process <= lv1 then
                cur_score = cur_score_1
            elseif  lv1< data.now_total_process and data.now_total_process <= lv2 then
                cur_score = cur_score_2
            else
                cur_score = cur_score_mormal
            end

        else
            cur_score = cur_score_mormal
        end

        -- dump(cur_score_2,"<color=white>cur_score_2</color>")
        -- dump(cur_score_1,"<color=white>cur_score_1</color>")

        base_self.num_txt.text = cur_score .. "/" .. cur_need

    end
    base_self.MyRefresh(base_self)
end

return C.HandleInit