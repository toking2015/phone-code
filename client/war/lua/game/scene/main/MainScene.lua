-- Create By Live -- 

MainScene = {}

require "lua/game/scene/main/MainCircle.lua"
require "lua/game/scene/main/MainPage.lua"

require "lua/game/view/mainUI/MainUIMgr.lua"
require "lua/game/view/mainUI/MainSceneUI.lua"
require "lua/game/scene/main/MainState.lua"

--require "lua/game/view/chatUI/new/ChatUI.lua"
require "lua/manager/TipsMgr.lua"
require "lua/game/view/chatUI/ChatUI.lua"
require "lua/game/view/vipUI/VipPayUI.lua"
require "lua/game/view/copyUI/NCopyUI.lua"
require "lua/game/view/taskUI/TaskUI.lua"
require "lua/game/view/bagUI/BagMain.lua"
require "lua/game/view/NTotemUI/TotemUI.lua"
require "lua/game/view/signUI/SignUI.lua"
require "lua/game/view/teamUI/TeamCommon.lua"
require "lua/game/view/cardUI/CardUI.lua"
require "lua/game/view/getUI/SoldierGetUI.lua"
require "lua/game/view/formationUI/FormationWin.lua"
-- require "lua/game/view/holyUI/HolySpeedup.lua"
require "lua/game/view/holyUI/BuildingUI.lua"
require "lua/game/view/holyUI/BuildingProdCount.lua"
require "lua/game/view/holyUI/BuildingSpeedStyle.lua"
require "lua/game/view/holyUI/BubbleLayer.lua"
require "lua/game/view/gutUI/Gut.lua"
require "lua/game/view/soldierUI/SoldierUI.lua"
require "lua/game/view/soldierUI/SoldierInfo.lua"
require "lua/game/view/mineUI/MineProdBubble.lua"
-- require "lua/game/view/mineUI/MineUpShow.lua"
-- require "lua/game/view/mineUI/MineMessage.lua"
-- require "lua/game/view/mineUI/MineUpSpeed.lua"
require "lua/game/view/inductUI/InductUI.lua"
require "lua/game/view/inductUI/GuideUI.lua"
require "lua/game/view/strengthUI/StrengthUI.lua"
require "lua/game/view/arenaUI/ArenaUI.lua"
require "lua/game/view/auctionUI/AuctionUI.lua"
require "lua/game/view/paperUI/PaperUI.lua"
require "lua/game/view/view.lua"
-- require "lua/game/view/mailboxUI/MailBoxUI.lua"
require "lua/game/view/mailboxUI/NMailBoxUI.lua"
require "lua/game/view/mailboxUI/NMailBoxContent.lua"
require "lua/game/view/mailboxUI/NMailEffect.lua"
require "lua/game/view/flyText/FlyUI.lua"
require "lua/game/view/actTipsUI/ActTipsUI.lua"
require "lua/game/view/activationUI/ActivationUI.lua"
require "lua/game/view/noticeUI/NoticeUI.lua"
require "lua/game/view/trialUI/TrialMainUI.lua"
require "lua/game/view/alteractivetips/AlteractyTipsUI.lua"
require "lua/game/view/tombUI/TombMainUI.lua"
require "lua/game/view/SkillBookMergeUI/SkillBookMergeUI.lua"
require "lua/game/view/friendUI/FriendUI.lua"
require "lua/game/view/activityUI/ActivityUI.lua"
require "lua/game/view/rewardgetUI/RewardGetUI.lua"
require "lua/game/view/teamUpgradeUI/TeamUpgradeUI.lua"
require "lua/game/view/vipActivityUI/VipActivityUI.lua"
require "lua/game/view/activityUI/ActivityFRUI.lua"
require "lua/game/view/totemStarUpUI/TotemStarUpUI.lua"
require "lua/game/view/rankUI/RankUI.lua"
require "lua/game/view/tipsTotemUI/TipsTotemUI.lua"
require "lua/game/view/tipsSoldierUI/TipsSoldierUI.lua"
require "lua/game/view/FightPower/FightPowerUI.lua"

