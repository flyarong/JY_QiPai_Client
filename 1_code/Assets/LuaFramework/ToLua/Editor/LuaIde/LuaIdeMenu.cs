/*
Copyright (c) 2015-2017 topameng(topameng@qq.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//打开开关没有写入导出列表的纯虚类自动跳过
//#define JUMP_NODEFINED_ABSTRACT         

using UnityEngine;
using UnityEditor;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using System.IO;
using System.Diagnostics;
using LuaInterface;

using Object = UnityEngine.Object;
using Debug = UnityEngine.Debug;
using Debugger = LuaInterface.Debugger;
using System.Threading;


[InitializeOnLoad]
public static class LuaIdeMenu
{
    //不需要导出或者无法导出的类型
    public static List<Type> dropType = new List<Type>
    {
        typeof(ValueType),                                  //不需要
#if !UNITY_5
        typeof(Motion),                                     //很多平台只是空类
#endif
        typeof(UnityEngine.YieldInstruction),               //无需导出的类      
        typeof(UnityEngine.WaitForEndOfFrame),              //内部支持
        typeof(UnityEngine.WaitForFixedUpdate),
        typeof(UnityEngine.WaitForSeconds),
        typeof(UnityEngine.Mathf),                          //lua层支持                
        //typeof(Plane),                                      
        //typeof(LayerMask),                                  
        //typeof(Vector3),
        //typeof(Vector4),
        //typeof(Vector2),
        //typeof(Quaternion),
        //typeof(Ray),
        //typeof(Bounds),
        //typeof(Color),                                    
        //typeof(Touch),
        //typeof(RaycastHit),                                 
        typeof(TouchPhase),     
        //typeof(LuaInterface.LuaOutMetatable),               //手写支持
        typeof(LuaInterface.NullObject),
        typeof(System.Array),
        typeof(System.Reflection.MemberInfo),
        typeof(System.Reflection.BindingFlags),
        typeof(LuaClient),
        typeof(LuaInterface.LuaFunction),
        typeof(LuaInterface.LuaTable),
        typeof(LuaInterface.LuaThread),
        typeof(LuaInterface.LuaByteBuffer),                 //只是类型标识符
        typeof(DelegateFactory),                            //无需导出，导出类支持lua函数转换为委托。如UIEventListener.OnClick(luafunc)
    };

    //可以导出的内部支持类型
    public static List<Type> baseType = new List<Type>
    {
        typeof(System.Object),
        typeof(System.Delegate),
        typeof(System.String),
        typeof(System.Enum),
        typeof(System.Type),
        typeof(System.Collections.IEnumerator),
        typeof(UnityEngine.Object),
        typeof(LuaInterface.EventObject),
        typeof(LuaInterface.LuaMethod),
        typeof(LuaInterface.LuaProperty),
        typeof(LuaInterface.LuaField),
        typeof(LuaInterface.LuaConstructor),
    };

    private static bool beAutoGen = false;
    static List<ToLuaMenu.BindType> allTypes = new List<ToLuaMenu.BindType>();




    static void AutoAddBaseType(ToLuaMenu.BindType bt, bool beDropBaseType)
    {
        Type t = bt.baseType;

        if (t == null)
        {
            return;
        }

        if (CustomSettings.sealedList.Contains(t))
        {
            CustomSettings.sealedList.Remove(t);
            Debugger.LogError("{0} not a sealed class, it is parent of {1}", LuaMisc.GetTypeName(t), bt.name);
        }

        if (t.IsInterface)
        {
            Debugger.LogWarning("{0} has a base type {1} is Interface, use SetBaseType to jump it", bt.name, t.FullName);
            bt.baseType = t.BaseType;
        }
        else if (dropType.IndexOf(t) >= 0)
        {
            Debugger.LogWarning("{0} has a base type {1} is a drop type", bt.name, t.FullName);
            bt.baseType = t.BaseType;
        }
        else if (!beDropBaseType || baseType.IndexOf(t) < 0)
        {
            int index = allTypes.FindIndex((iter) => { return iter.type == t; });

            if (index < 0)
            {
#if JUMP_NODEFINED_ABSTRACT
                if (t.IsAbstract && !t.IsSealed)
                {
                    Debugger.LogWarning("not defined bindtype for {0}, it is abstract class, jump it, child class is {1}", t.FullName, bt.name);
                    bt.baseType = t.BaseType;
                }
                else
                {
                    Debugger.LogWarning("not defined bindtype for {0}, autogen it, child class is {1}", t.FullName, bt.name);
                    bt = new BindType(t);
                    allTypes.Add(bt);
                }
#else
                Debugger.LogWarning("not defined bindtype for {0}, autogen it, child class is {1}", t.FullName, bt.name);
                bt = new ToLuaMenu.BindType(t);
                allTypes.Add(bt);
#endif
            }
            else
            {
                return;
            }
        }
        else
        {
            return;
        }

        AutoAddBaseType(bt, beDropBaseType);
    }

    static ToLuaMenu.BindType[] GenBindTypes(ToLuaMenu.BindType[] list, bool beDropBaseType = true)
    {
        allTypes = new List<ToLuaMenu.BindType>(list);

        for (int i = 0; i < list.Length; i++)
        {
            for (int j = i + 1; j < list.Length; j++)
            {
                if (list[i].type == list[j].type)
                    throw new NotSupportedException("Repeat BindType:" + list[i].type);
            }

            if (dropType.IndexOf(list[i].type) >= 0)
            {
                Debug.LogWarning(list[i].type.FullName + " in dropType table, not need to export");
                allTypes.Remove(list[i]);
                continue;
            }
            else if (beDropBaseType && baseType.IndexOf(list[i].type) >= 0)
            {
                Debug.LogWarning(list[i].type.FullName + " is Base Type, not need to export");
                allTypes.Remove(list[i]);
                continue;
            }
            else if (list[i].type.IsEnum)
            {
                continue;
            }

            AutoAddBaseType(list[i], beDropBaseType);
        }

        return allTypes.ToArray();
    }

    /*[MenuItem("LuaIde/LuaIde Api", false, 1)]
    public static void GenerateClassWraps()
    {
        if (!beAutoGen && EditorApplication.isCompiling)
        {

            EditorUtility.DisplayDialog("警告", "请等待编辑器完成编译再执行此功能", "确定");
            return;
        }
        LuaIdeClassDoc.checkDoc();
        LuaIdeInfo.luaInfos = new List<LuaIdeInfo>();
        if (!File.Exists(CustomSettings.saveDir))
        {
            Directory.CreateDirectory(CustomSettings.saveDir);
        }
        List<ToLuaMenu.BindType> gtlist = new List<ToLuaMenu.BindType>(){

            CustomSettings._GT(typeof(Vector3)),
            CustomSettings._GT(typeof(Vector2)),
            CustomSettings._GT(typeof(Vector4)),
            CustomSettings._GT(typeof(Color)),
            CustomSettings._GT(typeof(Quaternion)),
            CustomSettings._GT(typeof(Ray)),
            CustomSettings._GT(typeof(Bounds)),
            CustomSettings._GT(typeof(Touch)),
            CustomSettings._GT(typeof(RaycastHit)),
            CustomSettings._GT(typeof(LayerMask)),

        };
        for (int i = 0; i < CustomSettings.customTypeList.Length; i++)
        {
            var type = CustomSettings.customTypeList[i];
            bool result = false;
            foreach (var v in gtlist)
            {
                if (v.type == type.type)
                {
                    result = true;
                    break;
                }
            }

            if (!result)
            {
                gtlist.Add(CustomSettings.customTypeList[i]);
            }
        }


        allTypes.Clear();
        ToLuaMenu.BindType[] typeList = gtlist.ToArray();

        ToLuaMenu.BindType[] list = GenBindTypes(typeList);
        LuaIdeExport.allTypes.AddRange(baseType);

        for (int i = 0; i < list.Length; i++)
        {
            LuaIdeExport.allTypes.Add(list[i].type);
        }
        StringBuilder luasb = new StringBuilder();
        for (int i = 0; i < list.Length; i++)
        {
            LuaIdeExport.Clear();
            LuaIdeExport.className = list[i].name;
            LuaIdeExport.type = list[i].type;
            LuaIdeExport.isStaticClass = list[i].IsStatic;
            LuaIdeExport.baseType = list[i].baseType;
            LuaIdeExport.wrapClassName = list[i].wrapName;
            LuaIdeExport.libClassName = list[i].libName;
            LuaIdeExport.extendList = list[i].extendList;
            if (LuaIdeExport.className == "Input")
            {
                string ss = "1";
            }
            LuaIdeExport.Generate(CustomSettings.saveDir);
            if (LuaIdeInfo.luaInfo.tableName == null)
            {
                string ss = "1";
            }
            LuaIdeInfo.luaInfos.Add(LuaIdeInfo.luaInfo);

        }
        foreach (LuaIdeInfo luainfo in LuaIdeInfo.luaInfos)
        {
            if (luainfo.tableName == "UnityEngine.CameraClearFlags")
            {
                string ss = "1";
            }
            if (luainfo.tableName != null)
            {
                luasb.AppendLine(luainfo.toStr());
            }

        }

        DirectoryInfo dirinfo = new DirectoryInfo(Application.dataPath);
        string dir = dirinfo.FullName + "/LuaFramework/Lua/";
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }
        string filename = dir + "uluaApi.lua";
        using (StreamWriter textWriter = new StreamWriter(filename, false, Encoding.UTF8))
        {
            textWriter.Write(luasb.ToString());
            textWriter.Flush();
            textWriter.Close();
        }
        Debug.Log("Api 创建成功," + filename);
        LuaIdeExport.allTypes.Clear();
        allTypes.Clear();
        AssetDatabase.Refresh();
    }*/


}
