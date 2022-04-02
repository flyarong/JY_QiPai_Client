--分享帮助类
ShareHelper = {}
local M = ShareHelper
local MakeCameraImgAsyncSwitch = true --截图方式开关，true为旧的截图方式
local lister

local function AddLister()
	lister={}
	lister["get_share_url_response"] = M.get_share_url_response

	for proto_name,func in pairs(lister or {}) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister or {}) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function M.get_share_url_response(data)
	if not data or not data.url or not data.share_source then
		dump(data,"<color=white>分享数据异常</color>")
		Event.Brocast("qr_code_apply_fial")
		return
	end
	if not M.qr_code_img or not M.qr_code_img[data.share_source] or not IsEquals(M.qr_code_img[data.share_source]) then
		dump(data,"<color=white>分享异常</color>")
		Event.Brocast("qr_code_apply_fial")
		return
	end

	local url = data.url
	if not url then
		LittleTips.Create(string.format("获取二维码错误"))
		M.qr_code_img[data.share_source] = nil
		Event.Brocast("qr_code_apply_fial")
		return
	end
	M.QRCode(M.qr_code_img[data.share_source].mainTexture, data.url)
	M.qr_code_img[data.share_source] = nil
end

function M.Init()
	AddLister()
end

function M.Exit()
	RemoveLister()
end

--[[
    @desc: 截屏
    author:{ganshuangfeng}
    time:2020-09-29 10:17:43
    --@camera:要截图的相机
	--@rect:截图区域
    @return:截取的图片
]]
function M.ScreenShot(camera,rect)	
	if MakeCameraImgAsyncSwitch then
		M.MakeCameraImgAsync(rect)
		return
	end

	if not camera then
		--默认使用主相机渲染
		camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
	end
	if not rect then
		--默认全屏截图
		rect = UnityEngine.Rect.New(0,0,Screen.width,Screen.height)
	end
	if not camera or not rect then return end
	if not rect.x or not rect.y or not rect.width or not rect.height then return end
	Event.Brocast("screen_shot_begin")
	-- 创建一个RenderTexture对象  
	local rt = UnityEngine.RenderTexture.New(rect.width,rect.height,0)  
	-- 临时设置相关相机的targetTexture为rt, 并手动渲染相关相机  
	camera.targetTexture = rt
	camera:Render()
	--ps: --- 如果这样加上第二个相机，可以实现只截图某几个指定的相机一起看到的图像。  
	--ps: camera2.targetTexture = rt;  
	--ps: camera2.Render();  
	--ps: -------------------------------------------------------------------  
	-- 激活这个rt, 并从中中读取像素。  
	UnityEngine.RenderTexture.active = rt
	local screenShot = UnityEngine.Texture2D.New(rect.width,rect.height,UnityEngine.TextureFormat.RGB24,false)
	screenShot:ReadPixels(rect, 0, 0)-- 注：这个时候，它是从RenderTexture.active中读取像素  
	screenShot:Apply()
	-- 重置相关参数，以使用camera继续在屏幕上显示  
	camera.targetTexture = nil
		--ps: camera2.targetTexture = null
	UnityEngine.RenderTexture.active = nil -- JC: added to avoid errors  
	GameObject.Destroy(rt)
	-- return screenShot
	-- 最后将这些纹理数据，生成一个png图片文件
	M.SaveScreenShot(screenShot)
	Event.Brocast("screen_shot_end")
end

--[[
    @desc: 保存截图
    author:{ganshuangfeng}
    time:2020-09-29 14:58:10
    --@screenShot: 截图的Texture2D
    @return:
]]
function M.SaveScreenShot(screenShot)
	local bytes = ImageConversion.EncodeToPNG(screenShot)
	local path = ""
	if not (gameRuntimePlatform == "Android" or gameRuntimePlatform == "Ios") then
		path = M.GetImagePath()
		File.WriteAllBytes(path, bytes);
	end

	local now = os.time()
	local filename = string.format("Screenshot%s.png", now);
	local check_directory = function(  )
		if not Directory.Exists(path) then
			Directory.CreateDirectory(path);
		end
		path = path + "/" + filename;
		if Directory.Exists(path) then
			Directory.Delete(path);
		end
	end
	if gameRuntimePlatform == "Android" then
		path = Application.persistentDataPath.Substring(0, Application.persistentDataPath.IndexOf("Android"));
		path = path + "DCIM/Screenshots";
		check_directory()
		File.WriteAllBytes(path, bytes);
		--安卓在这里需要去 调用原生的接口去 刷新一下，不然相册显示不出来
		sdkMgr:ScanFile(path)
	elseif gameRuntimePlatform == "Ios" then
		path = Application.persistentDataPath
		check_directory()
		File.WriteAllBytes(path, bytes)
		sdkMgr:SaveImageToPhotosAlbum(path)
	end
	print(string.format("截屏了一张照片: %s", path))

	HintPanel.Create(1,"已成功将图片保存到相册，请前往微信打开相册进行分享",function (  )
		ShareHelper.OpenWeChat()
		--分享完成
		print("<color=white>分享完成</color>")
	end)
