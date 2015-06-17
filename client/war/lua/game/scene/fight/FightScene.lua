require "lua/game/scene/fight/FightBackground.lua"
require("lua/game/view/fight/FightResultUI.lua")

local scene = Scene:create()

function scene:onShow()
  Command.run("loading can frog", false)
  ClearDataExceptList({ 'xls/Skill', 'xls/Soldier', 'xls/Monster', 'xls/Totem', 'xls/Odd', 'xls/Item' })
  local bg = FightBackground:getInstance()
  if bg:getParent() then
     bg:removeFromParent()
  end
  self.bg = bg
  self:addChild(bg, 0)
  Command.run("opening hide preload")
end

function scene:onClose()
  Command.run("loading can frog", true)
  if self.bg then
    if self.bg:getParent() == self then
       self:removeChild(self.bg)
       self.bg:dispose()
    end
    self.bg = nil
  end
  FightDataMgr:releaseAll() --清空战斗
  FightAnimationMgr.gut = nil -- 战斗剧情缓存清理
end

function scene:shakeLeft(time)
    time = time or 3
    if self.bg then
      self.bg:shakeLeft(time)
    end
end

function scene:shakeRight(time)
    time = time or 3
    if self.bg then
      self.bg:shakeRight(time)
    end
end

function scene:shakeLeftThenBack(time)
    time = time or 3
    if self.bg then
      self.bg:shakeLeftThenBack(time, 0.3, 4, 7)
    end
end

function scene:shakeRightThenBack(time)
    time = time or 3
    if self.bg then
      self.bg:shakeRightThenBack(time, 0.3, 4, 7)
    end
end

function scene:changToNormal()
    if self.bg then
      self.bg:changeScene()
    end
end

function scene:changeToSpecial()
    if self.bg then
      self.bg:changeScene()
    end
end

function scene:playChange()
    if self.bg then
      self.bg:changeScene()
    end
end

SceneMgr.insertScene( 'fight', scene )