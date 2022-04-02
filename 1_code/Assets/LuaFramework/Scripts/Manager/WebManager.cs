using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

namespace LuaFramework
{
    public class WebManager : Manager
    {
        private bool m_enableWKWebView = true;
        public void EnableWKWebView(bool value)
        {
            m_enableWKWebView = value;
        }

        //private Dictionary<string, WebViewObject> webviewMap = new Dictionary<string, WebViewObject>();

        //public void OpenURL(string key, string url, LuaFunction onEvent, LuaFunction onLoad, LuaFunction onError, Transform parent)
        //{
        //    WebViewObject webview;
        //    if (!webviewMap.TryGetValue(key, out webview))
        //    {
        //        GameObject go = new GameObject("WebView_" + key);
        //        if(parent != null)
        //        {
        //            RectTransform selfRT = go.AddComponent<RectTransform>();
        //            RectTransform parentRT = parent.GetComponent<RectTransform>();
        //            if(parentRT != null)
        //            {
        //                selfRT.anchorMin = parentRT.anchorMin;
        //                selfRT.anchorMax = parentRT.anchorMax;
        //                selfRT.anchoredPosition = parentRT.anchoredPosition;
        //                selfRT.sizeDelta = parentRT.sizeDelta;

        //                Debug.Log("[WEBVIEW] copy RectTransform");
        //            }

        //            go.transform.SetParent(parent);
        //        }

        //        webview = go.AddComponent<WebViewObject>();
        //        webviewMap.Add(key, webview);

        //        StartCoroutine(OpenURL(webview, url, onEvent, onLoad, onError));
        //    }
        //    else
        //    {
        //        webview.LoadURL(url.Replace(" ", "%20"));
        //    }
        //}

        //public void CloseURL(string key)
        //{
        //    WebViewObject wvb;
        //    if (!webviewMap.TryGetValue(key, out wvb))
        //        return;

        //    Debug.Log("DebugURL: CloseURL:" + key);

        //    webviewMap.Remove(key);
        //    GameObject.Destroy(wvb.gameObject);
        //}

        //public void EvaluateJS(string key, string value)
        //{
        //    WebViewObject wvb;
        //    if (!webviewMap.TryGetValue(key, out wvb))
        //        return;
        //    wvb.EvaluateJS(value);
        //}

        //public void SetMargins(string key, int left, int top, int right, int bottom, bool relative)
        //{
        //    WebViewObject wvb;
        //    if (!webviewMap.TryGetValue(key, out wvb))
        //        return;
        //    wvb.SetMargins(left, top, right, bottom, relative);
        //    Debug.Log("[WEBVIEW] set margins:" + key + "[" + left + "," + top + "," + right + "," +  bottom + "]");
        //}

        //public void SetVisible(string key, bool visible)
        //{
        //    WebViewObject wvb;
        //    if (!webviewMap.TryGetValue(key, out wvb))
        //        return;
        //    wvb.SetVisibility(visible);
        //}

        //public void ClearCookies(string key)
        //{
        //    WebViewObject wvb;
        //    if (!webviewMap.TryGetValue(key, out wvb))
        //        return;
        //    wvb.ClearCookies();
        //}

