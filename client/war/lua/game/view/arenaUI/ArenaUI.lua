--竞技场界面
--write by weihao
require "lua/game/view/arenaUI/ArenaResult.lua"
require "lua/game/view/arenaUI/ArenaWarRecord.lua"
require "lua/game/view/arenaUI/ArenaRanking.lua"
require "lua/game/view/storeUI/Store.lua"
local prePath = "image/ui/ArenaUI/"
local prePatharm = "image/armature/ui/ArenaUI/"
local url = prePath .. "WarArena.ExportJson"
ArenaUI = createUIClass("ArenaUI", url, PopWayMgr.SMALLTOBIG)
ArenaData.outShowFlag = false -- 是否重新弹出
ArenaUI.rolecd = 0 --cd时间
function ArenaUI.setFun(type ,id)
    return  function()   
        ArenaData.isIntoScene = false 
        Command.run("fight arena",type , id) end                      
end

function ArenaUI:addOutline(item, rgb, px)
    local txt = item:getVirtualRenderer()
    txt:enableOutline(rgb, px)
end

--进入布阵
function ArenaUI.setWarLister(funopen, funclose ,list, exData)
    Command.run('formation show arena', list,  funopen, funclose, exData)
end

-- 重新进入ui
local function funShow()
--    ArenaData.isIntoScene = false 
    ArenaUI.reShow()
    ArenaData.setRolelist()
    ArenaData.setEmenylist()
end 

function ArenaUI:btnlister()
    self.addbtn:addTouchEnded(function() LogMgr.debug("ArenaUI weihao".."添加")
        ActionMgr.save( 'UI', 'ArenaUI click addbtn' )
        local levelid = gameData.user.simple.vip_level
        local times = findLevel(levelid).singlearena_times
        if levelid > 20 then 
            times = findLevel(20).singlearena_times
        elseif times == nil then  
            times = 0
        end 

        local guding = tonumber(findGlobal("singlearena_challenge_times").data)
        if (self.all - guding )/findGlobal("singlearena_add_times_base").data < times then 
            local dim = CoinData.getCoinByCate(const.kCoinGold)
            local t = (self.all - guding)/findGlobal("singlearena_add_times_base").data + 1
            local cost = tonumber(findLevel((self.all - guding)/findGlobal("singlearena_add_times_base").data + 1).singlearena_price)
            if dim >= cost then 
                local str = "[image=diamond.png][font=ZH_3] 增加3次挑战需要消耗" ..cost .."钻石"
                showMsgBox(str,function()  Command.run( 'arenaaddtimes') end )            
            else 
                local str = "[image=diamond.png][font=ZH_3] 钻石不足，是否前往"
                showMsgBox(str,function()  Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
                    end )
            end  
        else 
            local str = "[image=alert.png][font=ZH_3] 添加的挑战次数超过上限 [btn=one]"
            showMsgBox(str)
        end 

    end )
    
    -- 进入防守布阵
    self.definefun = function ()
        ArenaData.isIntoScene = true 
        ArenaData.outShowFlag = true  
        self.setWarLister(function() funShow() end ,function() funShow() end , nil)
        Command.run('ui hide','ArenaUI') 
    end 
    EventMgr.addListener(EventType.ArenaDefine,self.definefun)
    self.definebtn:addTouchEnded(function() LogMgr.debug("ArenaUI weihao".."防守按钮")
         ActionMgr.save( 'UI', 'ArenaUI click definebtn' )
         EventMgr.dispatch(EventType.ArenaDefine)
    end )
    self.storebtn:addTouchEnded(function() LogMgr.debug("ArenaUI weihao".."商店按钮") 
            ActionMgr.save( 'UI', 'ArenaUI click storebtn' )
            Command.run('ui show','Store',PopUpType.SPECIAL) 
    end )
    self.rankbtn:addTouchEnded(function()
        ActionMgr.save( 'UI', 'ArenaUI click rankbtn' ) 
        Command.run('ui show' , 'ArenaRanking',PopUpType.SPECIAL) 
        Command.run( 'arenarank', 1 ,50)
    end )
    self.warreportbtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ArenaUI click warreportbtn' )
        Command.run('ui show' , 'ArenaWarRecord',PopUpType.SPECIAL) 
        Command.run( 'arenalog')
    end )
    self.rulebtn:addTouchEnded(function() LogMgr.debug("ArenaUI weihao".."规则按钮") 
        ActionMgr.save( 'UI', 'ArenaUI click rulebtn' )
        ArenaData.setRuleList({})
    end )
    self.refreshbtn:addTouchEnded(function() LogMgr.debug("ArenaUI weihao".."刷新按钮") 
         ActionMgr.save( 'UI', 'ArenaUI click refreshbtn' )
         Command.run( 'arenarefresh')
    end )
    self.czbtn:addTouchEnded(function() LogMgr.debug("ArenaUI weihao".."重置") 
        ActionMgr.save( 'UI', 'ArenaUI click czbtn' )
        local minute = math.floor((self.rolecd - gameData.getServerTime() )/60)
        if ( self.rolecd - gameData.getServerTime())  > minute*60 then 
            minute = minute + 1
        end 
        local coin = findGlobal("singlearena_clear_time_coin").data
        local str = "[image=diamond.png][font=ZH_3]  是否消耗50钻石重置冷却"
        showMsgBox(str, self.confirmHandler)
    end )

    self.confirmHandler = function()
        ActionMgr.save( 'UI', 'ArenaUI click confirmHandler' )
        local coin = CoinData.getCoinByCate(const.kCoinGold)
        self.need = 50  -- 花费固定为50钻石
        if self.need > coin then 
            Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
        else 
            LogMgr.debug("weihao_arenaclear")
            Command.run( 'arenaclear')
            EventMgr.dispatch(EventType.ArenaloadSoldier)
        end 
    end 

