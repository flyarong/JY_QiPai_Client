using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Linq;
using System;

public class ClearEmptyFolder : UnityEditor.AssetModificationProcessor
{
	static readonly List<DirectoryInfo> s_Results = new List<DirectoryInfo>();
    public static bool IsLock = false;
	static string[] OnWillSaveAssets(string[] paths)
	{
		// Get empty directories in Assets directory
		s_Results.Clear();
		var assetsDir = Application.dataPath + Path.DirectorySeparatorChar;
		GetEmptyDirectories(new DirectoryInfo(assetsDir), s_Results);

		// When empty directories has detected, remove the directory.
		if (0 < s_Results.Count)
		{
			foreach (var d in s_Results)
			{
                if (!IsLock) {
                    FileUtil.DeleteFileOrDirectory(d.FullName);
                }
            }
			AssetDatabase.Refresh();
		}
		return paths;
	}

	static bool GetEmptyDirectories(DirectoryInfo dir, List<DirectoryInfo> results)
	{
		if (EditorApplication.isCompiling)
			return false;

		bool isEmpty = true;
		try
		{
			isEmpty = dir.GetDirectories().Count(x => !GetEmptyDirectories(x, results)) == 0	// Are sub directories empty?
				&& dir.GetFiles("*.*").All(x => x.Extension == ".meta");	// No file exist?
		}
		catch
		{
		}

		// Store empty directory to results.
		if (isEmpty)
			results.Add(dir);
		return isEmpty;
	}
}
