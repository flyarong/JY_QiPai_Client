using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using UnityEngine.UI;
using LuaInterface;

namespace LuaFramework
{
    public class PanelManager : Manager
    {
        private Dictionary<string, GameObject> panelCacheDic = new Dictionary<string, GameObject>();
        private string curPanel;
        private Transform parent;

        Transform Parent
        {
            get
            {
                if (parent == null)
                {
                    GameObject go = GameObject.Find("Canvas/GUIRoot");
                    if (go != null)
                        parent = go.transform;
                }
                return parent;
            }
        }

        GameObject InstantiateGo(GameObject prefab, Transform p, bool isCache, LuaFunction func, LuaTable params_table)
        {
            GameObject go = Instantiate(prefab, p) as GameObject;
            go.name = prefab.name;
            go.layer = LayerMask.NameToLayer("Default");
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            LuaBehaviour luaBehaviour = null;
            luaBehaviour = go.GetComponent<LuaBehaviour>();
            if (luaBehaviour == null)
            {
                Debug.LogError("LuaBehaviour is not exist!!!");
            }
            luaBehaviour.SetParams(params_table);
            // if (isCache)
            // {
            //     if (panelCacheDic.ContainsKey(go.name))
            //         Debug.LogErrorFormat("go.name={0} is exist!!!", go.name);
            //     else
            //         panelCacheDic[go.name] = go;
            // }

            if (func != null)
                func.Call(go);

            return go;
        }

