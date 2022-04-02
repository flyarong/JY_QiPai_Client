using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using System;
using UnityEngine.UI;

namespace LuaFramework
{
    public static class LuaHelper
    {

        /// <summary>
        /// getType
        /// </summary>
        /// <param name="classname"></param>
        /// <returns></returns>
        public static System.Type GetType(string classname)
        {
            Assembly assb = Assembly.GetExecutingAssembly();  //.GetExecutingAssembly();
            System.Type t = null;
            t = assb.GetType(classname); ;
            if (t == null)
            {
                t = assb.GetType(classname);
            }
            return t;
        }

        /// <summary>
        /// 面板管理器
        /// </summary>
        public static PanelManager GetPanelManager()
        {
            return AppFacade.Instance.GetManager<PanelManager>(ManagerName.Panel);
        }

        /// <summary>
        /// 资源管理器
        /// </summary>
        public static ResourceManager GetResManager()
        {
            return AppFacade.Instance.GetManager<ResourceManager>(ManagerName.Resource);
        }

        /// <summary>
        /// 网络管理器
        /// </summary>
        public static NetworkManager GetNetManager()
        {
            return AppFacade.Instance.GetManager<NetworkManager>(ManagerName.Network);
        }

        /// <summary>
        /// 音乐管理器
        /// </summary>
        public static SoundManager GetSoundManager()
        {
            return AppFacade.Instance.GetManager<SoundManager>(ManagerName.Sound);
        }

        public static SDKManager GetSDKManager(){
            //var sdk = AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK);
            return AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK);
        }

		public static GameManager GetGameManager(){
			return AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
		}
        public static WebManager GetWebManager()
        {
            return AppFacade.Instance.GetManager<WebManager>(ManagerName.WEB);
        }
		public static GestureManager GetGestureManager() {
			return AppFacade.Instance.GetManager<GestureManager> (ManagerName.GestureManager);
		}
		public static LuaManager GetLuaManager() {
			return AppFacade.Instance.GetManager<LuaManager> (ManagerName.Lua);
		}

        
        /// <summary>
        /// pbc/pblua函数回调
        /// </summary>
        /// <param name="func"></param>
        public static void OnCallLuaFunc(LuaByteBuffer data, LuaFunction func)
        {
            if (func != null) func.Call(data);
            Debug.LogWarning("OnCallLuaFunc length:>>" + data.buffer.Length);
        }

        /// <summary>
        /// cjson函数回调
        /// </summary>
        /// <param name="data"></param>
        /// <param name="func"></param>
        public static void OnJsonCallFunc(string data, LuaFunction func)
        {
            Debug.LogWarning("OnJsonCallback data:>>" + data + " lenght:>>" + data.Length);
            if (func != null) func.Call(data);
        }

        /// <summary>
        /// 通过节点名称，自动生成变量和节点的绑定关系
        /// @name_type
        /// </summary>
        /// <param name="parent"></param>
        /// <param name="table"></param>
        public static LuaTable GeneratingVar(Transform parent, LuaTable table = null)
        {
            if (table == null)
            {
                LuaManager mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
                if (mgr != null)
                {
                    table = mgr.NewLuaTable();
                }
            }

            if (table == null)
            {
                Debug.LogError("create lua table faild!!!");
                return null;
            }

            int count = parent.childCount;

            List<string> list_name = new List<string>();
            for (int i = 0; i < count; i++)
            {
                Transform tran = parent.GetChild(i);
                if (tran.childCount > 0)
                    GeneratingVar(tran, table);

                if (tran.name.StartsWith("@") == false)
                    continue;

                string str = tran.name;
                str = str.Remove(0, 1);
                if (list_name.Contains(str))
                {
                    Debug.LogErrorFormat("name={0} is exist!!!", str);
                }
                else
                {
                    list_name.Add(str);
                }

                string[] array = str.Split('_');
                string type_str = "";
                if (array.Length >= 2)
                    type_str = array[array.Length - 1];
                Type type = null;
                switch (type_str)
                {
                    case "img": type = typeof(Image); break;
                    case "txt": type = typeof(Text); break;
                    case "ipf": type = typeof(InputField); break;
                    case "btn": type = typeof(Button); break;
                    case "tge": type = typeof(Toggle); break;
                    default: break;
                }

                if (type != null)
                {
                    var c = tran.GetComponent(type);
                    table[str] = c;
                }
                else
                {
                    table[str] = tran;
                }
            }

            return table;
        }

