using UnityEngine;
using System.Collections;
using DG.Tweening;

namespace LuaFramework
{

    /// <summary>
    /// </summary>
    public class Main : MonoBehaviour
    {
		void Awake() {
			DontDestroyOnLoad (this);
			Application.targetFrameRate = 60;
            DOTween.Init(true, true);
        }

        void Start()
        {
            AppFacade.Instance.StartUp();   //启动游戏
        }

        //焦点转移
        void OnApplicationFocus(bool isFocus)
        {
// #if UNITY_EDITOR
// #else
            //if (isFocus)
            //{
            //    Debug.LogFormat("OnApplicationFocus :{0}", isFocus);
            //    Util.CallMethod("MainModel", "OnForeGround");
            //}
            //else
            //{
            //    Debug.LogFormat("OnApplicationFocus :{0}", isFocus);
            //    Util.CallMethod("MainModel", "OnBackGround");
            //}
// #endif
        }

        //前后台
        void OnApplicationPause(bool isPause)
        {
            if(isPause)
            {
                Debug.LogErrorFormat("OnApplicationPause :{0}", isPause);
                Util.CallMethod("MainModel", "OnBackGround");
            }
            else
            {
                Debug.LogErrorFormat("OnApplicationPause :{0}", isPause);
                Util.CallMethod("MainModel", "OnForeGround");
            }

			GameManager gameMgr = AppFacade.Instance.GetManager<GameManager> (ManagerName.Game);
			if (gameMgr) {
				if (isPause)
					gameMgr.HandleOnBackGround ();
				else
					gameMgr.HandleOnForeGround ();
			}
        }

    }
}