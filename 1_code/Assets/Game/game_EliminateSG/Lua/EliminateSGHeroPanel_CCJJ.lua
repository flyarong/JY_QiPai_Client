
 local basefunc = require "Game/Common/basefunc"

 EliminateSGHeroPanel_ccjj = basefunc.class()
 local C = EliminateSGHeroPanel_ccjj
 C.name = "EliminateSGHeroPanel_ccjj"
 
 function C.Create()
	 return C.New()
 end
 
 function C:AddMsgListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.AddListener(proto_name, func)
	 end
 end
 
 function C:MakeLister()
	 self.lister = {}
	 self.lister["eliminate_ccjj_biggame_msg"] =  basefunc.handler(self, self.eliminate_ccjj_biggame_msg)
	 --self.lister["clear_arrow_group"] =  basefunc.handler(self, self.clear_arrow_group)
	 self.lister["jump_arrows_fly"] =  basefunc.handler(self, self.jump_arrows_fly)
 end
 
 function C:RemoveListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.RemoveListener(proto_name, func)
	 end
	 self.lister = {}
 end
 
 function C:Killseq()
	 if self.seq then
		 self.seq:Killseq()
	 end
	 self.seq = nil
 end
 
 
 function C:MyExit()
	 self:RemoveListener()
	 if self.seq then
		 self.seq:Killseq()
		 self.seq = nil
	 end
	 if self.seq_settlement then
		 self.seq_settlement:Killseq()
		 self.seq_settlement = nil
	 end
 
	 destroy(self.gameObject)
 end
 
 function C:OnDestroy()
	 self:MyExit()
 end
 
 function C:MyClose()
	 self:MyExit()
 end
 
 
 function C:ctor()
	 ExtPanel.ExtMsg(self)
	 local parent = GameObject.Find("Canvas/LayerLv1").transform
	 local obj = newObject(C.name, parent)
	 local tran = obj.transform
	 self.transform = tran
	 self.gameObject = obj
	 LuaHelper.GeneratingVar(self.transform, self)
	 
	 self:MakeLister()
	 self:AddMsgListener()
	 self:InitUI()
 end
 

 function C:KillSeq()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
