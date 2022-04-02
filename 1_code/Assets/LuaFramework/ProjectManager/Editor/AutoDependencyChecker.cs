// 自动检测并移动资源

using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using UnityEngine.UI;
using System.Linq;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.IO;
using System;

public class AutoDependencyChecker : EditorWindow
{
	static string cur_path = "";
    static string cur_pre_name = "";

	static string log_path = Application.dataPath + "/unity_res_move_log.txt";
	static FileStream fs = null;
	static StreamWriter sw = null;

	internal class pre_yy{
		public string pre_name = "";
    public string obj_name = "";
		public string path = "";
	}
	//
	internal class doc_gl{
		public string move_path = "Assets/Game/CommonPrefab";
		public List<string> paths = new List<string>();
	}
	internal class prefab_cls{
		public string path = "";
		public GameObject obj;
	}

	internal class ActivityContent
	{
		public string name = string.Empty;
		public bool enable = false;
	}
	internal class ActivityConfig
	{
		public List<ActivityContent> activities = new List<ActivityContent>();
	}
	static Dictionary<string, doc_gl> all_doc = new Dictionary<string, doc_gl>();
	static List<string> check_paths = new List<string>();
	static Dictionary<string, string> baoToNickname = new Dictionary<string, string>();
	// 初始化配置
	static void InitConfig()
	{
		all_doc.Clear ();
		doc_gl gl;

  //       // 一级资源
		// gl = new doc_gl ();
		// all_doc.Add ("Assets/Game/CommonPrefab", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_Hall", gl);

		// gl = new doc_gl ();
		// gl.paths = new List<string> (){"Assets/Game/CommonPrefab" };
		// all_doc.Add ("Assets/Game/Channel", gl);

  //       // 二级资源
  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/normal_ddz_common", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/normal_fishing_common", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/normal_lhd_common", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/normal_mj_common", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/normal_qhb_common", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/normal_xxl_common", gl);

  //       // 三级资源
  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab" };
  //       all_doc.Add ("Assets/Game/game_CityMatch", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_ddz_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_ddz_common" };
  //       all_doc.Add ("Assets/Game/game_DdzFK", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_ddz_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_ddz_common" };
  //       all_doc.Add ("Assets/Game/game_DdzFree", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_ddz_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_ddz_common" };
  //       all_doc.Add ("Assets/Game/game_DdzMatch", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_ddz_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_ddz_common" };
  //       all_doc.Add ("Assets/Game/game_DdzMillion", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_ddz_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_ddz_common" };
  //       all_doc.Add ("Assets/Game/game_DdzPDK", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_ddz_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_ddz_common" };
  //       all_doc.Add ("Assets/Game/game_DdzPDKMatch", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_ddz_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_ddz_common" };
  //       all_doc.Add ("Assets/Game/game_DdzTy", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_xxl_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_xxl_common" };
  //       all_doc.Add ("Assets/Game/game_Eliminate", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_xxl_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_xxl_common" };
  //       all_doc.Add ("Assets/Game/game_EliminateCS", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_xxl_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_xxl_common" };
  //       all_doc.Add ("Assets/Game/game_EliminateSH", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_fishing_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_fishing_common" };
  //       all_doc.Add ("Assets/Game/game_Fishing", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_fishing_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_fishing_common" };
  //       all_doc.Add ("Assets/Game/game_Fishing3D", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_fishing_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_fishing_common" };
  //       all_doc.Add ("Assets/Game/game_Fishing3DHall", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_fishing_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_fishing_common" };
  //       all_doc.Add ("Assets/Game/game_FishingDR", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_fishing_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_fishing_common" };
  //       all_doc.Add ("Assets/Game/game_FishingHall", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_fishing_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_fishing_common" };
  //       all_doc.Add ("Assets/Game/game_FishingMatch", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_lhd_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_lhd_common" };
  //       all_doc.Add ("Assets/Game/game_LHD", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_lhd_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_lhd_common" };
  //       all_doc.Add ("Assets/Game/game_LHDHall", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_mj_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_mj_common" };
  //       all_doc.Add ("Assets/Game/game_Mj3D", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_mj_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_mj_common" };
  //       all_doc.Add ("Assets/Game/game_MjXl3D", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_mj_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_mj_common" };
  //       all_doc.Add ("Assets/Game/game_MjXzFK3D", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_mj_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_mj_common" };
  //       all_doc.Add ("Assets/Game/game_MjXzMatchER3D", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_qhb_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_qhb_common" };
  //       all_doc.Add ("Assets/Game/game_QHB", gl);

