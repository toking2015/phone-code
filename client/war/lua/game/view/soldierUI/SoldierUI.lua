--**谭春映
--**英雄系统 2015版  
require "lua/game/view/soldierUI/SoldierDefine.lua"
require "lua/game/view/soldierUI/SoldierList.lua"
--声明类
local url = SoldierDefine.prePath .. "main.ExportJson"
SoldierUI = createUIClass("SoldierUI", url, PopWayMgr.SMALLTOBIG)
local __this = SoldierUI
__this.sceneName = "common"

function __this:onShow()
    EventMgr.addList(self.event_list)
    local function callback()
        if self.listView then
            self.listView:onShow()
        end
        self:updateData()
    end
    performNextFrame(self, callback)
    --Command.run("ui show", "RewardGetUI", PopUpType.SPECIAL)
end

function __this:onClose()
    EventMgr.removeList(self.event_list)
    if self.listView then
        self.listView:onClose()
    end
end

function __this:updateData()
    if not self.listView then
        return
    end
    self:updateDataRedPoint()
    self.listView:updateData()
end

function __this:updateDataRedPoint( ... )
    --可招募英雄红点显示
    self:clearRed()
    local enRecruit= SoldierData.enRecruitMapByEquipType()
    local enLevelUp,enStarUp = SoldierData.starAndLevelUpMap()

    local index = 0
    local has = false
    --equipType [1~4]
    for i=1,4 do
        if enRecruit[i] or enLevelUp[i] or enStarUp[i] 
            or SoldierData.hasStepUp(i) or SoldierData.hasBookDress(i) then
            index = self:getIndex(i)
            self:setRedByIndex(index)
            has = true
        end
    end

    if has then
        self:setRedByIndex(1)
    end
end

function __this:clearRed()
    for k,v in pairs(self.btnList) do
        setButtonPoint( v, false)
    end
    setButtonPoint( self.mainBtnS, false)
end

function __this:setRedByIndex(index)
    local redBtn = self.btnList[index]
    if index == self.index then
        redBtn = self.mainBtnS
    end
    local size = redBtn:getSize()
    local off = cc.p(8,size.height - 8)
    setButtonPoint( redBtn, true ,off)
end

function __this:changeContent()
    if not self.listView then
        return
    end

    if(self.curBtn ~= nil) then
        self:setBtn(self.curBtn,true)
    end

    local equipType = self:getEquipType(self.index)
	--内容变更
    self.listView:setType( equipType )
    self:setBtn(self.btnList[self.index],false)
    self.curBtn = self.btnList[self.index]
    self:updateDataRedPoint()
end

function __this:getEquipType( index )
    --1全部2板甲3锁甲4皮甲5布甲【按钮顺序】
    --1:布甲，2:皮甲，3:锁甲，4:板甲【真实值】
    if index == 1 then
        return 0
    elseif index == 2 then
        return 4
    elseif index == 3 then
        return 3
    elseif index == 4 then
        return 2
    elseif index == 5 then
        return 1
    end
end

function __this:getIndex( equipType )
    --1全部2板甲3锁甲4皮甲5布甲【按钮顺序】
    --1:布甲，2:皮甲，3:锁甲，4:板甲【真实值】
    if equipType == 0 then
        return 1
    elseif equipType == 4 then
        return 2
    elseif equipType == 3 then
        return 3
    elseif equipType == 2 then
        return 4
    elseif equipType == 1 then
        return 5
    end
end

function __this:setBtn( btn,state)
	local index = btn.index
	local btnS = self.mainBtnS
    if not state then
        --选中
        btn:setVisible(false)
		btnS:setVisible(true)
		btnS.mainBtnTitle:loadTexture (self.titleUrls[index] .. ".png", ccui.TextureResType.plistType)
    	btnS.mainBtnIcon:loadTexture (self.iconUrl[index] .. ".png", ccui.TextureResType.plistType)
    	local btnPosi = cc.p( btn:getPosition() )
    	btnPosi.x = btnPosi.x - 25
    	btnS:setPosition(btnPosi)
    else
    	btn:setVisible(true)
    end
end

--按钮初始化
function __this:initMainBtn( )
    local function btnFunc(sender,type)
        ActionMgr.save( 'UI', 'SoldierUI click mainBtn_obj'..sender.index..' T'.. self:getEquipType(sender.index))
    	if type ~= ccui.TouchEventType.ended then
	        return
	    end

        self.index = sender.index
        self:changeContent()
    end
 
 	self.btnList = {}
    for i=1,5 do
        local offY = 446 - 90 * ( i -1 )
        local obj = getLayout(SoldierDefine.prePath .. "mainBtn.ExportJson")
        self.mainBtnLay:addChild(obj)
        obj:setPosition(2,offY)
        self.btnList[i]  = obj
        obj.mainBtnTitle:loadTexture (self.titleUrln[i] .. ".png", ccui.TextureResType.plistType)
        obj.mainBtnIcon:loadTexture (self.iconUrl[i] .. ".png", ccui.TextureResType.plistType)
        obj.mainBtnBg:addTouchEventListener(btnFunc)
        obj.index = i
        createScaleButton(obj)
    	obj:addTouchEnded(btnFunc)
	end
end

function __this:initSelectedBtn( ... )
	self.mainBtnS = getLayout(SoldierDefine.prePath .. "mainBtnS.ExportJson")
	self:addChild(self.mainBtnS,5)
	self.mainBtnS:setVisible(false)
end

--初始化列表
function __this:initList( )
    if self.listView then
        return
    end

    self.listView = SoldierList.new()
    self.listView:setPosition(153,25)
    self:addChild(self.listView,10) 
    self.index = 1
    self:changeContent()
end

--初始化基础
function __this:ctor()
    local function update( )
        self:updateData()
    end
    local function getNewSoldier( )
        self:changeContent()
        self:updateData()
    end
	self.isUpRoleTopView = true --显示资源条

	self.titleUrln = {"soldiern_mainbtn_a1","soldiern_mainbtn_b1","soldiern_mainbtn_c1","soldiern_mainbtn_d1","soldiern_mainbtn_e1"}
    self.titleUrls = {"soldiern_mainbtn_a2","soldiern_mainbtn_b2","soldiern_mainbtn_c2","soldiern_mainbtn_d2","soldiern_mainbtn_e2"}
    self.iconUrl = {"soldiern_mainbtn_a","soldiern_mainbtn_b","soldiern_mainbtn_c","soldiern_mainbtn_d","soldiern_mainbtn_e"}
	
	self:initSelectedBtn()
	self:initMainBtn()
	self:initList()
    self.event_list = {}
    self.event_list[EventType.UserSoldierUpdate] = update
    self.event_list[EventType.UserItemUpdate] = update
    self.event_list[EventType.UserFightExtAbleUpdate] = update
    self.event_list[EventType.UserSoldierRecruit] = getNewSoldier
    local bottomLine = cc.Sprite:createWithSpriteFrameName("soldierbg_bottom.png")
    self:addChild(bottomLine,100)
    bottomLine:setPosition(508,20)
end

function __this:dispose( )
    if self.listView then
        self.listView:dispose()
    end
end

--引导接口
function __this:getSelectedItem(id)
    if self.index ~= 1 then
        self.index = 1
        self:changeContent()
    end
    
    if self.listView then
        self.listView:setDefaultSoldier(id)
        return self.listView.inductItem
    end
    return nil
end
--引导接口