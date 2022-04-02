local basefunc = require "Game.Common.basefunc"
ComMatchWaitProgress = basefunc.class()
local M = ComMatchWaitProgress
M.name = "ComMatchWaitProgress"
local instance
--[[param = {
    anchor, --挂载节点
    is_pro, --是否晋级
    game_cfg, --游戏配置，match_ui.lua -> config
    award_cfg, --奖励设置， match_ui_lua -> award
    match_player_num,--当前在比赛中的玩家
    round_info,--轮数信息
    total_players,--总参与人数
    state, --当前状态，MatchResultState
}]]
function M.Create(param)
    if instance then
		instance:MyExit()
	end
	instance = M.New(param)
	return instance
end

function M.Close()
    if instance then
        instance:MyExit()
    end 
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:ctor(param)
    self.param = param
    dump(self.param, "<color=white>param</color>")
    self:MakeLister()
    self:AddMsgListener()
    local obj = newObject(M.name, self.param.anchor)
	self.gameObject = obj
	self.transform = obj.transform
	LuaHelper.GeneratingVar(obj.transform, self)
    self:Init()
end

function M:Init()
    if not self.param then return end
    self.nodes = {data = {}, obj = {}}
    self.lines = {data = {}, obj = {}}    

    if self.param.game_cfg.tryouts and self.param.game_cfg.tryouts == 1 then
        --有预赛
        if self.param.total_players > self.param.game_cfg.round[1] then
            table.insert( self.nodes.data,0,self.param.total_players)
            table.insert( self.lines.data,1,1)
            for i=1,#self.param.game_cfg.round do
                if self.param.game_cfg.round[i] == self.param.round_info.rise_num then
                    self.my_round = i - 1
                end
            end
        else
            --没有预赛
            self.my_round = self.param.round_info.round - 1
        end
    else
        --没有预赛
        self.my_round = self.param.round_info.round - 1
    end

    if not self.my_round then
        self.my_round = 1
    end

    for i,v in ipairs(self.param.game_cfg.round) do
        table.insert( self.nodes.data,v)
    end
    local index = #self.lines.data > 0 and 2 or 1
    for i=index,#self.nodes.data do
        table.insert( self.lines.data,i,i) 
    end
    for i=0,#self.nodes.data do
        if self.nodes.data[i] then
            local v = self.nodes.data[i]
            local node = GameObject.Instantiate(self.node,self.content)
            table.insert(self.nodes.obj,i,node)
            local c_txt = node.transform:Find("count_txt"):GetComponent("Text")
            c_txt.text = v        
            if self.lines.data[i + 1] then
                local line = GameObject.Instantiate(self.line,self.content)
                table.insert(self.lines.obj,i,line)
                line.gameObject:SetActive(true)
            end
            node.gameObject:SetActive(true)
        end
    end

    if #self.param.game_cfg.round > 6 then
        local offets = 1000
        if self.my_round < #self.param.game_cfg.round / 2 then
            offets = 1000
        else
            offets = -1000
        end
        local rt = self.content:GetComponent("RectTransform")
        rt.anchoredPosition = Vector2.New(offets,rt.anchoredPosition.y)
    end

    local reward_parent = self.nodes.obj[#self.nodes.obj].transform:Find("reward_node")
    self.reward_obj = GameObject.Instantiate(self.reward, reward_parent)
    self.reward_obj.transform.localPosition = Vector3.zero
    if self.param.award_cfg then
        for _, v in ipairs(self.param.award_cfg) do
            if v.rank == "第1名" then
                self.reward_obj.transform:Find("award_name_txt").gameObject:GetComponent("Text").text = v.award_desc[1]
                local icon = self.reward_obj.transform:Find("item_img").gameObject
                local iconImg = icon:GetComponent("Image")
                local iconRect = icon:GetComponent("RectTransform")
                local iconHeight = iconRect.rect.height
                local iconWidth = iconRect.rect.width
                iconImg.sprite = GetTexture(v.award_icon[1])
                iconImg:SetNativeSize()
                if iconRect.rect.width > iconWidth then
                    iconRect.sizeDelta = Vector2.New(iconWidth, iconRect.rect.height)
                end
                if iconRect.rect.height > iconHeight then
                    iconRect.sizeDelta = Vector2.New(iconRect.rect.width, iconHeight)
                end
                break
            end
        end
    end
    self.reward_obj.gameObject:SetActive(true)

    --进度
    for i=0,#self.nodes.data do
        if self.nodes.data[i] then
            if i <= self.my_round then
                local light_img = self.nodes.obj[i].transform:Find("light_img"):GetComponent("Image")
                light_img.fillAmount = 1
                if self.lines.obj[i - 1] then
                    light_img = self.lines.obj[i - 1].transform:Find("light_img"):GetComponent("Image")
                    light_img.fillAmount = 1
                end
                if i == self.my_round then
                    local _parent = self.nodes.obj[i].transform:Find("head_node")
                    self.head_obj = GameObject.Instantiate(self.head,_parent)
                    self.head_obj.transform.localPosition = Vector3.zero
                    local headImg = self.head_obj.transform:Find("head_img").gameObject:GetComponent("Image")
                    if headImg and MainModel.UserInfo and MainModel.UserInfo.head_image then
                        URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, headImg)
                    end
                    self.head_obj.gameObject:SetActive(true)
                end
            end
        end
    end

    if self.param.is_pro then
        --晋级
        if self.param.round_info.rise_num >= self.param.game_cfg.round[1] then
            return
        end

        if self.my_round == #self.param.game_cfg.round - 1 or self.my_round == #self.param.game_cfg.round then
            self.reward_obj.transform.localPosition = Vector3.New(0,150,0)
        end

        --动画
        local i = self.my_round + 1
        local line_light_img
        if self.lines.obj[i - 1] then
            line_light_img = self.lines.obj[i - 1].transform:Find("light_img"):GetComponent("Image")
        end
        local node_light_img = self.nodes.obj[i].transform:Find("light_img"):GetComponent("Image")
        if self.head_obj then
            local _parent = self.nodes.obj[i].transform:Find("head_node")
            self.head_obj.transform:SetParent(_parent)
        end
        local seq = DoTweenSequence.Create()
        local tween = self.head_obj.transform:DOLocalMoveX(-250, 1.9):From()
        seq:Append(tween)
        seq:OnForceKill(
            function ()
                if IsEquals(self.head_obj) then
                    self.head_obj.transform.localPosition = Vector3.zero
                end
            end
        )

        local seq1 = DG.Tweening.DOTween.Sequence()
        local seq1 = DoTweenSequence.Create()
        seq1:AppendCallback(function ()
            local totalTime = 1
            local direction = 0.02
            local countNum = totalTime / direction
            local fillAmountDire = 1 / countNum
            if self.timer1 then
                self.timer1:Stop()
            end
            self.timer1 = Timer.New(function()
                if IsEquals(line_light_img) then
                    line_light_img.fillAmount = line_light_img.fillAmount + fillAmountDire
                end
                end,direction,countNum)
            self.timer1:Start()
            return self.timer1
        end)
        seq1:AppendInterval(1)
        seq1:AppendCallback(function ()
            if IsEquals(node_light_img) then
                node_light_img.fillAmount = 1
            end
            if self.nodes.obj[i] and IsEquals(self.nodes.obj[i]) then
                local tx = self.nodes.obj[i].transform:Find("tx")
                if IsEquals(tx) then
                    tx.gameObject:SetActive(true)
                end
                tx = nil
            end
        end)
        seq1:OnForceKill(
            function ()
                if IsEquals(node_light_img) then
                    node_light_img.fillAmount = 1
                end
                if IsEquals(line_light_img) then
                    line_light_img.fillAmount = 1
                end
                if self.nodes.obj[i] and IsEquals(self.nodes.obj[i]) then
                    local tx = self.nodes.obj[i].transform:Find("tx")
                    if IsEquals(tx) then
                        tx.gameObject:SetActive(true)
                    end
                    tx = nil
                end
            end
        )
    else
        --等待
       
    end
end

function M:MyExit()
    if self.timer1 then
        self.timer1:Stop()
    end
	self:RemoveListener()
	GameObject.Destroy(self.gameObject)
end

-- 场景退出
function M:ExitScene()
	self:MyExit()
end

function M.SetRankAward(awardCfg)
    dump(awardCfg,"<color=white>awardCfg</color>")
    if awardCfg then
        for _, v in ipairs(awardCfg) do
            if v.rank == "第1名" then
                self.rewardIcon.transform:Find("name_txt").gameObject:GetComponent("Text").text = v.award
    
                local icon = self.rewardIcon.transform:Find("item_img").gameObject
                local iconImg = icon:GetComponent("Image")
                local iconRect = icon:GetComponent("RectTransform")
                local iconHeight = iconRect.rect.height
                local iconWidth = iconRect.rect.width
                iconImg.sprite = GetTexture(v.award_icon[1])
                iconImg:SetNativeSize()
    
                if iconRect.rect.width > iconWidth then
                    iconRect.sizeDelta = Vector2.New(iconWidth, iconRect.rect.height)
                end
                if iconRect.rect.height > iconHeight then
                    iconRect.sizeDelta = Vector2.New(iconRect.rect.width, iconHeight)
                end
                break
            end
        end
    end
end