  //       gl = new doc_gl ();
  //       gl.move_path = "Assets/Game/normal_qhb_common";
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/normal_qhb_common" };
  //       all_doc.Add ("Assets/Game/game_QHBHall", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_Free", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_Gobang", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_MatchHall", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_MiniGame", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_Zjd", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_ScannerQRCode", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_Loding", gl);

  //       gl = new doc_gl ();
  //       gl.paths = new List<string> (){"Assets/Game/CommonPrefab"};
  //       all_doc.Add ("Assets/Game/game_Login", gl);

		

        string[] dirs = Directory.GetDirectories("Assets/Game/Activity");
		foreach(string dd in dirs)
        {
            gl = new doc_gl ();
			gl.paths = new List<string> (){"Assets/Game/CommonPrefab", "Assets/Game/game_Hall", "Assets/Game/Activity/act_com"};
			string dd1 = dd.Replace('\\', '/');
			all_doc.Add (dd1, gl);
        }



		// 需要检查的目录
		check_paths.Clear();
		foreach(string path in all_doc.Keys)			
        {
			check_paths.Add(path);
        }
	}

	static List<prefab_cls> all_prefabs = new List<prefab_cls>();

	static List<pre_yy> ActiveTextures = new List<pre_yy>();
  static List<pre_yy> ActiveFontDetails = new List<pre_yy>();
  static List<pre_yy> ActiveMaterials = new List<pre_yy>();
	static List<pre_yy> ActiveAnimDetails = new List<pre_yy>();
	static List<pre_yy> ActiveSoundDetails = new List<pre_yy>();
	static List<pre_yy> ActiveShaderDetails = new List<pre_yy>();

	static bool CheckPath(string path1)
  {
		if (all_doc.ContainsKey(cur_path)) {
			if (path1.Contains (cur_path)) {
				return true;
			}
			if (all_doc [cur_path].paths != null) {
				foreach (string pp in all_doc[cur_path].paths) {
					if (path1.Contains(pp)) {
						return true;
					}
				}
			}
		}
		return false;
  }

	public static void WindowSceneReady()
	{
		string[] paths = Directory.GetFiles(cur_path, "*.prefab", SearchOption.AllDirectories);

		for (int i = 0; i < paths.Length; i++)
		{
			GameObject prefabObj = AssetDatabase.LoadAssetAtPath(paths[i], typeof(GameObject)) as GameObject;
			prefab_cls pp = new prefab_cls ();
			pp.path = paths [i];
			pp.obj = prefabObj;
			all_prefabs.Add (pp);
		}
	}

  static bool CheckPath1(string path1)
  {
    if (File.Exists (path1) && (!path1.Contains("Assets/Game/CommonPrefab") && !path1.Contains("Assets/Game/normal_base_common") && !path1.Contains("Assets/Game/Activity/normal_activity_common")))
    {
      return true;
    }
    return false;
  }
    [MenuItem("Assets/材质球的依赖与移动资源")]
    static void MaterialYNAndYD()
    {
        string jj = "Assets/Game/CommonPrefab";
        string path = "Assets/Game/CommonPrefab/Material";
        string[] paths = Directory.GetFiles(path, "*.mat", SearchOption.AllDirectories);
        for (int i = 0; i < paths.Length; i++)
        {
          Material prefabObj = AssetDatabase.LoadAssetAtPath (paths [i], typeof(Material)) as Material;
          string fn = Path.GetFileName (paths [i]);
          
          string assetPath = AssetDatabase.GetAssetPath(prefabObj.mainTexture);
          if (!assetPath.Contains(fn))
          {
            Debug.Log(fn);
            Debug.Log(assetPath);
          }
        }
    }
    [MenuItem("Assets/预制体的依赖与移动资源")]
    static void PrefabYNAndYD()
    {
      GameObject[] objects = Selection.gameObjects;
      foreach (GameObject obj in objects)
      {
          string path = AssetDatabase.GetAssetPath(obj);
          Debug.Log(path);
          GameObject prefabObj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
          prefab_cls pp = new prefab_cls ();
          pp.path = path;
          pp.obj = prefabObj;

          var file = Path.GetFileNameWithoutExtension (path);

          cur_pre_name = pp.obj.name;
          CheckResources (pp);

          string move_path = Path.GetDirectoryName(path);
          move_path = move_path + "/" + file;

          List<pre_yy> ll = new List<pre_yy>();
          ll.Clear();
          foreach (pre_yy old_p in ActiveTextures) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/Image", "Image");
          ll.Clear();
          foreach (pre_yy old_p in ActiveFontDetails) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/Font", "Font");
          ll.Clear();
          foreach (pre_yy old_p in ActiveMaterials) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/Material", "Material");
          ll.Clear();
          foreach (pre_yy old_p in ActiveAnimDetails) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/Anim", "Animation or Animator");

      }
        AssetDatabase.Refresh ();
    }
        [MenuItem("Assets/预制体的依赖与移动资源（移动到同一文件夹）")]
    static void PrefabYNAndYD1()
    {
      GameObject[] objects = Selection.gameObjects;
      foreach (GameObject obj in objects)
      {
          string path = AssetDatabase.GetAssetPath(obj);
          Debug.Log(path);
          GameObject prefabObj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
          prefab_cls pp = new prefab_cls ();
          pp.path = path;
          pp.obj = prefabObj;

          var file = Path.GetFileNameWithoutExtension (path);

          cur_pre_name = pp.obj.name;
          CheckResources (pp);

          string move_path = Path.GetDirectoryName(path);
          move_path = move_path + "/" + file;

          List<pre_yy> ll = new List<pre_yy>();
          ll.Clear();
          foreach (pre_yy old_p in ActiveTextures) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/", "Image");
          ll.Clear();
          foreach (pre_yy old_p in ActiveFontDetails) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/", "Font");
          ll.Clear();
          foreach (pre_yy old_p in ActiveMaterials) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/", "Material");
          ll.Clear();
          foreach (pre_yy old_p in ActiveAnimDetails) 
          {
            if (CheckPath1(old_p.path)) 
            {
              ll.Add(old_p);
              Debug.Log(old_p.path);
            }
          }
          MoveRes (ll, move_path + "/", "Animation or Animator");

          ll.Clear();
          var yy = new pre_yy();
          yy.pre_name = cur_pre_name;
          yy.path = path;
          ll.Add(yy);
          MoveRes (ll, move_path + "/", "MY");
      }
        AssetDatabase.Refresh ();
    }

    [MenuItem("Window/项目依赖与移动资源")]
    static void Init()
    {
      Debug.Log("关闭");
      return;
  		InitConfig ();

			fs = new FileStream(log_path, FileMode.OpenOrCreate, FileAccess.ReadWrite);
			fs.Close();
            fs = new FileStream(log_path, FileMode.OpenOrCreate);
			sw = new StreamWriter(fs);

  		foreach (string path in check_paths)
      {
  			all_prefabs.Clear ();
  			ActiveTextures.Clear ();
  			ActiveFontDetails.Clear ();
  			ActiveMaterials.Clear ();
  			ActiveAnimDetails.Clear ();

        cur_path = path;
		    ShowLog ("path : " + cur_path);

        WindowSceneReady();
			 ShowLog ("all_prefabs count =  " + all_prefabs.Count);
			 foreach (var pp in all_prefabs)
			 {
          cur_pre_name = pp.obj.name;
  				CheckResources (pp);
			 }
  			string move_path = all_doc [cur_path].move_path;
  			MoveRes (ActiveTextures, move_path + "/Image", "Image");
  			MoveRes (ActiveFontDetails, move_path + "/Font", "Font");
  			MoveRes (ActiveMaterials, move_path + "/Material", "Material");
  			MoveRes (ActiveAnimDetails, move_path + "/Anim", "Animation or Animator");
        AssetDatabase.Refresh ();
      }
      if (sw != null) 
      {
        sw.Close ();
      }

      if (fs != null) 
      {
        fs.Close ();
      }
      AssetDatabase.Refresh ();
    }
	static void MoveRes(List<pre_yy> list, string move_path, string type)
	{
		ShowLog (type + " == " + list.Count);
		if (list.Count > 0) {
			if (!Directory.Exists (move_path)) {
				Directory.CreateDirectory (move_path);
			}

			foreach (pre_yy old_p in list) 
            {
				if (File.Exists (old_p.path)) 
                {
					   string name = Path.GetFileName (old_p.path);
                      if (old_p.obj_name != null)
                      {
                        ShowLog ("pre_name = " + old_p.pre_name + "  obj_name = " + old_p.obj_name + "\n" + old_p.path + " => " + move_path + "/" + name + "\n");
                      }
                      else
                      {
                        ShowLog ("pre_name = " + old_p.pre_name + "\n" + old_p.path + " => " + move_path + "/" + name + "\n");
                      }
    					File.Move (old_p.path, move_path + "/" + name);
    					File.Move (old_p.path + ".meta", move_path + "/" + name + ".meta");                        
				}
			}
		}
        else
        {
            ShowLog ("\n");
        }
	}
	static void ShowLog(string log)
	{
        if (sw != null)
        {
          sw.WriteLine (log);
        }
	}

  private static string GetGameObjectPath(GameObject inGameObject)
  {
    Transform transform = inGameObject.transform;
    string path = transform.name;
    while (transform.parent != null)
    {
    transform = transform.parent;
    path = transform.name + "/" + path;
    }
    return path;
  }
	static void TryAddActiveTextures(Texture tex, UnityEngine.Object inMaterials, GameObject inGameObject)
    {
        if (tex == null)
            return;

        string assetPath = AssetDatabase.GetAssetPath(tex);
        if (CheckPath(assetPath))
        {
            return;
        }

        if (IgnoreDependencyFromPath(assetPath))
            return;
        // Debug.Log("Texture===" + assetPath);
        pre_yy details = ActiveTextures.Find((o) => { return o.path == assetPath; });
		if (details != null)
			return;
		pre_yy yy = new pre_yy();
		yy.pre_name = cur_pre_name;
        yy.obj_name = GetGameObjectPath(inGameObject);
		yy.path = assetPath;

        ActiveTextures.Add(yy);
        return;
    }

	static void TryAddAudioClip(AudioClip s)
    {
        if (s == null)
            return;

        string assetPath = AssetDatabase.GetAssetPath(s);

        if (CheckPath(assetPath))
            return;

        if (IgnoreDependencyFromPath(assetPath))
            return;
        // Debug.Log("Audio===" + assetPath);
		// if (ActiveSoundDetails.Contains (assetPath))
		// 	return;
        pre_yy details = ActiveSoundDetails.Find((o) => { return o.path == assetPath; });
        if (details != null)
            return;
		pre_yy yy = new pre_yy();
		yy.pre_name = cur_pre_name;
		yy.path = assetPath;

        ActiveSoundDetails.Add(yy);
        return;
    }

	static void TryAddFont(Font s, GameObject inGameObject)
    {
        if (s == null)
            return;
		TryAddActiveMaterial (s.material, inGameObject);

        string assetPath = AssetDatabase.GetAssetPath(s);

        if (CheckPath(assetPath))
            return;

        if (IgnoreDependencyFromPath(assetPath))
            return;
		// if (ActiveFontDetails.Contains (assetPath))
		// 	return;
        pre_yy details = ActiveFontDetails.Find((o) => { return o.path == assetPath; });
        if (details != null)
            return;
        pre_yy yy = new pre_yy();
		yy.pre_name = cur_pre_name;
        yy.obj_name = GetGameObjectPath(inGameObject);
	    yy.path = assetPath;
        ActiveFontDetails.Add(yy);

        return;
    }

	static void TryAddActiveMaterial(Material mat, GameObject inGameObject)
    {
        if (mat == null)
            return;

		foreach (UnityEngine.Object obj in EditorUtility.CollectDependencies(new UnityEngine.Object[] { mat }))
		{
			if (obj is Texture)
			{
				Texture tTexture = obj as Texture;
				TryAddActiveTextures(tTexture, mat, inGameObject);
			}
			if (obj is Shader)
			{
				Shader shader = obj as Shader;
				TryAddActiveShader(shader, mat, inGameObject);
			}
		}

		string assetPath = AssetDatabase.GetAssetPath(mat);

        if (CheckPath(assetPath))
            return;

        if (IgnoreDependencyFromPath(assetPath))
            return;
		// if (ActiveMaterials.Contains (assetPath))
		// 	return;
        // Debug.Log("Material===" + assetPath);
        pre_yy details = ActiveMaterials.Find((o) => { return o.path == assetPath; });
        if (details != null)
            return;
		pre_yy yy = new pre_yy();
		yy.pre_name = cur_pre_name;
        yy.obj_name = GetGameObjectPath(inGameObject);
		yy.path = assetPath;

        ActiveMaterials.Add(yy);

        return;
    }

	static void TryAddActiveShader(Shader s, UnityEngine.Object inMaterials, GameObject inGameObject)
    {
        if (s == null)
            return;

        string assetPath = AssetDatabase.GetAssetPath(s);

        if (CheckPath(assetPath))
            return;

        if (IgnoreDependencyFromPath(assetPath))
            return;
        // if (ActiveShaderDetails.Contains (assetPath))
        //     return;
        // Debug.Log("Shader===" + assetPath);
        pre_yy details = ActiveShaderDetails.Find((o) => { return o.path == assetPath; });
        if (details != null)
            return;
		pre_yy yy = new pre_yy();
		yy.pre_name = cur_pre_name;
        yy.obj_name = GetGameObjectPath(inGameObject);
		yy.path = assetPath;

        ActiveShaderDetails.Add(yy);
        return;
    }
	static void TryAddAnim(RuntimeAnimatorController s, GameObject inGameObject)
	{
		if (s == null)
			return;

		string assetPath = AssetDatabase.GetAssetPath(s);

		if (CheckPath(assetPath))
			return;

		if (IgnoreDependencyFromPath(assetPath))
			return;
		// if (ActiveAnimDetails.Contains (assetPath))
		// 	return;
        pre_yy details = ActiveAnimDetails.Find((o) => { return o.path == assetPath; });
        if (details != null)
            return;
		pre_yy yy = new pre_yy();
		yy.pre_name = cur_pre_name;
        yy.obj_name = GetGameObjectPath(inGameObject);
		yy.path = assetPath;

		ActiveAnimDetails.Add(yy);
		return;
	}
	static void TryAddAnimClip(AnimationClip s, GameObject inGameObject)
	{
		if (s == null)
			return;

		string assetPath = AssetDatabase.GetAssetPath(s);

		if (CheckPath(assetPath))
			return;

		if (IgnoreDependencyFromPath(assetPath))
			return;
		// if (ActiveAnimDetails.Contains (assetPath))
		// 	return;
        pre_yy details = ActiveAnimDetails.Find((o) => { return o.path == assetPath; });
        if (details != null)
            return;
		pre_yy yy = new pre_yy();
		yy.pre_name = cur_pre_name;
        yy.obj_name = GetGameObjectPath(inGameObject);
		yy.path = assetPath;

		ActiveAnimDetails.Add(yy);
		return;
	}

	static void CheckResources(prefab_cls pp)
    {
		Renderer[] renderers = pp.obj.GetComponentsInChildren<Renderer> (true);
        foreach (Renderer renderer in renderers)
        {
            if (renderer is SpriteRenderer && (renderer as SpriteRenderer).sprite != null)
            { 
                TryAddActiveTextures((renderer as SpriteRenderer).sprite.texture, null, renderer.gameObject);
            }
            else
            {
                foreach (Material material in renderer.sharedMaterials)
                {
                    if (material == null)
                        continue;

                    TryAddActiveMaterial(material, renderer.gameObject);
                }
            }
        }

		Transform[] gameObjs = pp.obj.GetComponentsInChildren<Transform> (true);
        foreach (Transform item in gameObjs)
        {
            MaskableGraphic maskableGraphic = item.GetComponent<MaskableGraphic>();

            if (maskableGraphic is Image)
            {
                Image image = item.GetComponent<Image>();
                TryAddActiveTextures(image.mainTexture, image.material, item.gameObject);
                TryAddActiveMaterial(image.material, item.gameObject);
            }
            else if (maskableGraphic is RawImage)
            {
                RawImage image = item.GetComponent<RawImage>();
                TryAddActiveTextures(image.mainTexture, image.material, item.gameObject);
                TryAddActiveMaterial(image.material, item.gameObject);
            }
            else if (maskableGraphic is Text)
            {
                Text text = item.GetComponent<Text>();
                TryAddFont(text.font, item.gameObject);
            }
        }
		Animator[] anims = pp.obj.GetComponentsInChildren<Animator> (true);
		foreach (Animator item in anims)
		{
            if (item != null && item.runtimeAnimatorController != null)
            {            
                TryAddAnim (item.runtimeAnimatorController, item.gameObject);
                AnimationClip[] clips = item.runtimeAnimatorController.animationClips;
                foreach(AnimationClip clip in clips)
                {
                    TryAddAnimClip (clip, item.gameObject);
                }
            }
		}
		Animation[] anims_old = pp.obj.GetComponentsInChildren<Animation> (true);
		foreach (Animation item in anims_old)
		{
			AnimationClip[] clips = AnimationUtility.GetAnimationClips (item);
			foreach(AnimationClip clip in clips)
			{
				TryAddAnimClip (clip, item.gameObject);
			}
		}
    }

    static bool IgnoreDependencyFromPath(string path)
    {
        return
            path.StartsWith("Library") ||
            path.StartsWith("Resources/unity_builtin_extra") ||
            path.EndsWith("dll") ||
            path.EndsWith("asset") ||
            string.IsNullOrEmpty(path);
    }

    public void OnDestroy()
    {
    }
}