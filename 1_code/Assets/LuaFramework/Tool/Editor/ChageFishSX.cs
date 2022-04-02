using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.Animations;

public class ChageFishSX : Editor
{
    [MenuItem(@"Tools/ChangeFishSX")]
    public static void OnChangeFishSX()
    {
        GameObject[] objects = Selection.gameObjects;
 
		EditorUtility.DisplayProgressBar("Progress", "Change Fish Prefab...", 0);
		var count = 0;
        foreach (var item in objects)
        {
            ChangeObj(item);
			count++;
			EditorUtility.DisplayProgressBar("Change Fish Prefab", item.name, count / (float)objects.Length);
        }
		Debug.Log ("完成 " + count);
		EditorUtility.ClearProgressBar();
    }
    public static void ChangeObj(GameObject Obj)
    {
    	var newPrefab = PrefabUtility.InstantiatePrefab(Obj) as GameObject;
    	/*/
    	foreach (Transform item in newPrefab.transform)
        {
			Debug.Log (item.name);
			if (item.name == "fish3d") 
			{
				var fish3dyz = GameObject.Instantiate (item);
			}
        }
		/*/ 
		Dictionary<string, float> dd = new Dictionary<string, float> ();
		dd.Add ("Fish3D001", 0.3f);
		dd.Add ("Fish3D002", 0.4f);
		dd.Add ("Fish3D004", 0.3f);
		dd.Add ("Fish3D005", 0.4f);
		dd.Add ("Fish3D006", 0.3f);
		dd.Add ("Fish3D007", 0.4f);
		dd.Add ("Fish3D008", 0.5f);
		dd.Add ("Fish3D009", 0.4f);
		dd.Add ("Fish3D010", 0.3f);
		dd.Add ("Fish3D011", 0.35f);
		dd.Add ("Fish3D013", 0.6f);
		dd.Add ("Fish3D014", 0.5f);
		dd.Add ("Fish3D015", 0.5f);
		dd.Add ("Fish3D016", 0.6f);
		dd.Add ("Fish3D017", 0.46f);
		dd.Add ("Fish3D018", 0.6f);
		dd.Add ("Fish3D019", 0.5f);
		dd.Add ("Fish3D020", 0.6f);
		dd.Add ("Fish3D021", 0.6f);
		dd.Add ("Fish3D022", 0.5f);
		dd.Add ("Fish3D023", 0.6f);
		dd.Add ("Fish3D024", 0.5f);
		dd.Add ("Fish3D026", 0.5f);
		dd.Add ("Fish3D027", 0.9f);
		dd.Add ("Fish3D028", 1.2f);
		dd.Add ("Fish3D029", 0.5f);
		dd.Add ("Fish3D030", 0.5f);
		dd.Add ("Fish3D031", 0.7f);
		dd.Add ("Fish3D032", 0.5f);
		dd.Add ("Fish3D034", 0.5f);
		dd.Add ("Fish3D036", 1f);
		dd.Add ("Fish3D041", 0.5f);
		dd.Add ("Fish3D042", 0.8f);
		dd.Add ("Fish3D043", 0.8f);

		if (dd [Obj.name] == null)
		{
			Debug.Log (Obj.name);
			return;
		}
		var sc = dd[Obj.name];
		var hang_node = newPrefab.transform.Find ("hang_node");
		hang_node.transform.localPosition = new Vector3 (0, 0, 0);
		var fish3d = newPrefab.transform.Find ("fish3d");
		var fish3dyz = newPrefab.transform.Find ("fish3dyz");
		fish3d.transform.localScale = new Vector3 (sc, sc, sc);
		if (fish3dyz != null)
		{
			fish3dyz.transform.localScale = new Vector3 (sc, sc, sc);
			fish3dyz.transform.localPosition = new Vector3(fish3dyz.transform.localPosition.x * sc, fish3dyz.transform.localPosition.y * sc, 5);
		}
		var box = newPrefab.transform.GetComponent<BoxCollider2D> ();
		box.offset = new Vector2(box.offset.x * sc, box.offset.y * sc);
		box.size = new Vector2(box.size.x * sc, box.size.y * sc);
		//*/

		PrefabUtility.ReplacePrefab(newPrefab, Obj);
		UnityEngine.Object.DestroyImmediate(newPrefab);
	}

	static string cur_path = "Assets/Game/normal_fishing3d_common/Image";

	[MenuItem(@"Tools/ChangeFishFBX")]
	public static void WindowSceneReady()
	{
		string[] paths = Directory.GetFiles(cur_path, "*.mat", SearchOption.AllDirectories);


		for (int i = 0; i < paths.Length; i++) {
			Material prefabObj = AssetDatabase.LoadAssetAtPath (paths [i], typeof(Material)) as Material;
			string x = Path.GetDirectoryName (paths [i]);
			string fn = Path.GetFileName (paths [i]);

			prefabObj.SetFloat("_Speed", 0.2f);
			prefabObj.SetFloat("_Intensity", 0.5f);

		}
	}


	[MenuItem(@"Tools/ChangeFishAnim")]
	public static void OnChangeFishAnim()
	{
		GameObject[] objects = Selection.gameObjects;

		EditorUtility.DisplayProgressBar("Progress", "Change Fish Prefab...", 0);
		var count = 0;
		Debug.Log (objects.Length);
		foreach (var item in objects)
		{
			Debug.Log (item.name);
			ChangeObjAnim (item);
			count++;
			EditorUtility.DisplayProgressBar("Change Fish Prefab", item.name, count / (float)objects.Length);
		}
		Debug.Log ("完成 " + count);
		EditorUtility.ClearProgressBar();

	}
	public static void ChangeObjAnim(GameObject Obj)
	{
		Debug.Log (Obj.name);
		string assetPath = AssetDatabase.GetAssetPath(Obj);
		Debug.Log (assetPath);
		string x = Path.GetDirectoryName(assetPath);
		Debug.Log (x);
		string nnn = Obj.name.Substring (7, 2);
		Debug.Log (nnn);

		string model_path = "Assets/Game/game_Fishing3D/Image/fish3d/b_model_1" + nnn;

		var newPrefab = PrefabUtility.InstantiatePrefab (Obj) as GameObject;
		var fish3d = newPrefab.transform.Find ("fish3d");
		var anim = fish3d.GetComponent<Animation> ();
		AnimationClip[] clips = AnimationUtility.GetAnimationClips (anim);


		Animator  a = fish3d.gameObject.AddComponent<Animator> ();

		AnimatorController animatorController = AnimatorController.CreateAnimatorControllerAtPath(model_path + "/fish3d_anim_" + nnn + ".controller");
		a.runtimeAnimatorController = animatorController;

		for (int i = 0; i < clips.Length; ++i)
		{
			animatorController.AddMotion (clips [i]);
		}


		PrefabUtility.ReplacePrefab(newPrefab, Obj);
		UnityEngine.Object.DestroyImmediate(newPrefab);
	}
}
