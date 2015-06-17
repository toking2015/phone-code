EventType = {}

EventType.VersionUpdate = "VersionUpdate" --版本更新，percent为100表示更新完成

EventType.UserLogout = "UserLogout" --用户登出，需要清理一些数据

--用户数据加载成功(初登录成功后被调用)
EventType.UserDataLoaded = "UserDataLoaded"
EventType.FirstEnterScene = "FirstEnterScene" --新号第一次进入场景

EventType.InfEnterServer = "InfEnterServer" --登陆服务器成功
EventType.InfCreateRole = "InfCreateRole" --创建角色成功
EventType.InfLevelUp = "InfLevelUp" --角色升级

--模块数据更新事件
EventType.UserBuildingUpdate = "UserBuildingUpdate"
EventType.UserBuildingAdd = "UserBuildingAdd"
EventType.UserCoinUpdate = "UserCoinUpdate"
EventType.UserCopyUpdate = "UserCopyUpdate"
EventType.UserFightExtAbleUpdate = "UserFightExtAbleUpdate" --二级属性更新
EventType.UserItemUpdate = "UserItemUpdate"
EventType.UserItemAdd = "UserItemAdd"
EventType.UserItemMerge = "UserItemMerge"
EventType.UserEquipMerge = "UserEquipMerge"
EventType.UserMergeReplace = "UserMergeReplace"
EventType.UserMarkUpdate = "UserMarkUpdate" --签到更新
EventType.UserMarkReward = "UserMarkReward" --签到奖励领取
EventType.UserSimpleUpdate = "UserSimpleUpdate"
EventType.UserSoldierUpdate = "UserSoldierUpdate"
EventType.UserSoldierRecruit = "UserSoldierRecruit"
EventType.UserSoldierEquipExt = "UserSoldierEquipExt"
EventType.UserTaskLogUpdate = "UserTaskLogUpdate"
EventType.UserTaskUpdate = "UserTaskUpdate"
EventType.TaskFinsh = 'TaskFinsh'
EventType.TaskAdd = 'TaskAdd'
EventType.TaskDel = 'TaskDel'
EventType.UserTotemUpdate = "UserTotemUpdate"
EventType.UserTotemChange = "UserTotemChange"
EventType.UserTotemBlessSuccess = "UserTotemBlessSuccess"  --图腾强化成功
EventType.UserTotemLevelUp = "UserTotemLevelUp"
EventType.UserFormationUpdate = "UserFormationUpdate"
EventType.UserFormationUp = "UserFormationUp" --英雄上阵
EventType.UserFormationDown = "UserFormationDown" --英雄上阵
EventType.UserVarUpdate = "UserVarUpdate"
EventType.UserPayUpdate = "UserPayUpdate"
EventType.UserCardUpdate = "UserCardUpdate"
EventType.UserStarUpdate = "UserStarUpdate"
EventType.UserMailBoxUpdate = "UserMailBoxUpdate"
EventType.MarketBatchBuy = "MarketBatchBuy"
EventType.MarketBatchMatch = "MarketBatchMatch"

--一天时间更新
EventType.NewDayBegain = "NewDayBegain"

--战斗事件
EventType.FightBegin = "FightBegin"
EventType.FightEnd = "FightEnd"
EventType.FightInduct = "FightInduct"
EventType.FightRecordGet = "FightRecordGet"
EventType.FightCopyGut = "FightCopyGut"
EventType.FightToTemClick = "FightToTemClick"

--场景事件
EventType.SceneShow = "SceneShow"
EventType.SceneShows = "SceneShows"
EventType.SceneClose = "SceneClose"
EventType.ScenePage = 'ScenePage'
EventType.ScenePageBuilding = "ScenePageBuilding"
EventType.ScenePageLoaded = "ScenePageLoaded"
--窗口事件
EventType.WindowOutClick = "WindowOutClick"
EventType.WindowDownShow = "WindowDownShow"

--新手引导
EventType.InductEnd = 'InductEnd'
--副本新开启事件
EventType.CopyNewBuilding = "CopyNewBuilding"
--副本类型切换
EventType.CopySelect='CopySelect'
EventType.CopySelects='CopySelects'

--其它更新事件
EventType.btnMainHide = "btnMainHide"
EventType.ChangeChannel = "ChangeChannel"
EventType.closeButtonFunc = "closeButtonFunc"

EventType.bagMainUpdate = "bagMainUpdate"
EventType.bagSaleUpdate = 'bagSaleUpdate'
EventType.showGmUI = "showGmUI"
EventType.showHeroUI = "showHeroUI"
EventType.showSpeedStyle = "showSpeedStyle"
EventType.showMineStype = "showMineStyle"
EventType.showMineUpShow = "showMineUpShow"
EventType.ShowMaterialUI = "ShowMaterialUI"
EventType.MineBubbleShow ="MineBubbleShow"
EventType.MineBuildingSet = 'MineBuildingSet'
EventType.updateGutTalk = 'updateGutTalk'
EventType.hideGutTalk = 'hideGutTalk'
EventType.clickGutTalk = 'clickGutTalk'
EventType.endGutBox = 'endGutBox'
EventType.endGutReward = 'endGutReward'
EventType.autoGut = 'autoGut'
EventType.closeTeamUpgradeUI = 'closeTeamUpgradeUI'
EventType.expBarActionComplete = 'expBarActionComplete'
EventType.BuildingBubbleShow = 'BuildingBubbleShow'