require "lua/game/view/ActivityOpenTarget/ActivityOpenTargetUI.lua"
require "lua/utils/StringTools.lua"



MainScene.OFFX = visibleSize.width / 2
MainScene.OFFY = PageInfo.distance

MainScene.DAY = 1
MainScene.RAIN = 2
MainScene.SNOW = 3
MainScene.NIGHT = 4

MainScene.MaxTeamLevel = 80

local sceneGame = Scene:create()

local circle = nil
local mainSceneUI = nil
local popLayer = nil

PageData.loadConfig() -- 加载地图配置

local function initSceneGame()
  debug.showTime("initSceneGame_0_")
  circle = MainCircle:create()
  sceneGame:addChild(circle, 0, 1)
  sceneGame:addDisplayList("circle", circle)
  debug.showTime("initSceneGame_0_")
  debug.showTime("initSceneGame_1_")
  MainState:init(circle)
  debug.showTime("initSceneGame_1_")

  if nil == mainSceneUI then
    debug.showTime("initSceneGame_2_")
  	mainSceneUI = MainSceneUI:create()
  	sceneGame:addChild(mainSceneUI, 1)
    debug.showTime("initSceneGame_2_")
  end

  if false == sceneGame.isInit then
  	sceneGame.isInit = true
  end
  debug.showTime("initSceneGame_3_")
  if ArenaData.isCdTime == false then -- 只调用一次
    ArenaData.sendCdTime()
    ArenaData.isCdTime = true
  end 
  if ArenaData.isArenaServerRand == false then  --只调用一次
     ChatData.loadYuyin()
     ChatData.clearSoundFile() --聊天在这里只执行一次
     ReportPostData.setTime( gameData.user.other.chat_ban_endtime) -- 禁言时间设置
     ArenaData.loadRank()
     local flag = false 
     for key ,value in pairs(gameData.user.building_list) do
        if value.building_type == const.kBuildingTypeSingleArena then 
           flag = true 
           break 
        end 
     end 
     if flag == true then 
       Command.run("arenamyrank")  --获取服务器竞技场排名
     end 
     ArenaData.isArenaServerRand = true 
  end
  debug.showTime("initSceneGame_3_")
  debug.showTime("initSceneGame_4_")
  local copy_id = CopyData.getNextCopyId()
  local area_id = math.floor(copy_id / 1000)
  if CopyData.checkOpenArea(area_id) == false then area_id = area_id - 1 end
  debug.showTime("initSceneGame_4_")
  debug.showTime("initSceneGame_5_")
  local area = findArea(area_id)
  if area ~= nil then
    local page = math.floor(area.icon / 1000)
    local bgPath = "image/ui/NCopyUI/copyBg/copy_select_bg_" .. page .. ".jpg"
    LoadMgr.loadImageAsync(bgPath, LoadMgr.SCENE, "copyUI")
  end
  debug.showTime("initSceneGame_5_")
end

--世界地图
function sceneGame:getCircle()
	return circle
end

function sceneGame:getMainUI()
    return mainSceneUI
end

--onShow
function sceneGame:onShow()
    EventMgr.addListener(EventType.SceneShow, ArenaUI.reShow)
    debug.showTime("MainScene_1_")
    initSceneGame()
    debug.showTime("MainScene_1_")
    debug.showTime("MainScene_2_")
    mainSceneUI:onShow()
    debug.showTime("MainScene_2_")
    -- 获取最大战队等级
    MainScene.MaxTeamLevel = tonumber(findGlobal("team_level_max").data)
end

function sceneGame:onClose()
    EventMgr.removeListener (EventType.SceneShow,ArenaUI.reShow)
    LogMgr.log( 'scene', 'sceneGame:onClose' )
    mainSceneUI:onClose()
    MainState:dispose()
    circle:dispose()
    -- sceneGame:removeChild(circle)
    circle = nil
end
SceneMgr.insertScene( 'main', sceneGame )

