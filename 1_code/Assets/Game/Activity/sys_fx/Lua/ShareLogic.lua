ShareLogic = {}
local M = ShareLogic

--手动分享方式
M.share_type_me = false

local lister
local function AddLister()
	lister={}
	lister["screen_shot_end"] = M.screen_shot_end

	for proto_name,func in pairs(lister or {}) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveLister()
	for msg,cbk in pairs(lister or {}) do
		Event.RemoveListener(msg, cbk)
	end
	lister=nil
end

function M.Init()
	AddLister()
end

function M.Exit()
	RemoveLister()
end

local function HandleSDKShareCallback(json_data)
	local parm_lua = json2lua(json_data)
	if parm_lua == nil then
		print(string.format("[Share] result invalid"))
		return
	end
	if parm_lua.result == 0 then
		--分享完成
		M.ShareFinish()
	elseif parm_lua.result < 0 then
		if parm_lua.result == -5 then
			if parm_lua.errno == -2 then
				HintPanel.ErrorMsg(3046)
			else
				local channel = MainModel.LoginInfo.channel_type or ""
				HintPanel.Create(1, "分享异常(" .. channel .. ":" .. parm_lua.errno .. ")")
			end
		elseif parm_lua.result == -8 then
			HintPanel.ErrorMsg(3046)
		else
			HintPanel.ErrorMsg(parm_lua.result)
		end
	end
end

function M.ShareUrl(share_cfg,finish_parm)
	dump(share_cfg,"<color=white>share_cfg</color>")
	if not share_cfg then
		LittleTips.Create(string.format("分享配置错误"))
		dump(share_cfg,"<color=white>分享配置</color>")
		return
	end

	if share_cfg.type ~= 3 then
		LittleTips.Create(string.format("分享类型错误%s",share_cfg.type))
		print("<color=green>分享类型</color>",share_cfg.type)
		return
	end
	
	--默认分享到微信群
	if share_cfg.isCircleOfFriends == nil then
		share_cfg.isCircleOfFriends = false
	end

	M.share_cfg = share_cfg
	M.finish_parm = finish_parm

	if AppDefine.IsEDITOR() then
		Application.OpenURL(M.share_cfg.url);
		--分享完成
		M.ShareFinish()
		return
	end

	if not M.share_cfg.icon then
		M.share_cfg.icon = ShareHelper.GetImagePath()
	end
	local parm = lua2json(M.share_cfg)
	dump(parm,"<color=yellow>分享数据</color>")
	sdkMgr:Share(parm, function (json_data)
		HandleSDKShareCallback(json_data)
	end)
end

function M.ShareImage(share_cfg,finish_parm)
	dump(share_cfg,"<color=white>分享配置</color>")
	if not share_cfg then
		LittleTips.Create(string.format("分享配置错误"))
		return
	end

	if share_cfg.type ~= 7 then
		LittleTips.Create(string.format("分享类型错误%s",share_cfg.type))
		print("<color=green>分享类型</color>",share_cfg.type)
		return
	end

	--默认分享到微信群
	if share_cfg.isCircleOfFriends == nil then
		share_cfg.isCircleOfFriends = false
	end

	M.share_cfg = share_cfg
	M.finish_parm = finish_parm

	--截图分享方式
	if type(share_cfg.share_img) == "string" and share_cfg.share_img == "ScreenShot" then
		--全屏截图
		ShareHelper.ScreenShot(nil, share_cfg.rect)
	else
		--分享小图
		ShareImage.Create(share_cfg)
	end
end

function M.screen_shot_end()
	if not M.share_cfg then
		print("<color=white>share_cfg is nil</color>")
		return 
	end

	if AppDefine.IsEDITOR() then
		--sdk 分享方式 1:自己手动分享 2:使用微信sdk分享
		if M.share_type_me then
			HintPanel.Create(1,"已成功将图片保存到相册，请前往微信打开相册进行分享",function (  )
				ShareHelper.OpenWeChat()
				--分享完成
				M.ShareFinish()
			end)
			return
		end
		ShareHelper.OpenWeChat()
		--分享完成
		M.ShareFinish()
		return
	end

	--sdk 分享方式 1:自己手动分享 2:使用微信sdk分享
	if M.share_type_me then
		HintPanel.Create(1,"已成功将图片保存到相册，请前往微信打开相册进行分享",function (  )
			ShareHelper.OpenWeChat()
			--分享完成
			M.ShareFinish()
		end)
		return
	end

	if not M.share_cfg.imgFile then
		M.share_cfg.imgFile = ShareHelper.GetImagePath()
		dump(M.share_cfg.imgFile,"<color=white>保存的图片位置</color>")
	end
	if M.share_cfg.rect then
		M.share_cfg.rect = nil
	end
	local parm = lua2json(M.share_cfg)
	dump(parm,"<color=yellow>分享数据</color>")
	sdkMgr:Share(parm, function (json_data)
		HandleSDKShareCallback(json_data)
	end)
end

--分享完成
function M.ShareFinish()
	dump( {share_cfg = M.share_cfg,finish_parm = M.finish_parm},"<color=green>分享完成</color>")
	if not M.share_cfg then 
		return
	end

	if not M.share_cfg.finish_type then
		if M.share_cfg.isCircleOfFriends == true then
			M.share_cfg.finish_type = "shared_timeline"
		else
			M.share_cfg.finish_type = "shared_friend"
		end
	end

	ShareModel.SendShareFinish(M.share_cfg,M.finish_parm)
	M.share_cfg = nil
	M.finish_parm = nil
end