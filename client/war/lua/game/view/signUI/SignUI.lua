--@author zengxianrong
--@author zengxianrong
local prePath = "image/ui/SignUI/"
local url_item = prePath .. "SignItem.ExportJson"
local num_img_src = "image/share/num_item.png"
require("lua/game/view/bagUI/BagItem.lua")

local STATE_NORMAL = 0
local STATE_MARK = 1
local STATE_MEND = 2
local STATE_READY = 3

local SignItem = class(
    "SignItem", 
    function()
        return getLayout(url_item)
    end
)

function SignItem:ctor()
    self:setTouchEnabled(true)
    local function onDayTouchEnd(sender, eventType)
        ActionMgr.save( 'UI', '[SignItem] click [btn]' )
        if SignData.canSign( ) then
            trans.send_msg("PQSign", {})
        end
    end
    UIMgr.addTouchEnded(self.btn, onDayTouchEnd)
    UIMgr.addTouchEnded(self, onDayTouchEnd)
end

--刷新显示
function SignItem:updateData()
    local item_url = "SignUI/"
    self:setTouchEnabled(false)
    self.fla_done:setVisible(false)
    self.btn:setVisible(false)
    self.fla_day:setVisible(false)
    setButtonPoint(self.btn,false)
    if self.time_data then
        local dif_day = SignData.getCountInOpenDay(self.time_data)
        self.btn.time_data = time_data
        local cur_day = SignData.getDifDay(self.time_data,SignData.getCurrentSeverTime())
        if dif_day <= 0 then

        else
            if dif_day == 1 then --开服
                self.fla_day:setVisible(true)
                self.fla_day:loadTexture(item_url.."fla_open_day.png",ccui.TextureResType.plistType)
            else
                if cur_day == 0 then
                    self.fla_day:setVisible(true)
                    self.fla_day:loadTexture(item_url.."fla_today.png",ccui.TextureResType.plistType)
                end
            end
            if SignData.canSign(self.time_data) then
                self.btn:setVisible(true)
                self:setTouchEnabled(true)
                setButtonPoint(self.btn,true,cc.p(65,29),nil,nil,cc.p(0.8,0.8))
                self.btn:loadTextureNormal(item_url.."btn_sign1.png",ccui.TextureResType.plistType)
                self.btn:setTouchEnabled(true)
            elseif SignData.hasSign(self.time_data) then
                self.fla_done:setVisible(true)
            elseif cur_day > 0 then
                self.btn:setVisible(true)
                self.btn:loadTextureNormal(item_url.."btn_await2.png",ccui.TextureResType.plistType)
                self.btn:setTouchEnabled(false)
            end
        end
    end
end
---
-- 窗口类
---
local SignUI = createUIClass("SignUI", prePath .. "SignUI.ExportJson", PopWayMgr.SMALLTOBIG)
SignUI.sceneName = "common"

