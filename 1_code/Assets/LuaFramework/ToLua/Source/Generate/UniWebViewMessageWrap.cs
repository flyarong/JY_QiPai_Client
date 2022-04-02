﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UniWebViewMessageWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UniWebViewMessage), null);
		L.RegFunction("New", _CreateUniWebViewMessage);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("RawMessage", get_RawMessage, null);
		L.RegVar("Scheme", get_Scheme, null);
		L.RegVar("Path", get_Path, null);
		L.RegVar("Args", get_Args, null);
		L.RegVar("Key", get_Key, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUniWebViewMessage(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				UniWebViewMessage obj = new UniWebViewMessage(arg0);
				ToLua.PushValue(L, obj);
				return 1;
			}
			else if (count == 0)
			{
				UniWebViewMessage obj = new UniWebViewMessage();
				ToLua.PushValue(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UniWebViewMessage.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_RawMessage(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UniWebViewMessage obj = (UniWebViewMessage)o;
			string ret = obj.RawMessage;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index RawMessage on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Scheme(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UniWebViewMessage obj = (UniWebViewMessage)o;
			string ret = obj.Scheme;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Scheme on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Path(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UniWebViewMessage obj = (UniWebViewMessage)o;
			string ret = obj.Path;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Path on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Args(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UniWebViewMessage obj = (UniWebViewMessage)o;
			System.Collections.Generic.Dictionary<string,string> ret = obj.Args;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Args on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Key(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UniWebViewMessage obj = (UniWebViewMessage)o;
			string ret = obj.Key;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Key on a nil value");
		}
	}
}