        //public int QueryProgress(string key)
        //{
        //    WebViewObject wvb;
        //    if (!webviewMap.TryGetValue(key, out wvb))
        //        return -1;
        //    return wvb.Progress();
        //}

//        private IEnumerator OpenURL(WebViewObject webview, string url, LuaFunction onEvent, LuaFunction onLoad, LuaFunction onError)
//        {
//            webview.Init(
//                cb: (msg) =>
//                {
//                    Debug.Log(string.Format("DebugURL: CallFromJS[{0}]", msg));
//                    if (msg == "form?msg=aaa")
//                    {
//                        webview.SetVisibility(false);
//                    }
//                    if(onEvent != null) onEvent.Call(msg);
//                },
//                err: (msg) =>
//                {
//                    Debug.Log(string.Format("DebugURL: CallOnError[{0}]", msg));
//                    if(onError != null) onError.Call(msg);
//                },
//                started: (msg) =>
//                {
//                    Debug.Log(string.Format("DebugURL: CallOnStarted[{0}]", msg));
//                },
//                ld: (msg) =>
//                {
//                    Debug.Log(string.Format("DebugURL: CallOnLoaded[{0}]", msg));
//                    if (onLoad != null) onLoad.Call(msg);

//#if UNITY_EDITOR_OSX || !UNITY_ANDROID
//                    // NOTE: depending on the situation, you might prefer
//                    // the 'iframe' approach.
//                    // cf. https://github.com/gree/unity-webview/issues/189
//#if true
//                    webview.EvaluateJS (@"
//                        if (window && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.unityControl) {
//                            window.Unity = {
//                                call: function(msg) {
//                                    window.webkit.messageHandlers.unityControl.postMessage(msg);
//                                }
//                            }
//                        } else {
//                            window.Unity = {
//                                call: function(msg) {
//                                    window.location = 'unity:' + msg;
//                                }
//                            }
//                        }
//                    ");
//#else
//                    webview.EvaluateJS(@"
//                        if (window && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.unityControl) {
//                            window.Unity = {
//                                call: function(msg) {
//                                    window.webkit.messageHandlers.unityControl.postMessage(msg);
//                                }
//                            }
//                        } else {
//                            window.Unity = {
//                                call: function(msg) {
//                                    var iframe = document.createElement('IFRAME');
//                                    iframe.setAttribute('src', 'unity:' + msg);
//                                    document.documentElement.appendChild(iframe);
//                                    iframe.parentNode.removeChild(iframe);
//                                    iframe = null;
//                                }
//                            }
//                        }
//                    ");
//#endif
//#endif
//                    webview.EvaluateJS(@"Unity.call('ua=' + navigator.userAgent)");
//                },
//                //ua: "custom user agent string",
//                enableWKWebView: m_enableWKWebView
//            );
//#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
//            webview.bitmapRefreshCycle = 1;
//#endif
//            //webViewObject.SetAlertDialogEnabled(false);
//            //webview.SetMargins(0, 0, 0, 0, false);
//            //webview.SetVisibility(true);

//#if !UNITY_WEBPLAYER && !UNITY_WEBGL
//            if (url.StartsWith("http"))
//            {
//                webview.LoadURL(url.Replace(" ", "%20"));
//            }
//            else
//            {
//                StartCoroutine(CallTest(webview, url));
//            }
//#else
//            if (url.StartsWith("http")) {
//                webview.LoadURL(url.Replace(" ", "%20"));
//            } else {
//                webview.LoadURL("StreamingAssets/" + url.Replace(" ", "%20"));
//            }
//            webview.EvaluateJS(
//                "parent.$(function() {" +
//                "   window.Unity = {" +
//                "       call:function(msg) {" +
//                "           parent.unityWebView.sendMessage('HandleWebViewMessage', msg)" +
//                "       }" +
//                "   };" +
//                "});"
//            );
//#endif
//            yield break;
//        }

      //  private IEnumerator CallTest(WebViewObject webview, string Url)
      //  {
      //      var exts = new string[]{
      //          ".jpg",
      //          ".js",
      //          ".html"  // should be last
		    //};
      //      foreach (var ext in exts)
      //      {
      //          var url = Url.Replace(".html", ext);
      //          var src = System.IO.Path.Combine(Application.streamingAssetsPath, url);
      //          var dst = System.IO.Path.Combine(Application.persistentDataPath, url);
      //          byte[] result = null;
      //          if (src.Contains("://"))
      //          {  // for Android
      //              var www = new WWW(src);
      //              yield return www;
      //              result = www.bytes;
      //          }
      //          else
      //          {
      //              result = System.IO.File.ReadAllBytes(src);
      //          }
      //          System.IO.File.WriteAllBytes(dst, result);
      //          if (ext == ".html")
      //          {
      //              webview.LoadURL("file://" + dst.Replace(" ", "%20"));
      //              break;
      //          }
      //      }
      //      yield break;
      //  }

        //旧接口
        //private const string SHOP_KEY = "_shop_";
        //public void OnShopClick(string url, bool isHide = false)
        //{
        //    OpenURL(SHOP_KEY, url, null, null, null, null);
        //    SetMargins(SHOP_KEY, 0, 0, 0, 0, false);
        //    SetVisible(SHOP_KEY, !isHide);
        //}
        //public void OnShopClickLoadURL(string url)
        //{
        //    OpenURL(SHOP_KEY, url, null, null, null, null);
        //    SetVisible(SHOP_KEY, true);
        //}
    }

        //    public class WebManager : Manager
        //    {
        //		private bool m_enableWKWebView = true;
        //		public void EnableWKWebView(bool value) {
        //			m_enableWKWebView = value;
        //		}

        //        private string Url;
        //        WebViewObject webViewObject;


        //        public void OnShopClick(string url, bool isHide = false)
        //        {
        //            Url = url;
        //            Debug.Log("<color=red>OnShopClick*****</color>");