         /// <summary>
        /// 通过节点名称，自动生成变量和节点的绑定关系
        /// @name_type
        /// </summary>
        /// <param name="parent"></param>
        /// <param name="table"></param>
        public static LuaTable GetComponentsInChildrenParticle(Transform parent, LuaTable table = null)
        {
            if (table == null)
            {
                LuaManager mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
                if (mgr != null)
                {
                    table = mgr.NewLuaTable();
                }
            }

            if (table == null)
            {
                Debug.LogError("create lua table faild!!!");
                return null;
            }

            ParticleSystem[] ps = parent.transform.GetComponentsInChildren<ParticleSystem>();

            for (int i = 1; i <= ps.Length; i++)
            {
                table[i] = ps[i - 1];
            }

            return table;
        }
        public static LuaTable MyScreenPointToLocalPointInRectangle(RectTransform rect, Vector2 screenPoint, Camera cam)
        {
            Vector2 p=new Vector2(0,0);
            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(rect,screenPoint,cam,out p))
            {   
                LuaTable table;
                LuaManager mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
                if (mgr != null)
                {
                    table = mgr.NewLuaTable();
                    table["x"]=p.x;
                    table["y"]=p.y;
                    return table;
                }

                return null;
            }
            return null;
        }

        //--------------iOS 内购---------------
        public static void AddInAppPurchasing()
        {
#if UNITY_ANDROID
#elif UNITY_IOS
            AppFacade.Instance.AddManager<InAppPurchasing>(ManagerName.InAppPurchasing);
#endif

        }

        public static void InitInAppPurchasing(LuaTable idTable)
        {
#if UNITY_ANDROID
#elif UNITY_IOS

            List<String> idList = new List<string>();
            for (int i = 1; i <= idTable.Length; i++)
            {
                idList.Add(idTable[i].ToString());
            }

            InAppPurchasing.instance.StartUnityPurchase(idList);
#endif
        }

        public static InAppPurchasing GetInAppPurchasing()
        {
            return AppFacade.Instance.GetManager<InAppPurchasing>(ManagerName.InAppPurchasing);
        }

        public static void RegistluaPurchaseCallback(LuaFunction func){
            luaPurchaseCallback = func;
        }

		private static LuaFunction luaPurchaseCallback = null;
		public static void OnPurchaseCallback(string receipt, string transactionID, string definition_id) {
			if (luaPurchaseCallback != null) {
				luaPurchaseCallback.Call (receipt, transactionID, definition_id);
			} else {
				Debug.LogError ("[IOS] OnPurchaseClicked luaPurchaseCallback is null");
			}
		}
         public static bool OnPurchaseClicked(String purchaseId,LuaFunction func)
        {
#if UNITY_ANDROID
			return false;
#elif UNITY_IOS
			luaPurchaseCallback = func;
			return InAppPurchasing.instance.OnPurchaseClicked(purchaseId);
#else
			return false;
#endif
        }

        public static void APPSeverConfirmPendingPurchase(string definition_id)
        {
#if UNITY_ANDROID
			
#elif UNITY_IOS
		InAppPurchasing.instance.APPSeverConfirmPendingPurchase(definition_id);
#endif
        }

        //网络延迟相关
        public static LuaFunction deferredFunc;
        public static void AddDeferred(LuaFunction func)
        {
#if UNITY_ANDROID
#elif UNITY_IOS
           deferredFunc = func;
#endif
        }

        public static void OnDeferred()
        {
#if UNITY_ANDROID
#elif UNITY_IOS
           if (deferredFunc != null) deferredFunc.Call();
#endif
        }

        //手机设置了禁止APP内购
        public static LuaFunction purchasingUnavailableFunc;
        public static void AddPurchasingUnavailable(LuaFunction func)
        {
#if UNITY_ANDROID
#elif UNITY_IOS
           purchasingUnavailableFunc = func;
#endif
        }

        public static void OnPurchasingUnavailable()
        {
#if UNITY_ANDROID
#elif UNITY_IOS
           if (purchasingUnavailableFunc != null) deferredFunc.Call();
#endif
        }

          //购买失败
        public static LuaFunction purchaseFailedFunc;
        public static void AddPurchaseFailed(LuaFunction func)
        {
#if UNITY_ANDROID
#elif UNITY_IOS
           purchaseFailedFunc = func;
#endif
        }

        public static void OnPurchaseFailed()
        {
#if UNITY_ANDROID
#elif UNITY_IOS
           if (purchaseFailedFunc != null) deferredFunc.Call();
#endif
        }
        //------------------------------------

        public static string GetRuntimePlatform(){
			if(Application.platform == RuntimePlatform.IPhonePlayer
            || Application.platform == RuntimePlatform.tvOS)
                return "Ios";
            else if(Application.platform == RuntimePlatform.Android)
				return "Android";
            else if(Application.platform == RuntimePlatform.WindowsEditor)
                return "WindowsEditor";
            else
                return "";
		}

        //-------------软裁剪-------------------
        public static void SoftClipFactors(Transform content, Vector2 softArgs,Vector2 direction , float depth = 1, float force = 1){
            SoftClipHelper.Instance.SetSoftClipFactors(content,softArgs,direction,depth,force);
        }

        public static ShowFPS fpsObj;
        public static void OnPing(float ping){
            if (fpsObj == null) {
                fpsObj =  GameObject.FindObjectOfType<ShowFPS>();
            }
            fpsObj.ping = ping;
        }
    }
}