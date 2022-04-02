-- 创建时间:2018-07-31
BannerLogic = {}
local this -- 单例
local bannerModel

local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
end

function BannerLogic.Init()
    BannerLogic.Exit()
    this = BannerLogic
    MakeLister()
    AddLister()
    bannerModel = BannerModel.Init()
    return this
end
function BannerLogic.Exit()
	if this then
		BannerPanel.Close()
		bannerModel.Exit()
		bannerModel = nil
		RemoveLister()
		this = nil
	end
end

-- 运行广告 (id有就显示一个)
function BannerLogic.RunBanner()
    if not GameGlobalOnOff.Banner then
        return
    end
	if BannerModel.data.IsFirstRun then
		BannerModel.data.IsFirstRun = false
		BannerModel.CalcShowList()
		if #BannerModel.data.bannerList > 0 then
			BannerPanel.Show()
		end
	end
end
function BannerLogic.ShowBanner(id)
    if not GameGlobalOnOff.Banner then
        return
    end
    BannerPanel.Show(id)
end