        //            if (webViewObject == null)
        //            {
        //                webViewObject = (new GameObject("WebViewObject")).AddComponent<WebViewObject>();
        //                webViewObject.Init(
        //                    cb: (msg) =>
        //                    {
        //                        Debug.Log(string.Format("CallFromJS[{0}]", msg));
        //                        if (msg == "form?msg=aaa")
        //                        {
        //                            webViewObject.SetVisibility(false);
        //                        }
        //                    },
        //                    err: (msg) =>
        //                    {
        //                        Debug.Log(string.Format("CallOnError[{0}]", msg));
        //                    },
        //                    ld: (msg) =>
        //                    {
        //                        Debug.Log(string.Format("CallOnLoaded[{0}]", msg));
        //    #if !UNITY_ANDROID
        //					    // NOTE: depending on the situation, you might prefer
        //					    // the 'iframe' approach.
        //					    // cf. https://github.com/gree/unity-webview/issues/189
        //    #if true
        //					    webViewObject.EvaluateJS (@"
        //				    if (window && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.unityControl) {
        //				    window.Unity = {
        //				    call: function(msg) {
        //				    window.webkit.messageHandlers.unityControl.postMessage(msg);
        //				    }
        //				    }
        //				    } else {
        //				    window.Unity = {
        //				    call: function(msg) {
        //				    window.location = 'unity:' + msg;
        //				    }
        //				    }
        //				    }
        //				    ");
        //    #else
        //					    webViewObject.EvaluateJS(@"
        //					    if (window && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.unityControl) {
        //					    window.Unity = {
        //					    call: function(msg) {
        //					    window.webkit.messageHandlers.unityControl.postMessage(msg);
        //					    }
        //					    }
        //					    } else {
        //					    window.Unity = {
        //					    call: function(msg) {
        //					    var iframe = document.createElement('IFRAME');
        //					    iframe.setAttribute('src', 'unity:' + msg);
        //					    document.documentElement.appendChild(iframe);
        //					    iframe.parentNode.removeChild(iframe);
        //					    iframe = null;
        //					    }
        //					    }
        //					    }
        //					    ");
        //    #endif
        //    #endif
        //                        webViewObject.EvaluateJS(@"Unity.call('ua=' + navigator.userAgent)");
        //                    },
        //                    //ua: "custom user agent string",
        //					enableWKWebView: m_enableWKWebView);
        //    #if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
        //			    webViewObject.bitmapRefreshCycle = 1;
        //    #endif
        //                webViewObject.SetMargins(0, 0, 0, 0);

        //                if (isHide)
        //                {
        //                    webViewObject.SetVisibility(false);
        //                }
        //                else
        //                {
        //                    webViewObject.SetVisibility(true);
        //                }

        //#if !UNITY_WEBPLAYER
        //                if (Url.StartsWith("http"))
        //                {
        //                    webViewObject.LoadURL(Url.Replace(" ", "%20"));
        //                }
        //                else
        //                {
        //                    StartCoroutine(CallTest());
        //                }
        //    #else
        //			    if (Url.StartsWith("http")) {
        //			    webViewObject.LoadURL(Url.Replace(" ", "%20"));
        //			    } else {
        //			    webViewObject.LoadURL("StreamingAssets/" + Url.Replace(" ", "%20"));
        //			    }
        //			    webViewObject.EvaluateJS(
        //			    "parent.$(function() {" +
        //			    "   window.Unity = {" +
        //			    "       call:function(msg) {" +
        //			    "           parent.unityWebView.sendMessage('WebViewObject', msg)" +
        //			    "       }" +
        //			    "   };" +
        //			    "});");
        //    #endif
        //            }
        //            else
        //            {
        //                webViewObject.SetVisibility(true);
        //                webViewObject.EvaluateJS(@"webviewWillAppear()");
        //                Debug.Log("<color=red>WebManager Show UI</color>");
        //            }

        //        }

        //        public void OnShopClickLoadURL(string url) {
        //          Url = url;
        //          webViewObject.SetVisibility(true);
        //          webViewObject.LoadURL(Url.Replace(" ", "%20"));
        //          webViewObject.EvaluateJS(@"webviewWillAppear()");
        //        }

        //        IEnumerator CallTest()
        //        {
        //            var exts = new string[]{
        //                ".jpg",
        //                ".js",
        //                ".html"  // should be last
        //		    };
        //            foreach (var ext in exts)
        //            {
        //                var url = Url.Replace(".html", ext);
        //                var src = System.IO.Path.Combine(Application.streamingAssetsPath, url);
        //                var dst = System.IO.Path.Combine(Application.persistentDataPath, url);
        //                byte[] result = null;
        //                if (src.Contains("://"))
        //                {  // for Android
        //                    var www = new WWW(src);
        //                    yield return www;
        //                    result = www.bytes;
        //                }
        //                else
        //                {
        //                    result = System.IO.File.ReadAllBytes(src);
        //                }
        //                System.IO.File.WriteAllBytes(dst, result);
        //                if (ext == ".html")
        //                {
        //                    webViewObject.LoadURL("file://" + dst.Replace(" ", "%20"));
        //                    break;
        //                }
        //            }
        //            yield break;
        //        }
        //    }
}
