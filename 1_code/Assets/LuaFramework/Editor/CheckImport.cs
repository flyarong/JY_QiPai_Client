using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

public class CheckImport : AssetPostprocessor {

	private void Check() {
		string newFile = Path.GetFileName (this.assetPath);

		string[] files = Directory.GetFiles (Application.dataPath, "*.*", SearchOption.AllDirectories);

		string refFile = string.Empty;
		string fileName = string.Empty;

		bool inGame1 = this.assetPath.StartsWith ("Assets/Game/");
		bool inGame2 = false;
			
		foreach (string file in files) {
			refFile = file.Replace (Application.dataPath, "");
			refFile = refFile.Replace ('\\', '/');
			if (refFile.IndexOf ('/') == 0)
				refFile = "Assets" + refFile;
			
			if (refFile == this.assetPath)
				continue;
			fileName = Path.GetFileName (file);
			if (string.Compare (newFile, fileName, true) == 0) {
				inGame2 = refFile.StartsWith("Assets/Game/");
				if (inGame1 && inGame2) {
					string notice = string.Format ("名字冲突: {0} - {1}", this.assetPath, file);
					Debug.LogError (notice);
					EditorUtility.DisplayDialog ("注意", notice, "赶紧修改");
					break;
				}
			}
		}
	}

	public void OnPreprocessTexture() {
		//Check ();
	}

	public void OnPreprocessAudio() {
		//Check ();
	}
}