        /// <summary>
        /// 激活的1个已经存在的对象
        /// </summary>
        /// <param name="go"></param>
        /// <param name="callback"></param>
        /// <param name="params_table"></param>
        void ActiveGameObject(GameObject go, LuaFunction callback, LuaTable params_table)
        {
            go.SetActive(true);
            go.transform.SetAsLastSibling();
            if (callback != null)
            {
                callback.Call(go);
            }
            //var luaBehaviour = go.GetComponent<LuaBehaviour>();
            //luaBehaviour.SetParams(params_table);
            //Util.CallMethod(luaBehaviour.luaTableName, "Start", luaBehaviour.GetLuaTable());
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="panel_name"></param>
        /// <param name="func"></param>
        /// <param name="isCache"></param>
        /// <param name="params_table">创建面板是需要传递的参数</param>
        public void CreatePanel(string panel_name, LuaFunction func, bool isCache, LuaTable params_table)
        {
            //if (panelCacheDic.ContainsKey(panel_name))
            //{
            //    var cache_go = panelCacheDic[panel_name];
            //    ActiveGameObject(cache_go, func, params_table);
            //    return;
            //}
            var trans = Parent.Find(panel_name);
            if (trans != null)
            {
                ActiveGameObject(trans.gameObject, func, params_table);
                return;
            }
            string assetName = panel_name;

            if (!Path.HasExtension(assetName))
                assetName += ".prefab";
            GameObject prefab = ResManager.LoadAsset<GameObject>(assetName, null, null);
            if (prefab == null)
                return;

            InstantiateGo(prefab, Parent, isCache, func, params_table);
        }

        ///// <summary>
        ///// 弹出面板
        ///// </summary>
        ///// <param name="name"></param>
        //public void PushPanel(string name, LuaFunction func = null)
        //{
        //    if (!panelCacheDic.ContainsKey(name))
        //    {
        //        Debug.LogWarning(name + " is null");
        //        return;
        //    }
        //    panelCacheDic[name].SetActive(true);
        //    if (curPanel != null && curPanel != "")
        //        panelCacheDic[curPanel].SetActive(false);

        //    if (func != null)
        //        func.Call(panelCacheDic[curPanel]);

        //    curPanel = name;
        //}

        /// <summary>
        /// 关闭面板
        /// </summary>
        /// <param name="name"></param>
        public void ClosePanel(string name)
        {
            //var panelName = name + "Panel";
            var panelObj = Parent.Find(name);
            if (panelObj == null)
                return;
            Destroy(panelObj.gameObject);

            //if (panelCacheDic.ContainsKey(name))
            //{
            //    panelCacheDic.Remove(name);
            //}
        }

        public void MakeCameraImgAsync(int x, int y, int width, int height, string path, LuaFunction func, bool isRotate = false, bool isSavePhoto = false)
        {
            StartCoroutine(getScreenTexture(x, y, width, height, path, func, isRotate, isSavePhoto));
        }
        IEnumerator getScreenTexture(int capx, int capy, int capwidth, int capheight, string path, LuaFunction callback, bool isRotate, bool isSavePhoto)
        {
            yield return new WaitForEndOfFrame();
            Texture2D t = new Texture2D(capwidth, capheight, TextureFormat.RGB24, false);
            t.ReadPixels(new Rect(capx, capy, capwidth, capheight), 0, 0, false);//按照设定区域读取像素；注意是以左下角为原点读取  
            t.Apply();
            if (isRotate)
            {
                t = rotateTexture(t, true);
            }
            //二进制转换
            byte[] byt = t.EncodeToPNG();
            if (isSavePhoto){
                RecordFrame(t,path,byt); 
            }
            else{
                File.WriteAllBytes(path, byt);
            }
            if (callback != null)
            {
                callback.Call();
            }
        }
        private Texture2D rotateTexture(Texture2D originalTexture, bool clockwise)
        {
            Color32[] original = originalTexture.GetPixels32();
            Color32[] rotated = new Color32[original.Length];
            int w = originalTexture.width;
            int h = originalTexture.height;

            int iRotated, iOriginal;

            for (int j = 0; j < h; ++j)
            {
                for (int i = 0; i < w; ++i)
                {
                    iRotated = (i + 1) * h - j - 1;
                    iOriginal = clockwise ? original.Length - 1 - (j * w + i) : j * w + i;
                    rotated[iRotated] = original[iOriginal];
                }
            }

            Texture2D rotatedTexture = new Texture2D(h, w);
            rotatedTexture.SetPixels32(rotated);
            rotatedTexture.Apply();
            return rotatedTexture;
        }

        void RecordFrame(Texture2D texture,string path, byte[] byt)
        {
            DateTime now = new DateTime();
            now = DateTime.Now;
            string filename = string.Format("image{0}{1}{2}{3}.png", now.Day, now.Hour, now.Minute, now.Second);
            // string filename = "wx_share.png";
            string destination = "";
            if (Application.platform == RuntimePlatform.Android)
            {
                destination = Application.persistentDataPath.Substring(0, Application.persistentDataPath.IndexOf("Android"));
                destination = destination + "DCIM/Screenshots";
                if (!Directory.Exists(destination))
                {
                    Directory.CreateDirectory(destination);
                }
                destination = destination + "/" + filename;
                if (Directory.Exists(destination)) {
                    Directory.Delete(destination);
                }
                File.WriteAllBytes(destination, byt);
                // 安卓在这里需要去 调用原生的接口去 刷新一下，不然相册显示不出来
                SDKInterface.Instance.ScanFile(destination);
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
                destination = Application.persistentDataPath;
                if (!Directory.Exists(destination))
                {
                    Directory.CreateDirectory(destination);
                }
                destination = destination + "/" + filename;
                if (Directory.Exists(destination)) {
                    Directory.Delete(destination);
                }
                File.WriteAllBytes(destination, byt);
#if UNITY_IOS
                SDKInterface.Instance.SaveImageToPhotosAlbum(destination);
#endif
            }
            else
            {
                File.WriteAllBytes(path, byt);
            }
            // cleanup
            // Destroy(texture);
        }

        /// <summary>  
        /// 对相机截图
        /// </summary>  
        /// <returns>The screenshot2.</returns>  
        /// <param name="camera">Camera.要被截屏的相机</param>  
        /// <param name="rect">Rect.截屏的区域</param>  
        Texture2D CaptureCamera(Camera camera, Rect rect)   
        {  
            // 创建一个RenderTexture对象  
            RenderTexture rt = new RenderTexture((int)rect.width, (int)rect.height, 0);  
            // 临时设置相关相机的targetTexture为rt, 并手动渲染相关相机  
            camera.targetTexture = rt;  
            camera.Render();  
            //ps: --- 如果这样加上第二个相机，可以实现只截图某几个指定的相机一起看到的图像。  
            //ps: camera2.targetTexture = rt;  
            //ps: camera2.Render();  
            //ps: -------------------------------------------------------------------  
        
            // 激活这个rt, 并从中中读取像素。  
            RenderTexture.active = rt;  
            Texture2D screenShot = new Texture2D((int)rect.width, (int)rect.height, TextureFormat.RGB24,false);  
            screenShot.ReadPixels(rect, 0, 0);// 注：这个时候，它是从RenderTexture.active中读取像素  
            screenShot.Apply();  
        
            // 重置相关参数，以使用camera继续在屏幕上显示  
            camera.targetTexture = null;  
                //ps: camera2.targetTexture = null;  
            RenderTexture.active = null; // JC: added to avoid errors  
            GameObject.Destroy(rt);  
            // 最后将这些纹理数据，成一个png图片文件  
            byte[] bytes = screenShot.EncodeToPNG();  
            string filename = Application.dataPath + "/Screenshot.png";  
            System.IO.File.WriteAllBytes(filename, bytes);  
            Debug.Log(string.Format("截屏了一张照片: {0}", filename));  
            
            return screenShot;  
        } 
    }
}