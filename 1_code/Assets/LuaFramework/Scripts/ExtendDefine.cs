using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;

public static class ExtendDefine
{
    /// <summary>
    /// 扩展 GameObject 方法，根据字符串添加脚本
    /// </summary>
    /// <param name="obj">扩展的对象</param>
    /// <param name="className">图片资源名称</param>
    public static object AddComponentEX(this GameObject obj, string className)
    {
        Type t = Type.GetType(className);
        Debug.Log(t);
        Component c = obj.AddComponent(t);
        if (c == null)
        {
            Debug.Log("<color=red>AddComponent error " + className + "</color>");
        }
        return c;
        //MethodInfo mi = obj.GetType().GetMethod("AddComponent", BindingFlags.OptionalParamBinding);
        //if (mi != null)
        //{
        //    return mi.MakeGenericMethod(new Type[] { Type.GetType(className) }).Invoke(null, null);
        //}
        //else
        //{
        //    Debug.Log("<color=red>AddComponent null " + className + "</color>");
        //    return null;
        //}
    }

    public static void AddOptionData(this Dropdown obj, Dropdown.OptionData data)
    {
        if(data != null)
        {
            obj.options.Add(data);
        }
    }
}