end

 function C:InitUI()

	self.content = GameObject.Find("ItemContent_ccjj").transform
	self:creat_start_arrow()
	self:MyRefresh()
 end
 
 function C:MyRefresh()
 end
 
 function C:creat_start_arrow()
	--所有箭矢队列长度
	self.all_arrowsLength=0
	 --箭矢队列的物体
	self.all_arrows={{},{},{},{}}
	 --一个箭矢图标的宽度
	self.move_distance=60
	 --新的位置 要飞向的最终位置
	self.index_pos=0
	 --每种箭矢拥有的箭矢数目
	self.every_arrow_have={1,3,5,10}
 	 --每一组的箭矢数目文本框
	self.all_arrows_txt={}
	 --游戏结束
	self.is_over=false
	table.insert(self.all_arrows_txt,self.arrow_group_01_txt)
	table.insert(self.all_arrows_txt,self.arrow_group_02_txt)
	table.insert(self.all_arrows_txt,self.arrow_group_03_txt)
	table.insert(self.all_arrows_txt,self.arrow_group_04_txt)
	--初始生成的箭矢
	 for i=4,1,-1 do
		local arrow={}
		arrow.obj = newObject("ccjj_fangzhi_0"..i,self.StartPos) 
		arrow.obj.gameObject.name=i;
		arrow.is_move=false	
		arrow.end_pos=-(self.move_distance*(4-i))
		arrow.end_pos2=arrow.end_pos
		arrow.obj.transform.localPosition=Vector3.New(arrow.end_pos,0,0)
		arrow.kind=i
		table.insert(self.all_arrows[i],arrow)
	 end
 end
 
 --收集箭矢
 function C:eliminate_ccjj_biggame_msg(parm)
	local cover_objs={}
	--dump(parm,"<color=red><size=15>++++++++++jieshou shucju+++++++++</size></color>")
	if  parm.arrow_fly_list then
		parm.seq:AppendInterval(0.5)
		Event.Brocast("add_free_game_times_msg")
		parm.seq:AppendCallback(function ()
			self.BGImg.gameObject:SetActive(true)
			for i,v in ipairs(cover_objs) do
				v.gameObject:SetActive(true)
			end
		end)
		for i=#parm.arrow_fly_list,1,-1 do
			for j,k in ipairs( parm.arrow_fly_list[i]) do
				if self.all_arrowsLength>14 then
					if not self.is_over then
						for i,v in ipairs(cover_objs) do
							v.gameObject:SetActive(true)
						end
						parm.seq:AppendCallback(function ()
							ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_ccjj_xccxzj.audio_name)
							self.zgl_talk2.gameObject:SetActive(true) 
						end)
						parm.seq:AppendInterval(4)
						parm.seq:AppendCallback(function ()
							parm.seq:Append(self.ZGL.transform:DORotate(Vector3.New(0,180,0), 1))
							parm.seq:Append(self.ZGL.transform:DOLocalMove(Vector3.New(self.ZGL.transform.localPosition.x-500,0,0), 1))
						end)
						self.is_over=true
					end
				end
				
				--生成箭矢的obj
				local arrow={}
				self:SetArrowsLength()
				arrow.kind=i
				arrow.obj = newObject("ccjj_fangzhi_0"..i,self.StartPos)
				arrow.obj.gameObject.name=k.x.."--"..k.y;
				arrow.obj.gameObject:SetActive(false)

				arrow.hight_light = newObject("ccjj_jian_0"..i,self.content)
				arrow.hight_light.gameObject:SetActive(false)
				arrow.hight_light.transform.localPosition = eliminate_sg_algorithm.get_pos_by_index(k.x,k.y)	

				arrow.cover_obj = newObject("EliminateSGCoverPrefab_ccjj",self.StartPos)
				arrow.cover_obj.gameObject:SetActive(false)
				arrow.cover_obj.transform.position=arrow.hight_light.transform.position
				arrow.cover_obj.transform:Find("bg_img"):GetComponent("Image").sprite= GetTexture("xcys_bg_1")
				arrow.cover_obj.transform:Find("icon_img").gameObject:SetActive(false)
				-- cover_icon:GetComponent("RectTransform").sizeDelta=Vector2.New(104,104)

				arrow.end_pos=self:GetArrowIndex(i)*self.move_distance
				arrow.is_move=false	

				if self.is_over then
					arrow.cover_obj.gameObject:SetActive(true)
					arrow.hight_light.gameObject:SetActive(true)
				end
				if not self.is_over then
					parm.seq:AppendCallback(function ()
						ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_ccjj_fei.audio_name)	
					end)
					--箭矢的飞向队列的动画		
					self:arrows_fly(arrow,i,parm.seq)
					parm.seq:AppendCallback(function ()
						destroy(arrow.hight_light.gameObject)
						arrow.obj.gameObject:SetActive(true)
						self:show_arrows_group_number(i)
					end)
				    self:Setting_Move(i)
				    table.insert(self.all_arrows[i],arrow)
				    table.insert(cover_objs,arrow.cover_obj)
				    table.insert(cover_objs,arrow.hight_light)
				    self:SetArrowsLength()
					parm.seq:AppendInterval(1)
					--移动箭矢队列动画
					self:MoveArrows(parm.seq)
					self:move_arrows_group_number(parm.seq,i)
					self:show_warning(parm.seq)
				end
			end
		end
	end

	 --生成草船
	if parm.boat_fly_list then
		for i,v in ipairs(parm.boat_fly_list) do			
			local boat_hight_light = newObject("ccjj_chuan_chuxian",self.content)
			boat_hight_light.gameObject:SetActive(false)
			local boat_cover_ovj = newObject("EliminateSGCoverPrefab_ccjj",self.StartPos)
			boat_cover_ovj.gameObject:SetActive(false)
			boat_hight_light.transform.localPosition = eliminate_sg_algorithm.get_pos_by_index(v.x,v.y)
			boat_cover_ovj.transform.position=boat_hight_light.transform.position
			boat_hight_light.transform:SetParent(boat_cover_ovj.transform)
			-- if self.is_over then
			-- 	boat_cover_ovj.gameObject:SetActive(true)
			-- 	boat_hight_light.gameObject:SetActive(true)
			-- end
			table.insert(cover_objs,boat_cover_ovj)
			table.insert(cover_objs,boat_hight_light)
			self:SetArrowsLength()
			if not self.is_over then
				local obj_boat = newObject("EliminateSGCollectPrefab_ccjj", self.StartPos)
				obj_boat.transform.localPosition=Vector3.New(-self.move_distance*15.8,0,0)
				obj_boat.gameObject:SetActive(false)
				local path = {}
				local TX_star = GameObject.Instantiate(GetPrefab("xxl_sg_hf_prefab"),self.content)
				TX_star.transform.position=boat_hight_light.transform.position
				--TX_star.transform.localPosition= eliminate_sg_algorithm.get_pos_by_index(v.x,v.y)
				TX_star.gameObject:SetActive(false)
				local a = TX_star.transform.position
				local b = obj_boat.transform.position
				path[0] = a
				path[1] = Vector3.New(b.x,b.y,0)
				parm.seq:AppendCallback(function ()
					TX_star.gameObject:SetActive(true)
					boat_cover_ovj.transform:Find("icon_img").gameObject:SetActive(false)
					destroy(boat_hight_light)
				end)
				parm.seq:Append(TX_star.transform:DOPath(path,EliminateSGModel.GetTime(1),DG.Tweening.PathType.CatmullRom))
				parm.seq:AppendCallback(function ()
					obj_boat.gameObject:SetActive(true)
					destroy(TX_star)
				end)
			
				local boat_under_Atk_FX = newObject("ccjj_jianyu_under_atk",self.StartPos)
				boat_under_Atk_FX.transform.localPosition=Vector3.New(-self.move_distance*15.5,600,0)
				boat_under_Atk_FX.gameObject:SetActive(false)
				local arrow_fire_FX = newObject("ccjj_jianyu_fire",self.StartPos)
				arrow_fire_FX.gameObject:SetActive(false)
				parm.seq:AppendCallback(function ()
					self:ready_arrow_group(parm.seq,1)	
				end)
				parm.seq:AppendInterval(1)
	
				-- parm.seq:AppendCallback(function ()
				-- 	self:ready_arrow_group(parm.seq,2)	
				-- end)
				-- parm.seq:AppendInterval(1)
				
				parm.seq:AppendCallback(function ()
					self:ready_arrow_group(parm.seq,3,obj_boat,arrow_fire_FX)	
				end)
				parm.seq:AppendInterval(1)
	
				parm.seq:AppendCallback(function ()			
					self:ready_arrow_group(parm.seq,4,obj_boat)
					boat_under_Atk_FX.gameObject:SetActive(true)
					destroy(arrow_fire_FX)
				end)
				
				local ii={}
				for ll,mm in ipairs(self.all_arrows) do
					if #mm~=0 then
						table.insert(ii,ll)
					end
				end
				--这是对船多了，箭矢组数不够 进行报错打印！
				if  not self.all_arrows[ii[i]] then
					dump(self.all_arrows[ii[i]],"<color=red><size=15>++++++++++数据不对！！+++++++++</size></color>")	
				end
				--dump(#self.all_arrows[ii[i]],"<color=blue><size=15>++++++++++sssssssss+++++++++</size></color>")
				for m,t in ipairs(self.all_arrows[ii[i]]) do
					local add_bubb=newObject("arrow_add_0"..t.kind,obj_boat.transform)
					add_bubb.gameObject:SetActive(false)
					parm.seq:AppendInterval(0.4)
					parm.seq:AppendCallback(function ()			
						add_bubb.gameObject:SetActive(true)
					end)
				end

				parm.seq:AppendInterval(1.5)
				parm.seq:AppendCallback(function ()
					self:ready_arrow_group(parm.seq,5)
					destroy(boat_under_Atk_FX)
					destroy(obj_boat)
					self:SetArrowsLength()
					self:show_warning()	
				end)
			end
		end	
	end	
	parm.seq:AppendCallback(function ()
		self.BGImg.gameObject:SetActive(false)
		for j=#cover_objs,1,-1 do
			destroy(cover_objs[j])
			table.remove(cover_objs,j)
		end
	end)
 end
 
--箭矢飞行
function C:arrows_fly(arrow,arrow_type,seq)
	arrow.end_pos2=self:GetArrowIndex(arrow_type)*self.move_distance
	arrow.obj.transform.localPosition=Vector3.New(arrow.end_pos2,0,0)		
	seq:Append(arrow.hight_light.transform:DOMove(Vector3.New(arrow.obj.transform.position.x,arrow.obj.transform.position.y,0), 0.6))
end

--危字的显示 
function C:show_warning(seq)
	if self.all_arrowsLength>11 then
		if seq then
			seq:AppendCallback(function ()
				self.warning.gameObject:SetActive(true) 
			end)
		else
			self.warning.gameObject:SetActive(true) 
		end
	else
		if seq then
			seq:AppendCallback(function ()
				self.warning.gameObject:SetActive(false) 
			end)
		else
			self.warning.gameObject:SetActive(false) 
		end
	end
end

 --跳过箭矢飞行动画
 function C:jump_arrows_fly()
	 self.Is_jump_arrows_fly=true
 end


 --显示每组箭矢的数目
 function C:show_arrows_group_number(arrow_type,is_clear)
	local arrows= 0 
	for i,v in ipairs(self.all_arrows_txt) do
		if arrow_type==i then
			if is_clear then
				arrows= v.text+0
				v.text=0
				v.gameObject:SetActive(false)
			else
				v.gameObject:SetActive(true)
				v.text=v.text+self.every_arrow_have[i]
			end
		end
	end
	return arrows
 end

 --每组箭矢的数目的文本移动
 function C:move_arrows_group_number(seq,arrow_type)
	for i,v in ipairs(self.all_arrows_txt) do
		if arrow_type>=i then
			local index=(#self.all_arrows[i]-1)/2
			local pos= (self:GetArrowIndex(i)-index)*self.move_distance-15
			seq:Join(v.transform:DOLocalMove(Vector3.New(pos,50,0), 1))				
		end
	end
 end

 --清除最前面的一组 箭矢
 function C:ready_arrow_group(seq,index,boat,arrow_fire_FX)  
	local num=0
	for i,v in ipairs(self.all_arrows) do
		local fire_pos=self:GetArrowIndex(i)*self.move_distance
		if #v~=0 then
			if index==1 then
				ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_ccjj_fangjian.audio_name)	
				for j=#v,1,-1 do
					seq:Join(v[j].obj.transform:DOLocalMove(Vector3.New(fire_pos+(j-1)*4,0,0), 1))
				end
				break
			elseif index==2 then
				for j=#v,1,-1 do
			--		seq:Join(v[j].obj.transform:DOLocalMove(Vector3.New(fire_pos+(j-1)*15,-30,0),0.75))
				end
				break
			elseif index==3 then
				arrow_fire_FX.transform.localPosition=(Vector3.New(fire_pos,0,0))
				arrow_fire_FX.gameObject:SetActive(true)
				for j=#v,1,-1 do
					if j%3==0 then
						seq:Join(v[j].obj.transform:DOLocalMove(Vector3.New(fire_pos-500,750,0), 0.4))
					elseif j%3==2 then
						seq:Join(v[j].obj.transform:DOLocalMove(Vector3.New(fire_pos-400,650,0), 0.5))
					else
						seq:Join(v[j].obj.transform:DOLocalMove(Vector3.New(fire_pos-300,550,0), 0.75))
					end	
				end
				break
			elseif index==4 then
				if  boat then
					seq:Join(boat.transform:DOShakePosition(2,Vector3.New(5,1,0)))
				end
				break
			elseif index==5 then
				num=self:show_arrows_group_number(i,true)
				for j=#v,1,-1 do 
					destroy(v[j].obj)
					destroy(v[j].hight_light)
					table.remove(v,j)
				end
				break
			end
		end
	end
	Event.Brocast("refresh_collect_arrows_nums_change_mag",num)
 end

 --重置箭矢队列的长度
 function C:SetArrowsLength()
	 self.all_arrowsLength=0
	 for i,v in ipairs(self.all_arrows) do
		 self.all_arrowsLength = #v + self.all_arrowsLength
	 end
 end
 
 --返回生成哪类箭矢在整个箭矢队列的位置序号（从右到左）
 function C:GetArrowIndex(arrow_type)
	local index=0;	
	if arrow_type==1 then
		index= #self.all_arrows[arrow_type]
	elseif arrow_type==2 then
		index=  #self.all_arrows[arrow_type]+#self.all_arrows[arrow_type-1]		
	elseif arrow_type==3 then
		index=  #self.all_arrows[arrow_type]+#self.all_arrows[arrow_type-1]+#self.all_arrows[arrow_type-2]
	else
		index=  self.all_arrowsLength	
	end
	return index-self.all_arrowsLength;	
 end

 --设置需要向前移动的箭矢
 function C:Setting_Move(arrow_type)	
	for i=1,arrow_type do
		for j,k in ipairs(self.all_arrows[i]) do
			k.is_move =true
		end
	end
end

 
 --向前移动生成那类箭矢（包含自身类）
 function C:MoveArrows(seq)
	for i,v in ipairs(self.all_arrows) do
		for j,k in ipairs(v) do
			if k.is_move then
				k.end_pos=k.end_pos-self.move_distance
				--self.all_arrows[i][j].end_pos=self.all_arrows[i][j].end_pos-self.move_distance
				if self.Is_jump_arrows_fly then
					k.obj.transform.localPosition=Vector3.New(k.end_pos,0,0)
				else
					seq:Join(k.obj.transform:DOLocalMove(Vector3.New(k.end_pos,0,0), 0.75))
					k.is_move=false
				end
			end
		end
	end	
end

 
 
 