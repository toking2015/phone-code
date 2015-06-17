--单个排名
--by weihao
local prePath = "image/ui/ArenaUI/"
ArenaRankingOne = class("ArenaRankingOne",function() 
    return getLayout(prePath .. "RankingOne1.ExportJson")
end)

ArenaRankingOne.oneimg = nil --第一名图标
ArenaRankingOne.twoimg = nil --第二名图标
ArenaRankingOne.threeimg = nil --第三名图标
ArenaRankingOne.otherlabel = nil --其他排名
ArenaRankingOne.roleimg = nil --人物头像
ArenaRankingOne.levellabel = nil --人物等级
ArenaRankingOne.namelabel = nil --人物名称
ArenaRankingOne.powerlabel = nil --人物战力
ArenaRankingOne.onebgimg = nil --第一名bg
ArenaRankingOne.twothreebgimg = nil --第二三名bg
ArenaRankingOne.otherimg = nil --其他bg 
ArenaRankingOne.lineimg = nil --line
function ArenaRankingOne:init(rank, id, level,name,power)
   self.oneimg = self.one
   self.twoimg = self.two
   self.threeimg = self.three
   self.otherlabel = self.number
   self.roleposition = self.Image_5
   self.roleimg = self.coin
   self.levellabel = self.level
   FontStyle.setFontNameAndSize(self.levellabel, FontNames.HEITI, 18)
   self.namelabel = self.name
   FontStyle.setFontNameAndSize(self.namelabel, FontNames.HEITI, 24)
   self.powerlabel = self.zhanli
   FontStyle.setFontNameAndSize(self.powerlabel, FontNames.HEITI, 20)
   self.onebgimg = self.onebg
   self.twothreebgimg = self.twothree
   self.otherimg = self.other
   self.lineimg = self.line
   self.oneimg:setVisible(false)
   self.twoimg:setVisible(false)
   self.threeimg:setVisible(false)
   self.otherlabel:setVisible(false)
   self.onebgimg:setVisible(false)
   self.twothreebgimg:setVisible(false)
   self.otherimg:setVisible(false)

   local url = TeamData.getAvatarUrlById(id)
   local pianyi = TeamData.AVATAR_OFFSET
   local x = self.roleposition:getPositionX()+pianyi.x
   local y = pianyi.y+self.roleposition:getPositionY()
   if url then
      self.roleimg:setPosition(x,y)
      self.roleimg:loadTexture(url, ccui.TextureResType.localType)
   end
   if rank ==1 then 
       self.lineimg:setVisible(false)
       self.oneimg:setVisible(true)
       self.onebgimg:setVisible(true)
   elseif rank == 2 then
       self.twoimg:setVisible(true)
       self.twothreebgimg:setVisible(true)
   elseif rank == 3 then
       self.threeimg:setVisible(true)
       self.twothreebgimg:setVisible(true)
   elseif rank >3 then
       self.otherimg:setVisible(true)
       self.otherlabel:setVisible(true)
       self.otherlabel:setString(rank .. '')
   end 
   self.namelabel:setString(name)
   self.levellabel:setString('LV.'..level)
   self.powerlabel:setString('战力:' .. power)
end 
--1人物名次，2人物id，3人物等级,4人物名称，5人物攻击力
function ArenaRankingOne:createView(rank, id, level,name,power)
    local view = ArenaRankingOne.new()
    if rank ~= nil then 
       view:init(rank, id, level,name,power)
    end 
    return view 
end 
