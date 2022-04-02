using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.ProjectWindowCallback;
using UnityEngine;

public class AddLuaScript
{
    [MenuItem("Assets/Create/Lua Panel Script", false, 81)]
    public static void CreatNewPanelLua()
    {
        ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0,
       ScriptableObject.CreateInstance<MyDoCreateScriptAsset>(),
       GetSelectedPathOrFallback() + "/New Lua.lua",
       null,
      "Assets/LuaFramework/Tool/Editor/LuaPanelTemplate.txt");
    }
    [MenuItem("Assets/Create/Lua Script", false, 81)]
    public static void CreatNewLua()
    {
        ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0,
       ScriptableObject.CreateInstance<MyDoCreateScriptAsset>(),
       GetSelectedPathOrFallback() + "/New Lua.lua",
       null,
      "Assets/LuaFramework/Tool/Editor/Template.txt");
    }

    [MenuItem("Assets/Create/Lua Manager Script", false, 81)]
    public static void CreatNewManagerLua()
    {
        ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0,
       ScriptableObject.CreateInstance<MyDoCreateScriptAsset>(),
       GetSelectedPathOrFallback() + "/New Lua.lua",
       null,
      "Assets/LuaFramework/Tool/Editor/LuaManagerTemplate.txt");
    }

    public static string GetSelectedPathOrFallback()
    {
        string path = "Assets";
        foreach (UnityEngine.Object obj in Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.Assets))
        {
            path = AssetDatabase.GetAssetPath(obj);
            if (!string.IsNullOrEmpty(path) && File.Exists(path))
            {
                path = Path.GetDirectoryName(path);
                break;
            }
        }
        return path;
    }
}

class MyDoCreateScriptAsset : EndNameEditAction
{
    public override void Action(int instanceId, string pathName, string resourceFile)
    {
        UnityEngine.Object o = CreateScriptAssetFromTemplate(pathName, resourceFile);
        ProjectWindowUtil.ShowCreatedAsset(o);
    }

    internal static UnityEngine.Object CreateScriptAssetFromTemplate(string pathName, string resourceFile)
    {
        string fullPath = Path.GetFullPath(pathName);
        StreamReader streamReader = new StreamReader(resourceFile);
        string text = streamReader.ReadToEnd();
        streamReader.Close();
        string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(pathName);

        string[] nn = pathName.Split('/');
        if (nn.Length >= 3)
        {        
            string[] mm = nn[2].Split('_');
            if (mm.Length == 2)
            {
                text = Regex.Replace(text, "#PATH#", mm[1]);
            }
        }
        text = Regex.Replace(text, "#NAME#", fileNameWithoutExtension);        
        text = Regex.Replace(text, "#TIME#", System.DateTime.Now.ToString("yyyy-MM-dd"));

        if (pathName.Contains("Assets/Game/Activity/"))
        {
            var arr = pathName.Split('/');
            if (arr.Length >= 4)
            {
                text = Regex.Replace(text, "#KEY#", arr[3]);
            }
        }
        
        bool encoderShouldEmitUTF8Identifier = false;
        bool throwOnInvalidBytes = false;
        UTF8Encoding encoding = new UTF8Encoding(encoderShouldEmitUTF8Identifier, throwOnInvalidBytes);
        bool append = false;
        StreamWriter streamWriter = new StreamWriter(fullPath, append, encoding);
        streamWriter.Write(text);
        streamWriter.Close();
        AssetDatabase.ImportAsset(pathName);
        return AssetDatabase.LoadAssetAtPath(pathName, typeof(UnityEngine.Object));
    }

}