function SignUI:ctor()
    --记录需要释放的其他窗口的资源
    local otherPath = "image/ui/bagUI/"
    LoadMgr.addPlistPool(otherPath.."WarPackage0.plist", otherPath.."WarPackage0.png", LoadMgr.WINDOW, self.winName)

    self.img_1:loadTexture(prePath.."bg_img1.png",ccui.TextureResType.localType)
    self.img_2:loadTexture(prePath.."bg_img2.png",ccui.TextureResType.localType)
    self.txt_getted_normal:setString("明天可领取")
    self.txt_getted_normal:setPosition(cc.p(166 + 16,68))
    self.txt_getted_haohua:setString("明天充值可领取")
    addOutline(self.txt_count_title, cc.c4b(0x54, 0x1c, 0x04, 0xff), 2)
    addOutline(self.txt_haohua_title, cc.c4b(0x54, 0x1c, 0x04, 0xff), 2)
    addOutline(self.txt_getted_normal, cc.c4b(0x54, 0x1c, 0x04, 0xff), 2)
    addOutline(self.txt_getted_haohua, cc.c4b(0x54, 0x1c, 0x04, 0xff), 2)
    addOutline(self.txt_getted_sun, cc.c4b(0x54, 0x1c, 0x04, 0xff), 2)
    addOutline(self.txt_count, cc.c4b(0x54, 0x1c, 0x04, 0xff), 2)
     addOutline(self.txt_count_sum, cc.c4b(0x54, 0x1c, 0x04, 0xff), 2)
    self.txt_count:setPosition(cc.p(175,473))
    self.txt_getted_normal:setVisible(false)
    self.txt_getted_haohua:setVisible(falOpse)
    self.txt_getted_sun:setVisible(false)
    local function onHaohuaTouchEnd(sender, eventType)
        ActionMgr.save( 'UI', '[SignUI] click [btn_get_haohua]' )
        if SignData.canGetHaoHua() then
            if self.jSignDay_haohua then
                 trans.send_msg("PQTakeHaohuaReward", {})
            end
        end
    end
    local function onHaohuaRechargeTouchEnd(sender, eventType)
        ActionMgr.save( 'UI', '[SignUI] click [btn_haohua]' )
        PopMgr.removeWindowByName("SignUI")
        Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
    end
    local function onRewardTouchEnd(sender, eventType)
        ActionMgr.save( 'UI', '[SignUI] click [btn_get_sum]' )
        if SignData.canGetSum() then
            local jSignSum = SignData.getNextTotalReward()
            if jSignSum then
                 trans.send_msg("PQTakeSignSumReward", {reward_id = jSignSum.id})
            end
        end
    end
    UIMgr.addTouchEnded(self.btn_get_haohua, onHaohuaTouchEnd)
    UIMgr.addTouchEnded(self.btn_haohua, onHaohuaRechargeTouchEnd)
    UIMgr.addTouchEnded(self.btn_get_sum, onRewardTouchEnd)
    -- self.btn_get_haohua:addTouchEnded(onHaohuaTouchEnd)
    -- self.btn_haohua:addTouchEnded(onHaohuaRechargeTouchEnd)
    -- self.btn_get_sum:addTouchEnded(onRewardTouchEnd)
    self.event_list = {}
    self.event_list[EventType.UserMarkUpdate] = function() self:updateData() end
    self.event_list[EventType.UserMarkReward] = function() self:updateData() end
    self.item_list = {}
    self.item_rewardList = {}
    self:initItemList()
    self:initReward()
    self.normal_cpoint = cc.p(177,100)
    self.haohua_cpoint = cc.p(521,100)
    self.sum_cpoint = cc.p(737,232)
end

function SignUI:initReward( ... )
    self.normal_reward_itemList = {}
    self.haohua_reward_itemList = {}
    self.sum_reward_itemList = {}
    for i=1,4 do
        table.insert(self.normal_reward_itemList,self:createRewardItem())
        table.insert(self.haohua_reward_itemList,self:createRewardItem())
    end
    for i=1,2 do
        table.insert(self.sum_reward_itemList,self:createRewardItem())
    end
end
--获取物品显示
function SignUI:createRewardItem( ... )
    local rewardItem = BagItem:create("image/ui/bagUI/Item.ExportJson" )
    rewardItem.item_num_line:setVisible(false)
    rewardItem.btn_item_delect:setVisible(false)
    self:addChild(rewardItem)
    rewardItem:setVisible(false)
    rewardItem:showTips(true)
    return rewardItem
end

function SignUI:initItemList( ... )
    self.item_list = {}
    for i=1,7 do 
        local item = SignItem:new()
        item.index = i
        item.img_day:loadTexture("SignUI/day_"..i..".png",ccui.TextureResType.plistType)
        addToParent(item ,self, 27 + (i -1) * 94, 314)
        table.insert( self.item_list, item )
    end
end

function SignUI:updateBtnAndText( ... )
    local count = SignData.getCount()
    local nextCount = SignData.getNextCount()
    self.txt_count:setString(tostring(count))
    self.txt_count_sum:setString(tostring(count).."/"..tostring(nextCount))
    --普通奖励
    self.txt_getted_normal:setVisible(false)
    self.btn_get_normal:setVisible(false)
    local dif_day = SignData.getCountInOpenDay()
    if dif_day > 0 then
        local jSign = findSignDay(dif_day)
        if jSign and SignData.getServerDay(jSign.id) then --如果已领取
            self.txt_getted_normal:setVisible(true)
        end
    end

    --豪华奖励
    self.btn_get_haohua:setVisible(false)
    self.txt_getted_haohua:setVisible(false)
    self.btn_haohua:setVisible(false)
    if SignData.canGetHaoHua() then
        self.btn_get_haohua:setVisible(true)
        ProgramMgr.setNormal(self.btn_get_haohua)
        self.btn_get_haohua:setEnabled(true)
        setButtonPoint(self.btn_get_haohua,true,cc.p(154,46))
    else
        setButtonPoint(self.btn_get_haohua,false)
        if SignData.hasGetHaoHua() then
             self.txt_getted_haohua:setVisible(true)
        else
            self.btn_haohua:setVisible(true)
        end
    end
    --累积奖励
    self.btn_get_sum:setVisible(false)
    self.txt_getted_sun:setVisible(false)
    if SignData.canGetSum() then
         self.btn_get_sum:setVisible(true)
        ProgramMgr.setNormal(self.btn_get_sum)
        self.btn_get_sum:setEnabled(true)
        setButtonPoint(self.btn_get_sum,true,cc.p(148,43))
    else
        self.btn_get_sum:setVisible(true)
        ProgramMgr.setGray(self.btn_get_sum)
        self.btn_get_sum:setEnabled(false)
        setButtonPoint(self.btn_get_sum,false)
    end
