-- 创建时间:2018-07-31
BannerModel = {}
local this
local m_data
local lister
local function AddLister()
    lister={}
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
end

-- 初始化Data
local function InitData()
    BannerModel.data={
	    -- 是否是首次执行(登录算首次)
        IsFirstRun = MainModel.banner_if_first_run
    }
    MainModel.banner_if_first_run = false
    m_data = BannerModel.data
end

function BannerModel.Init()
    this = BannerModel
    InitData()
    this.InitUIConfig()
    MakeLister()
    AddLister()
    HandleLoadChannelLua("BannerModel", this)
    return this
end
function BannerModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

function BannerModel.InitUIConfig()
    this.UIConfig={
        config = {},
        hallconfig = {},
    }
    this.UIConfig.config = BannerManager.banner_style_ui.upconfig
    this.UIConfig.hallconfig = BannerManager.banner_style_ui.hallconfig
end

function BannerModel.GetShareLink()
    for k,v in ipairs(this.UIConfig.hallconfig) do
        if v.id == 35 then
            return v.gotoUI[2]
        end
    end
end

-- 计算并排序显示列表
function BannerModel.CalcShowList()
	local newtime = tonumber(os.date("%Y%m%d", os.time()))

	local config = this.UIConfig.config
    this.UIConfig.upconfigMap = {}
    local bannerConfig = {}
    if next(config) then
        for k,v in ipairs(config) do
            bannerConfig[k] = v
        end
    end
    local nowtime = os.time()
	bannerConfig = MathExtend.SortList(bannerConfig, "order", true)
	this.data.bannerList = {}
	for k,v in ipairs(bannerConfig) do
		if (v.isOnOff and v.isOnOff == 1) and (not v.srartTime or v.srartTime == -1 or nowtime >= v.srartTime)
            and (not v.endTime or v.endTime == -1 or nowtime <= v.endTime) then
            if not v.shop_id or MainModel.GetGiftShopShowByID(v.shop_id) then
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint=true}, "CheckCondition")
                if not a or b then
                    if v.model == "DailyUp" then
                        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("BannerRecentlyRunTime" .. v.bannerID, 0))))
                        if oldtime ~= newtime then
                            this.data.bannerList[#this.data.bannerList + 1] = v.bannerID
                            this.UIConfig.upconfigMap[v.bannerID] = v
                        end
                    else
                        this.data.bannerList[#this.data.bannerList + 1] = v.bannerID
                        this.UIConfig.upconfigMap[v.bannerID] = v
                    end
                end
                
            end
		end
	end
end

-- 计算并排序显示列表-大厅轮换切换
function BannerModel.CalcHallBannerList()
    local config = this.UIConfig.hallconfig
    this.UIConfig.hallconfigMap = {}
    local bannerConfig = {}
    if config then
        for k,v in ipairs(config) do
            bannerConfig[k] = v
        end
    end
    local nowtime = os.time()
    bannerConfig = MathExtend.SortList(bannerConfig, "order", true)
    this.data.hallBannerList = {}
    for k,v in ipairs(bannerConfig) do
        if (v.isOnOff and v.isOnOff == 1) and (not v.srartTime or v.srartTime == -1 or nowtime >= v.srartTime)
            and (not v.endTime or v.endTime == -1 or nowtime <= v.endTime) then
            if not v.shop_id or MainModel.GetGiftShopShowByID(v.shop_id) then

                -- 根据玩家标签及渠道，展示不同的banner图
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint=true}, "CheckCondition")
                if not a or b then
                    this.data.hallBannerList[#this.data.hallBannerList + 1] = v.bannerID
                    this.UIConfig.hallconfigMap[v.bannerID] = v                    
                end

            end
        end
    end
end

function BannerModel.IsOutTime()
    if table_is_null(this.data.hallBannerList) then
        return false
    end
    for i = 1, #this.data.hallBannerList do
        local bannerId = this.data.hallBannerList[i]
        local config = this.UIConfig.hallconfigMap[bannerId]
        local nowtime = os.time()
        if config.endTime and config.endTime ~= -1 and nowtime > config.endTime then
            return true 
        end
    end
end