EventType.showVipPayUI = "showVipPayUI"

EventType.LoadOverTime = "LoadOverTime"
EventType.ShowChatView = "ShowChatView"
EventType.UpdateChat = "UpdateChat"
EventType.ChangeChannel = "ChangeChannel"
EventType.TestEvent = "TestEvent"

EventType.TeamNameChange = "TeamNameChange"
EventType.TeamLevelUp = "TeamLevelUp"
EventType.TeamUpgradeHide = 'TeamUpgradeHide'
EventType.TeamCDKeyTakeRusult = "TeamCDKeyTakeRusult"
EventType.GutInfo = "GutInfo"
EventType.GutEnd = "GutEnd"
EventType.GutInductEnd = "GutInductEnd"

EventType.BuildingCritUpdate = "BuildingCritUpdate"
EventType.HolyBuildingSet = "HolyBuildingSet"

EventType.CheckPayOK = "CheckPayOK"

EventType.ChangeMainState = "ChangeMainState"

EventType.ShowWindow = "ShowWindow" -- 窗口打开事件
EventType.CloseWindow = "CloseWindow" -- 窗口关闭完成
EventType.ShowWinName = 'ShowWinName'  -- 窗口打开事件,带 名称
EventType.ShowWinNames = 'ShowWinNames'
EventType.HideWinName = 'HideWinName'  -- 窗口关闭事件,带 名称
EventType.SoldierGetUIClose = "SoldierGetUIClose" 	--获得英雄界面关闭

EventType.FormationUIShow = "FormationUIShow" --英雄上阵
EventType.FormationBtnFight = "FormationBtnFight" --开战

EventType.DoNextChunk = "DoNextChunk"

EventType.RefreshCopyUpdate = "RefreshCopyUpdate"

EventType.ArenaOpponent = "ArenaOpponent" --竞技场对手
EventType.ArenaRole = "ArenaRole" --竞技场自身信息
EventType.UpdateArenaResultData = "UpdateArenaResultData" --竞技场结果
EventType.ArenaRanking = "ArenaRanking" -- 竞技场拍名
EventType.ArenaWarRecord = "ArenaWarRecord"  -- 竞技场战报

EventType.SelectCopy = "SelectCopy" -- 选择副本
EventType.SelectBoss = "SelectBoss" -- 选择扫荡boss
EventType.ShowResultList = "ShowResultList" -- 显示扫荡结果
EventType.ShowTomb = "ShowTomb"		--大墓地扫荡
EventType.ShowTrial = "ShowTrial"	--扫荡十字军试炼
EventType.FightCopyMonster = "FightCopyMonster" -- 攻打遇见怪物
EventType.UpdateCopyBoss = "UpdateCopyBoss"
EventType.SelectNormalBoss = "SelectNormalBoss"
EventType.SelectEliteBoss = "SelectEliteBoss"
EventType.ShowBossInfo = "ShowBossInfo"
EventType.CloseBossInfo = "CloseBossInfo"
EventType.GetPresent = "GetPresent"
EventType.ShowGetCopyPrize = "ShowGetCopyPrize"
EventType.ShowMonsterMet = 'ShowMonsterMet'
EventType.CopySearchCompleteUIHide = 'CopySearchCompleteUIHide'
EventType.UpdateCopyLog = "UpdateCopyLog"
EventType.CopyShowFightBtn = "CopyShowFightBtn"
EventType.NCopyUIHide = "NCopyUIHide"
EventType.CopyClearance = 'CopyClearance'
EventType.UpdateMaterial = "UpdateMaterial"
EventType.UpdateMaterialPoint = "UpdateMaterialPoint"
EventType.CollectMaterial = "CollectMaterial"
EventType.COPY_FIGHTLOG_LOADED = "COPY_FIGHTLOG_LOADED"
EventType.CopySearchShow = 'CopySearchShow'
EventType.CopyPage = 'CopyPage'
EventType.CopyPtViewItem = "CopyPtViewItem"		--更新副本建筑物上的物品检测

EventType.ArenaCdtime = "ArenaCdtime" --cd时间
EventType.ArenaAddnum = "ArenaAddnum" --增加挑战次数
EventType.AuctionUIsetT = "AuctionUIsetT" -- 设置t
EventType.AuctionUIBuy = "AuctionUIBuy" -- 设置n甲类型出现
EventType.AuctionSellView = "AuctionSellView" --出售的view 更新
EventType.AuctionRecordView = "AuctionRecordView" -- 出售记录

