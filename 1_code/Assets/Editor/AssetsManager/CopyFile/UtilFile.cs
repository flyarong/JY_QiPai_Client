using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
 
namespace UtilityEditFrameWork
{
    public class UtilFile
    {
        public static void CopyDirectory(string sourceDirectory, string destDirectory)
        {
            //判断源目录和目标目录是否存在，如果不存在，则创建一个目录
            if (!Directory.Exists(sourceDirectory))
            {
                Directory.CreateDirectory(sourceDirectory);
            }
            if (!Directory.Exists(destDirectory))
            {
                Directory.CreateDirectory(destDirectory);
            }
            //拷贝文件
            CopyFile(sourceDirectory, destDirectory);
            //拷贝子目录       
            //获取所有子目录名称
            string[] directionName = Directory.GetDirectories(sourceDirectory);
            foreach (string directionPath in directionName)
            {
                //根据每个子目录名称生成对应的目标子目录名称
                string directionPathTemp = Path.Combine(destDirectory, directionPath.Substring(sourceDirectory.Length + 1));// destDirectory + "\\" + directionPath.Substring(sourceDirectory.Length + 1);
                                                                                                                            //递归下去
                CopyDirectory(directionPath, directionPathTemp);
            }
        }
        public static void CopyFile(string sourceDirectory, string destDirectory)
        {
            //获取所有文件名称
            string[] fileName = Directory.GetFiles(sourceDirectory);
            foreach (string filePath in fileName)
            {
                //根据每个文件名称生成对应的目标文件名称
                string filePathTemp = Path.Combine(destDirectory, filePath.Substring(sourceDirectory.Length + 1));// destDirectory + "\\" + filePath.Substring(sourceDirectory.Length + 1);
                                                                                                                  //若不存在，直接复制文件；若存在，覆盖复制
                if (File.Exists(filePathTemp))
                {
                    File.Copy(filePath, filePathTemp, true);
                }
                else
                {
                    File.Copy(filePath, filePathTemp);
                }
            }
        }

        [MenuItem("Assets/Util/复制文件夹(复制依赖关系)",false,100)]
        [MenuItem("Util/复制文件夹(复制依赖关系)",false,100)]
        static private void CopFilesWithDependency()
        {
            string[] objects = Selection.assetGUIDs;
            string oldFolderPath = AssetDatabase.GUIDToAssetPath(objects[0]);
            string[] s = oldFolderPath.Split('/');
            string folderName = s[s.Length - 1];
            if (folderName.Contains("."))
            {
                Debug.LogError("该索引不是文件夹名字");
                return;
            }
            string copyedFolderPath = Path.GetFullPath(".") + Path.DirectorySeparatorChar + oldFolderPath;
            string newfolderName = folderName + "_copy";
            string tempFolderPath = Application.dataPath.Replace("Assets", "TempAssets") + "/" + oldFolderPath.Replace("Assets/", "").Replace(folderName, newfolderName);
            string newFoldrPath = tempFolderPath.Replace("TempAssets", "Assets");
 
            UtilFile.CopyDirectory(copyedFolderPath, newFoldrPath);
            //重新生成guids
            UtilGuids.RegenerateGuids(newFoldrPath);
            // UtilFile.CopyDirectory(copyedFolderPath, newFoldrPath);
            // AssetDatabase.DeleteAsset(oldFolderPath);
            // UtilFile.CopyDirectory(tempFolderPath, copyedFolderPath);
            AssetDatabase.Refresh();
            AssetDatabase.SaveAssets();
        }
    }
}