end

function SignUI:updateDataReward( ... )
    local normal_rewardlsit = SignData.getCurJSinData() and SignData.getCurJSinData().rewards
    local haohua_rewardlist = SignData.getCurJSinData(true) and SignData.getCurJSinData(true).haohua_rewards
    self.jSignDay_normal = SignData.getCurJSinData()
    self.jSignDay_haohua = SignData.getCurJSinData(true)
    self:updateDataRewardItem(self.normal_reward_itemList,normal_rewardlsit,self.normal_cpoint)
    self:updateDataRewardItem(self.haohua_reward_itemList,haohua_rewardlist,self.haohua_cpoint)
    self:updateDataRewardSum()
end

function SignUI:updateDataRewardSum( ... )
    local  itemlist = self.sum_reward_itemList
    if itemlist then
        for k,v in pairs(itemlist) do
            if v then
                v:setVisible(false)
            end
        end
        local rewardlist = SignData.getNextTotalReward()
        if rewardlist and not table.empty(rewardlist.rewards) then
            local len = math.min(#itemlist,#rewardlist.rewards)
            local starY = self.sum_cpoint.y - (104 * len + (len -1) * 30)/2
            for i=1,(math.min(#itemlist,#rewardlist.rewards)) do
                itemlist[i]:setVisible(true)
                itemlist[i]:setPosition(cc.p(self.sum_cpoint.x ,starY + (i -1) * (104 + 30)))
                self:updateItemBox(itemlist[i],rewardlist.rewards[i])
            end
        end
    end
end

function SignUI:updateDataRewardItem( itemlist,rewardlist,cpoint )
    --普通奖励
    if itemlist then
        for k,v in pairs(itemlist) do
            if v then
                v:setVisible(false)
            end
        end
        if rewardlist and not table.empty(rewardlist) then
            local len = math.min(#itemlist,#rewardlist)
            local starx = cpoint.x - ( 104 * len + (len -1) * 34 )/2
            for i=1,(math.min(#itemlist,#rewardlist)) do
                itemlist[i]:setVisible(true)
                itemlist[i]:setPosition(cc.p(starx + (i -1) * (105 + 34),cpoint.y))
                self:updateItemBox(itemlist[i],rewardlist[i])
            end
        end
    end
end

function SignUI:updateItemBox( rewardItem,reward )
    if not rewardItem or not reward then
        return
    end
    rewardItem.reward = reward
    local quality = 3
    if reward.cate == const.kCoinItem then
        local jItem = findItem( reward.objid )
        if jItem then
            quality = ItemData.getQuality( jItem, userItem )
        end
    end
    rewardItem.item_quality:loadTexture(ItemData.getItemBgUrl( quality ),ccui.TextureResType.localType)
    local url = CoinData.getCoinUrl(reward.cate, reward.objid)
    if nil == url or url == "" then
        LogMgr.debug("路径不存在：")
    else
        rewardItem.item_icon:loadTexture(url,ccui.TextureResType.localType)
        rewardItem:setItemCount(reward.val)
    end
end

function SignUI:updateDataItem( ... )
    local timedatalist = SignData.getItemTimeList()
    if self.item_list then
        for k,v in pairs(self.item_list) do
            if v and v.updateData then
                if v.index and v.index <= #timedatalist then
                    v.time_data = timedatalist[v.index]
                end
                v:updateData()
            end
        end
    end
end

function SignUI:onShow()
    SignData.getCanGet(true)
    EventMgr.addList(self.event_list)
    performNextFrame(self, function() self:updateData() end)
end

function SignUI:updateData( ... )
    self:updateDataItem()
    self:updateDataReward()
    self:updateBtnAndText()
end

function  SignUI:onClose()
    EventMgr.removeList(self.event_list)
end

