﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaFramework_SDKManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaFramework.SDKManager), typeof(Manager));
		L.RegFunction("Init", Init);
		L.RegFunction("Login", Login);
		L.RegFunction("LoginOut", LoginOut);
		L.RegFunction("Relogin", Relogin);
		L.RegFunction("Pay", Pay);
		L.RegFunction("PostPay", PostPay);
		L.RegFunction("SetPayCallback", SetPayCallback);
		L.RegFunction("SetPostPayCallback", SetPostPayCallback);
		L.RegFunction("Share", Share);
		L.RegFunction("ShowAccountCenter", ShowAccountCenter);
		L.RegFunction("SendToSDKMessage", SendToSDKMessage);
		L.RegFunction("SetupAD", SetupAD);
		L.RegFunction("PrepareAD", PrepareAD);
		L.RegFunction("PlayAD", PlayAD);
		L.RegFunction("AddRewardVideoAdListener", AddRewardVideoAdListener);
		L.RegFunction("AddRewardAdInteractionListener", AddRewardAdInteractionListener);
		L.RegFunction("AddExpressAdListener", AddExpressAdListener);
		L.RegFunction("AddExpressAdInteractionListener", AddExpressAdInteractionListener);
		L.RegFunction("RemoveRewardVideoAdListener", RemoveRewardVideoAdListener);
		L.RegFunction("RemoveRewardAdInteractionListener", RemoveRewardAdInteractionListener);
		L.RegFunction("RemoveExpressAdExpressListener", RemoveExpressAdExpressListener);
		L.RegFunction("RemoveExpressAdInteractionListener", RemoveExpressAdInteractionListener);
		L.RegFunction("ClearAD", ClearAD);
		L.RegFunction("ClearAllAD", ClearAllAD);
		L.RegFunction("AddHandleScanFileCallback", AddHandleScanFileCallback);
		L.RegFunction("ScanFile", ScanFile);
		L.RegFunction("SaveImageToPhotosAlbum", SaveImageToPhotosAlbum);
		L.RegFunction("SaveVideoToPhotosAlbum", SaveVideoToPhotosAlbum);
		L.RegFunction("OpenPhotoAlbums", OpenPhotoAlbums);
		L.RegFunction("OpenApp", OpenApp);
		L.RegFunction("AddHandleOpenAppResultCallback", AddHandleOpenAppResultCallback);
		L.RegFunction("OnUpdCityName", OnUpdCityName);
		L.RegFunction("OnGPS", OnGPS);
		L.RegFunction("GetLatitude", GetLatitude);
		L.RegFunction("GetLongitude", GetLongitude);
		L.RegFunction("GetLocation", GetLocation);
		L.RegFunction("OnRecord", OnRecord);
		L.RegFunction("OnPlayRecordFinish", OnPlayRecordFinish);
		L.RegFunction("GetDeviceID", GetDeviceID);
		L.RegFunction("GetDeeplink", GetDeeplink);
		L.RegFunction("GetPushDeviceToken", GetPushDeviceToken);
		L.RegFunction("RunVibrator", RunVibrator);
		L.RegFunction("CallUp", CallUp);
		L.RegFunction("StartGPS", StartGPS);
		L.RegFunction("QueryCityName", QueryCityName);
		L.RegFunction("QueryGPS", QueryGPS);
		L.RegFunction("GetRecordTime", GetRecordTime);
		L.RegFunction("StartRecord", StartRecord);
		L.RegFunction("StopRecord", StopRecord);
		L.RegFunction("PlayRecord", PlayRecord);
		L.RegFunction("StopPlayRecord", StopPlayRecord);
		L.RegFunction("ShowProductRate", ShowProductRate);
		L.RegFunction("GetCanLocation", GetCanLocation);
		L.RegFunction("GetCanVoice", GetCanVoice);
		L.RegFunction("GetCanCamera", GetCanCamera);
		L.RegFunction("GetCanPushNotification", GetCanPushNotification);
		L.RegFunction("OpenLocation", OpenLocation);
		L.RegFunction("OpenVoice", OpenVoice);
		L.RegFunction("OpenCamera", OpenCamera);
		L.RegFunction("GotoSetScene", GotoSetScene);
		L.RegFunction("LoadFile", LoadFile);
		L.RegFunction("ForceQuit", ForceQuit);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Init(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.Init(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Login(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.Login(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoginOut(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.LoginOut(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Relogin(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.Relogin(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Pay(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.Pay(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PostPay(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.PostPay(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPayCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.SetPayCallback(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPostPayCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.SetPostPayCallback(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Share(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.Share(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ShowAccountCenter(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.ShowAccountCenter(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendToSDKMessage(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.SendToSDKMessage(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetupAD(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.SetupAD(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PrepareAD(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 12);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
			string arg3 = ToLua.CheckString(L, 5);
			string arg4 = ToLua.CheckString(L, 6);
			int arg5 = (int)LuaDLL.luaL_checknumber(L, 7);
			int arg6 = (int)LuaDLL.luaL_checknumber(L, 8);
			string arg7 = ToLua.CheckString(L, 9);
			int arg8 = (int)LuaDLL.luaL_checknumber(L, 10);
			int arg9 = (int)LuaDLL.luaL_checknumber(L, 11);
			LuaFunction arg10 = ToLua.CheckLuaFunction(L, 12);
			obj.PrepareAD(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayAD(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.PlayAD(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddRewardVideoAdListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
			obj.AddRewardVideoAdListener(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddRewardAdInteractionListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 8);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
			LuaFunction arg4 = ToLua.CheckLuaFunction(L, 6);
			LuaFunction arg5 = ToLua.CheckLuaFunction(L, 7);
			LuaFunction arg6 = ToLua.CheckLuaFunction(L, 8);
			obj.AddRewardAdInteractionListener(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddExpressAdListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 6);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
			LuaFunction arg4 = ToLua.CheckLuaFunction(L, 6);
			obj.AddExpressAdListener(arg0, arg1, arg2, arg3, arg4);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddExpressAdInteractionListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 7);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
			LuaFunction arg4 = ToLua.CheckLuaFunction(L, 6);
			LuaFunction arg5 = ToLua.CheckLuaFunction(L, 7);
			obj.AddExpressAdInteractionListener(arg0, arg1, arg2, arg3, arg4, arg5);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveRewardVideoAdListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.RemoveRewardVideoAdListener();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveRewardAdInteractionListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.RemoveRewardAdInteractionListener();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveExpressAdExpressListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.RemoveExpressAdExpressListener();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveExpressAdInteractionListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.RemoveExpressAdInteractionListener();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearAD(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.ClearAD(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearAllAD(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.ClearAllAD();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddHandleScanFileCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.AddHandleScanFileCallback(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ScanFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.ScanFile(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SaveImageToPhotosAlbum(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.SaveImageToPhotosAlbum(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SaveVideoToPhotosAlbum(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.SaveVideoToPhotosAlbum(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenPhotoAlbums(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.OpenPhotoAlbums();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenApp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			obj.OpenApp(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddHandleOpenAppResultCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.AddHandleOpenAppResultCallback(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnUpdCityName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.OnUpdCityName(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnGPS(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.OnGPS(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLatitude(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			float o = obj.GetLatitude();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLongitude(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			float o = obj.GetLongitude();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLocation(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string o = obj.GetLocation();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnRecord(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.OnRecord(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnPlayRecordFinish(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.OnPlayRecordFinish(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDeviceID(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string o = obj.GetDeviceID();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDeeplink(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string o = obj.GetDeeplink();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPushDeviceToken(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string o = obj.GetPushDeviceToken();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RunVibrator(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			long arg0 = LuaDLL.tolua_checkint64(L, 2);
			obj.RunVibrator(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallUp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.CallUp(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StartGPS(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.StartGPS(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int QueryCityName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			obj.QueryCityName(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int QueryGPS(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.QueryGPS(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetRecordTime(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			int o = obj.GetRecordTime();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StartRecord(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			int o = obj.StartRecord(arg0, arg1);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StopRecord(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.StopRecord(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayRecord(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			int o = obj.PlayRecord(arg0, arg1);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StopPlayRecord(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.StopPlayRecord();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ShowProductRate(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.ShowProductRate(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCanLocation(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			int o = obj.GetCanLocation();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCanVoice(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			int o = obj.GetCanVoice();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCanCamera(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			int o = obj.GetCanCamera(arg0);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCanPushNotification(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			int o = obj.GetCanPushNotification();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenLocation(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.OpenLocation();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenVoice(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.OpenVoice();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenCamera(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.OpenCamera();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GotoSetScene(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.GotoSetScene(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			byte[] o = obj.LoadFile(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ForceQuit(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.SDKManager obj = (LuaFramework.SDKManager)ToLua.CheckObject<LuaFramework.SDKManager>(L, 1);
			obj.ForceQuit();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

