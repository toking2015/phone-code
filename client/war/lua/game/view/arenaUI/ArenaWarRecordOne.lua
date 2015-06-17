--单个对战
--by weihao
local prePath = "image/ui/ArenaUI/"
ArenaWarRecordOne = class("ArenaWarRecordOne",function() 
    return getLayout(prePath .. "WarRecordOne.ExportJson")
end)

ArenaWarRecordOne.winimg = nil --胜利图案
ArenaWarRecordOne.loseimg = nil --失败图案
ArenaWarRecordOne.roleimg = nil --人物图案
ArenaWarRecordOne.levellabel = nil --人物等级
ArenaWarRecordOne.namelabel = nil --人物名称
ArenaWarRecordOne.timelabel = nil --时间
ArenaWarRecordOne.downimg = nil --下降图案
ArenaWarRecordOne.downlabel = nil --下降label
ArenaWarRecordOne.sendbtn = nil --转发按钮
ArenaWarRecordOne.playbtn = nil --播放按钮


function ArenaWarRecordOne:btnlister()

    self.playbtn:addTouchEnded(function() 
          SoundMgr.isArena = true
--          LogMgr.debug("self.fightid " .. self.fightid )
          Command.run("fight replay",self.fightid)
          ArenaData.outShowFlag = true  
          ArenaData.isWarRecord = true
          LogMgr.debug("ArenaWarRecordOne weihao".."回放视频") end )
    self.sendbtn:addTouchEnded(function()  ActionMgr.save( 'UI', 'ArenaWarRecordOne click sendbtn' ) LogMgr.debug("ArenaWarRecordOne weihao".."发到聊天") end )
end
function ArenaWarRecordOne:init(avatar,winflag ,roleid,level, time,name,downname,fightid)
    self.winimg = self.win
    self.loseimg = self.lose
    self.roleimg = self.coin 
    self.levellabel = self.level 
    self.fightid = fightid
    FontStyle.setFontNameAndSize(self.levellabel, FontNames.HEITI, 18)
    self.namelabel = self.name
    FontStyle.setFontNameAndSize(self.namelabel, FontNames.HEITI, 24)
    self.timelabel = self.time
    FontStyle.setFontNameAndSize(self.timelabel, FontNames.HEITI, 20)
    self.downimg = self.down 
    self.downlabel = self.downnumber
    FontStyle.setFontNameAndSize(self.downlabel, FontNames.HEITI, 18)
    self.sendbtn = self.send
    self.sendbtn = createScaleButton(self.sendbtn)
    self.playbtn = self.play
    self.playbtn = createScaleButton(self.playbtn)
    self.winimg:setVisible(false)
    self.loseimg:setVisible(false)
    self.downimg:setVisible(false)
    self.downlabel:setVisible(false)
    if winflag == false then 
        self.loseimg:setVisible(true)
    else 
        self.winimg:setVisible(true)
    end 
    
    local url = TeamData.getAvatarUrlById(avatar)
    if url then
        local pianyi = TeamData.AVATAR_OFFSET
        self.roleimg:setPosition(self.roleimg:getPositionX()+pianyi.x , pianyi.y+self.roleimg:getPositionY())
        self.roleimg:loadTexture(url, ccui.TextureResType.localType)
    end
    
    self.levellabel:setString("LV."..level)
    self.namelabel:setString(name)
    if time.day > 0 then 
        self.timelabel:setString(time.day .."天前")
    elseif time.hour > 0 then 
        self.timelabel:setString(time.hour .. "小时前")
    elseif time.minute >= 0 then 
        local minute = 0
        if time.minute == 0 then 
           self.timelabel:setString("刚刚")
        else 
          minute = time.minute
          self.timelabel:setString(time.minute .. "分钟前")
        end      
    end 
    if downname ~= 0 and downname < 0 then 
        local downname1 = 0-downname
        self.downimg:setVisible(true)
        self.downlabel:setVisible(true)
        self.downlabel:setString(downname1)
    end 
    self:btnlister()
end 
--1是否胜利，2人物头像id,3人物等级，4时间，5人物名称，6下降多少名次
function ArenaWarRecordOne:createView(avatar,winflag ,roleid,level, time,name,downname,fightid)
    local view = ArenaWarRecordOne.new()
    view:init(avatar,winflag ,roleid,level, time,name,downname,fightid)
    LogMgr.debug("ArenaWarRecordOne weihao".."in")
    return view 
end 