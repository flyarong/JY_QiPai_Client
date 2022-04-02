using UnityEngine;
using System.Collections;
using LuaFramework;

public class StartUpCommand : ControllerCommand {

    public override void Execute(IMessage message) {
        //if (!Util.CheckEnvironment()) return;

        GameObject gameMgr = GameObject.Find("GlobalGenerator");
        if (gameMgr != null) {
            AppView appView = gameMgr.AddComponent<AppView>();
        }
        //-----------------关联命令-----------------------
        //AppFacade.Instance.RegisterCommand(NotiConst.DISPATCH_MESSAGE, typeof(SocketCommand));

        //-----------------初始化管理器-----------------------
        AppFacade.Instance.AddManager<ResourceManager>(ManagerName.Resource);
        AppFacade.Instance.AddManager<ThreadManager>(ManagerName.Thread);
		AppFacade.Instance.AddManager<DownloadManager>(ManagerName.Download);
		AppFacade.Instance.AddManager<EventManager> (ManagerName.EventManager);
        AppFacade.Instance.AddManager<GameManager>(ManagerName.Game);
		AppFacade.Instance.AddManager<SDKManager>(ManagerName.SDK);
	
		GameManager mgr = AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
		if(mgr)
			mgr.gameObject.AddComponent<GPS> ();
    }
}