EventType.RankList = "RankList" -- 排行榜

EventType.PaomaEvent = "PaomaEvent"  -- 公告
EventType.CopyExpLevelUp = "CopyExpLevelUp" -- 副本經驗增加戰隊升級

EventType.CopyGetExp = "CopyGetExp"
EventType.CopyGetList = "CopyGetList"
EventType.UpdateCopyProgress = "UpdateCopyProgress"

-- EventType.ShowMailContent = "ShowMailContent"
EventType.openMailBox = "openMailBox"

EventType.OpenFunc = "OpenFunc" --功能开放

EventType.UserOther = "UserOther" -- 常用数据

EventType.TotemSlotResult = "TotemSlotResult" --图腾镶嵌结果
EventType.TotemMergeResult = "TotemMergeResult" --图腾雕文合成结果
EventType.TotemMergeFly = "TotemMergeFly" --图腾合成飞~

EventType.ShowMeiriStore = "ShowMeiriStore" --商店每日更新
EventType.UpdateStoreDataDJ = "UpdateStoreDataDJ" --更新数据
EventType.UpdateStoreDataYX = "UpdateStoreDataYX" --更新数据
EventType.UpdateStoreDataXZ = "UpdateStoreDataXZ" --更新数据
EventType.UpdataXZCount = "UpdataXZCount" --更新勋章数据
EventType.HideMine = "HideMine"  --隐藏金矿

EventType.SoldierStepUp = "SoldierStepUp"
EventType.SoldierLevelUp = "SoldierLevelUp"
EventType.SoldierEatBookQ = "SoldierEatBookQ"

EventType.BackButtonClick = "BackButtonClick"

EventType.TrialRewardUpdate = "TrialRewardUpdate"
EventType.TrialUpdate = "TrialUpdate"

EventType.showCopyExpBar = 'showCopyExpBar'
EventType.ArenaDefine = 'ArenaDefine'
EventType.showExpBarUI = 'showExpBarUI'
EventType.ArenaWarReport = "ArenaWarReport"
EventType.ArenaloadSoldier = "ArenaloadSoldier"
EventType.UpdateMainChat = "UpdateMainChat" --聊天主界面
EventType.addFriendDetail = "addFriendDetail" -- 添加聊天左边框

EventType.ShowGetRow = 'ShowGetRow'
EventType.ActivationResult = "ActivationResult" --激活游戏结果

EventType.addNewMail = "addNewMail" -- 邮件事件
EventType.updateMail = "updateMail"
EventType.deleteMail = "deleteMail"
EventType.delAllMail = "delAllMail"
EventType.recvAllMail = "recvAllMail"
EventType.showMailContent = "showMailContent"
EventType.RemoveMainChat = "RemoveMainChat"
EventType.RemoveChat = "RemoveChat"
EventType.UpdateStoreDataAch = "UpdateStoreDataAch"
EventType.showBuildingInfoByType = "showBuildingInfoByType"
EventType.showProdCount = "showProdCount"

EventType.hour = 'hour'

EventType.tombUiUpdata = "tombUiUpdata"

--friend 好友
EventType.ShowFriendChat = "ShowFriendChat"
EventType.FriendUpdata = "FriendUpdata"
EventType.FriendTypeChange = "FriendTypeChange"
EventType.FriendRecomChange = "FriendRecomChange"
EventType.FriendLimitChange = "FriendLimitChange"
EventType.FriendErrNoExist = "kErrFriendNoExist"
EventType.FriendChatUpdate = "FriendChatUpdate" 
EventType.AddExp = "AddExp"
--app进入前台，后台
EventType.EnterBackground = "enterBackground"
EventType.EnterForeground = "enterForeground"

--活动
EventType.activityListUpdate = "activityListUpdate"
EventType.activityGetReward = "activityGetReward"

--7天目标
EventType.actOpenTargetUpdate = "actOpenTargetUpdate"

EventType.canCloseFightResultUI = "canCloseFightResultUI"
--vip活动
EventType.VipTimeWeek = "VipTimeWeek"
EventType.VipPackageBuy = "VipPackageBuy"
EventType.VipBuyPackage = "VipBuyPackage"
EventType.changeSelect = "changeSelect"
EventType.showSelectBox = "showSelectBox"

EventType.expBarPercent = "expBarPercent"

-- 神殿系统
EventType.TempleInfo = "TempleInfo"
EventType.TempleTakeScoreReward = "TakeScoreReward"
EventType.TempleGroupLevelUp = "TempleGroupLevelUp"
EventType.TempleChangeSelect = "TempleChangeSelect"

--战力手册
EventType.FightPowerUpdate = "FightPowerUpdata"

--副本获取装备
EventType.CopyTipsEquip = "CopyTipsEquip"
EventType.CopyTipsShow = "CopyTipsShow"