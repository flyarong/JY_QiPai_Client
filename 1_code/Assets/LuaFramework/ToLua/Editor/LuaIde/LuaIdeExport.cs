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
using UnityEngine;
using System;
using System.Collections;
using System.Text;
using System.Reflection;
using System.Collections.Generic;
using LuaInterface;

using Object = UnityEngine.Object;
using System.IO;
using System.Text.RegularExpressions;
using System.Runtime.CompilerServices;

public static class LuaIdeExport 
{
    public static string className = string.Empty;
    public static Type type = null;
    public static Type baseType = null;
        
    public static bool isStaticClass = true;    

    static HashSet<string> usingList = new HashSet<string>();
    static MetaOp op = MetaOp.None;    
   
    static List<MethodInfo> methods = new List<MethodInfo>();
    static Dictionary<string, int> nameCounter = new Dictionary<string, int>();
    static FieldInfo[] fields = null;
    static PropertyInfo[] props = null;    
    static List<PropertyInfo> propList = new List<PropertyInfo>();  //非静态属性
    static List<PropertyInfo> allProps = new List<PropertyInfo>();
    static EventInfo[] events = null;
    static List<EventInfo> eventList = new List<EventInfo>();
    static List<ConstructorInfo> ctorList = new List<ConstructorInfo>();
    static List<ConstructorInfo> ctorExtList = new List<ConstructorInfo>();
    static List<MethodInfo> getItems = new List<MethodInfo>();   //特殊属性
    static List<MethodInfo> setItems = new List<MethodInfo>();

    static BindingFlags binding = BindingFlags.Public | BindingFlags.Static | BindingFlags.IgnoreCase;
        
    static ObjAmbig ambig = ObjAmbig.NetObj;    
    //wrapClaaName + "Wrap" = 导出文件名，导出类名
    public static string wrapClassName = "";

    public static string libClassName = "";
    public static string extendName = "";
    public static Type extendType = null;

    public static HashSet<Type> eventSet = new HashSet<Type>();

    public static List<Type> extendList = new List<Type>();
    public static List<MethodInfo> extendMethod = new List<MethodInfo>();    

    public static List<string> memberFilter = new List<string>
    {
        "String.Chars",
        "Directory.SetAccessControl",
        "File.GetAccessControl",
        "File.SetAccessControl",
        //UnityEngine
        "AnimationClip.averageDuration",
        "AnimationClip.averageAngularSpeed",
        "AnimationClip.averageSpeed",
        "AnimationClip.apparentSpeed",
        "AnimationClip.isLooping",
        "AnimationClip.isAnimatorMotion",
        "AnimationClip.isHumanMotion",
        "AnimatorOverrideController.PerformOverrideClipListCleanup",
        "Caching.SetNoBackupFlag",
        "Caching.ResetNoBackupFlag",
        "Light.areaSize",
        "Light.lightmappingMode",
        "Light.lightmapBakeType",
        "Security.GetChainOfTrustValue",
        "Texture2D.alphaIsTransparency",
        "WWW.movie",
        "WebCamTexture.MarkNonReadable",
        "WebCamTexture.isReadable",
        "Graphic.OnRebuildRequested",
        "Text.OnRebuildRequested",
        "Resources.LoadAssetAtPath",
        "Application.ExternalEval",
        "Handheld.SetActivityIndicatorStyle",
        "CanvasRenderer.OnRequestRebuild",
        "CanvasRenderer.onRequestRebuild",
        "Terrain.bakeLightProbesForTrees",
        "MonoBehaviour.runInEditMode",
        //NGUI
        "UIInput.ProcessEvent",
        "UIWidget.showHandlesWithMoveTool",
        "UIWidget.showHandles",
        "Input.IsJoystickPreconfigured",
        "UIDrawCall.isActive"
    };

	public static List<MemberInfo> memberInfoFilter = new List<MemberInfo>
	{
        //可精确查找一个函数
		//Type.GetMethod(string name, BindingFlags bindingAttr, Binder binder, CallingConventions callConvention, Type[] types, ParameterModifier[] modifiers);
    };

    public static bool IsMemberFilter(MemberInfo mi)
    {
		return memberInfoFilter.Contains(mi) || memberFilter.Contains(type.Name + "." + mi.Name);
    }

    public static bool IsMemberFilter(Type t)
    {
        string name = LuaMisc.GetTypeName(t);
        return memberInfoFilter.Contains(t) || memberFilter.Find((p) => { return name.Contains(p); }) != null;
    }

    static LuaIdeExport()
    {
        Debugger.useLog = true;
    }

    public static void Clear()
    {
        LuaIdeInfo.luaInfo = new LuaIdeInfo();
        className = null;
        type = null;
        baseType = null;
        isStaticClass = false;        
        usingList.Clear();
        op = MetaOp.None;    
      
        fields = null;
        props = null;
        methods.Clear();
        allProps.Clear();
        propList.Clear();
        eventList.Clear();
        ctorList.Clear();
        ctorExtList.Clear();        
        ambig = ObjAmbig.NetObj;
        wrapClassName = "";
        libClassName = "";
        extendName = "";
        eventSet.Clear();
        extendType = null;
        nameCounter.Clear();
        events = null;
        getItems.Clear();
        setItems.Clear();
    }

    private static MetaOp GetOp(string name)
    {
        if (name == "op_Addition")
        {
            return MetaOp.Add;
        }
        else if (name == "op_Subtraction")
        {
            return MetaOp.Sub;
        }
        else if (name == "op_Equality")
        {
            return MetaOp.Eq;
        }
        else if (name == "op_Multiply")
        {
            return MetaOp.Mul;
        }
        else if (name == "op_Division")
        {
            return MetaOp.Div;
        }
        else if (name == "op_UnaryNegation")
        {
            return MetaOp.Neg;
        }
        else if (name == "ToString" && !isStaticClass)
        {
            return MetaOp.ToStr;
        }

        return MetaOp.None;
    }

