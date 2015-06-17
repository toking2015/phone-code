local prePath = 'image/ui/NTeamUpgradeUI/'

TeamUpgradItem = createUILayout("TeamUpgradItem", prePath .. "TeamUpgradeItem.ExportJson", "TeamUpgradeUI")

-- 获取开启的功能
local function judgeOpenFunc()
	local team_level = gameData.getSimpleDataByKey("team_level")
	local openData = findLevel(team_level)
	local openName = openData.open_desc or ''
	return openName
end

local len = 0
local function addWord(str, parent,fontSize,c3b,font)
	local txt = UIFactory.getText(str, parent, nil, nil, fontSize, c3b, font)
	txt:setAnchorPoint(0, 0.5)
	txt:setPositionX(len)
	len = txt:getContentSize().width + len + 24
	LogMgr.debug('Word index = ', index, 'len = ', len)
end

local function addImage(img, parent, index)
	local image = ccui.ImageView:create(img, ccui.TextureResType.localType)
	parent:addChild(image)
	image:setAnchorPoint(cc.p(0, 0.5))
	LogMgr.debug('Image index = ', index, 'len = ', len)
	image:setPositionX(len*index)
	len = image:getSize().width + len
end

local function resolveString(str, prePath, node)
	if str == nil and str == "" then
		return
	end
        
    local textFont = FontStyle.ZH_12
	 -- str: 待解析字符串
	 -- str1: 正解析字符串
	 -- str2: 两[]之间文字
	local str1, str2 = '', ''
	local index = 0
	while str and str ~= '' and index < 3 do
		local i, j = string.find(str, '(%b[])')
		if not i then
			str2 = str
			str = ''
			addWord(str2, node, textFont.fontSize, textFont.fontColor, textFont.fontName)
		elseif i > 1 then
			str2 = string.sub(str, 1, i - 1)
			str = string.sub(str, i)
			addWord(str2, node, textFont.fontSize, textFont.fontColor, textFont.fontName)
		elseif 1 == i and RichText.isFone(string.sub(str, i+1, j-1)) then
			str1 = string.sub(str, i, j)
			local m, n = string.find(str1,"%l+")   
			local tag = string.sub(str1,m,n)
			if tag ~= 'br' and tag ~= 'image' then
				local k, l = string.find(str, "(%b[])", j + 1) -- 匹配下一个[]
				if k then 
					str1 = string.sub(str, i, k - 1) 
					str = string.sub(str, k)
				else
					str1 = string.sub(str, i, k)
					str = ''
				end
			elseif tag == 'br' or tag == 'image' then
				str = string.sub(str, j + 1)
			end
			if tag == "font" then	
				local font = string.sub(str1, n+2, j-1)
				local word = string.sub(str1, j+1)
				LogMgr.debug("word = ", word)
                textFont = FontStyle[font]
				addWord(word, node, textFont.fontSize, textFont.fontColor, textFont.fontName)
			elseif tag == "image" then	
				local img = string.sub(str1, n+2, j-1)
				addImage(prePath .. img, node, index)
				index = index + 1
			end
		end
	end
end

function TeamUpgradItem:setGLFiltersWhite()
    local programState = ProgramMgr.createProgramState("paint")
    programState:setUniformFloat('u_color', {x = 1, y = 1, z = 1, w = 1} )
	self.lev_num:setGLProgramState(programState)
end


function TeamUpgradItem:ctor()
	-- self.shine:loadTexture(prePath .. "team_shine.png", ccui.TextureResType.localType)
	self:showEffectAction("zdsj-zdjsgx1-tx-01", -10, -23 , self.shine)
	self:showEffectAction("zdsj-zdqdangx-tx-01", 79, 24, self.btn_confirm)

	self:init()
	-- self:setGLFiltersWhite()
	ProgramMgr.setLight(self.lev_num, 199)

	self.con_open:setTouchEnabled(false)

	local btn_confirm = createScaleButton(self.btn_confirm)
	local function callback()
    	ActionMgr.save( 'UI', string.format('[%s] click [%s]', "TeamUpgradeUI", 'btn_confirm') )
    	EventMgr.dispatch(EventType.closeTeamUpgradeUI)
		PopMgr.removeWindowByName("TeamUpgradeUI")
	end
	btn_confirm:addTouchEnded(callback)
end

function TeamUpgradItem:init()
	self.upgrade_txt_1:setOpacity(0)
	self.upgrade_txt_2:setOpacity(0)
	self.arrow:setOpacity(0)
	self.arrow_0:setOpacity(0)
	self.arrow_1:setOpacity(0)
	self.arrow:setPositionX(self.arrow:getPositionX()-6)
	self.arrow_0:setPositionX(self.arrow_0:getPositionX()-6)
	self.arrow_1:setPositionX(self.arrow_1:getPositionX()-6)
	self.cur_con:setVisible(false)
	self.txt_cur_strength_2:setVisible(false)
	self.txt_strength_limit_2:setVisible(false)
	self.txt_hero_limit_2:setVisible(false)
	self.con_open.img_open:setOpacity(0)
	self.btn_confirm:setVisible(false)	
end

