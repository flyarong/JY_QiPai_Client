
--local basefunc = require "Game.Common.basefunc"

UniWebViewMgr = {}
local M = UniWebViewMgr
local UniWebViewHash = {}
local cur_load_key

local is_loading
local timer_loading
M.load_jh_key = "shop_loading"
M.load_max_time = 30

--Web端标准通讯格式
--1.关闭页面 "uniwebview://close?key=shop"
--2.清除某个页面的缓存 "uniwebview://cleancache?key=shop"

--key==shop 兑换商城的页面
--key==kffk 客服反馈的页面
--print("Key is Not Contain!!!") = 接受的消息中不包含"key"
local PrintError = function (str)
    print("</color=red>" .. str .. "</color>")
end
 
local function HandleMessage(_view,_message)
    if _message.Key == "NoContainKey" then
        PrintError("Key is Not Contain!!!")
        return
    end
    if _message.Path == "close" then
        M.ShowOrHide(_message.Key, false)
    elseif _message.Path == "cleancache" then
        M.CleanCache(_message.Key)
    end
end

local function HandleMessageErrorReceived(_view,_error,_message)
    PrintError("Load Page ErrorReceived ----->" .. _message)
end

local function HandleMessageShouldClose(_view)
    if cur_load_key then
        M.ShowOrHide(cur_load_key, false)
    end
    return false
end

local function HandleMessagePageFinish()
    print("<------HandleMessagePageFinish----->")
    if is_loading then
        FullSceneJH.RemoveByTag(M.load_jh_key)
        is_loading = false
        UniWebViewHash[cur_load_key]:Show()

        if timer_loading then
            timer_loading:Stop()
            timer_loading = nil
        end
    end
end

local function HandleOpenUrl()
    --if gameRuntimePlatform == "WindowsEditor" then return end
    is_loading = true
    FullSceneJH.Create("", M.load_jh_key)
    timer_loading = Timer.New(function()
        FullSceneJH.RemoveByTag(M.load_jh_key)
        LittleTips.Create("加载失败，请稍后再试")
        --UniWebViewHash[cur_load_key]:Show()
        is_loading = false
        M.CloseWebImmediate(cur_load_key)
        timer_loading:Stop()
        timer_loading = nil
    end, M.load_max_time, 1)
    timer_loading:Start()
end

function M.CreateUniWebView(key)
    if not UniWebViewHash[key] then
        local webObj = GameObject.New("UniWebView_" .. key)
        GameObject.DontDestroyOnLoad(webObj)
        UniWebViewHash[key] = webObj:AddComponent(typeof(UniWebView))

        UniWebViewHash[key]:AddMessage(
        function(view, message)  --在收到来自Web视图的消息时引发
            HandleMessage(view, message)
        end)

        UniWebViewHash[key]:AddMessageErrorReceived(
        function(view, error, message)  --在加载过程中遇到错误时引发
            HandleMessageErrorReceived(view, error, message)
        end)

        UniWebViewHash[key]:AddMessageShouldClose(
        function(view)  --在Web视图即将关闭时引发，Andorid的返回键
            HandleMessageShouldClose(view)
        end)

        UniWebViewHash[key]:AddMessagePageFinish(
        function(view, statusCode, url) --当网络视图成功加载网址时引发
            HandleMessagePageFinish(view, statusCode, url)
        end)
        webObj = nil
    end
end

function M.OpenUrl(key, url)
    if not UniWebViewHash[key] then

        M.CreateUniWebView(key)
        UniWebViewHash[key]:SetFrame()
        UniWebViewHash[key]:Load(url, true)
        --UniWebViewHash[key].BackgroundColor = Color.New(0,0,0,0.6)
        --UniWebViewHash[key].Frame = Rect.New(0,0,300,300)
        --UniWebViewHash[key].Alpha = 0.5
        cur_load_key = key
        --UniWebViewHash[key]:Show()
        UniWebViewHash[key]:ShowToEvaluateJS()
        HandleOpenUrl()
    else
        M.ShowOrHide(key, true)
    end
end

function M.ShowOrHide(key, is_show)
    if not M.IsKeyContain(key) then return end
    if is_loading then return end
    if is_show then
        cur_load_key = key
        UniWebViewHash[key]:Show()
        UniWebViewHash[key]:ShowToEvaluateJS()
    else
        cur_load_key = nil
        UniWebViewHash[key]:Hide()
    end
end

--关闭Web页面，销毁对象（场景中的）
function M.CloseWebImmediate(key)
    if not M.IsKeyContain(key) then return end
    cur_load_key = nil
    UniWebViewHash[key]:Hide()
    UniWebViewHash[key]:RemoveAllMessageReceive()
    destroy(UniWebViewHash[key].gameObject)
    UniWebViewHash[key] = nil
end

function M.IsKeyContain(key)
    for k, v in pairs(UniWebViewHash) do
        if k == key then
            return true
        end
    end
    return false
end

--清除单个WebView的缓存
function M.CleanCache(key)
    if not M.IsKeyContain(key) then return end
    UniWebViewHash[key]:CleanCache()
end

--清除所有WebView的缓存
function M.CleanCacheAll()
    for k, v in pairs(UniWebViewHash) do
        UniWebViewHash[k]:CleanCache()
        UniWebViewHash[k]:RemoveAllMessageReceive()
        destroy(UniWebViewHash[k].gameObject)
        UniWebViewHash[k] = nil
        cur_load_key = nil
    end
end

--清除所有来自WebView的Cookies
function M.CleanCookies()
    UniWebView.ClearCookies()
end