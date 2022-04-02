using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;

public class EnterMainCommand : ControllerCommand {

	public override void Execute(IMessage message) {
		//-----------------关联命令-----------------------
		//AppFacade.Instance.RegisterCommand(NotiConst.DISPATCH_MESSAGE, typeof(SocketCommand));

		//-----------------初始化管理器-----------------------
		AppFacade.Instance.AddManager<LuaManager>(ManagerName.Lua);
		AppFacade.Instance.AddManager<PanelManager>(ManagerName.Panel);
		AppFacade.Instance.AddManager<SoundManager>(ManagerName.Sound);
		AppFacade.Instance.AddManager<TimerManager>(ManagerName.Timer);
		AppFacade.Instance.AddManager<NetworkManager>(ManagerName.Network);
        AppFacade.Instance.AddManager<WebManager>(ManagerName.WEB);
        AppFacade.Instance.AddManager<ObjectPoolManager>(ManagerName.ObjectPool);
		AppFacade.Instance.AddManager<GestureManager> (ManagerName.GestureManager);

		LuaManager luaManager = AppFacade.Instance.GetManager<LuaManager> (ManagerName.Lua);
		if (luaManager) {
			luaManager.InitStart ();
			luaManager.RegisterBundle ("common/common.unity3d");
			luaManager.RegisterBundle ("framework/framework.unity3d");
			luaManager.RegisterBundle ("sproto/sproto.unity3d");
			luaManager.RegisterBundle ("commonprefab/commonprefab_lua.unity3d");

			luaManager.RegisterBundle ("game_loding/game_loding_lua.unity3d");

			luaManager.DoFile ("Game/Framework/MainLogic");
		}
		NetworkManager netManager = AppFacade.Instance.GetManager<NetworkManager> (ManagerName.Network);
		if (netManager) {
			netManager.OnInit ();
		}
		Util.CallMethod ("MainLogic", "Init");
	}
}
