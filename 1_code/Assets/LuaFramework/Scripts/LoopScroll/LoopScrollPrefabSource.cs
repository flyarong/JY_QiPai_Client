using UnityEngine;
using System.Collections;
using LuaFramework;

namespace UnityEngine.UI
{
    [System.Serializable]
    public class LoopScrollPrefabSource 
    {
        public string prefabName;
        public int poolSize = 5;

        private bool inited = false;
        public virtual GameObject GetObject()
        {
            if(!inited)
            {
                LuaHelper.GetResManager().InitPool(prefabName, poolSize);
                inited = true;
            }
            return LuaHelper.GetResManager().GetObjectFromPool(prefabName);
        }
    }
}
