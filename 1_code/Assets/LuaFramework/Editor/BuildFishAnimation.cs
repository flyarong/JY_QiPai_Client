using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Animations;

public static class BuildFishAnimation {

	static string defBasicPath = Application.dataPath + "/Game";
	static string lastBasicPath = string.Empty;

	[MenuItem("Tools/MakeFishObject")]
	static void MakeFishObject()
	{
		if (string.IsNullOrEmpty (lastBasicPath))
			lastBasicPath = defBasicPath;

		string imgPath = EditorUtility.OpenFolderPanel ("打开图片目录", lastBasicPath, string.Empty);
		if (string.IsNullOrEmpty (imgPath))
			return;
		imgPath = imgPath.Replace ('\\', '/');

		List<Sprite> sprites = LoadAllSprite (imgPath);
		if (sprites.Count <= 0)
			return;
		sprites.Sort (Compare);

		int offset = imgPath.IndexOf ("game_");
		string gameName = imgPath.Substring (offset, imgPath.IndexOf ('/', offset) - offset);
		if(!string.IsNullOrEmpty(gameName))
			lastBasicPath = defBasicPath + "/" + gameName;

		offset = imgPath.LastIndexOf ('/');
		string prefabName = "prefab";
		if(offset > 0)
			prefabName = imgPath.Substring (offset + 1);

		string prefabPath = EditorUtility.SaveFilePanel ("预制体保存路径", lastBasicPath + "/Prefab", prefabName, "prefab");
		prefabName = Path.GetFileNameWithoutExtension (prefabPath);

		string animationPath = EditorUtility.SaveFilePanel ("动画文件保存路径", lastBasicPath + "/Animation", prefabName, "");
		prefabPath = prefabPath.Substring (Application.dataPath.Length - 6);
		animationPath = animationPath.Substring (Application.dataPath.Length - 6);

		//imgPath = imgPath.Substring (Application.dataPath.Length - 6);
		int layerFactor = getIdxValue(prefabName);

		GameObject go = new GameObject (prefabName);
		go.layer = LayerMask.NameToLayer ("fish");

		GameObject fish = new GameObject ("fish");
		fish.layer = LayerMask.NameToLayer ("fish");
		fish.transform.SetParent (go.transform);
		SpriteRenderer render = fish.AddComponent<SpriteRenderer> ();
		render.sprite = sprites [0];
		render.sortingOrder = layerFactor * 10;

		GameObject shadow = new GameObject ("shadow");
		shadow.layer = LayerMask.NameToLayer ("fish");
		shadow.transform.localPosition = new Vector3 (0.221f, -0.239f, 0.0f);
		shadow.transform.SetParent (fish.transform);
		render = shadow.AddComponent<SpriteRenderer> ();
		render.sprite = sprites [0];
		render.sortingOrder = layerFactor * 10 - 1;
		render.color = new Color (0, 0, 0, 179.0f/255.0f);
		shadow.AddComponent<Shadow> ();

		GameObject lock_node = new GameObject ("lock_node");
		lock_node.layer = LayerMask.NameToLayer ("fish");
		lock_node.transform.SetParent (go.transform);

		GameObject hang_node = new GameObject ("hang_node");
		hang_node.layer = LayerMask.NameToLayer ("fish");
		hang_node.transform.SetParent (go.transform);

		go = PrefabUtility.CreatePrefab(prefabPath, go, ReplacePrefabOptions.ConnectToPrefab);
		BoxCollider2D bc = go.AddComponent<BoxCollider2D> ();
		bc.isTrigger = true;

		AnimationClip clip = BuildAnimationClip (animationPath + "_anim.anim", "fish", sprites);
		AnimatorController controller = AnimatorController.CreateAnimatorControllerAtPathWithClip(animationPath + ".controller", clip);

		Animator animator = go.AddComponent<Animator> ();
		animator.runtimeAnimatorController = controller;

		AssetDatabase.SaveAssets();
	}

	[MenuItem("Tools/MakeFishAnimation")]
	static void MakeFishAnimation()
	{
		if (string.IsNullOrEmpty (lastBasicPath))
			lastBasicPath = defBasicPath;

		string imgPath = SelectImagePathAndSaveBasicPath ();
		if (string.IsNullOrEmpty (imgPath))
			return;

		List<Sprite> sprites = LoadAllSprite (imgPath);
		if (sprites.Count <= 0)
			return;
		sprites.Sort (Compare);

		int offset = imgPath.LastIndexOf ('/');
		string animationName = "Animation";
		if(offset > 0)
			animationName = imgPath.Substring (offset + 1) + "_anim";
		
		string animationPath = EditorUtility.SaveFilePanel ("动画文件保存路径", lastBasicPath + "/Animation", animationName, "anim");
		animationPath = animationPath.Substring (Application.dataPath.Length - 6);
		AnimationClip clip = BuildAnimationClip (animationPath, "fish", sprites);

		AssetDatabase.SaveAssets();
	}

