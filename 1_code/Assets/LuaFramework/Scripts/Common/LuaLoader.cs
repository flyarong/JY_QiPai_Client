using UnityEngine;
using System.Collections;
using System.IO;
using LuaInterface;

namespace LuaFramework
{
    /// <summary>
    /// 集成自LuaFileUtils，重写里面的ReadFile，
    /// </summary>
    public class LuaLoader : LuaFileUtils
    {
        private ResourceManager m_resMgr;

        ResourceManager resMgr
        {
            get
            {
                if (m_resMgr == null)
                    m_resMgr = AppFacade.Instance.GetManager<ResourceManager>(ManagerName.Resource);
                return m_resMgr;
            }
        }

        // Use this for initialization
        public LuaLoader()
        {
            instance = this;
            beZip = AppConst.LuaBundleMode;
        }

        /// <summary>
        /// 添加打入Lua代码的AssetBundle
        /// </summary>
        /// <param name="bundle"></param>
        public void AddBundle(string bundleName)
        {
            
			bool hasExist = RemBundle (bundleName);
			AssetBundle bundle = resMgr.ReloadBundle (bundleName, !hasExist);
			if (bundle != null) {
				bundleName = bundleName.Replace ("lua/", "").Replace (".unity3d", "");
				base.AddSearchBundle (bundleName.ToLower (), bundle);
			} else
				Debug.LogWarning ("[AssetBundle] AddBundle for Lua error: Can't find bundle: " + bundleName);
			
			/*string url = resMgr.DataPath + bundleName.ToLower();
			if (File.Exists(url))
            {
				bool hasExist = RemBundle (bundleName);
				AssetBundle bundle = resMgr.ReloadBundle (bundleName, !hasExist);
				if (bundle != null) {
					bundleName = bundleName.Replace ("lua/", "").Replace (".unity3d", "");
					base.AddSearchBundle (bundleName.ToLower (), bundle);
				} else
					Debug.LogError ("[AssetBundle] AddBundle for Lua error: Can't find bundle " + url);
            }*/
        }
		public bool RemBundle(string bundleName) {
			bundleName = bundleName.Replace("lua/", "").Replace(".unity3d", "");
			return base.RemSearchBundle (bundleName);
		}

        /// <summary>
        /// 当LuaVM加载Lua文件的时候，这里就会被调用，
        /// 用户可以自定义加载行为，只要返回byte[]即可。
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public override byte[] ReadFile(string fileName)
        {
            //Debug.Log("Lua ReadFile=>" + fileName);
            return base.ReadFile(fileName);
        }
    }
}