function TeamUpgradItem:showStyle()
	local a_title_show = cc.CallFunc:create(function()
		local fade = cc.FadeIn:create(0.2)
		local function levelShow()
			local scale_1 = cc.ScaleTo:create(0.15, 1.5)
			local scale_2 = cc.ScaleTo:create(0.1, 1)
			self.lev_num:runAction(cc.Sequence:create(scale_1, scale_2))
		end
		self.upgrade_txt_1:runAction(fade:clone())
		self.upgrade_txt_2:runAction(cc.Sequence:create(fade:clone(), cc.CallFunc:create(levelShow)))
	end)
	local a_con_show = cc.CallFunc:create(function()
		self.cur_con:setVisible(true)
		local fade = cc.FadeIn:create(0.2)
		local move = cc.MoveBy:create(0.25, cc.p(6, 0))
		local sq = cc.Sequence:create(fade, move)
		local function callfunc()
			local fade = cc.FadeIn:create(0.2)
			local function callback()
				self.con_open.open_bg:setVisible(true)
				self.btn_confirm:setVisible(true)
			end
			self.con_open.img_open:runAction(cc.Sequence:create(fade, cc.CallFunc:create(callback)))
		end
		self.arrow:runAction(cc.Sequence:create(fade:clone(), move:clone(), cc.CallFunc:create(function() 
				a_num_rolling(self.txt_cur_strength_2, self.newStrength, self.originStrength, callfunc)
			end)))
		self.arrow_0:runAction(cc.Sequence:create(fade:clone(), move:clone(), cc.CallFunc:create(function() 
				a_num_rolling(self.txt_strength_limit_2, self.newStrengthLimit, self.oldStrengthLimit)
			end)))
		self.arrow_1:runAction(cc.Sequence:create(fade:clone(), move:clone(), cc.CallFunc:create(function() 
				a_num_rolling(self.txt_hero_limit_2, self.newHeroLevelLimit, self.oldHeroLevelLimit)
			end)))
	end)
	local a_open_show = cc.CallFunc:create(function()
		-- local fade = cc.FadeIn:create(0.2)
		-- local function callback()
		-- 	self.con_open.open_bg:setVisible(true)
		-- 	self.btn_confirm:setVisible(true)
		-- end
		-- self.con_open.img_open:runAction(cc.Sequence:create(fade, cc.CallFunc:create(callback)))
	end)
	local delay = cc.DelayTime:create(0.56)
	self:runAction(cc.Sequence:create(a_title_show, delay:clone(), a_con_show))--, delay:clone(), a_open_show))
end

function TeamUpgradItem:showEffectAction(name, x, y, parent)
	local url = "image/armature/ui/TeamUpgradeUI/" .. name .. "/" .. name ..".ExportJson"
	LoadMgr.loadArmatureFileInfo(url, LoadMgr.SCENE, "main")
	local effect = ArmatureSprite:create(name, 0)

	effect:setPosition(cc.p(x, y))

	parent:addChild(effect)

	return effect
end

function TeamUpgradItem:createItem(oldLev, newLev, oldStrength)
	local view = TeamUpgradItem.new()
    -- initLayout(view)
    view.oldLevel = oldLev
    view.newLevel = newLev
    view.originStrength = oldStrength

    view:updateData()
    view:showOpenFunc()
	view:showStyle()

    return view
end

function TeamUpgradItem:showOpenFunc()
	local open = judgeOpenFunc()
	self.open = open
	if open == "" then
		-- 无新功能开启
		self.con_open:setVisible(false)
	else
		self.con_open:setVisible(true)
		self.con_open.open_bg:setVisible(false)
		self.con_open.open_bg:loadTexture(prePath .. "team_frame.png", ccui.TextureResType.localType)
	end
	self:updateOpenContent()
end

function TeamUpgradItem:updateOpenContent()
	local richText = ccui.RichText:create()
	richText:setSize(cc.size(517, 53))
	richText:setTouchEnabled(false)
	richText:setPosition(cc.p(self.con_open.open_bg:getSize().width/2, self.con_open.open_bg:getSize().height/2))
	self.con_open.open_bg:addChild(richText)
	local open_str = self.open
	-- open_str = "英雄进阶，图腾升级，金矿开启"
	open_str = open_str or ""
	local node = cc.Node:create()
	self.con_open.open_bg:addChild(node)
	resolveString(open_str, prePath .. "open_icon/", node)
	LogMgr.debug('len = ', len)
	node:setPosition(cc.p((self.con_open.open_bg:getSize().width-len+24)/2, self.con_open.open_bg:getSize().height/2))
end

function TeamUpgradItem:updateData()
 	local newStrength = gameData.getSimpleDataByKey('strength')
 	self.newStrength = newStrength

 	local oldData = findLevel(self.oldLevel)
 	local oldStrengthLimit = oldData.strength
 	local oldHeroLevelLimit = oldData.soldier_lv
 	self.oldStrengthLimit = oldStrengthLimit
 	self.oldHeroLevelLimit = oldHeroLevelLimit

 	local newData = findLevel(self.newLevel)
 	local newStrengthLimit = newData.strength
 	local newHeroLevelLimit = newData.soldier_lv
 	self.newStrengthLimit = newStrengthLimit
 	self.newHeroLevelLimit = newHeroLevelLimit

	self.lev_num:setString(self.newLevel)
	self.cur_con.txt_cur_strength_1:setString(self.originStrength)
	-- self.txt_cur_strength_2:setString(newStrength)
	self.cur_con.txt_strength_limit_1:setString(oldStrengthLimit)
	-- self.txt_strength_limit_2:setString(newStrengthLimit)
	self.cur_con.txt_hero_limit_1:setString(oldHeroLevelLimit)
	-- self.txt_hero_limit_2:setString(newHeroLevelLimit)
end

function TeamUpgradItem:releaseAll()
	len = 0
end