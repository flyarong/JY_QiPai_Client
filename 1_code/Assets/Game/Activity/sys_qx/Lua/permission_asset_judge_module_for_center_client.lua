local basefunc = require "Game/Common/basefunc"

local permission_asset_judge_module_for_center_client = {}

local C = permission_asset_judge_module_for_center_client

function C.judeg_condition_asset( _asset_key , _condition_data )
	local asset_num = GameItemModel.GetItemCount(_asset_key)
	return basefunc.compare_value( asset_num , _condition_data.value , _condition_data.judge )
end

return C