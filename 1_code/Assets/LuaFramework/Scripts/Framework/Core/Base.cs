using UnityEngine;
using System.Collections;
using LuaFramework;
using System.Collections.Generic;

public class Base : MonoBehaviour {
    private AppFacade m_Facade;
    private LuaManager m_LuaMgr;
    private ResourceManager m_ResMgr;
    private GameManager m_GameMgr;
    private NetworkManager m_NetMgr;
    private SoundManager m_SoundMgr;
    private TimerManager m_TimerMgr;
    private ThreadManager m_ThreadMgr;
    private ObjectPoolManager m_ObjectPoolMgr;
    private SDKManager m_SDKManager;
    private WebManager m_WebManager;
	private GestureManager m_GestureManager;

    /// <summary>
    /// 注册消息
    /// </summary>
    /// <param name="view"></param>
    /// <param name="messages"></param>
    protected void RegisterMessage(IView view, List<string> messages) {
        if (messages == null || messages.Count == 0) return;
        Controller.Instance.RegisterViewCommand(view, messages.ToArray());
    }

    /// <summary>
    /// 移除消息
    /// </summary>
    /// <param name="view"></param>
    /// <param name="messages"></param>
    protected void RemoveMessage(IView view, List<string> messages) {
        if (messages == null || messages.Count == 0) return;
        Controller.Instance.RemoveViewCommand(view, messages.ToArray());
    }

    protected AppFacade facade {
        get {
            if (m_Facade == null) {
                m_Facade = AppFacade.Instance;
            }
            return m_Facade;
        }
    }

    protected LuaManager LuaManager {
        get {
            if (m_LuaMgr == null) {
                m_LuaMgr = facade.GetManager<LuaManager>(ManagerName.Lua);
            }
            return m_LuaMgr;
        }
    }

    protected ResourceManager ResManager {
        get {
            if (m_ResMgr == null) {
                m_ResMgr = facade.GetManager<ResourceManager>(ManagerName.Resource);
            }
            return m_ResMgr;
        }
    }
    protected GameManager GaManager
    {
        get
        {
            if (m_GameMgr == null)
            {
                m_GameMgr = facade.GetManager<GameManager>(ManagerName.Game);
            }
            return m_GameMgr;
        }
    }

    protected NetworkManager NetManager {
        get {
            if (m_NetMgr == null) {
                m_NetMgr = facade.GetManager<NetworkManager>(ManagerName.Network);
            }
            return m_NetMgr;
        }
    }

    protected SoundManager SoundManager {
        get {
            if (m_SoundMgr == null) {
                m_SoundMgr = facade.GetManager<SoundManager>(ManagerName.Sound);
            }
            return m_SoundMgr;
        }
    }

    protected TimerManager TimerManager {
        get {
            if (m_TimerMgr == null) {
                m_TimerMgr = facade.GetManager<TimerManager>(ManagerName.Timer);
            }
            return m_TimerMgr;
        }
    }

    protected ThreadManager ThreadManager {
        get {
            if (m_ThreadMgr == null) {
                m_ThreadMgr = facade.GetManager<ThreadManager>(ManagerName.Thread);
            }
            return m_ThreadMgr;
        }
    }

    protected ObjectPoolManager ObjPoolManager {
        get {
            if (m_ObjectPoolMgr == null) {
                m_ObjectPoolMgr = facade.GetManager<ObjectPoolManager>(ManagerName.ObjectPool);
            }
            return m_ObjectPoolMgr;
        }
    }

    protected SDKManager SDKManager {
        get {
            if (m_SDKManager == null) {
                m_SDKManager = facade.GetManager<SDKManager>(ManagerName.SDK);
            }
            return m_SDKManager;
        }
    }
    protected WebManager WebManager
    {
        get
        {
            if (m_WebManager == null)
            {
                m_WebManager = facade.GetManager<WebManager>(ManagerName.WEB);
            }
            return m_WebManager;
        }
    }
    
}
