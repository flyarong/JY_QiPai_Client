-- 创建时间:2019-12-24
-- 扩展消息监听机制

ExtPanel = {}
ExtPanel.ExtMsg = function (_self)
	if _self.lister then
		_self.AddMsgListener = function ()
			if not _self.ext_lister then
				_self.ext_lister = {}
				for k,v in pairs(_self.lister or {}) do
					local msg_name = k
					_self.ext_lister[msg_name] = function (...)
						if IsEquals(_self.gameObject) then
							_self.lister[msg_name](...)
						else
							dump(msg_name, "<color=red><size=40>EEE obj nil</size></color>")
							if _self.MyExit then
								_self:MyExit()
							end
						end
					end
					Event.AddListener(msg_name, _self.ext_lister[msg_name])
				end
			end
		end
		_self.RemoveListener = function ()
			if _self.ext_lister then
				for proto_name,func in pairs(_self.ext_lister) do
					Event.RemoveListener(proto_name, func)
				end
				_self.lister = {}
				_self.ext_lister = {}
			end
		end
	end

	_self.ext_my_exit = _self.MyExit
	_self.MyExit = function ()
		if not _self.gameObject then
			return
		end
		local dot_del_obj = _self.dot_del_obj
		local obj = _self.gameObject
		_self.gameObject = nil

		_self:ext_my_exit()
		-- local bclick = _self.transform:GetComponentsInChildren(typeof(UnityEngine.UI.Button), true)
		-- for i = 0, bclick.Length - 1 do
		-- 	bclick[i].onClick:RemoveAllListeners()
		-- end

		for k,v in pairs(_self) do
			if k ~= "MyExit" then					
				_self[k] = nil
			end
		end
		if not dot_del_obj then
			destroy(obj)
		end
		--Util.ClearMemory()
	end
end