	[MenuItem("Tools/AdjustFishAnimation")]
	static void AdjustFishAnimation()
	{
		if (string.IsNullOrEmpty (lastBasicPath))
			lastBasicPath = defBasicPath;

		string animationPath = EditorUtility.OpenFilePanel ("动画文件路径", lastBasicPath + "/Animation", "anim");
		animationPath = animationPath.Substring (Application.dataPath.Length - 6);

		AnimationClip clip = AssetDatabase.LoadAssetAtPath<AnimationClip> (animationPath);

		EditorCurveBinding[] curves = AnimationUtility.GetObjectReferenceCurveBindings (clip);
		ObjectReferenceKeyframe[] frames = AnimationUtility.GetObjectReferenceCurve (clip, curves[0]);
		for (int idx = 0; idx < frames.Length; ++idx) {
			frames [idx].time = 0.2f * idx;
		}
		AnimationUtility.SetObjectReferenceCurve (clip, curves[0], frames);
		clip.frameRate = 30;

		AnimationClipSettings setting = AnimationUtility.GetAnimationClipSettings(clip);
		setting.loopTime = true;
		AnimationUtility.SetAnimationClipSettings(clip, setting);

		AssetDatabase.SaveAssets();
	}

	static string SelectImagePathAndSaveBasicPath() {
		string imgPath = EditorUtility.OpenFolderPanel ("打开图片目录", lastBasicPath, string.Empty);
		if (string.IsNullOrEmpty (imgPath))
			return string.Empty;
		
		imgPath = imgPath.Replace ('\\', '/');
		int offset = imgPath.IndexOf ("game_");
		string gameName = imgPath.Substring (offset, imgPath.IndexOf ('/', offset) - offset);
		if(!string.IsNullOrEmpty(gameName))
			lastBasicPath = defBasicPath + "/" + gameName;

		return imgPath;
	}

	static AnimationClip BuildAnimationClip(string fileName, string nodeName, List<Sprite> sprites) {
		AnimationClip clip = new AnimationClip ();
		AssetDatabase.CreateAsset (clip, fileName);

		EditorCurveBinding curve = new EditorCurveBinding ();
		curve.type = typeof(SpriteRenderer);
		curve.path = nodeName;
		curve.propertyName = "m_Sprite";

		ObjectReferenceKeyframe[] frames = new ObjectReferenceKeyframe[sprites.Count];
		for (int idx = 0; idx < sprites.Count; ++idx) {
			frames [idx] = new ObjectReferenceKeyframe ();
			frames [idx].time = 0.1f * idx;
			frames [idx].value = sprites [idx];
		}
		AnimationUtility.SetObjectReferenceCurve (clip, curve, frames);
		clip.frameRate = 30;

		AnimationClipSettings setting = AnimationUtility.GetAnimationClipSettings(clip);
		setting.loopTime = true;
		AnimationUtility.SetAnimationClipSettings(clip, setting);

		return clip;
	}

	static List<Sprite> LoadAllSprite(string dir) {
		List<Sprite> result = new List<Sprite> ();
		string[] files = Directory.GetFiles (dir, "*.png", SearchOption.AllDirectories);
		for (int idx = 0; idx < files.Length; ++idx) {
			result.Add(AssetDatabase.LoadAssetAtPath<Sprite> (files [idx].Substring(Application.dataPath.Length - 6)));
		}
		return result;
	}

	static int Compare(Sprite a, Sprite b) {
		int aidx = getIdxValue(a.name);
		int bidx = getIdxValue(b.name);
	
		return aidx - bidx;
	}

	static int getIdxValue(string v) {
		int idx = v.Length - 1;
		for (; idx >= 0; --idx) {
			char c = v [idx];
			if (char.IsDigit (c))
				continue;
			break;
		}
		idx += 1;
		if (idx >= v.Length)
			return 0;
		
		string s = v.Substring (idx);
		int i = 0;
		int.TryParse(s, out i);
		return i;
	}
}
