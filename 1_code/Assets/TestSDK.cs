using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LitJson;
using UnityEngine.UI;
public class TestSDK : MonoBehaviour {
	JsonData json = new JsonData();
	public Text text;
	public bool session;
    void Start() {
        //		// example2: Stopwatch class
        //		System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
        //		sw.Start();
        //		for (int i = 0; i < 10; i++) {
        //			Texture dd = (Texture)Resources.Load("CardType " + i);
        //		}
        //		sw.Stop();
        //		TimeSpan ts2 = sw.Elapsed;
        //		NGUIDebug.Log ("tongyong_di   " + ts2.TotalMilliseconds.ToString ());
        Debug.Log("{\"type\" = 3, \"url\" = \"www.baide.com\", \"title\" = \"标题\",\"description\" = \"百度大法好\"}");
        
    }

	public void CallBack(string str)
	{
		Debug.Log (str);
		text.text = str;
        tok = str;
	}
    string tok = "";
	// Use this for initialization
	void OnGUI ()   
	{  
		if(GUILayout.Button("调用安卓Jar中的函数 RegisterToWeChat ！",GUILayout.Height(50)))  
			{  
			//获取Android的Java接口  
			AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        	AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
        	jo.Call("RegisterToWeChat", "wxf64ec3fb99c28771");  //填写appid
		}  

		// 通过API调用对话框  
		if(GUILayout.Button("调用安卓Jar中的函数 WeChatLogin ！",GUILayout.Height(50)))  
		{  
			AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        	AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
        	jo.Call("WeChatLogin","");  //填写appid
		}
        // 通过API调用Toast
        if (GUILayout.Button("调用安卓Jar中的函数 sendToken !", GUILayout.Height(50))) {
            AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            jo.Call("ShowToast", "Showing on Toast");
        }
        // // 通过API调用手机震动的方法
        // if(GUILayout.Button("调用安卓Jar中的函数 SetVibrator !",GUILayout.Height(50)))  
        // { 
        // 	AndroidJavaClass jc=new AndroidJavaClass("com.unity3d.player.UnityPlayer");  
        // 	AndroidJavaObject jo=jc.GetStatic<AndroidJavaObject>("currentActivity"); 
        // 	jo.Call("SetVibrator"); 
        // }
    } 

	public void ShareUrl()
	{
		json.Clear ();
		json ["type"] = 3;
		json ["url"] = "http://weibo.com/u/1235764025?refer_flag=1001030102_";
		json ["title"] = "饭太黏";
		json ["description"] = "饭太黏最帅";
		json ["isCircleOfFriends"] = session;
		Share ();
		// AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
		// AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
		// jo.Call("WeChat", json）//"{\"type\" = 3, \"url\" = \"www.baide.com\", \"title\" = \"标题\",\"description\" = \"百度大法好\"},\"isCircleOfFriends\" = \"true\"");
	}

	public void ShareText()
	{
		json.Clear ();
		json ["type"] = 4;
		json ["title"] = "饭太黏";
		json ["description"] = "饭太黏最帅";
		json ["text"] = "饭太黏最帅text";

		json ["isCircleOfFriends"] = session;
		Share ();
	}

	public void ShareMusic()
	{
		json.Clear ();
		json ["type"] = 5;
		json ["url"] = "http://music.163.com/m/song?id=110771&userid=6725175#?thirdfrom=qq";
		json ["title"] = "饭太黏";
		json ["description"] = "饭太黏最帅";
		json ["isCircleOfFriends"] = session;
		Share ();
	}

	public void ShareVideo()
	{
		json.Clear ();
		json ["type"] = 6;
		json ["url"] = "http://www.qq.com";
		json ["title"] = "饭太黏";
		json ["description"] = "饭太黏最帅";
		json ["isCircleOfFriends"] = session;
		Share ();
	}

	public void ShareImage()
	{
		json.Clear ();
		json ["type"] = 7;
		json ["title"] = "饭太黏";
		json ["description"] = "饭太黏最帅";
		json ["isCircleOfFriends"] = session;
		Share ();
	}
	public void Selected(bool isSelect)
	{
		session = isSelect;
		Debug.Log (isSelect);
	}
	void Share()
	{
		AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
		AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
		jo.Call("WeChat", json.ToJson());
		jo.Call ("StartAc", "dddd0");
	}
}
