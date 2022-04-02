using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LayerOrderOptionWindow : EditorWindow {

	[MenuItem("Tools/UI/SetLayerOrder")]
	static void SetLayerOrder()
	{
		EditorWindow.GetWindow<LayerOrderOptionWindow> ().Show ();
	}

	private string fileName = string.Empty;
	private GameObject go;
	private Vector2 layerView = Vector2.zero;
	private string baseLayer = "0";
	private bool negative = false;

	int GetBaseLayer(GameObject go) {
		int layer = 0;
		Canvas canvas = go.GetComponent<Canvas> ();
		if (canvas != null)
			layer = canvas.sortingOrder;
		return layer;
	}
	void SetBaseLayer(int layer) {
		Canvas canvas = go.GetComponent<Canvas> ();
		if (canvas)
			canvas.sortingOrder = layer;
	}
	void UpdateHierarchy(int offset) {
		int newLayer = 0;

		Canvas currentCanvas = go.GetComponent<Canvas> ();
		if (currentCanvas != null) {
			newLayer = currentCanvas.sortingOrder + offset;
			if (!negative)
				newLayer = Mathf.Max (0, newLayer);
			currentCanvas.sortingOrder = newLayer;
		}

		Canvas[] canvas = go.GetComponentsInChildren<Canvas> (true);
		for (int idx = 0; idx < canvas.Length; ++idx) {
			if (canvas [idx] == currentCanvas)
				continue;

			newLayer = canvas [idx].sortingOrder + offset;
			if (!negative)
				newLayer = Mathf.Max (0, newLayer);
			canvas [idx].sortingOrder = newLayer;
		}

		Renderer[] renderer = go.GetComponentsInChildren<Renderer> (true);
		for (int idx = 0; idx < renderer.Length; ++idx) {
			newLayer = renderer [idx].sortingOrder + offset;
			if (!negative)
				newLayer = Mathf.Max (0, newLayer);
			renderer [idx].sortingOrder = newLayer;
		}

		/*int offset = layer - GetBaseLayer (go);

		Canvas[] canvas = go.GetComponentsInChildren<Canvas> (true);
		for (int idx = 0; idx < canvas.Length; ++idx)
			canvas [idx].sortingOrder += offset;

		Renderer[] renderer = go.GetComponentsInChildren<Renderer> (true);
		for (int idx = 0; idx < renderer.Length; ++idx)
			renderer [idx].sortingOrder += offset;*/
	}

	void RefreshHierarchy() {
		GUILayout.BeginVertical ("Canvas");
		{
			Canvas[] canvas = go.GetComponentsInChildren<Canvas> (true);
			for(int idx = 0; idx < canvas.Length; ++idx)
				GUILayout.Label (canvas[idx].name + ":" + canvas[idx].sortingOrder);
		}
		GUILayout.EndVertical ();

		GUILayout.BeginVertical ("Renderer");
		{
			Renderer[] renderer = go.GetComponentsInChildren<Renderer> (true);
			for(int idx = 0; idx < renderer.Length; ++idx)
				GUILayout.Label (renderer[idx].name + ":" + renderer[idx].sortingOrder);
		}
		GUILayout.EndVertical ();
	}

	void OnGUI () {
		EditorGUILayout.BeginVertical ();
		{
			if (GUILayout.Button ("选择预制体")) {
				string dataPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
				fileName = EditorUtility.OpenFilePanelWithFilters ("选择预制体", Application.dataPath, new string[] {"prefab", "prefab"});
				go = AssetDatabase.LoadAssetAtPath<GameObject> (fileName.Replace (dataPath, string.Empty));
				if (go == null)
					Debug.LogError ("Can't load GameObject:" + fileName);
			}

			if (go != null) {
				EditorGUILayout.BeginHorizontal ();
				{
					GUILayout.Label ("设置偏移:", new GUILayoutOption[]{GUILayout.Width(90)});
					baseLayer = GUILayout.TextField (baseLayer);
					negative = GUILayout.Toggle (negative, "层级可以小于0");

					if (GUILayout.Button ("应用")) {
						int layer = 0;
						if (int.TryParse (baseLayer, out layer)) {
							UpdateHierarchy (layer);
							AssetDatabase.SaveAssets (); 
						}
					}
				}
				EditorGUILayout.EndHorizontal ();

				EditorGUILayout.Space ();

				layerView = EditorGUILayout.BeginScrollView (layerView);
				{
					GUILayout.BeginVertical ("HelpBox");
					{
						RefreshHierarchy ();
					}
					GUILayout.EndVertical ();
				}
				EditorGUILayout.EndScrollView ();
			}
		}
		EditorGUILayout.EndVertical ();
	}
}
