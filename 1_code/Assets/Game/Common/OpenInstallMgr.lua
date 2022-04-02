OpenInstallMgr = {}
local M = OpenInstallMgr

--拉起参数
function M.Initialization()
	if MainModel.UserInfo.parent_id then return end
	sdkMgr:OpenInstallInitialization()
	M.RemoveGetInstallFinishListener()
	M.AddGetInstallFinishListener()
	M.RemoveGetWakeupFinishListener()
	M.AddGetWakeupFinishListener()
end

--安装参数
function M.GetInstall()
	if MainModel.UserInfo.parent_id then return end
	sdkMgr:OpenInstallGetInstall()
end

function M.ReportRegister()
	if MainModel.UserInfo.parent_id then return end
	sdkMgr:OpenInstallReportRegister()
end

function M.ReportEffectPoint()
	if MainModel.UserInfo.parent_id then return end
	sdkMgr:OpenInstallReportEffectPoint()
end

function M.AddGetInstallFinishListener()
	if MainModel.UserInfo.parent_id then return end
	dump({},"<color=green>[OpenInstall]AddGetInstallFinishListener</color>")
	sdkMgr:OpenInstallAddGetInstallFinishListener(M.GetInstallFinish)
end

function M.RemoveGetInstallFinishListener()
	if MainModel.UserInfo.parent_id then return end
	sdkMgr:OpenInstallRemoveGetInstallFinishListener()
end

function M.AddGetWakeupFinishListener()
	if MainModel.UserInfo.parent_id then return end
	dump({},"<color=green>[OpenInstall]AddGetWakeupFinishListener</color>")
	sdkMgr:OpenInstallAddGetWakeupFinishListener(M.GetWakeupFinish)
end

function M.RemoveGetWakeupFinishListener()
	if MainModel.UserInfo.parent_id then return end
	sdkMgr:OpenInstallRemoveGetWakeupFinishListener()
end

--安装参数获取回调
function M.GetInstallFinish(json_data)
	if MainModel.UserInfo.parent_id then return end
	dump(json_data,"<color=green>[OpenInstall]GetInstallFinish</color>")
	local lua_data = json2lua(json_data)
	dump(lua_data,"<color=white>[OpenInstall] GetInstallFinish lua_data :</color>")
	if not lua_data or not lua_data.bindData then return end
	local bindData = json2lua(lua_data.bindData)
	dump(bindData,"<color=white>OpenInstall bindData</color>")
	if not bindData then return end
	Network.SendRequest("register_by_introducer", {parent_id = tostring(bindData.yqPlayerId)}, "请求数据")
end

--拉起参数获取回调
function M.GetWakeupFinish(json_data)
	if MainModel.UserInfo.parent_id then return end
	dump(json_data,"<color=green>[OpenInstall]GetWakeupFinish</color>")
end

