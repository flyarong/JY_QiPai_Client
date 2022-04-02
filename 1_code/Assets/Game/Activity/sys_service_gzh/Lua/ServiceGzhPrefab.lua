-- 创建时间:2018-08-17

local basefunc = require "Game.Common.basefunc"

ServiceGzhPrefab = basefunc.class()

function ServiceGzhPrefab.Create(parm)
    return ServiceGzhPrefab.New(parm)
end

function ServiceGzhPrefab:ctor(parm)
    self.parm = parm

    local parent = AdaptLayerParent("Canvas/LayerLv50", parm)
    if not IsEquals(parent) then return end

    self.gameObject = newObject("ServiceGzhPrefab", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BGImg = tran:Find("BGImg"):GetComponent("Button")
    self.BGImg.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    self.copy_btn = tran:Find("ImgPopupPanel/copy_btn"):GetComponent("Button")
    self.copy_btn.onClick:AddListener(function ()
        self:OnCopyClick()
    end)

    self.goto_btn = tran:Find("ImgPopupPanel/goto_btn"):GetComponent("Button")
    self.goto_btn.onClick:AddListener(function ()
        self:OnGotoClick()
    end)

    self.hint_info_txt = tran:Find("ImgPopupPanel/hint_info_txt"):GetComponent("Text")

    self.gzh = "鲸鱼新家园"
    self:InitUI()
    DOTweenManager.OpenPopupUIAnim(self.transform)

    HandleLoadChannelLua("ServiceGzhPrefab",self)
end
function ServiceGzhPrefab:InitUI()
    if self.parm and self.parm.desc then
    	if self.parm.gzh then
		    self.gzh = self.parm.gzh
	    end
        self.hint_info_txt.text = string.format(self.parm.desc, self.gzh)
        self.goto_btn.gameObject:SetActive(true)
        self.copy_btn.gameObject:SetActive(false)
    else
        self.hint_info_txt.text = "请关注微信公众号，尊享鲸鱼服务\n打开微信添加“".. self.gzh .. "”公众号"
        self.goto_btn.gameObject:SetActive(false)
        self.copy_btn.gameObject:SetActive(true)
    end
end

function ServiceGzhPrefab:Close()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end
	GameObject.Destroy(self.gameObject)
end

function ServiceGzhPrefab:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end
function ServiceGzhPrefab:OnCopyClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	LittleTips.Create("已复制微信号请前往微信进行添加")
	UniClipboard.SetText(self.gzh)
	self:Close()
end

function ServiceGzhPrefab:OnGotoClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local share_cfg = basefunc.deepcopy(share_link_config.url_gzgfgzh)
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "url",share_cfg = share_cfg})
	self:Close()
end