end

--打开微信
function M.OpenWeChat()
	if gameRuntimePlatform == "Ios" then
		Application.OpenURL("weixin://");
	elseif gameRuntimePlatform == "Android" then
		sdkMgr:OpenApp("com.tencent.mm","http://weixin.qq.com/")
	else
		Application.OpenURL("https://weixin.qq.com/");
	end
end

function M.RotateTexture(originalTexture, clockwise)
	local original = originalTexture:GetPixels32();
	local rotated = {}
	local w = originalTexture.width
	local h = originalTexture.height

	local iRotated, iOriginal

	for j=0,h - 1 do
		for i=0,w - 1 do
			iRotated = (i + 1) * h - j - 1
			iOriginal = clockwise and original.Length - 1 - (j * w + i) or j * w + i
			rotated[iRotated] = original[iOriginal]
		end
	end

	local rotatedTexture = UnityEngine.Texture2D.New(h, w, UnityEngine.TextureFormat.RGB24,false)
	rotatedTexture:SetPixels32(rotated)
	rotatedTexture:Apply()
	return rotatedTexture
end

--二维码大小
local qr_code_size = 300
--[[
    @desc: 生成二维码
    author:{author}
    time:2020-09-29 15:29:24
    --@texture:二维码所在Texture
	--@url: 二维码url
    @return:
]]
function M.QRCode(texture, url)
	if not IsEquals(texture) or not url then
		Event.Brocast("qr_code_apply_fial")
        return
    end
	local data = ewmTools.getEwmDataWithPixel(url, qr_code_size)    
	if not data then
		Event.Brocast("qr_code_apply_fial")
        return
    end
    local w = data.width
    local scale = math.floor(qr_code_size/w)
    local py = (qr_code_size-w*scale)/2
    py = math.floor(py)
    print(py .. " " .. w .. " " .. scale)
    local dots = data.data
    for i = 1, w do
        for j = 1, w do
            if dots[(i-1)*w + j] == 1 then
                texture:SetPixel(i-1+py, j-1+py, Color.New(0,0,0,1))
            else
                texture:SetPixel(i-1+py, j-1+py, Color.New(1,1,1,1))
            end
        end
    end
	texture:Apply()
	Event.Brocast("qr_code_apply_success")
end

--刷新二维码
function M.RefreshQRCode(qr_code_img,share_cfg)
	if not IsEquals(qr_code_img) then
		print("<color=whiet>qr_code_img is nil</color>")
		Event.Brocast("qr_code_apply_fial")
		return
	end
	local url = ShareModel.GetShareUrl(share_cfg)
	if not url then
		print("<color=white>url is nil</color>")
		M.qr_code_img = M.qr_code_img or {}
		M.qr_code_img[share_cfg.share_source] = qr_code_img
		ShareModel.ReqGetShareUrl(share_cfg)
		return
	end
	M.QRCode(qr_code_img.mainTexture, url)
end

--刷新头像，icon，推广码
function M.RefreshImage(head_img,logo_img,invite_txt,share_img_id)
	if IsEquals(head_img) then
		URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, head_img)
	end
	if IsEquals(logo_img) then
		local sp = GetTexture("login_icon_name")
		if sp then
			logo_img.sprite = sp
			logo_img:SetNativeSize()
		end
		sp = nil
	end
	if IsEquals(invite_txt) then
		if MainModel.UserInfo.user_id then
			invite_txt.text = "邀请码：" .. MainModel.UserInfo.user_id
		else
			invite_txt.text = ""
		end

		--根据分享图设置邀请码颜色，默认白色
		if share_img_id and share_img_id == 16 then
			invite_txt.color = Color.black
		end
	end
end

--刷新分享图
function M.RefreshShareImage(share_img,share_cfg)
	if not IsEquals(share_img) or not share_cfg then return end
	if not share_cfg.share_img then return end
	local id = 1
	if type(share_cfg.share_img) == "number" then
		id =  share_cfg.share_img
	elseif type(share_cfg.share_img) == "table" then
		id = share_cfg.share_img[math.random(1,#share_cfg.share_img)]
		share_cfg.share_source = share_cfg.share_source .. id
	end
	local sp = GetTexture("share_" .. id)
	if sp then
		share_img.sprite = sp
	end
	sp = nil
	return id
end

function M.GetImagePath()
	if not Directory.Exists(resMgr.DataPath) then
        Directory.CreateDirectory(resMgr.DataPath)
    end

    local path = resMgr.DataPath .. "Screenshot.jpg"
    return path
end

function M.MakeCameraImgAsync(rect)
	if not rect then
		--默认全屏截图
		rect = UnityEngine.Rect.New(0,0,Screen.width,Screen.height)
	end
	if not rect then return end
	if not rect.x or not rect.y or not rect.width or not rect.height then return end
	local imageName = M.GetImagePath()
	Event.Brocast("screen_shot_begin")
	panelMgr:MakeCameraImgAsync(rect.x, rect.y, rect.width, rect.height, imageName, function ()
        Event.Brocast("screen_shot_end")
    end, false,ShareLogic.share_type_me)
end