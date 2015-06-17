--声明类
FlyUI = createUIClassEx("FlyUI", cc.Node,PopWayMgr.NONE )

local win = nil
function FlyUI:onShow()  
	self:updateData()

end

function FlyUI:updateData( )
	if win == nil then
		return
	end
	if table.getn( self.flyList ) <= 0 then 
		self:newFly()
	end
end

function FlyUI:newFly()
	for k,v in pairs(self.inList) do
		local c3b = cc.c3b(255, 0, 0 )
		local label = UIFactory.getText(v, self, 0, 0, 21, c3b, 18,nil,0)
		label:setFontName(FontNames.HEITI)
		--self:addOutline(label,cc.c4b(30,12,0,255),1)
		self:addOutline(label,cc.c4b(30,12,0,100),1)
		--cc.LabelTTF:create(v, FontNames.HEITI,21)
	    --label:setColor( cc.c3b(240, 30, 30 ))
	    --self:addChild(label)
	    label:setAnchorPoint( cc.p(0.5, 0.5) )
	    table.remove(self.inList,k)
	    self:fly(label)
	    break
	end
end

function FlyUI:addOutline(item, rgb, px)
    if item == nil then return end
    local txt = item:getVirtualRenderer()
    --txt:enableOutline(rgb, px)
    txt:enableGlow(rgb)
end

function FlyUI:fly( obj )
    table.insert(self.flyList,obj)
    local function actionNext( )
    	if table.getn( self.inList ) > 0 then 
			self:newFly()
		end
    end

	local function actionComplete( )
		if win == nil then
			return
		end
		
        for k,v in pairs(self.flyList) do
            extRemoveChild(v)
            table.remove(self.flyList,k)
            break
        end
		if table.getn( self.flyList ) <= 0 then
			extRemoveChild(win)
			win = nil
		end
	end

	local moveToAction = cc.MoveTo:create(0.3, cc.p(0, 170))
	
   	local delay = cc.DelayTime:create(0.3)

	local outAction = cc.FadeOut:create(0.3)
	local moveToAction2 = cc.MoveTo:create(0.3, cc.p(0, 200))
	local spa = cc.Spawn:create(outAction,moveToAction2)
    local seq = cc.Sequence:create( moveToAction,delay,cc.CallFunc:create(actionNext),spa, cc.CallFunc:create(actionComplete) )
    obj:runAction(seq)
end

function FlyUI:onClose() 
	
end
function FlyUI:ctor()
	self.inList = {}  
	self.flyList ={}
	self:setAnchorPoint(cc.p(0,0)) 
end

function FlyTxt( info,type )
	if win == nil then
		win = FlyUI.new()
	    SceneMgr.getLayer(SceneMgr.LAYER_EFFECT):addChild(win, 999)
	    win:setPosition( visibleSize.width/2 , visibleSize.height/2 - 30)
	end
	table.insert( win.inList, info )
    win:onShow()
end