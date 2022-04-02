ShareModel = {}
local M = ShareModel

function M.ReqGetShareUrl(share_cfg)
	dump(share_cfg,"<color=white>ReqGetShareUrl 分享配置</color>")
	if not share_cfg then
		LittleTips.Create(string.format("分享配置错误"))
		return
	end

	if share_cfg.type ~= 7 then
		LittleTips.Create(string.format("分享类型错误%s",share_cfg.type))
		print("<color=green>分享类型</color>",share_cfg.type)
		return
	end

	if AppDefine.IsEDITOR() then
		M.data = M.data or {}
		M.data[share_cfg.share_source] = "www.baidu.com"
		local _share_cfg = basefunc.deepcopy(share_cfg)
		_share_cfg.url = M.data[share_cfg.share_source]
		--获取url完成
		Event.Brocast("get_share_url_response",_share_cfg)
		return
	end

	local callback = function(data)
		dump({data = data,share_cfg = share_cfg},"<color=white>获取二维码</color>")
		if data.result ~= 0 then
			LittleTips.Create(errorCode[data.result])
			return
		end
		M.data = M.data or {}
		M.data[share_cfg.share_source] = data.share_url
		local _share_cfg = basefunc.deepcopy(share_cfg)
		_share_cfg.url = M.data[share_cfg.share_source]
		--获取url完成
		Event.Brocast("get_share_url_response",_share_cfg)
	end

	--获取url
	if not Network.SendRequest("get_share_url", {share_source = share_cfg.share_type,category = share_cfg.category or 1}, "",callback) then
		M.data = M.data or {}
		M.data[share_cfg.share_source] = nil
	end
end

function M.GetShareUrl(share_cfg)
	if not share_cfg then
		print(string.format("<color=white>share_cfg is nil</color>"))
		return
	end
	if not share_cfg.share_source then
		print(string.format("<color=white>share_source is nil</color>"))
		return
	end
	if not M.data or not M.data[share_cfg.share_source] then
		print(string.format("<color=white>%s url is nil</color>", share_cfg.share_source))
		return
	end
	return M.data[share_cfg.share_source]
end

M.EverydaySharedAwardType = {
	shared_timeline = "shared_timeline",
	shared_friend = "shared_friend",
}
--[[
    @desc: 
    author:{author}
    time:2020-10-11 09:05:07
    --@finish_type: shared_timeline 朋友圈，shared_friend 微信好友
    @return:
]]
function M.ReqQueryEverydaySharedAward(finish_type,parm)
	if not finish_type then
		print("<color=red>ReqQueryEverydaySharedAward error : finish_type is nil</color>")
		return
	end
	Network.SendRequest("query_everyday_shared_award", {type=finish_type}, function (_data)  
		if _data.result == 0 then
			M.share_award_status = M.share_award_status or {}
			M.share_award_status[finish_type] = _data.status
		else
			M.share_award_status = M.share_award_status or {}
			M.share_award_status[finish_type] = nil
		end
		Event.Brocast("query_everyday_shared_award_response",{type = finish_type,status = M.share_award_status[finish_type],parm = parm})
	end)
end

function M.GetQueryEverydaySharedAward(finish_type)
	if not M or not M.share_award_status or not M.share_award_status[finish_type] then
		return
	end
	return M.share_award_status[finish_type]
end

-- 发送分享完成
function M.SendShareFinish(share_cfg,finish_parm)
	local finish_type = share_cfg.finish_type
	if not finish_type then
		print("<color=red>SendShareFinish error : finish_type is nil</color>")
		return
	end
	if finish_type == "match_signup" then
		if finish_parm and finish_parm.cfg then
			--比赛场报名
			Network.SendRequest("shared_finish", {game_id = finish_parm.cfg.game_id}, "",function (data)
				if data.result == 0 then
					data.share_cfg = share_cfg
					data.finish_parm = finish_parm
					Event.Brocast("shared_finish_response",data)
				else
					LittleTips.Create(errorCode[data.result])
				end
			end)
		else
			dump(finish_parm,"<color=white>数据错误：</color>")
		end
	else
		--其它分享
		Network.SendRequest("shared_finish", {type = finish_type}, "",function(data)
			if data.result == 0 then
				M.share_award_status = M.share_award_status or {}
				M.share_award_status[finish_type] = nil
				data.share_cfg = share_cfg
				data.finish_parm = finish_parm
				Event.Brocast("shared_finish_response",data)
				--更新数据
				M.ReqQueryEverydaySharedAward(finish_type)
			else
				LittleTips.Create(errorCode[data.result])
			end
		end)
	end
end
