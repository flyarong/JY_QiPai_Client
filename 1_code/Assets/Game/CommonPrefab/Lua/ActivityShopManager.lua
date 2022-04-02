-- 创建时间:2019-06-03


ActivityShopManager = {}

-- 礼包
function ActivityShopManager.Create(gift_id, parent, backcall)
	if gift_id == 8 then
		ActivityShop10Panel.Create(parent, backcall)
	elseif gift_id == 10 then
		GameShop1YuanPanel.Create(parent, backcall)
	elseif gift_id == 11 then
		ActivityShop11Panel.Create(parent, backcall)
	elseif gift_id == 13 then
		GameManager.GotoUI({gotoui = "gift_13",goto_scene_parm = "panel",parent = parent,backcall = backcall})
	elseif gift_id == 20 then
		ActivityShop14Panel.Create(parent, backcall)
	elseif gift_id == 21 then
		ActivityShop15Panel.Create(parent, backcall)
	elseif gift_id == 29 then
		ActivityShop16Panel.Create(parent, backcall)
	elseif gift_id == 35 then
		ActivityShop17Panel.Create(parent, backcall)
	elseif gift_id == 38 then
		ActivityShop18Panel.Create(parent, backcall)
	elseif gift_id == 41 or gift_id == 42 then
		ActivityShop20Panel.Create(parent, backcall)
	elseif gift_id == 73 then
		ActivityShopDWPanel.Create(parent, backcall)
	elseif gift_id == 75 then
		ActivityShop88Panel.Create(parent, backcall)
	elseif gift_id == 74 then
		GameManager.GotoUI({gotoui = "gift_74",goto_scene_parm = "panel",parent = parent,backcall = backcall})
	elseif gift_id == 101 then
		ActivityShop101Panel.Create(parent, backcall)
	elseif gift_id == 102 then
		ActivityShop102Panel.Create(parent, backcall)
	elseif gift_id == 106 then
		ActivityShop106Panel.Create(parent, backcall)
	elseif gift_id == 10006 then
		ShopSummerPanel.Create(parent, backcall)
	elseif gift_id == 10007 then
		ActivityShop10007Panel.Create(parent, backcall)
	elseif gift_id == 10008 then
		ActivityShop10008Panel.Create(parent, backcall)	
	elseif gift_id == 10009 then
		ActivityShop10009Panel.Create(parent, backcall)
	elseif gift_id == 10010 then
		ActivityShop10010Panel.Create(parent, backcall)
	elseif gift_id == 10012 then
		ActivityShop10012Panel.Create(parent, backcall)
	else
		print("<color=red>商品不存在 gift_id = " .. gift_id .. "</color>")
	end
end

-- 检查是否显示
function ActivityShopManager.ActivityShopManager(gift_id)
	return MainModel.GetGiftShopShowByID(gift_id)
end