    //操作符函数无法通过继承metatable实现
    static void GenBaseOpFunction(List<MethodInfo> list)
    {        
        Type baseType = type.BaseType;

        while (baseType != null)
        {
            if (allTypes.IndexOf(baseType) >= 0)
            {
                MethodInfo[] methods = baseType.GetMethods(BindingFlags.Instance | BindingFlags.Public | BindingFlags.Static | BindingFlags.IgnoreCase);

                for (int i = 0; i < methods.Length; i++)
                {
                    MetaOp baseOp = GetOp(methods[i].Name);

                    if (baseOp != MetaOp.None && (op & baseOp) == 0)
                    {
                        if (baseOp != MetaOp.ToStr)
                        {
                            list.Add(methods[i]);
                        }

                        op |= baseOp;
                    }
                }
            }

            baseType = baseType.BaseType;
        }
    }

    public static void Generate(string dir)
    {
        Type iterType = typeof(System.Collections.IEnumerator);

        if (type.IsInterface && type != iterType)
        {
            return;
        }

        if (type != iterType && iterType.IsAssignableFrom(type))
        {
            return;
        }

        //Debugger.Log("Begin Generate lua Wrap for class {0}", className);        
        
        usingList.Add("System");                

        if (wrapClassName == "")
        {
            wrapClassName = className;
        }

        if (type.IsEnum)
        {

            LuaIdeInfo.luaInfo.tableName = className;
            GenEnum();                                    
          
            return;
        }

        InitMethods();
        InitPropertyList();
        InitCtorList();

       

        GenRegisterFunction();
        GenConstructFunction();
      
    }

    //记录所有的导出类型
    public static List<Type> allTypes = new List<Type>();

    static bool BeDropMethodType(MethodInfo md)
    {
        Type t = md.DeclaringType;

        if (t == type)
        {
            return true;
        }

        return allTypes.IndexOf(t) < 0;        
    }

    //是否为委托类型，没处理废弃
    public static bool IsDelegateType(Type t)
    {
        if (!typeof(System.MulticastDelegate).IsAssignableFrom(t) || t == typeof(System.MulticastDelegate))
        {
            return false;
        }        

        if (IsMemberFilter(t))
        {
            return false;
        }

        return true;
    }

   

    static void InitMethods()
    {
        bool flag = false;

        if (baseType != null || isStaticClass)
        {
            binding |= BindingFlags.DeclaredOnly;
            flag = true;
        }

        List<MethodInfo> list = new List<MethodInfo>();
        list.AddRange(type.GetMethods(BindingFlags.Instance | binding));

        for (int i = list.Count - 1; i >= 0; --i)
        {
            //去掉操作符函数
            if (list[i].Name.StartsWith("op_") || list[i].Name.StartsWith("add_") || list[i].Name.StartsWith("remove_"))
            {
                if (!IsNeedOp(list[i].Name))
                {
                    list.RemoveAt(i);
                }

                continue;
            }

            //扔掉 unity3d 废弃的函数                
            if (IsObsolete(list[i]))
            {
                list.RemoveAt(i);
            }
        }

        PropertyInfo[] ps = type.GetProperties();

        for (int i = 0; i < ps.Length; i++)
        {
            if (IsObsolete(ps[i]))
            {
                list.RemoveAll((p) => { return p == ps[i].GetGetMethod() || p == ps[i].GetSetMethod(); });
            }
            else
            {
                MethodInfo md = ps[i].GetGetMethod();

                if (md != null)
                {
                    int index = list.FindIndex((m) => { return m == md; });

                    if (index >= 0)
                    {
                        if (md.GetParameters().Length == 0)
                        {
                            list.RemoveAt(index);
                        }
                        else if (HasGetIndex(md))
                        {
                            getItems.Add(md);
                        }
                    }
                }

                md = ps[i].GetSetMethod();

                if (md != null)
                {
                    int index = list.FindIndex((m) => { return m == md; });

                    if (index >= 0)
                    {
                        if (md.GetParameters().Length == 1)
                        {
                            list.RemoveAt(index);
                        }
                        else if (HasSetIndex(md))
                        {
                            setItems.Add(md);
                        }
                    }
                }
            }
        }

        if (flag && !isStaticClass)
        {
            List<MethodInfo> baseList = new List<MethodInfo>(type.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static | BindingFlags.IgnoreCase));

            for (int i = baseList.Count - 1; i >= 0; i--)
            {
                if (BeDropMethodType(baseList[i]))
                {
                    baseList.RemoveAt(i);
                }
            }

            HashSet<MethodInfo> addList = new HashSet<MethodInfo>();

            for (int i = 0; i < list.Count; i++)
            {
                List<MethodInfo> mds = baseList.FindAll((p) => { return p.Name == list[i].Name; });

                for (int j = 0; j < mds.Count; j++)
                {
                    addList.Add(mds[j]);
                    baseList.Remove(mds[j]);
                }
            }

            list.AddRange(addList);
        }

        for (int i = 0; i < list.Count; i++)
        {
            GetDelegateTypeFromMethodParams(list[i]);
        }

