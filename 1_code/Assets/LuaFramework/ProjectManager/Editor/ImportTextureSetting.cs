using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Drawing;


public class ImportTextureSetting
{
	const string SETTextureTag = "Assets/Texture Tool/设置TextureTag";
	// 设置为当前项目目录
    [MenuItem(SETTextureTag, false, 61)]
    public static void SetTextureTag()
    {
    	string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]);
            Debug.Log(assetPath);
            List<string> filePaths = new List<string> ();
            string imgtype = "*.BMP|*.JPG|*.GIF|*.PNG";
			string[] ImageType = imgtype.Split ('|');
			for (int i = 0; i < ImageType.Length; i++) {
				string[] dirs = Directory.GetFiles(assetPath, ImageType [i], SearchOption.AllDirectories);
				for (int j = 0; j < dirs.Length; j++) {
					filePaths.Add (dirs [j]);
				}
			}

			//"Assets/Game/"
			int index = 11;
			EditorUtility.DisplayProgressBar("SetTextureTag", "SetTextureTag...", 0);
			var count = 0;
			for (int i = 0; i < filePaths.Count; i++)
			{
				var filePath = filePaths [i];
				count++;
				EditorUtility.DisplayProgressBar("SetTextureTag", filePath, count / (float)filePaths.Count);

				TextureImporter textureImporter = AssetImporter.GetAtPath(filePath) as TextureImporter;

				string path = Path.GetDirectoryName (filePath);
				string spriteTag = path.Substring (index + 1, path.Length - index - 1);
				spriteTag = spriteTag.Replace ('/', '_');

				if(textureImporter.spritePackingTag != spriteTag)
				{
					textureImporter.spritePackingTag = spriteTag;
					AssetDatabase.ImportAsset(filePath);
				}
			}

			EditorUtility.ClearProgressBar();
        }
    }

    const string YSTextureTag = "Assets/Texture Tool/压缩Texture";
    [MenuItem(YSTextureTag, false, 62)]
    public static void SetYSTextureTag()
    {
    	string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]);
            Debug.Log(assetPath);
            List<string> filePaths = new List<string> ();
            string imgtype = "*.BMP|*.JPG|*.GIF|*.PNG";
			string[] ImageType = imgtype.Split ('|');
			for (int i = 0; i < ImageType.Length; i++) {
				string[] dirs = Directory.GetFiles(assetPath, ImageType [i], SearchOption.AllDirectories);
				for (int j = 0; j < dirs.Length; j++) {
					filePaths.Add (dirs [j]);
				}
			}

			int[] size_r = {32, 64, 128, 256, 512, 1024, 2048};

			//"Assets/Game/"
			int index = 11;
			EditorUtility.DisplayProgressBar("YSTextureTag", "YSTextureTag...", 0);
			var count = 0;
			for (int i = 0; i < filePaths.Count; i++)
			{
				bool is_update = false;
				var filePath = filePaths [i];
				count++;
				EditorUtility.DisplayProgressBar("YSTextureTag", filePath, count / (float)filePaths.Count);

				TextureImporter textureImporter = AssetImporter.GetAtPath(filePath) as TextureImporter;

				string path = Path.GetDirectoryName (filePath);
				string spriteTag = path.Substring (index + 1, path.Length - index - 1);
				spriteTag = spriteTag.Replace ('/', '_');

				TextureImporterPlatformSettings platformSettings = textureImporter.GetPlatformTextureSettings("iPhone");
				
				if (platformSettings.overridden == true)
				{
					is_update = true;
					platformSettings.overridden = false;
					textureImporter.SetPlatformTextureSettings(platformSettings);
				}
	
				platformSettings = textureImporter.GetPlatformTextureSettings("Android");
				if (platformSettings.overridden == true)
				{
					is_update = true;
					platformSettings.overridden = false;
					textureImporter.SetPlatformTextureSettings(platformSettings);
				}

				Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D> (filePath);
				if (texture != null)
				{
					platformSettings = textureImporter.GetDefaultPlatformTextureSettings();

					int max_s = texture.width;
					int min_s = texture.height;
					if (max_s >= 32 || min_s >= 32)
					{
						if (max_s < texture.height)
						{
							min_s = texture.width;
							max_s = texture.height;
						}
						int max_jj = size_r.Length - 1;
						for (int j = 0; j < size_r.Length; j++)
						{
							if (j==0 && max_s <= size_r[j])
							{
								max_jj = j;
								break;
							}
							if (j!=size_r.Length && max_s <= size_r[j+1] && max_s > size_r[j])
							{
								max_jj = j;
								break;
							}
						}
						if ((max_jj+1)>=size_r.Length || (max_s < (size_r[max_jj] * 1.35)))
						{
							is_update = true;
							platformSettings.maxTextureSize = size_r[max_jj];
							textureImporter.SetPlatformTextureSettings(platformSettings);
						}
					}
					
				}
				if (is_update)
				{
					AssetDatabase.ImportAsset(filePath);
				}
			}

			EditorUtility.ClearProgressBar();
        }
    }

    public class image_cls{
		public string new_path = "";
		public string old_path = "";
		public int max_size = 1024;
		public bool chg_size = false;
		public bool is_have = true;
    	public image_cls(string p1, string p2)
    	{
    		new_path = p1;
    		old_path = p2;
    	}
	}
    static List<image_cls> change_list = new List<image_cls>();
    static string temp_dir = Application.dataPath + "/temp_NewImg/";
	static string[] ImageType = new string[]{".bmp",".jpg",".png"};

    static void AddFileList(List<string> filePaths, string path)
    {
    	for(int j = 0; j < ImageType.Length; ++j)
    	{
    		if (ImageType[j] == Path.GetExtension(path))
    		{
                if (Path.GetFileNameWithoutExtension (path) != "2D_map_anbuzhezhao_3"
					&& Path.GetFileNameWithoutExtension (path) != "2D_map_guangshu"
					&& Path.GetFileNameWithoutExtension (path) != "2D_map_beijing")
					filePaths.Add (path);
    			break;
    		}
    	}
    }

  //   const string XGCCTextureTag = "Assets/Texture Tool/修改图片尺寸(满足Unity%4)";
  //   [MenuItem(XGCCTextureTag, false, 62)]
  //   public static void SetXGCCTextureTag()
  //   {
  //   	if (Directory.Exists (temp_dir)) {
		// 	Directory.Delete (temp_dir, true);
		// }
		// Directory.CreateDirectory (temp_dir);

		// change_list = new List<image_cls>();

  //   	string[] assetGUIDArray = Selection.assetGUIDs;
  //       if (assetGUIDArray.Length > 0)
  //       {
  //           List<string> filePaths = new List<string> ();
  //       	for(int i = 0; i < assetGUIDArray.Length; ++i)
  //       	{
	 //            string assetPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[i]);
	 //            if (Directory.Exists(assetPath))
	 //            {
	 //                string[] folder = new string[] { assetPath };
	 //                //将文件夹下所有资源作为选择资源
	 //                string[] paths = AssetDatabase.FindAssets(null, folder);
	 //                foreach(var p in paths)
	 //                {
	 //                	string ppath = AssetDatabase.GUIDToAssetPath(p);
	 //                    if ( !Directory.Exists(ppath) )
	 //                    {
	 //                    	AddFileList(filePaths, ppath);
	 //                    }                        
	 //                }
	 //            }
	 //            else
	 //            {
	 //            	AddFileList(filePaths, assetPath);
	 //            }
  //       	}

		// 	int[] size_r = {32, 64, 128, 256, 512, 1024, 2048 ,4096};

		// 	EditorUtility.DisplayProgressBar("1.YSTextureTag ", "YSTextureTag...", 0);
		// 	var count = 0;
		// 	for (int i = 0; i < filePaths.Count; i++) {
		// 		bool is_update = false;
		// 		var filePath = filePaths [i];
		// 		count++;
		// 		EditorUtility.DisplayProgressBar("1.YSTextureTag " + "(" + count + "/" + filePaths.Count + ")", filePath, count / (float)filePaths.Count);

		// 		string path = Path.GetDirectoryName (filePath);
		// 		//*
		// 		var cIma = System.Drawing.Image.FromFile(filePath); //第一种方式
		// 		int width = cIma.Width;
  //               int height = cIma.Height;
  //               cIma.Dispose();
		// 		/*/
		// 		TextureImporter textureImporter = AssetImporter.GetAtPath(filePath) as TextureImporter; //第二种方式
  //               int width = 0;
  //               int height = 0;
  //               GetTextureOriginalSize(textureImporter, out width, out height);
		// 		//*/

  //               Debug.Log(width + "：" + height + "path = " + filePath);

		// 		int max_s = width;
		// 		int min_s = height;
  //               if (max_s >= 32 || min_s >= 32) {
		// 			bool is_jh = false;
		// 			if (max_s < height) {
		// 				is_jh = true;
		// 				min_s = width;
		// 				max_s = height;
		// 			}
		// 			int max_jj = size_r.Length - 1;
		// 			for (int j = 0; j < size_r.Length; j++) {
		// 				if (j==0 && max_s <= size_r[j]) {
		// 					max_jj = j;
		// 					break;
		// 				}
		// 				if (j!=size_r.Length && max_s < size_r[j+1] && max_s >= size_r[j]) {
		// 					max_jj = j;
		// 					break;
		// 				}
		// 			}

  //           		var name = Path.GetFileNameWithoutExtension (filePath);
		// 	        string copy_path = Path.GetDirectoryName (filePath);

		// 	    	string new_path = temp_dir + name + ".png";
	 //                image_cls img_data = new image_cls(new_path, filePath);
		// 	        change_list.Add(img_data);

		// 			if ((max_jj+1)>=size_r.Length || (max_s < (size_r[max_jj] * 1.35))) {
		// 		        img_data.max_size = size_r[max_jj];

		// 				is_update = true;
		// 				int mb_s = size_r[max_jj];
		// 				float scale = (float)mb_s / max_s;
		// 				int s1 = (int)Math.Round(scale * min_s, MidpointRounding.AwayFromZero);
		// 				if (s1 % 4 != 0) {
		// 					// 最小变化法
		// 					if (s1 % 4 < 2) {
		// 						s1 = s1 - s1 % 4;
		// 					}
		// 					else {
		// 						s1 = s1 + 4 - s1 % 4;
		// 					}
		// 					min_s = (int)Math.Round(s1 / scale, MidpointRounding.AwayFromZero);
		// 					img_data.chg_size = true;
		// 					ChangeImage(new_path, filePath, min_s, max_s, is_jh, img_data);
		// 				}
		// 			}
		// 			else {
		// 				if (max_s % 4 != 0 && min_s % 4 == 0) {
		// 					if (max_s % 4 < 2) {
		// 						max_s = max_s - max_s % 4;
		// 					}
		// 					else {
		// 						max_s = max_s + 4 - max_s % 4;
		// 					}
		// 					img_data.chg_size = true;
		// 					ChangeImage(new_path, filePath, min_s, max_s, is_jh, img_data);
		// 				}
		// 				else if (max_s % 4 == 0 && min_s % 4 != 0) {
		// 					if (min_s % 4 < 2) {
		// 						min_s = min_s - min_s % 4;
		// 					}
		// 					else {
		// 						min_s = min_s + 4 - min_s % 4;
		// 					}
		// 					img_data.chg_size = true;
		// 					ChangeImage(new_path, filePath, min_s, max_s, is_jh, img_data);
		// 				}
		// 				else if (max_s % 4 != 0 && min_s % 4 != 0) {
		// 					if (min_s % 4 < 2) {
		// 						min_s = min_s - min_s % 4;
		// 						max_s = max_s - max_s % 4;
		// 					}
		// 					else {
		// 						min_s = min_s + 4 - min_s % 4;
		// 						max_s = max_s + 4 - max_s % 4;
		// 					}
		// 					img_data.chg_size = true;
		// 					ChangeImage(new_path, filePath, min_s, max_s, is_jh, img_data);
		// 				}
		// 			}
		// 		}
		// 	}
		// 	EditorUtility.ClearProgressBar();

		// 	EditorUtility.DisplayProgressBar("2.File Copy ", "2.File Copy ...", 0);
		// 	count = 0;

		// 	foreach (image_cls pp in change_list) {
		// 		count++;
		// 		EditorUtility.DisplayProgressBar("2.File Copy " + "(" + count + "/" + change_list.Count + ")", pp.old_path, count / (float)change_list.Count);
		// 		if (pp.is_have && pp.chg_size) {
		// 			System.IO.File.Copy(pp.new_path, pp.old_path, true);
		// 			AssetDatabase.ImportAsset(pp.old_path);
		// 		}
		// 	}

		// 	if (Directory.Exists (temp_dir)) {
		// 		Directory.Delete (temp_dir, true);
		// 	}

		// 	AssetDatabase.Refresh();

		// 	count = 0;
		// 	EditorUtility.DisplayProgressBar("3.Set Image ", "3.Set Image ..."  , 0);
		// 	foreach (image_cls pp in change_list) {
		// 		count++;
		// 		EditorUtility.DisplayProgressBar("3.Set Image " + "(" + count + "/" + change_list.Count + ")" , pp.old_path, count / (float)change_list.Count);
		// 		if (pp.is_have && pp.max_size != null ) {
		// 			TextureImporter textureImporter = AssetImporter.GetAtPath(pp.old_path) as TextureImporter;
		// 			TextureImporterPlatformSettings platformSettings = textureImporter.GetDefaultPlatformTextureSettings();
		// 			platformSettings.maxTextureSize = pp.max_size;
		// 			textureImporter.SetPlatformTextureSettings(platformSettings);
		// 			AssetDatabase.ImportAsset(pp.old_path);
		// 		}
		// 	}
		// 	EditorUtility.ClearProgressBar();
  //       }
  //   }

  //   static public System.Drawing.Image GetFile(string path)
  //   {
  //       FileStream stream = File.OpenRead(path);
  //       int fileLength = 0;
  //       fileLength = (int)stream.Length;
  //       Byte[] image = new Byte[fileLength];
  //       stream.Read(image, 0, fileLength);
  //       System.Drawing.Image result = System.Drawing.Image.FromStream(stream);
  //       stream.Close();
  //       return result;
  //   }
  //   static public void ChangeImage(string new_path, string old_path, int min_s, int max_s, bool is_jh, image_cls img_cls)
  //   {
  //   	Debug.Log("min_s = " + min_s + " max_s = " + max_s);
		// System.Drawing.Image img = GetFile(old_path);
  //       Size s;
  //       if (is_jh) {
  //       	s = new Size(min_s, max_s);
  //       }
  //       else {
		// 	s = new Size(max_s, min_s);
  //       }
		// try
		// {
 	// 		Bitmap bit = new Bitmap(img, s);
  //       	SaveImage(bit, new_path, old_path);
		// 	// var palette = bit.Palette;
		// }
		// catch
		// {
		// 	img_cls.is_have = false;
		// 	Debug.LogError("old_path=" + old_path);
		// }
  //   }
  //   static public void SaveImage(Bitmap bit, string new_path, string old_path)
  //   {
  //       bit.Save(new_path);
  //       bit.Dispose();
  //       //Debug.Log("大小调整:" + old_path);
  //       AssetDatabase.ImportAsset(new_path);
  //   }

  //   public static void GetTextureOriginalSize(TextureImporter ti, out int width, out int height)
  //   {
  //       if (ti == null)
  //       {
  //           width = 0;
  //           height = 0;
  //           return;
  //       }

  //       object[] args = new object[2] { 0, 0 };
  //       MethodInfo mi = typeof(TextureImporter).GetMethod("GetWidthAndHeight", BindingFlags.NonPublic | BindingFlags.Instance);
  //       mi.Invoke(ti, args);

  //       width = (int)args[0];
  //       height = (int)args[1];
  //   }


    static string temp_copy_dir = Application.dataPath + "/temp_copy_dir/";
    const string img_names = "xrxsfl_icon_50ylb#xrxsfl_icon_10ylb#xrxsfl_icon_30ylb#xrxsfl_jbzk_icon_jbzk#xrxsfl_icon_hb#act_ty_by_drop_7_1#com_award_icon_f";
    const string CopyTexturesTag = "Assets/Texture Tool/CopyTextures";
    [MenuItem(CopyTexturesTag, false, 62)]
    public static void CopyTextures()
	{
    	if (Directory.Exists (temp_copy_dir)) {
			Directory.Delete (temp_copy_dir, true);
		}
		Directory.CreateDirectory (temp_copy_dir);

		string[] name_list = img_names.Split('#');
		if (name_list.Length <= 0)
		{
			return;
		}
		Dictionary<string, string> asset_path = new Dictionary<string, string>();
		foreach(string name in name_list)
		{
			asset_path.Add(name, "");
		}

    	string[] assetGUIDArray = Selection.assetGUIDs;

        string assetPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]);
        Debug.Log(assetPath);
        List<string> filePaths = new List<string> ();
        string imgtype = "*.JPG|*.PNG";
		string[] ImageType = imgtype.Split ('|');
		for (int i = 0; i < ImageType.Length; i++) {
			string[] dirs = Directory.GetFiles(assetPath, ImageType [i], SearchOption.AllDirectories);
			for (int j = 0; j < dirs.Length; j++) {
				var name = Path.GetFileNameWithoutExtension (dirs[j]);
				if (asset_path.ContainsKey(name))
				{
					asset_path[ name ] = dirs[j];
				}
			}
		}

		foreach(KeyValuePair<String, String> keyValue in asset_path)
		{
			if (keyValue.Value != "")
			{
				string old_path = keyValue.Value;

				File.Copy(asset_path[keyValue.Key], temp_copy_dir + keyValue.Key + ".png", true);
			}
		}
	}
}