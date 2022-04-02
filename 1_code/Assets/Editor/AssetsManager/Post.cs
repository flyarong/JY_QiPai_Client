using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
using System;
 
public class  Post //: AssetPostprocessor 
{
//     private string[] Filters = {
//         "LoadingPanel"
//     };
// 	void OnPostprocessTexture (Texture2D texture)
// 	{
//         TextureImporter textureImporter  = assetImporter as TextureImporter;
//         if (textureImporter.textureType != TextureImporterType.Sprite) return;
//         for(int idx = 0; idx < Filters.Length; ++idx)
//         {
//             if(assetPath.IndexOf(Filters[idx]) >= 0)
//             {
//                 Debug.Log("filter jump:" + assetPath);
//                 return;
//             }
//         }

//         string AtlasName = "";
//         if (texture.width <= 512 && texture.height <= 512)
//         {
//             string[] pathArr = assetPath.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//             if (pathArr[1] == "Entry" || pathArr[1] == "Unused" || pathArr[1] == "Game")
//             {
//                 for (int i = 1; i < pathArr.Length - 1; i++)
//                 {
//                     AtlasName = AtlasName + pathArr[i];
//                     if (i < pathArr.Length -2) {
//                         AtlasName = AtlasName + "_";
//                     }
//                 }
//             }
//         }
//         if (textureImporter.spritePackingTag == AtlasName) return;
//         textureImporter.spritePackingTag = AtlasName;
// 		textureImporter.mipmapEnabled = false;
// 	}
}