        ProcessExtends(list);
        GenBaseOpFunction(list);
        methods = list;
    }

    static void InitPropertyList()
    {
        props = type.GetProperties(BindingFlags.GetProperty | BindingFlags.SetProperty | BindingFlags.Instance | binding);
        propList.AddRange(type.GetProperties(BindingFlags.GetProperty | BindingFlags.SetProperty | BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase));
        fields = type.GetFields(BindingFlags.GetField | BindingFlags.SetField | BindingFlags.Instance | binding);
        events = type.GetEvents(BindingFlags.DeclaredOnly | BindingFlags.Instance | BindingFlags.Public | BindingFlags.Static);
        eventList.AddRange(type.GetEvents(BindingFlags.DeclaredOnly | BindingFlags.Instance | BindingFlags.Public));

        List<FieldInfo> fieldList = new List<FieldInfo>();
        fieldList.AddRange(fields);

        for (int i = fieldList.Count - 1; i >= 0; i--)
        {
            if (IsObsolete(fieldList[i]))
            {
                fieldList.RemoveAt(i);
            }
            else if (IsDelegateType(fieldList[i].FieldType))
            {
                eventSet.Add(fieldList[i].FieldType);
            }
        }

        fields = fieldList.ToArray();

        List<PropertyInfo> piList = new List<PropertyInfo>();
        piList.AddRange(props);

        for (int i = piList.Count - 1; i >= 0; i--)
        {
            if (IsObsolete(piList[i]))
            {
                piList.RemoveAt(i);
            }
            else if (piList[i].Name == "Item" && IsItemThis(piList[i]))
            {
                piList.RemoveAt(i);
            }
            else if(piList[i].GetGetMethod() != null && HasGetIndex(piList[i].GetGetMethod()))
            {
                piList.RemoveAt(i);
            }
            else if (piList[i].GetSetMethod() != null && HasSetIndex(piList[i].GetSetMethod()))
            {
                piList.RemoveAt(i);
            }
            else if (IsDelegateType(piList[i].PropertyType))
            {
                eventSet.Add(piList[i].PropertyType);
            }
        }

        props = piList.ToArray();

        for (int i = propList.Count - 1; i >= 0; i--)
        {
            if (IsObsolete(propList[i]))
            {
                propList.RemoveAt(i);
            }
        }

        allProps.AddRange(props);
        allProps.AddRange(propList);

        List<EventInfo> evList = new List<EventInfo>();
        evList.AddRange(events);

        for (int i = evList.Count - 1; i >= 0; i--)
        {
            if (IsObsolete(evList[i]))
            {
                evList.RemoveAt(i);
            }
            else if (IsDelegateType(evList[i].EventHandlerType))
            {
                eventSet.Add(evList[i].EventHandlerType);
            }
        }

        events = evList.ToArray();

        for (int i = eventList.Count - 1; i >= 0; i--)
        {
            if (IsObsolete(eventList[i]))
            {
                eventList.RemoveAt(i);
            }
        }
    }

    static void SaveFile(string file)
    {        
       
    }

    static string GetMethodName(MethodInfo md)
    {
        if (md.Name.StartsWith("op_"))
        {
            return md.Name;
        }

        object[] attrs = md.GetCustomAttributes(true);

        for (int i = 0; i < attrs.Length; i++)
        {            
            if (attrs[i] is LuaRenameAttribute)
            {
                LuaRenameAttribute attr = attrs[i] as LuaRenameAttribute;
                return attr.Name;
            }
        }

        return md.Name;
    }

    static bool HasGetIndex(MemberInfo md)
    {
        if (md.Name == "get_Item")
        {
            return true;
        }

        object[] attrs = type.GetCustomAttributes(true);

        for (int i = 0; i < attrs.Length; i++)
        {
            if (attrs[i] is DefaultMemberAttribute)
            {
                return md.Name == "get_ItemOf";
            }
        }

        return false;
    }

    static bool HasSetIndex(MemberInfo md)
    {
        if (md.Name == "set_Item")
        {
            return true;
        }

        object[] attrs = type.GetCustomAttributes(true);

        for (int i = 0; i < attrs.Length; i++)
        {
            if (attrs[i] is DefaultMemberAttribute)
            {
                return md.Name == "set_ItemOf";
            }
        }

        return false;
    }

    static bool IsThisArray(MethodInfo md, int count)
    {
        ParameterInfo[] pis = md.GetParameters();

        if (pis.Length != count)
        {
            return false;
        }

        if (pis[0].ParameterType == typeof(int))
        {
            return true;
        }

        return false;
    }

    static void GenRegisterFuncItems()
    {
        //bool isList = type.IsGenericType && type.GetGenericTypeDefinition() == typeof(List<>);
        //注册库函数
        for (int i = 0; i < methods.Count; i++)
        {
            MethodInfo m = methods[i];
            int count = 1;

            if (IsGenericMethod(m))
            {
                continue;
            }

            string name = GetMethodName(m);

            if (!nameCounter.TryGetValue(name, out count))
            {
                if (name == "get_Item" && IsThisArray(m, 1))
                {

                    LuaIdeInfo.luaInfo.addFun(m, "geti");
                }
                else if (name == "set_Item" && IsThisArray(m, 2))
                {
                    LuaIdeInfo.luaInfo.addFun(m, "seti");
                   
                }

                if (!name.StartsWith("op_"))
                {

                    LuaIdeInfo.luaInfo.addFun(m, name);
                   
                }

                nameCounter[name] = 1;
            }
            else
            {
                nameCounter[name] = count + 1;
            }
        }

        if (ctorList.Count > 0 || type.IsValueType || ctorExtList.Count > 0)
        {
            LuaIdeInfo.luaInfo.isNewFun = true;
               
        }
    }

    

    static bool IsItemThis(PropertyInfo info)
    {        
        MethodInfo md = info.GetGetMethod();

        if (md != null)
        {
            return md.GetParameters().Length != 0;
        }

        md = info.GetSetMethod();

        if (md != null)
        {
            return md.GetParameters().Length != 1;
        }

        return true;
    }

    static void GenRegisterVariables()
    {
        if (fields.Length == 0 && props.Length == 0 && events.Length == 0 && isStaticClass && baseType == null)
        {
            return;
        }

        for (int i = 0; i < fields.Length; i++)
        {
            if (fields[i].IsLiteral || fields[i].IsPrivate || fields[i].IsInitOnly)
            {
                if (fields[i].IsLiteral && fields[i].FieldType.IsPrimitive && !fields[i].FieldType.IsEnum)
                {
                    //k0204
                    double d = Convert.ToDouble(fields[i].GetValue(null));



                    LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
                    {
                        fieldInfo = fields[i],
                        value = d.ToString(),
                         isget = true
                    });
                }
                else
                {
                    LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
                    {
                        fieldInfo = fields[i],
                        isget = true
                    });
                    //k0204
                   
                }
            }
            else
            {
                LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
                {
                    fieldInfo = fields[i],
                    isget = true,
                    isset = true
                });
                
            }
        }

        for (int i = 0; i < props.Length; i++)
        {
            if (props[i].CanRead && props[i].CanWrite && props[i].GetSetMethod(true).IsPublic)
            {
                MethodInfo md = methods.Find((p) => { return p.Name == "get_" + props[i].Name; });
                string get = md == null ? "get" : "_get";                
                md = methods.Find((p) => { return p.Name == "set_" + props[i].Name; });
                string set = md == null ? "set" : "_set";

                LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
                {
                    
                    isget = true,
                    isset = true,
                    propertyInfo = props[i],
                });
            }
            else if (props[i].CanRead)
            {
                MethodInfo md = methods.Find((p) => { return p.Name == "get_" + props[i].Name; });

                LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
                {
                    propertyInfo = props[i],
                    isget = true
                   
                });
            }
            else if (props[i].CanWrite)
            {
                //k0204
                MethodInfo md = methods.Find((p) => { return p.Name == "set_" + props[i].Name; });


                LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
                {
                     propertyInfo = props[i],
                    isset = true
                });
            }
        }

        for (int i = 0; i < events.Length; i++)
        {
            LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
            {
                eventInfo = events[i],
                isset = true,
                isget = true
            });
              
        }  
    }   

    static void GenRegisterEventTypes()
    {
        List<Type> list = new List<Type>();

        foreach (Type t in eventSet)
        {
            string funcName = null;
            string space = GetNameSpace(t, out funcName);

            if (space != className)
            {
                list.Add(t);
                continue;
            }
                        
            funcName = ConvertToLibSign(funcName);            
            int index = Array.FindIndex<DelegateType>(CustomSettings.customDelegateList, (p) => { return p.type == t; });
            string abr = null;
            if (index >= 0) abr = CustomSettings.customDelegateList[index].abr;
            abr = abr == null ? funcName : abr;
            funcName = ConvertToLibSign(space) + "_" + funcName;

           
            //k0204
            LuaIdeInfo.luaInfo.events.Add(abr);
        }

        for (int i = 0; i < list.Count; i++)
        {
            eventSet.Remove(list[i]);
        }
    }
   

    static void GenRegisterFunction()
    {
        if (isStaticClass)
        {
            LuaIdeInfo.luaInfo.tableName = libClassName;
            LuaIdeInfo.luaInfo.isStaticClass = true;       
        }
        else if (!type.IsGenericType)
        {
            if (baseType == null)
            {
                LuaIdeInfo.luaInfo.tableName = className;
               
            }
            else
            {
                LuaIdeInfo.luaInfo.tableName = className;
                LuaIdeInfo.luaInfo.baseName = GetBaseTypeStr(baseType);
               
            }
        }
        else
        {
            if (baseType == null)
            {
                LuaIdeInfo.luaInfo.tableName = className;
               
            }
            else
            {
                LuaIdeInfo.luaInfo.tableName = libClassName;
                LuaIdeInfo.luaInfo.baseName = GetBaseTypeStr(baseType);
               
            }
        }
        if (LuaIdeInfo.luaInfo.tableName == "Input") { 
        
            
            string dd = "s";

        }

        GenRegisterFuncItems();
        GenRegisterVariables();
        GenRegisterEventTypes();            //注册事件类型
    }

    static bool IsParams(ParameterInfo param)
    {
        return param.GetCustomAttributes(typeof(ParamArrayAttribute), false).Length > 0;
    }

    

    //没有未知类型的模版类型List<int> 返回false, List<T>返回true
    static bool IsGenericConstraintType(Type t)
    {
        if (!t.IsGenericType)
        {
            return t.IsGenericParameter || t == typeof(System.ValueType);
        }

        Type[] types = t.GetGenericArguments();

        for (int i = 0; i < types.Length; i++)
        {
            Type t1 = types[i];

            if (t1.IsGenericParameter || t1 == typeof(System.ValueType))
            {
                return true;
            }

            if (IsGenericConstraintType(t1))
            {
                return true;
            }
        }

        return false;
    }

    static bool IsGenericConstraints(Type[] constraints)
    {
        for (int i = 0; i < constraints.Length; i++)
        {
            if (!IsGenericConstraintType(constraints[i]))
            {
                return false;
            }
        }

        return true;
    }

    static bool IsGenericMethod(MethodInfo md)
    {
        if (md.IsGenericMethod)
        {
            Type[] gts = md.GetGenericArguments();
            List<ParameterInfo> list = new List<ParameterInfo>(md.GetParameters());

            for (int i = 0; i < gts.Length; i++)
            {
                Type[] ts = gts[i].GetGenericParameterConstraints();

                if (ts == null || ts.Length == 0 || IsGenericConstraints(ts))
                {
                    return true;
                }

                ParameterInfo p = list.Find((iter) => { return iter.ParameterType == gts[i]; });

                if (p == null)
                {
                    return true;
                }

                list.RemoveAll((iter) => { return iter.ParameterType == gts[i]; });
            }

            for (int i = 0; i < list.Count; i++)
            {                
                Type t = list[i].ParameterType;

                if (IsGenericConstraintType(t))
                {
                    return true;
                }
            }
        }

        return false;
    }

  

    static bool IsSealedType(Type t)
    {
        if (t.IsSealed || CustomSettings.sealedList.Contains(t))
        {
            return true;
        }

        if (t.IsGenericType && (t.GetGenericTypeDefinition() == typeof(List<>) || t.GetGenericTypeDefinition() == typeof(Dictionary<,>)))
        {
            return true;
        }

        return false;
    }

    static string GetPushFunction(Type t, bool isByteBuffer = false)
    {        
        if (t.IsEnum || t.IsPrimitive || t == typeof(string) || t == typeof(LuaTable) || t == typeof(LuaCSFunction) || t == typeof(LuaThread) 
            || t == typeof(Type) || t == typeof(IntPtr) || typeof(Delegate).IsAssignableFrom(t) || t == typeof(LuaByteBuffer) // || t == typeof(LuaInteger64)
            || t == typeof(Vector3) || t == typeof(Vector2) || t == typeof(Vector4) || t == typeof(Quaternion) || t == typeof(Color) || t == typeof(RaycastHit)
            || t == typeof(Ray) || t == typeof(Touch) || t == typeof(Bounds) || t == typeof(object))
        {
            return "Push";
        }
        else if (t.IsArray || t == typeof(System.Array))
        {
            return "Push";
        }
        else if (typeof(IEnumerator).IsAssignableFrom(t))
        {
            return "Push";
        }
        else if (t == typeof(LayerMask))
        {
            return "PushLayerMask";
        }
        else if (typeof(UnityEngine.Object).IsAssignableFrom(t) || typeof(UnityEngine.TrackedReference).IsAssignableFrom(t))
        {
            return IsSealedType(t) ? "PushSealed" : "Push";
        }
        else if (t.IsValueType)
        {
            if (t.IsGenericType && t.GetGenericTypeDefinition() == typeof(Nullable<>))
            {
                return "PusNullable";
            }

            return "PushValue";
        }
        else if (IsSealedType(t))
        {
            return "PushSealed";
        }

        return "PushObject";
    }

   

    static string GetCountStr(int count)
    {
        if (count != 0)
        {
            return string.Format("count - {0}", count);
        }

        return "count";
    }

    static void GenOutFunction()
    {
        if (isStaticClass || CustomSettings.outList.IndexOf(type) < 0)
        {
            return;
        }

       
    }

    static void InitCtorList()
    {
        if (isStaticClass || type.IsAbstract || typeof(MonoBehaviour).IsAssignableFrom(type))
        {
            return;
        }

        ConstructorInfo[] constructors = type.GetConstructors(BindingFlags.Instance | binding);

        if (extendType != null)
        {
            ConstructorInfo[] ctorExtends = extendType.GetConstructors(BindingFlags.Instance | binding);

            if (HasAttribute(ctorExtends[0], typeof(UseDefinedAttribute)))
            {
                ctorExtList.AddRange(ctorExtends);
            }
        }

        if (constructors.Length == 0)
        {
            return;
        }        

        for (int i = 0; i < constructors.Length; i++)
        {                        
            if (IsObsolete(constructors[i]))
            {
                continue;
            }

            ConstructorInfo r = constructors[i];
            int index = ctorList.FindIndex((p) => { return CompareMethod(p, r) >= 0; });

            if (index >= 0)
            {
                if (CompareMethod(ctorList[index], r) == 2)
                {
                    ctorList.RemoveAt(index);
                    ctorList.Add(r);
                }
            }
            else
            {
                ctorList.Add(r);
            }
        }
    }

    static void GenConstructFunction()
    {
        if (ctorExtList.Count  > 0)
        {
            if (HasAttribute(ctorExtList[0], typeof(UseDefinedAttribute)))
            {
               

                FieldInfo field = extendType.GetField(extendName + "Defined");
                string strfun = field.GetValue(null) as string;
               
                return;
            }
        }

        if (ctorList.Count == 0)
        {
            if (type.IsValueType)
            {
                LuaIdeInfo.luaInfo.isDefConstructorInfo = true;
            }

            return;
        }

        ctorList.Sort(Compare);
       
        List<ConstructorInfo> list = new List<ConstructorInfo>();
        foreach (ConstructorInfo info in ctorList) {
            if (info.IsPublic) {
                list.Add(info);
            }
        }
        LuaIdeInfo.luaInfo.ctorList = list;
       
    }


    

    static int GetOptionalParamPos(ParameterInfo[] infos)
    {
        for (int i = 0; i < infos.Length; i++)
        {
            if (IsParams(infos[i]))
            {
                return i;
            }
        }

        return -1;
    }

    static int Compare(MethodBase lhs, MethodBase rhs)
    {
        int off1 = lhs.IsStatic ? 0 : 1;
        int off2 = rhs.IsStatic ? 0 : 1;

        ParameterInfo[] lp = lhs.GetParameters();
        ParameterInfo[] rp = rhs.GetParameters();
                
        int pos1 = GetOptionalParamPos(lp);
        int pos2 = GetOptionalParamPos(rp);

        if (pos1 >= 0 && pos2 < 0)
        {
            return 1;
        }
        else if (pos1 < 0 && pos2 >= 0)
        {
            return -1;
        }
        else if(pos1 >= 0 && pos2 >= 0)
        {
            pos1 += off1;
            pos2 += off2;

            if (pos1 != pos2)
            {
                return pos1 > pos2 ? -1 : 1;
            }
            else
            {
                pos1 -= off1;
                pos2 -= off2;

                if (lp[pos1].ParameterType.GetElementType() == typeof(object) && rp[pos2].ParameterType.GetElementType() != typeof(object))
                {
                    return 1;
                }
                else if (lp[pos1].ParameterType.GetElementType() != typeof(object) && rp[pos2].ParameterType.GetElementType() == typeof(object))
                {
                    return -1;
                }
            }
        }

        int c1 = off1 + lp.Length;
        int c2 = off2 + rp.Length;

        if (c1 > c2)
        {
            return 1;
        }
        else if (c1 == c2)
        {
            List<ParameterInfo> list1 = new List<ParameterInfo>(lp);
            List<ParameterInfo> list2 = new List<ParameterInfo>(rp);

            if (list1.Count > list2.Count)
            {
                if (list1[0].ParameterType == typeof(object))
                {
                    return 1;
                }

                list1.RemoveAt(0);
            }
            else if (list2.Count > list1.Count)
            {
                if (list2[0].ParameterType == typeof(object))
                {
                    return -1;
                }

                list2.RemoveAt(0);
            }

            for (int i = 0; i < list1.Count; i++)
            {
                if (list1[i].ParameterType == typeof(object) && list2[i].ParameterType != typeof(object))
                {
                    return 1;
                }
                else if (list1[i].ParameterType != typeof(object) && list2[i].ParameterType == typeof(object))
                {
                    return -1;
                }
            }

            return 0;
        }
        else
        {
            return -1;
        }
    }

    static bool HasOptionalParam(ParameterInfo[] infos)
    {        
        for (int i = 0; i < infos.Length; i++)
        {
            if (IsParams(infos[i]))
            {
                return true;
            }
        }

        return false;
    }

  
   

   
    
    
    static Type GetRefBaseType(Type argType)
    {
        if (argType.IsByRef)
        {
            return argType.GetElementType();
        }

        return argType;
    }

    

    static int GetMethodType(MethodBase md, out PropertyInfo pi)
    {
        pi = null;

        if (!md.IsSpecialName)
        {
            return 0;
        }

        int methodType = 0;        
        int pos = allProps.FindIndex((p) => { return p.GetGetMethod() == md || p.GetSetMethod() == md; });

        if (pos >= 0)
        {
            methodType = 1;
            pi = allProps[pos];

            if (md == pi.GetGetMethod())
            {
                if (md.GetParameters().Length > 0)
                {
                    methodType = 2;
                }
            }
            else if (md == pi.GetSetMethod())
            {
                if (md.GetParameters().Length > 1)
                {
                    methodType = 2;
                }
            }
        }

        return methodType;
    }

    static bool IsExtendFunction(MethodBase mb)
    {
        MethodInfo m = mb as MethodInfo;

        if (m != null)
        {
            return extendMethod.Contains(m);
        }

        return false;
    }

    static Type GetGenericBaseType(MethodBase md, Type t)
    {
        if (!md.IsGenericMethod)
        {
            return t;
        }

        List<Type> list = new List<Type>(md.GetGenericArguments());

        if (list.Contains(t))
        {            
            return t.BaseType;
        }

        return t;
    }

    
    static bool IsNumberEnum(Type t)
    {
        if (t == typeof(BindingFlags))
        {
            return true;
        }

        return false;
    }

   

    static bool CompareParmsCount(MethodBase l, MethodBase r)
    {
        if (l == r)
        {
            return false;
        }               

        int c1 = l.IsStatic ? 0 : 1;
        int c2 = r.IsStatic ? 0 : 1;

        c1 += l.GetParameters().Length;
        c2 += r.GetParameters().Length;

        return c1 == c2;
    }

    //decimal 类型扔掉了
    static Dictionary<Type, int> typeSize = new Dictionary<Type, int>()
    {        
        { typeof(char), 2 },
        { typeof(byte), 3 },
        { typeof(sbyte), 4 },
        { typeof(ushort),5 },      
        { typeof(short), 6 },        
        { typeof(uint), 7 },
        { typeof(int), 8 },                
        { typeof(ulong), 9 },
        { typeof(long), 10 },
        { typeof(decimal), 11 },
        { typeof(float), 12 },
        { typeof(double), 13 },

    };

    //-1 不存在替换, 1 保留左面， 2 保留右面
    static int CompareMethod(MethodBase l, MethodBase r)
    {
        int s = 0;

        if (!CompareParmsCount(l,r))
        {
            return -1;
        }
        else
        {
            ParameterInfo[] lp = l.GetParameters();
            ParameterInfo[] rp = r.GetParameters();

            List<Type> ll = new List<Type>();
            List<Type> lr = new List<Type>();

            if (!l.IsStatic)
            {
                ll.Add(type);
            }

            if (!r.IsStatic)
            {
                lr.Add(type);
            }

            for (int i = 0; i < lp.Length; i++)
            {
                ll.Add(lp[i].ParameterType);
            }

            for (int i = 0; i < rp.Length; i++)
            {
                lr.Add(rp[i].ParameterType);
            }

            for (int i = 0; i < ll.Count; i++)
            {
                if (!typeSize.ContainsKey(ll[i]) || !typeSize.ContainsKey(lr[i]))
                {
                    if (ll[i] == lr[i])
                    {
                        continue;
                    }
                    else
                    {
                        return -1;
                    }
                }
                else if (ll[i].IsPrimitive && lr[i].IsPrimitive && s == 0)
                {
                    s = typeSize[ll[i]] >= typeSize[lr[i]] ? 1 : 2;
                }
                else if (ll[i] != lr[i])
                {
                    return -1;
                }
            }

            if (s == 0 && l.IsStatic)
            {
                s = 2;
            }
        }

        return s;
    }

    static void Push(List<MethodInfo> list, MethodInfo r)
    {
        string name = GetMethodName(r);
        int index = list.FindIndex((p) => { return GetMethodName(p) == name && CompareMethod(p, r) >= 0; });

        if (index >= 0)
        {
            if (CompareMethod(list[index], r) == 2)
            {
                ParameterInfo[] pis = list[index].GetParameters();
                string[] names = new string[pis.Length];

                for (int i = 0; i < pis.Length; i++)
                {
                    names[i] = GetTypeStr(pis[i].ParameterType);
                }

                Debugger.LogWarning("{0}:{1}({2}) has been dropped as other overload function more match lua", className, r.Name, string.Join(", ", names));

                list.RemoveAt(index);
                list.Add(r);
                return;
            }
            else
            {
                ParameterInfo[] pis = r.GetParameters();
                string[] names = new string[pis.Length];

                for (int i = 0; i < pis.Length; i++)
                {
                    names[i] = GetTypeStr(pis[i].ParameterType);
                }

                Debugger.LogWarning("{0}:{1}({2}) has been dropped as other overload function more match lua", className, r.Name, string.Join(", ", names));
                return;
            }
        }

        list.Add(r);        
    }

   

    static int GetParamsCount(MethodBase md)
    {
        int c = md.IsStatic ? 0 : 1;
        return md.GetParameters().Length + c;
    }

    static int GetEqualParamsCount(MethodBase a, MethodBase b)
    {
        List<Type> list1 = new List<Type>();
        List<Type> list2 = new List<Type>();
        int count = 0;

        if (!a.IsStatic)
        {
            list1.Add(type);
        }

        if (!b.IsStatic)
        {
            list2.Add(type);
        }

        ParameterInfo[] p = a.GetParameters();

        for (int i = 0; i < p.Length; i++)
        {
            list1.Add(p[i].ParameterType);
        }

        p = b.GetParameters();

        for (int i = 0; i < p.Length; i++)
        {
            list2.Add(p[i].ParameterType);
        }

        for (int i = 0; i < list1.Count; i++)
        {
            if (list1[i] != list2[i])
            {
                break;
            }

            ++count;
        }

        return count;
    }

    static int[] CheckCheckTypePos<T>(List<T> list) where T : MethodBase
    {
        int[] map = new int[list.Count];                

        for (int i = 0; i < list.Count; )
        {
            if (HasOptionalParam(list[i].GetParameters()))
            {
                if (list[0].IsConstructor)
                {                    
                    for (int k = 0; k < map.Length; k++)
                    {
                        map[k] = 1;
                    }
                }
                else
                {
                    Array.Clear(map, 0, map.Length);
                }

                return map;
            }

            int c1 = GetParamsCount(list[i]);
            int count = c1;
            map[i] = count;
            int j = i + 1;

            for (; j < list.Count; j++)
            {
                int c2 = GetParamsCount(list[j]);                

                if (c1 == c2)
                {
                    count = Mathf.Min(count, GetEqualParamsCount(list[i], list[j]));
                }
                else
                {
                    map[j] = c2;
                    break;
                }

                for (int m = i; m <= j; m++)
                {
                    map[m] = count;
                }
            }

            i = j;
        }

        return map;
    }

    

    public static string CombineTypeStr(string space, string name)
    {
        if (string.IsNullOrEmpty(space))
        {
            return name;
        }
        else
        {
            return space + "." + name;
        }
    }

    public static string GetBaseTypeStr(Type t)
    {
        if(t.IsGenericType)
        {
            return LuaMisc.GetTypeName(t);            
        }
        else
        {
            return t.FullName.Replace("+", ".");
        }
    }

    //获取类型名字
    public static string GetTypeStr(Type t)
    {
        if (t.IsByRef)
        {
            t = t.GetElementType();
            return GetTypeStr(t);
        }
        else if (t.IsArray)
        {            
            string str = GetTypeStr(t.GetElementType());
            str += LuaMisc.GetArrayRank(t);
            return str;
        }
        else if(t == extendType)
        {            
            return GetTypeStr(type);
        }
        else if(typeof(IEnumerator).IsAssignableFrom(t))
        {
            return LuaMisc.GetTypeName(typeof(IEnumerator));
        }

        return LuaMisc.GetTypeName(t);
    }

    //获取 typeof(string) 这样的名字
    static string GetTypeOf(Type t, string sep)
    {
        string str;

        if (t.IsByRef)
        {
            t = t.GetElementType();
        }

        if (IsNumberEnum(t))
        {
            str = string.Format("uint{0}", sep);
        }
        else if (t == typeof(IEnumerator) || typeof(IEnumerator).IsAssignableFrom(t))
        {            
            str = string.Format("{0}{1}", GetTypeStr(typeof(IEnumerator)), sep);
        }
        else
        {
            str = string.Format("{0}{1}", GetTypeStr(t), sep);
        }

        return str;
    }

    static string GenParamTypes(ParameterInfo[] p, MethodBase mb, int offset = 0)
    {
        StringBuilder sb = new StringBuilder();
        List<Type> list = new List<Type>();        

        if (!mb.IsStatic)
        {
            list.Add(type);
        }

        for (int i = 0; i < p.Length; i++)
        {
            if (IsParams(p[i]))
            {
                continue;
            }

            if (p[i].Attributes != ParameterAttributes.Out)
            {
                list.Add(GetGenericBaseType(mb, p[i].ParameterType));
            }
            else
            {
                Type genericClass = typeof(LuaOut<>);
                Type t = genericClass.MakeGenericType(p[i].ParameterType);
                list.Add(t);
            }
        }

        for (int i = offset; i < list.Count - 1; i++)
        {
            sb.Append(GetTypeOf(list[i], ", "));
        }

        if (list.Count > 0)
        {
            sb.Append(GetTypeOf(list[list.Count - 1], ""));
        }

        return sb.ToString();
    }

    public static bool IsByteBuffer(Type type)
    {
        object[] attrs = type.GetCustomAttributes(true);

        for (int j = 0; j < attrs.Length; j++)
        {
            Type t = attrs[j].GetType();

            if (t == typeof(LuaByteBufferAttribute))
            {
                return true;
            }
        }

        return false;
    }


    static bool IsNeedOp(string name)
    {
        if (name == "op_Addition")
        {
            op |= MetaOp.Add;
        }
        else if (name == "op_Subtraction")
        {
            op |= MetaOp.Sub;
        }
        else if (name == "op_Equality")
        {
            op |= MetaOp.Eq;
        }
        else if (name == "op_Multiply")
        {
            op |= MetaOp.Mul;
        }
        else if (name == "op_Division")
        {
            op |= MetaOp.Div;
        }
        else if (name == "op_UnaryNegation")
        {
            op |= MetaOp.Neg;
        }
        else if (name == "ToString" && !isStaticClass)
        {
            op |= MetaOp.ToStr;
        }
        else
        {
            return false;
        }
        

        return true;
    }

    

    public static bool IsObsolete(MemberInfo mb)
    {
		if (IsMemberFilter(mb))
		{
			return true;
		}

        object[] attrs = mb.GetCustomAttributes(true);

        for (int j = 0; j < attrs.Length; j++)
        {
            Type t = attrs[j].GetType() ;            

            if (t == typeof(System.ObsoleteAttribute) || t == typeof(NoToLuaAttribute) || t == typeof(MonoPInvokeCallbackAttribute) ||
                t.Name == "MonoNotSupportedAttribute" || t.Name == "MonoTODOAttribute") // || t.ToString() == "UnityEngine.WrapperlessIcall")
            {
                return true;               
            }
        }

        return false;
    }    

    public static bool HasAttribute(MemberInfo mb, Type atrtype)
    {
        object[] attrs = mb.GetCustomAttributes(true);

        for (int j = 0; j < attrs.Length; j++)
        {
            Type t = attrs[j].GetType();

            if (t == atrtype)
            {
                return true;
            }
        }

        return false;
    }

    static void GenEnum()
    {
        LuaIdeInfo.luaInfo.IsEnum = true;
        fields = type.GetFields(BindingFlags.GetField | BindingFlags.Public | BindingFlags.Static);
        List<FieldInfo> list = new List<FieldInfo>(fields);

        for (int i = list.Count - 1; i > 0; i--)
        {
            if (IsObsolete(list[i]))
            {
                list.RemoveAt(i);
            }
        }

        fields = list.ToArray();                

        foreach(FieldInfo f in list){
            LuaIdeInfo.luaInfo.addVar(new LuaIdeVarInfo()
            {
                fieldInfo = f,
                isget = true,
                value = Convert.ToInt32(f.GetValue(null)).ToString()
            });
        }
        
          
    }

    

    
   

    static void ProcessEditorExtend(Type extendType, List<MethodInfo> list)
    {
        HashSet<string> removeSet = new HashSet<string>();

        if (extendType != null)
        {
            List<MethodInfo> list2 = new List<MethodInfo>();
            list2.AddRange(extendType.GetMethods(BindingFlags.Instance | binding | BindingFlags.DeclaredOnly));

            for (int i = list2.Count - 1; i >= 0; i--)
            {
                if (list2[i].Name.StartsWith("op_") || list2[i].Name.StartsWith("add_") || list2[i].Name.StartsWith("remove_"))
                {
                    if (!IsNeedOp(list2[i].Name))
                    {
                        continue;
                    }
                }

                string name = list2[i].Name;

                if (!removeSet.Contains(name))
                {
                    removeSet.Add(name);
                    list.RemoveAll((md) => { return md.Name == name; });
                }

                if (!IsObsolete(list2[i]))
                {
                    list.Add(list2[i]);
                }
            }

            FieldInfo field = extendType.GetField("AdditionNameSpace");

            if (field != null)
            {
                string str = field.GetValue(null) as string;
                string[] spaces = str.Split(new char[] { ';' });

                for (int i = 0; i < spaces.Length; i++)
                {
                    usingList.Add(spaces[i]);
                }
            }
        }
    }

    static bool IsGenericType(MethodInfo md, Type t)
    {
        Type[] list = md.GetGenericArguments();

        for (int i = 0; i < list.Length; i++)
        {
            if (list[i] == t)
            {
                return true;
            }
        }

        return false;
    }

    static void ProcessExtendType(Type extendType, List<MethodInfo> list, List<MethodInfo> extendList)
    {
        HashSet<string> removeSet = new HashSet<string>();

        if (extendType != null)
        {
            List<MethodInfo> list2 = new List<MethodInfo>();
            list2.AddRange(extendType.GetMethods(BindingFlags.Public | BindingFlags.Static | BindingFlags.DeclaredOnly));

            for (int i = list2.Count - 1; i >= 0; i--)
            {
                MethodInfo md = list2[i];

                if (!md.IsDefined(typeof(ExtensionAttribute), false))
                {
                    continue;
                }

                ParameterInfo[] plist = md.GetParameters();
                Type t = plist[0].ParameterType;

                if (t == type || t.IsAssignableFrom(type) || (IsGenericType(md, t) && (type == t.BaseType || type.IsSubclassOf(t.BaseType))))
                {
                    string name = md.Name;

                    if (!removeSet.Contains(name))
                    {
                        removeSet.Add(name);
                        list.RemoveAll((m) => { return m.Name == name; });
                    }

                    if (!IsObsolete(list2[i]))
                    {
                        extendList.Add(md);
                        list.Add(md);
                    }
                }
            }
        }
    }

    static void ProcessExtends(List<MethodInfo> list)
    {
        extendName = "ToLua_" + className.Replace(".", "_");
        extendType = Type.GetType(extendName + ", Assembly-CSharp-Editor");
        ProcessEditorExtend(extendType, list);
        string temp = null;

        for (int i = 0; i < extendList.Count; i++)
        {
            ProcessExtendType(extendList[i], list, extendMethod);
            string nameSpace = GetNameSpace(extendList[i], out temp);

            if (!string.IsNullOrEmpty(nameSpace))
            {
                usingList.Add(nameSpace);
            }
        }
    }

    static void GetDelegateTypeFromMethodParams(MethodInfo m)
    {
        if (m.IsGenericMethod)
        {
            return;
        }

        ParameterInfo[] pifs = m.GetParameters();

        for (int k = 0; k < pifs.Length; k++)
        {
            Type t = pifs[k].ParameterType;

            if (IsDelegateType(t))
            {
                eventSet.Add(t);
            }
        }
    }

    

    static string RemoveChar(string str, char c)
    {
        int index = str.IndexOf(c);

        while (index > 0)
        {
            str = str.Remove(index, 1);
            index = str.IndexOf(c);
        }

        return str;
    }

    public static string ConvertToLibSign(string str)
    {
        if (string.IsNullOrEmpty(str))
        {
            return null;
        }
  
        str = str.Replace('<', '_');
        str = RemoveChar(str, '>');
        str = str.Replace('[', 's');
        str = RemoveChar(str, ']');
        str = str.Replace('.', '_');
        return str.Replace(',', '_');        
    }

    public static string GetNameSpace(Type t, out string libName)
    {
        if (t.IsGenericType)
        {
            return GetGenericNameSpace(t, out libName);            
        }
        else
        {
            string space = t.FullName;

            if (space.Contains("+"))
            {
                space = space.Replace('+', '.');
                int index = space.LastIndexOf('.');
                libName = space.Substring(index + 1);
                return space.Substring(0, index);
            }
            else
            {
                libName = t.Namespace == null ? space : space.Substring(t.Namespace.Length + 1);
                return t.Namespace;
            }
        }
    }

    static string GetGenericNameSpace(Type t, out string libName)
    {        
        Type[] gArgs = t.GetGenericArguments();
        string typeName = t.FullName;
        int count = gArgs.Length;
        int pos = typeName.IndexOf("[");
        typeName = typeName.Substring(0, pos);

        string str = null;
        string name = null;
        int offset = 0;
        pos = typeName.IndexOf("+");

        while (pos > 0)
        {
            str = typeName.Substring(0, pos);
            typeName = typeName.Substring(pos + 1);
            pos = str.IndexOf('`');

            if (pos > 0)
            {
                count = (int)(str[pos + 1] - '0');
                str = str.Substring(0, pos);
                str += "<" + string.Join(",", LuaMisc.GetGenericName(gArgs, offset, count)) + ">";
                offset += count;
            }

            name = CombineTypeStr(name, str);            
            pos = typeName.IndexOf("+");
        }

        string space = name;
        str = typeName;

        if (offset < gArgs.Length)
        {
            pos = str.IndexOf('`');
            count = (int)(str[pos + 1] - '0');
            str = str.Substring(0, pos);
            str += "<" + string.Join(",", LuaMisc.GetGenericName(gArgs, offset, count)) + ">";
        }

        libName = str;

        if (string.IsNullOrEmpty(space))
        {
            space = t.Namespace;

            if (space != null)
            {
                libName = str.Substring(space.Length + 1);
            }            
        }

        return space; 
    }
}