end

-- 出现历史最高排名
function ArenaUI:result()
    if ArenaData.lishiflag == true then 
        PopMgr.checkPriorityPop( 
                'ArenaResult', 
                PopOrType.Com, 
                function()
                    Command.run('ui show', 'ArenaResult', PopUpType.SPECIAL)
                end
            )
        ArenaData.lishiflag = false
    end 
end

function ArenaUI:initViewData() 
    --初始化人物数据
    self.initrole = function()
        local list = ArenaData.getRolelist()[1]
        if not list or not list.left then
            return
        end
        local url = TeamData.getAvatarUrlById(list.id)
        self.rolecoin:setVisible(true)
        if url then
            self.rolecoin:loadTexture(url, ccui.TextureResType.localType)

        end
        if list.left == 0 then 
            FontStyle.applyStyle(self.leftlabel, FontStyle.JJ_4)
        else 
            FontStyle.applyStyle(self.leftlabel, FontStyle.JJ_1)
        end 


        self.leftlabel:setVisible(true)
        self.alllabel:setVisible(true)
        self.nowranklabel:setVisible(true)
        self.historytoplabel:setVisible(true)
        self.warpowerlabel:setVisible(true)        
        self.needdialabel:setVisible(true)

        self:addOutline(self.needdialabel,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边
        self:addOutline(self.czzhuanshi,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边

        self.leftlabel:setString(list.left .. '') --剩下挑战次数
        self.alllabel:setString("/" .. list.all)  --总共挑战次数 
        self.nowranklabel:setString(list.rank .. "") --当前排名
        if list.rank == 0 then 
            self.nowranklabel:setString("—")  --当前排名
        end 
        self.historytoplabel:setString(list.historytop .."") --历史最高
        if list.historytop == 0 then 
            self.historytoplabel:setString("—") --历史最高
        end 
        self.warpowerlabel:setString( list.power .. "") --战力        
        self.needdialabel:setString(list.need .. "") --需要钻石label
        self.needdialabel:setString("换一批") --需要钻石label
        --        self.needdialabel:setSystemFontSize(16)

        self.calculabel:setString("每天".. list.calcul .."结算") --每天几点结算label
        local coin = findGlobal("singlearena_clear_time_coin").data
        if coin ~= nil then 
            self.czzhuanshi:setString(coin)
        else 
            self.czzhuanshi:setString("50")
        end 
        self.need = tonumber(coin)
        self.rolecd = list.cd
        self.left = list.left
        self.all = list.all
        self.rolerank = list.rank
        self.lishirank = list.historytop
        -- 保存排名
        ArenaData.saveRank(self.rolerank)
        ArenaData.saveServerRank(self.rolerank)
        --        self.rolecd = 0 
        if self.rolecd > gameData.getServerTime() then 
            local time = tostring(os.date("%M:%S", self.rolecd - gameData.getServerTime()))
            self.showcd:setString("冷却时间  " .. time)
        end  
        self.select()
        TimerMgr.addTimeFun(ArenaData.updatekey, ArenaData.updatecd)
        createScaleButton(self.xbg.xz,false)
        self.xbg.xz:addTouchBegan(function() ActionMgr.save( 'UI', 'ArenaUI click down xz' )self.showtip1 (self.xbg.xz:getPositionX()+200,self.xbg.xz:getPositionY()-50) end)
        self.xbg.xz:addTouchEnded(function()  ActionMgr.save( 'UI', 'ArenaUI click up xz' ) self.hidetip1() end )
        self.xbg.xz:addTouchCancel(function() ActionMgr.save( 'UI', 'ArenaUI click cancle xz') self.hidetip1() end)
        
        -- 展示tip
        self.showtip1 = function(x,y)
            local level = self.rolerank
            local list = GetDataList('SingleArenaDayReward')
            local rewardlist = {}
            for key , value in pairs(list) do
                if self.rolerank >= tonumber(value.rank.first) and self.rolerank <= tonumber(value.rank.second) then 
                   rewardlist = value 
                   break
                end 
            end 
            if rewardlist == nil  then 
               return 
            end
            if  rewardlist.reward_ == nil then 
                return 
            end  
            local str2 = ""
            str2 = fontNameString("TIP_C") .. "当前排名可获得：[br]".. fontNameString("TIP_C") 
            for i = 1 , 5 do 
                local nlist = rewardlist["reward_"][i]
                if nlist ~= nil then 
                    if nlist.cate == const.kCoinMoney then 
                        str2 = str2 .. fontNameString("TIP_C") .. "金币 * " .. nlist.val .. "[br]"
                    elseif nlist.cate == const.kCoinGold then 
                        str2 = str2 .. fontNameString("TIP_C") .. "钻石 * " .. nlist.val .. "[br]"
                    elseif nlist.cate == const.kCoinMedal then 
                        str2 = str2 .. fontNameString("TIP_C") .. "竞技场勋章 * " .. nlist.val .. "[br]"
                    end 
                end 
            end 
            local parent = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
            self.tip = UIFactory.getScale9Sprite("tips_bg.png", cc.rect(32, 32, 1, 1), cc.size(1,1), parent,0,0,99)
            extRemoveChild(self.tip)
            local size = cc.size(1,1)
            extAddChild(parent,self.tip,99)
            local space = 40
            local richText = self:getRichText()
            RichTextUtil:DisposeRichText(str2,richText,nil,0,300,8)
            local txtSize = richText:getContentSize()
            size.height = txtSize.height + space+10
            size.width =150 + space
            self.tip:setContentSize(size)
            richText:setPosition(space/2,size.height - space/2 + 5)
            self.tip:setPosition(cc.p(x-280,y+120))
        end
        -- 隐藏tip
        self.hidetip1 = function() 
            extRemoveChild(self.rich_text)
            extRemoveChild(self.tip)
            self.rich_text = nil 
            self.tip = nil     
        end 
    end
    self.select = function ()
        if self.rolecd < gameData.getServerTime()  then 
            self.xbg.btnbg:setVisible(true)
            self.refreshbtn:setVisible(true)
            self.showcd:setVisible(false)
            self.czzhuanshi:setVisible(false)
            self.czbtn:setVisible(false) 
        else 
            self.xbg.btnbg:setVisible(false)
            self.refreshbtn:setVisible(false)
            self.showcd:setVisible(true)
            self.czzhuanshi:setVisible(true)
            self.czbtn:setVisible(true)
            local coin = findGlobal("singlearena_clear_time_coin").data
            if coin ~= nil then 
                self.czzhuanshi:setString(coin)
            else 
                self.czzhuanshi:setString("50")
            end 

        end 
    end 
     
    -- 初始化create 敌人卡牌ui
    self.initenemyView = function(i)
        -- 初始化ui
        self["card"..i] = getLayout(prePath .. "ArenaUntil.ExportJson")
        self["card"..i]:retain()
        local role = self["card"..i].card
        self["card"..i]:setPosition(cc.p((i - 1 )*190 , 0 ))
        self.bg1.vector:addChild(self["card"..i])
        local pianyi = TeamData.AVATAR_OFFSET
        role.rolecoin:setPosition(role.rolecoin:getPositionX()+pianyi.x , pianyi.y+role.rolecoin:getPositionY())
        role.tiaozhanbtn = createScaleButton(role.tiaozhanbtn)
        -- 将敌人ui 保存到self.rolelist当中
        table.insert(self.rolelist,{zhuanshi = role.zhuanshi,coin = role.rolecoin,level = role.level ,rank = role.paiminglabel, paiming = role.Label_125, name = role.namelabel, power = role.zhandouli, btn = role.tiaozhanbtn})     
        local path1 = prePatharm .. "zsx-tx-01/zsx-tx-01.ExportJson"
        self.effect1 = ArmatureSprite:addArmature(path1, 'zsx-tx-01', "ArenaUI", role.zhuanshi, 22, 25)
        createScaleButton(role.zhuanshi,false)
        role.zhuanshi:addTouchBegan(function() ActionMgr.save( 'UI', 'ArenaUI click down zhuanshi' ) self.showtip (self["card"..i]:getPositionX()+600,self["card"..i]:getPositionY()+150) end)
        role.zhuanshi:addTouchEnded(function()  ActionMgr.save( 'UI', 'ArenaUI click up zhuanshi' )self.hidetip() end )
        role.zhuanshi:addTouchCancel(function() ActionMgr.save( 'UI', 'ArenaUI click cancle zhuanshi' ) self.hidetip() end )

        --挑战按钮监听
        self.challegefun = function(num) 
            ArenaData.outShowFlag = true
            ArenaData.isIntoScene = true
            if ArenaData.isRealMan(self.rolelist[num].qid) then  --真人
                local fun = self.setFun(trans.const.kAttrPlayer,self.rolelist[num].qid)
                ArenaData.realrole = true 
                Command.run("arenauserpanel", self.rolelist[num].qid)
                local data = self.rolelist[num].data
                Command.bind("arenauerimformation" , function (list)
                    self.setWarLister(fun, function ()
                        funShow() end, list, data)
                end )

            else   --假人
                local fun = self.setFun(trans.const.kAttrMonster,self.rolelist[num].qid)
                self.setWarLister(fun, function ()                        
                    funShow() end,
                self.rolelist[num].list, self.rolelist[num].data)
            end 
        end        
       -- 挑战按钮的监听
        self.rolelist[i].btn:addTouchEnded(function()
            ActionMgr.save( 'UI', 'ArenaUI click rolelist['..  i  .. '].btn' ) 
            if self.rolecd ~= nil and self.rolecd < gameData.getServerTime() and self.left > 0 then 
                local list = ArenaData.loadChallege(self.rolelist[i].qid)
                -- 进入loading 界面
                local loadingTips = Command.run("loading get tips")
                Command.run("loading show preload","arenaui")
                Command.run("loading set percent", 0, loadingTips, "加载竞技场数据（不消耗流量）")
                local function progressHandler(value, title, text)
                    Command.run("loading set percent", value, loadingTips, "加载竞技场数据（不消耗流量）")
                end
                LoadMgr.loadFightModelListAsyncForWait(list, function() self.challegefun(i) end, progressHandler)

            elseif self.rolecd ~= nil and self.rolecd > gameData.getServerTime() then
                local minute = math.floor((self.rolecd - gameData.getServerTime() )/60)
                if ( self.rolecd - gameData.getServerTime())  > minute*60 then 
                    minute = minute + 1
                end 
                local coin = findGlobal("singlearena_clear_time_coin").data
                if coin ~= nil then 
                    self.czzhuanshi:setString(coin)
                else 
                    self.czzhuanshi:setString("50")
                end 
                local str = "[image=diamond.png][font=ZH_3]  是否消耗50钻石重置冷却"
                showMsgBox(str, self.confirmHandler)
            elseif self.rolecd ~= nil and self.left ~= nil and self.left <= 0 then 
                showMsgBox("[image=alert.png][font=ZH_3]  免费挑战次数没有了")
            end
            LogMgr.debug("ArenaUI weihao".."挑战人物"..i) 
       end )
    end 
    -- 挑战人
    Command.bind( 'arenachallege', 
        function(id)
            self.challegefun(id)
        end 
    )
    self.rolelist = {}
    --初始化敌人数据
    self.initenemy = function()
        LogMgr.debug("ArenaUI weihao".."initenemy")
        local list = ArenaData.getArenaList()
        if list ~= nil and #list ~= 0 then 
            for i=1 ,#(list),1 do
                --保证只初始化一次，防止重复初始化
                if self.rolelist ~= nil and #self.rolelist ~= 4 then 
                    self.initenemyView(i) 
                end 
                --给role赋值
                local role = self["card"..i]
                if self.rolelist ~= nil and #self.rolelist ~= 0 then 
                    local num = list[i].id % 8 
                    if num == 0 then 
                        num = 8
                    end 
                    local url = TeamData.getAvatarUrlById( num)

                    local avatar = list[i].avatar
                    if avatar ~= nil and avatar ~= 0 then 
                        url = TeamData.getAvatarUrlById(avatar)
                    end 
                    if self.rolelist[i] == nil or self.rolelist[i].coin == nil then 
                       return 
                    end 
                    if url then
                        self.rolelist[i].coin:loadTexture(url, ccui.TextureResType.localType)
                    end

                    self.rolelist[i].level:setString("LV.".. list[i].level)
                    self.rolelist[i].rank:setString(list[i].rank .. '')    
                    self.rolelist[i].name:setString(list[i].name)
                    self.rolelist[i].power:setString("战斗力:"..list[i].power)
                    self.rolelist[i].qid = list[i].id       --人物id
                    self.rolelist[i].qrank = list[i].level  --人物等级
                    self.rolelist[i].list = list[i].formationlist --人物布阵
                    self.rolelist[i].data = list[i].data
                    if self.lishirank ~= nil and self.lishirank ~= 0 and list[i].rank ~= nil and list[i].rank >= self.lishirank then 
                        self.rolelist[i].zhuanshi:setVisible(false)
                    else 
                        self.rolelist[i].zhuanshi:setVisible(true)
                    end 
                end 
            end
        end 
        EventMgr.dispatch(EventType.ArenaloadSoldier)
    end 
    
    --设置cd时间
    self.initcdtime = function (data)
        self.rolecd = data.time 
        local coin = findGlobal("singlearena_clear_time_coin").data
        if coin == nil then 
            coin = 50
        end 
        if not self.needdialabel then
            return
        end
        self.need =tonumber(coin)
        self.needdialabel:setString("换一批") --需要钻石label
        if self.rolecd > gameData.getServerTime() then 
            local time = tostring(os.date("%M:%S", self.rolecd - gameData.getServerTime()))
            self.showcd:setString("冷却时间  " .. time)
        end  
        self.select()
    end 
    --初始化调账次数
    self.initaddtime = function (list)
        local max = list.max
        local cur = list.cur
        if cur == 0 then 
            FontStyle.applyStyle(self.leftlabel, FontStyle.JJ_4)
        else 
            FontStyle.applyStyle(self.leftlabel, FontStyle.JJ_1)
        end 
        self.leftlabel:setString(cur .. '') --剩下挑战次数
        self.alllabel:setString("/" .. max)  --总共挑战次数 
        local list = ArenaData.getRolelist()[1]
        list.left = cur
        list.all = max  
        self.left = list.left
        self.all = list.all
    end

    self.showWarReport = function ()
        setButtonPoint(self.warreportbtn, ArenaData.redPoint)
    end 

    self:btnlister()


end 

function ArenaUI:loadOverTime()
    Command.run("loading wait hide" , "arenaui")
    TipsMgr.showError('请求超时重新刷新')
    Command.run( 'arenarefresh') 
end 

function ArenaUI:onShow()
    ArenaData.outShowFlag = false
    self.initView()
    self:initViewData()
    EventMgr.addListener(EventType.ArenaWarReport,self.showWarReport)
    EventMgr.addListener(EventType.ArenaAddnum,self.initaddtime)
    EventMgr.addListener(EventType.ArenaCdtime,self.initcdtime)
    EventMgr.addListener(EventType.ArenaRole,self.initrole)
    EventMgr.addListener(EventType.ArenaOpponent,self.initenemy)
    EventMgr.addListener(EventType.LoadOverTime,self.loadOverTime,self)
    
    -- 下一帧初始化敌人跟人物ui以及数据
    performNextFrame(self, self.delayOnShow, self)
    -- 如果不是防守或没挑战返回 会发送协议
    if ArenaData.isIntoScene == false then 
        TimerMgr.runNextFrame(function() Command.run( 'arenainfo') end)
    else 
        funShow()
        ArenaData.isIntoScene = false
    end 
end

function ArenaUI:delayOnShow()
    performNextFrame(self, self.result, self) --下一帧才弹出历史最高排名
    -- 飘字奖励
    if ArenaData.getBCoinList() ~= nil then
        ArenaData.clearBCoinList()
    end
    --出现战报
    ArenaData.ShowWarRecord()
    


end

function ArenaUI:onClose()
    Command.run("loading wait hide" , "arenaui")
    ArenaData.lishiflag = false
    TimerMgr.removeTimeFun(ArenaData.updatekey)
    EventMgr.removeListener(EventType.ArenaloadSoldier,self.loadSoldier)
    EventMgr.removeListener(EventType.ArenaWarReport,self.showWarReport)
    EventMgr.removeListener(EventType.ArenaDefine,self.definefun)
    EventMgr.removeListener(EventType.ArenaOpponent,self.initenemy)
    EventMgr.removeListener(EventType.ArenaRole,self.initrole)
    EventMgr.removeListener(EventType.ArenaAddnum,self.initaddtime)
    EventMgr.removeListener(EventType.ArenaCdtime,self.initcdtime)
    EventMgr.removeListener(EventType.LoadOverTime,self.loadOverTime)
    ArenaRanking:clear()
    Command.run("loading close","arenaui") 
    for i = 1 , 4 ,1 do
        if self["card" .. i ] ~= nil and self["card" .. i].release then 
            TimerMgr.releaseLater(self["card" .. i])
        end 
    end 
    
end

function ArenaUI:getRichText()
    if self.rich_text == nil then
        self.rich_text = cc.Node:create()
        self.rich_text:setAnchorPoint(0,0)
        extAddChild(self.tip,self.rich_text)
    else
        self.rich_text:removeAllChildren()
    end

    return self.rich_text
end


function ArenaUI:ctor()

    PopWayMgr.setSTBSkew(0,-10)
    self.isUpRoleTopView = true
    -- 初始化view
    self.initView = function ()
        self.addbtn = self.addbg.add
        self.addbtn = createScaleButton(self.addbtn)
        self.leftlabel = self.shenxia
        self.alllabel = self.all1
        self.nowranklabel = self.paiminglabel
        self.historytoplabel = self.lishilabel
        self.warpowerlabel = self.zhanlilabel
        self.needdialabel = self.diamondnum
        self.calculabel = self.jiesuanlabel
        self.calculabel:setString("")
        self.rolecoin = self.rolecoin
        self.showcd = self.cdtime -- cd时间显示
        self.czzhuanshi = self.chongzhi.dam --重置钻石数
        self.showcd:setString("")
        self.definebtn = self.fanshoubtn
        self.definebtn = createScaleButton(self.definebtn)
        self.storebtn = self.storebtn
        self.storebtn = createScaleButton(self.storebtn)
        self.rankbtn = self.paihangbtn
        self.rankbtn = createScaleButton(self.rankbtn)
        self.warreportbtn = self.zhanbaobtn
        self.warreportbtn = createScaleButton(self.warreportbtn)
        self.rulebtn = self.rulebtn
        self.rulebtn = createScaleButton(self.rulebtn)
        self.refreshbtn = self.refreshbtn
        self.refreshbtn = createScaleButton(self.refreshbtn)
        self.czbtn = self.chongzhi --重置btn
        self.shenyu:setString("可挑战次数")
        self.czbtn = createScaleButton(self.czbtn)
        local path2 = prePatharm .. "bxx-tx-01/bxx-tx-01.ExportJson"
        self.effect2 = ArmatureSprite:addArmature(path2, 'bxx-tx-01', "ArenaUI", self.xbg.xz, 50, 100)
        --设置偏移量
        local pianyi = TeamData.AVATAR_OFFSET
        self.rolecoin:setPosition(pianyi.x  +  self.rolecoin:getPositionX() , pianyi.y  + self.rolecoin:getPositionY())


        --设置所有可变数据为false
        self.rolecoin:setVisible(false)
        self.leftlabel:setVisible(false)
        self.alllabel:setVisible(false)
        self.nowranklabel:setVisible(false)
        self.historytoplabel:setVisible(false)
        self.warpowerlabel:setVisible(false)        
        self.needdialabel:setVisible(false)
    end 

    -- 展示tip
    self.showtip = function(x,y)
        local parent = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
        self.tip = UIFactory.getScale9Sprite("tips_bg.png", cc.rect(32, 32, 1, 1), cc.size(1,1), parent,0,0,99)
        extRemoveChild(self.tip)
        local size = cc.size(1,1)
        extAddChild(parent,self.tip,99)
        local str2 = ""
        str2 = fontNameString("TIP_C") .. "打败该玩家[br]".. fontNameString("TIP_C") .."可以获得钻石"
        local space = 40
        local richText = self:getRichText()
        RichTextUtil:DisposeRichText(str2,richText,nil,0,300,8)
        local txtSize = richText:getContentSize()
        size.height = txtSize.height + space+10
        size.width =150 + space
        self.tip:setContentSize(size)
        richText:setPosition(space/2,size.height - space/2 + 5)
        self.tip:setPosition(cc.p(x-280,y+120))
    end
    -- 隐藏tip
    self.hidetip = function() 
        extRemoveChild(self.rich_text)
        extRemoveChild(self.tip)
        self.rich_text = nil 
        self.tip = nil     
    end 
    -- 发送得到真人的布阵信息
    self.loadSoldier = function()
        TimerMgr.runNextFrame(function() ArenaData.sendRealRole() end)
    end 
    EventMgr.addListener(EventType.ArenaloadSoldier,self.loadSoldier)
end 

local function doShowArenaUI()
    if ArenaData.outShowFlag == true then
        ArenaData.outShowFlag = false
        Command.run('ui show' ,'ArenaUI', PopUpType.SPECIAL)
    end 
end

--是否重现弹出
function ArenaUI.reShow(name)
    if name ~= nil then 
        LogMgr.debug("ArenaUIname" .. name)
        if name == "main" then 
            TimerMgr.runNextFrame(doShowArenaUI)
        end 
    else 
        TimerMgr.runNextFrame(doShowArenaUI)
    end 
end 

