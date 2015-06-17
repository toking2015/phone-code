InductData = {}

const.kTypeFun = 1
const.kTypeModule = 2
const.kTypeWindow = 3
const.kTypeNo = 4

const.kResponseTpyeClick = 1
const.kResponseTpyeSlide = 2
const.kResponseTpyeDrag = 3

const.kOffTypeAll = 1
const.kOffTypeShow = 2
const.kOffTypeRespond = 3

const.kStarTypeCom = 1
const.kStarTypeJump = 2

const.kIndexTypeEvent = 1
const.kIndexTypeFun = 2

const.kDataTypeFun = 1
const.kDataTypeOther = 2

const.kdataValTypeNot = 1

local function getData( type, responseTpye, ui, module, bg, showHandle, handle, offPoint, isEnd, isAction, nextEvent )
    local data = {}
    data.type = type
    data.responseTpye = responseTpye
    data.ui = ui
    data.module = module
    data.bg = bg
    data.showHandle = showHandle
    data.handle = handle
    data.offPoint = offPoint
    data.isEnd = isEnd
    data.isAction = isAction
    data.nextEvent = nextEvent
    return data
end

InductData.Data =
{
    [1] =
    {   --1 退出引导
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {"PageData.setCurrPage(1)", "Command.run( 'scene enter', 'main' )"} )
    },    
    [2] =
    {   --2、第一场战斗
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'FightDataMgr:fightTotemBtn()', nil, 'zsyq-tx-01',{'FightDataMgr:fightPause()'}, {'FightDataMgr:fightTotemFire()', 'FightDataMgr:fightContinue()'} )
    },
    [3] =
    {   --3、点击进入第二个副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show", CopyData.getNextCopyId(const.kCopyMopupTypeNormal))'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },
    [4] =
    {   --4、第2个副本，加上原来的战斗介绍（就是介绍图腾和图腾怒气条之类的）
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'FightDataMgr:fightTotemPro()', nil, 'zsyq-tx-01',{'FightDataMgr:fightPause()'}, nil, {x=0, y=20} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'FightDataMgr:fightTotemBtn()', nil, 'zsyq-tx-01', nil, {'FightDataMgr:fightContinue()'} )
    },      
    [5] =
    {   --5、第2场战斗
        -- [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'FightDataMgr:fightTotemBtn()', nil, 'zsyq-tx-01',nil, nil, {x=50,y=50}, nil, nil, {{type=const.kDataTypeFun, event=EventType.FightToTemClick, data='FightDataMgr:fightTotemBtn()'}, {type=const.kDataTypeOther, event=EventType.SceneClose, data='fight'}} )
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'FightDataMgr:fightTotemBtn()', nil, 'zsyq-tx-01',{'FightDataMgr:fightPause()'}, {'FightDataMgr:fightTotemFire()', 'FightDataMgr:fightContinue()'} )
    },
    [6] =
    {   --6 关闭升级界面
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'TeamUpgradeUI', 'item.btn_confirm', 'zsyq-tx-01', nil, nil, {x=85, y=25}, nil, nil, {{type=const.kDataTypeOther, event=EventType.TeamUpgradeHide, data=nil}} )
    },
    [7] =
    {   --7、返回主界面，抽卡引导
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {"Command.run( 'scene enter', 'main' )"} ), 
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01',nil, { 'PopMgr.popUpWindow( "CardUI", true, PopUpType.SPECIAL )' }, {x=565, y=340} ),     
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick,'CardUI', 'norFrontGo', 'zsyq-tx-01', nil, {'PopMgr.getWindow("CardUI"):norToBack()'} ),     
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick,'CardUI', 'norOneBtn', 'zsyq-tx-01', nil, {' CardData.cardQ( trans.const.kAltarLotteryByMoney,1, const.kAltarLotteryUseFree )'} ),     
        [5] = getData( const.kTypeWindow, const.kResponseTpyeClick,'SoldierGetUI', 'btn_get', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierGetUI")'} ), 
        [6] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {"PopMgr.removeWindowByName('CardGet')","PopMgr.removeWindowByName('CardUI')"} )    
    },   
    [8] =
    {   --8、抽卡完成进入副本引导1
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn_main', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {"Command.run( 'NCopyUI show copy', const.kCopyMopupTypeNormal, 1011 )"} ), 
    },
    [9] =
    {   --9、点击进入第三个副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show", CopyData.getNextCopyId(const.kCopyMopupTypeNormal))'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },  
    [10] =
    {   --10、第三个副本后老牛升阶      
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_hero', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'},{'PopMgr.popUpWindow("SoldierUI")'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10801)', nil, 'zsyq-tx-01', nil,{'PopMgr.getWindow("SoldierUI").listView:toInfo(PopMgr.getWindow("SoldierUI"):getSelectedItem(10801))'} ),        
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierInfo', 'stepCon.nNotItem', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierInfo"):inductEatBook( 24041, 10801 )' } ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SkillBookMergeUI', 'left_panel.btn', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SkillBookMergeUI"):equipSkill()', 'PopMgr.removeWindowByName("SkillBookMergeUI")' }, nil, true ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierInfo") and PopMgr.getWindow("SoldierInfo"):GetBtnStepUp(10801)', nil, 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierInfo"):onStepUp()'} ),   
        [6] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierStepSuccess', 'btnOk', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierStepSuccess")'} ),   
        [7] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierInfo")', 'PopMgr.removeWindowByName("SoldierUI")'} )     
    }, 
    [11] =
    {
       --11、点击进入第四个副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show", CopyData.getNextCopyId(const.kCopyMopupTypeNormal))'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },  
    [12] =
    {   --12、第四个副本，进入战斗的时候指向血条，告诉玩家只要学了技能书的英雄，怒气槽满了就可以放大招
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'FightDataMgr:getSoldierView()', nil, 'zsyq-tx-01', nil, {'FightDataMgr:fightContinue()'},{ x=0, y=180} )
    },
    [13] =
    {   --13、图腾升级
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_totem', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("TotemUI")'} ), 
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TotemUI', '_upgrade.btn', 'zsyq-tx-01', {'PopMgr.getWindow("TotemUI").flushPage=true', 'PopMgr.getWindow("TotemUI"):updateData()', 'PopMgr.getWindow("TotemUI").flushPage=false', 'PopMgr.getWindow("TotemUI"):changeTotem(findTotem(80301))'}, {'PopMgr.getWindow("TotemUI").onUpgradeHandler(true)'} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TotemUI', '_upgrade.btn', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TotemUI").onUpgradeHandler(true)'} ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TotemUI', '_upgrade.btn', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TotemUI").onUpgradeHandler(true)'} ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("TotemUI")'} ) 
    },     
   [14]=
    {   --14、点击进入第五个副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show",  CopyData.getNextCopyId(const.kCopyMopupTypeNormal))'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', 'mainUI.btn_search', 'zsyq-tx-01', nil, {'Command.run("cmd copy search")'} )
    },  
   [15] =
    {   --15、打完第五副本之后 领取宝箱
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', 'mainUI.star.image', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'Command.run("CopyPresentUI show", {showType=1, area_id=1, area_attr=const.kCopyAreaAttrPass} )' } ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'CopyPresentUI', 'btn_get', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("CopyPresentUI")'} )        
    },   
    [16] =
    {   --16、打完第五副本，去召唤小黑 
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {"Command.run( 'scene enter', 'main' )"} ),            
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', nil, { 'PopMgr.popUpWindow( "CardUI" )' }, {x=565, y=340}),     
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick,'CardUI', 'dimFrontGo', 'zsyq-tx-01', nil, {'PopMgr.getWindow("CardUI"):dimToBack()' } ),     
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick,'CardUI', 'dimOneBtn', 'zsyq-tx-01', nil, {'CardData.cardQ(trans.const.kAltarLotteryByGold,1,const.kAltarLotteryUseFree)'} ),     
        [5] = getData( const.kTypeWindow, const.kResponseTpyeClick,'SoldierGetUI', 'btn_get', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierGetUI")'} ), 
        [6] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {"PopMgr.removeWindowByName('CardGet')","PopMgr.removeWindowByName('CardUI')"} )  
    },  
    [17] =
    {
        --17、太阳井按钮
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01',{'PopMgr.removeAllWindow()'}, { 'Command.run("holy collect")' }, {x=700, y =160} )
    },    
    [18] =
    {   --18、给小黑提升等级
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_hero', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("SoldierUI")'} ),     
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierUI', 'listView.top.btnTo', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierUI").listView:toModel()'} ),
        [3] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [4] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [6] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [7] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [8] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [9] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [10] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10801)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10801)'} ),
        [11] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10202)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10202)'} ),
        [12] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierUI', 'listView.top.btnBack', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierUI").listView:toModel()'} ),
        [13] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierInfo")', 'PopMgr.removeWindowByName("SoldierUI")'} )     
    },   
    [19] =
    {   --19、抽卡完成进入副本引导2
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn_main', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {"Command.run( 'NCopyUI show copy', const.kCopyMopupTypeNormal, 1031 )"} ), 
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', 'mainUI.btn_right', 'zsyq-tx-01', nil, {"SceneMgr.getCurrentScene().mainUI.clickToArea(SceneMgr.getCurrentScene().mainUI.btn_right)"}, nil, nil, true ),
    },      
    [20]=
    {   --20、点击进入1-6副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show",  1)'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} )
        -- [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },   
    [21] =
    {   --21、2-1副本布阵,上阵小黑
        -- [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_formation', 'zsyq-tx-01', nil, {'Command.run("formation show ui" )'} ),
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', nil, { 'FormationData.attr = const.kAttrSoldier', 'Command.run("formation show ui" )'}, {x=205, y=330} ),
        -- [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'ui.btn_1', 'zsyq-tx-01', nil, {'Command.run("formation ui changetab", 1 )'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'PopMgr.getWindow("FormationWin"):getSoldierNodeForId(10401)', nil, 'zsyq-tx-01', nil, {'Command.run("formation up", const.kFormationTypeCommon, 3, const.kAttrSoldier )', 'EventMgr.dispatch(EventType.UserFormationUpdate)'}, nil, true ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'ui.item_br.btn', 'zsyq-tx-01', nil, {'Command.run("formation hide ui" )'} ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },
    [22] =
    {   --22、打完后，让小黑升阶
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_hero', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("SoldierUI")'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil,{'PopMgr.getWindow("SoldierUI").listView:toInfo(PopMgr.getWindow("SoldierUI"):getSelectedItem(10401))'} ),        
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierInfo', 'stepCon.nNotItem', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierInfo"):inductEatBook( 24061, 10401 )' } ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SkillBookMergeUI', 'left_panel.btn', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SkillBookMergeUI"):equipSkill()', 'PopMgr.removeWindowByName("SkillBookMergeUI")' }, nil, true ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierInfo") and PopMgr.getWindow("SoldierInfo"):GetBtnStepUp(10401)', nil, 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierInfo"):onStepUp()'} ),
        [6] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierStepSuccess', 'btnOk', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierStepSuccess")'} ),   
        [7] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierInfo")', 'PopMgr.removeWindowByName("SoldierUI")'} )     
    },
    [23]=
    {
       --23、点击进入1-7副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show",  2)'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },    
    [24]=
    {
       --24、1-9打完 英雄升级
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_hero', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("SoldierUI")'} ),     
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierUI', 'listView.top.btnTo', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierUI").listView:toModel()'} ),
        [3] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10801)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10801)'} ),
        [4] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10801)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10801)'} ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10801)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10801)'} ),
        [6] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10202)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10202)'} ),
        [7] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10202)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10202)'} ),
        [8] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10202)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10202)'} ),
        [9] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [10] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [11] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10401)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10401)'} ),
        [12] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierUI', 'listView.top.btnBack', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierUI").listView:toModel()'} ),
        [13] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierInfo")', 'PopMgr.removeWindowByName("SoldierUI")'} )  
    },   
    [25]=
    {   --25、引导-领取刺客魂石-任务奖励
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleRight()', 'btn_task', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("TaskUI")'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("TaskUI"):getMainView()', 'btn_get', 'zsyq-tx-01', {'PopMgr.getWindow("TaskUI"):setAchieveSelect(1)'}, { 'PopMgr.getWindow("TaskUI").onMainViewBtnGet()', 'PopMgr.removeWindowByName("TaskUI")'} )
    },   
    [26] =
    {   --26、招募混血女刺客
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_hero', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("SoldierUI")'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil,{'PopMgr.getWindow("SoldierUI").listView:onRecruit(PopMgr.getWindow("SoldierUI"):getSelectedItem(10701))'} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'MsgBoxUI', 'bg.orange', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierUI").listView.okFun()', 'PopMgr.removeWindowByName("MsgBoxUI")'}, nil, true ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick,'SoldierGetUI', 'btn_get', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierGetUI")'} ), 
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierInfo")', 'PopMgr.removeWindowByName("SoldierUI")'} )     
    },
    [27]=
    {
       --27、点击进入1-10副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show",  CopyData.getNextCopyId(const.kCopyMopupTypeNormal))'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} )
        -- [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },  
    [28]=
    {
       --28、点击进入1-11副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', {'PopMgr.removeAllWindow()', 'Command.run("cmd DesWin show",  CopyData.getNextCopyId(const.kCopyMopupTypeNormal))'}, {'PopMgr.getWindow("BossInfoUI").fightFunc()'} )
        -- [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },  
    [29] =
    {   --29、图腾上阵
        -- [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_formation', 'zsyq-tx-01', nil, {'Command.run("formation show ui" )'}  ),
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', nil, {'FormationData.attr = const.kAttrTotem', 'Command.run("formation show ui" )'}, {x=495, y=330} ),
        -- [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'ui.btn_2', 'zsyq-tx-01', nil, {'Command.run("formation ui changetab", 2 )'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'PopMgr.getWindow("FormationWin"):getShenMingTotemNode()', nil, 'zsyq-tx-01', nil, {'Command.run("formation up", const.kFormationTypeCommon, 2, const.kAttrTotem )', 'EventMgr.dispatch(EventType.UserFormationUpdate)'}, nil, true ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'ui.item_br.btn', 'zsyq-tx-01', nil, {'Command.run("formation hide ui" )'} )
        --[5] = getData( const.kTypeFun, const.kResponseTpyeDrag, 'SceneMgr.getCurrentScene()', nil, 'yiwei-tx-01', nil, {'FormationData.switchIndex(const.kFormationTypeCommon, 0, 6)','EventMgr.dispatch(EventType.UserFormationUpdate)'}, {x=555, y=240, x1=-110, y1=115, x2=370,y2=160})
    },      
    [30] =
    {   --30、打完后，让三季稻升阶
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_hero', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'},{'PopMgr.popUpWindow("SoldierUI")'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10202)', nil, 'zsyq-tx-01', nil,{'PopMgr.getWindow("SoldierUI").listView:toInfo(PopMgr.getWindow("SoldierUI"):getSelectedItem(10202))'} ),        
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierInfo', 'stepCon.nNotItem', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierInfo"):inductEatBook( 24161, 10202)' } ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SkillBookMergeUI', 'left_panel.btn', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SkillBookMergeUI"):equipSkill()', 'PopMgr.removeWindowByName("SkillBookMergeUI")' }, nil, true ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierInfo") and PopMgr.getWindow("SoldierInfo"):GetBtnStepUp(10202)', nil, 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierInfo"):onStepUp()'} ),
        [6] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierStepSuccess', 'btnOk', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierStepSuccess")'} ),   
        [7] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierInfo")', 'PopMgr.removeWindowByName("SoldierUI")'} )     
    }, 
    [31]=
    {   --10级获得装备
        -- [1] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'OpenFuncUI', 'btn_open', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.getWindow("OpenFuncUI").onOpenClick()'} ),
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01',{'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow( "EquipmentUI")'}, {x=235, y=165} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'EquipmentUI', 'item_1', 'zsyq-tx-01' ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'EquipmentUI', 'infoview.info_all', 'zsyq-tx-01' ),
        [4] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("EquipmentUI")'} ),     
    },     
    [32] =
    {   --32、转屏开启竞技场建筑 
        [1] = getData( const.kTypeNo, const.kResponseTpyeSlide, '', '', 'yd-tx-01', {'PopMgr.removeAllWindow()'}, {'Command.run("cmd main turn", 45)'}, {x= 500, y=215} )
    },
    [33] =
    {   --23、竞技场引导
        [1] = getData( const.kTypeNo, const.kResponseTpyeSlide, '', '', 'yd-tx-01', {'PopMgr.removeAllWindow()'}, {'Command.run("cmd main turn", 45)'}, {x= 500, y=215} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("ArenaUI")'}, {x=430, y=400} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'ArenaUI', 'definebtn', 'zsyq-tx-01', nil,{'EventMgr.dispatch(EventType.ArenaDefine)'} ),
        [4] = getData( const.kTypeFun, const.kResponseTpyeClick,'FormationWin:getBtnFight()', nil, 'zsyq-tx-01', nil, {'Command.run("formation confirm" )'} ),
        [5] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'ArenaUI', 'card1.card.tiaozhanbtn', 'zsyq-tx-01', nil,{'InductMgr:runJJCFormation()'} ),
        [6] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'FormationData.okFun=function()end','PopMgr.getWindow("FormationWin").closeResult = true','PopMgr.getWindow("FormationWin").style = FormationData.STYLE_TWO','PopMgr.getWindow("FormationWin"):doHide()','InductMgr:runJJCFight()', 'PopMgr.removeWindowByName("ArenaUI")'} )
    }, 
    [34] =
    {   --34、商店引导
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_totem', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("TotemUI")'} ), 
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TotemUI', '_active.btn', 'zsyq-tx-01', {'PopMgr.getWindow("TotemUI").flushPage=true', 'PopMgr.getWindow("TotemUI"):updateData()', 'PopMgr.getWindow("TotemUI").flushPage=false', 'PopMgr.getWindow("TotemUI"):changeTotem(findTotem(80201))'}, {'PopMgr.getWindow("TotemUI"):onActiveHandler(true)'} )
        -- [3] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("TotemUI")'} ) 
    },    
    [35] =
    {   --35、精英副本引导
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', 'mainUI.copySelect.btn_elite', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'Command.run("cmd CopySelect")'} )
    },   
    [36] =
    {   --36、引导-装备-领取任务奖励
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleRight()', 'btn_task', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("TaskUI")'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("TaskUI"):getMainView()', 'btn_get', 'zsyq-tx-01', {'PopMgr.getWindow("TaskUI"):setAchieveSelect(1)'}, { 'PopMgr.getWindow("TaskUI").onMainViewBtnGet()', 'PopMgr.removeWindowByName("TaskUI")'} )
    }, 
    [37] =
    {   --37、引导-装备-制作
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01',{'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow( "EquipmentUI")'}, {x=235, y=165} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'EquipmentUI', 'button_type_1', 'zsyq-tx-01',nil, {'PopMgr.getWindow( "EquipmentUI").onTypeButtonTouch(PopMgr.getWindow( "EquipmentUI").button_type_1)'} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'EquipmentUI', 'item_1', 'zsyq-tx-01',nil, {'PopMgr.getWindow( "EquipmentUI").onSubclassButtonTouchBegin(PopMgr.getWindow( "EquipmentUI").item_1)', 'PopMgr.getWindow( "EquipmentUI").onSubclassButtonTouchEnd(PopMgr.getWindow( "EquipmentUI").item_1)' } ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'EquipmentMadeUI', 'madeItemView.button', 'zsyq-tx-01', nil, {'PopMgr.getWindow("EquipmentMadeUI").onButtonTouch()'}, nil, true ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("EquipmentMadeUI"):getRightButton()', nil, 'zsyq-tx-01', nil, {'PopMgr.getWindow("EquipmentMadeUI").rightButtonTouch()', 'PopMgr.removeWindowByName("EquipmentMadeUI")', 'PopMgr.removeWindowByName("EquipmentUI")', 'InductMgr:runGut( GutMgr:getTransformGut( 20001 ) )'} )
    },   
    [38] =
    {   --38、引导制作图纸
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01',{'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow( "PaperSkillSelectUI")' }, {x=460, y =140} )
    },
    [39] =
    {   --39、1-5探索指引
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', 'mainUI.btn_search', 'zsyq-tx-01', nil, nil, {x=80,y=80}, nil, nil, {{type=const.kDataTypeOther, event=EventType.CopySearchShow, data=false},{type=const.kDataTypeOther, event=EventType.SceneClose, data='copy'}} )
    }, 
    [40] =
    {   --40、1-5战斗指引
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', 'bg.met.btn_fight', 'zsyq-tx-01', nil, nil, {x=120,y=65}, nil, nil, {{type=const.kDataTypeOther, event=EventType.SceneClose, data='copy'}} )
    },
    [41] =
    {   --41、给女刺客提升等级
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleBottom()', 'con_bottom.btn_hero', 'zsyq-tx-01', {'PopMgr.removeAllWindow()'}, {'PopMgr.popUpWindow("SoldierUI")'} ),     
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierUI', 'listView.top.btnTo', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierUI").listView:toModel()'} ),
        [3] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [4] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [6] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [7] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [8] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [9] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [10] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [11] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [12] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),
        [13] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),        
        [14] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),        
        [15] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),        
        [16] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),        
        [17] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("SoldierUI"):getSelectedItem(10701)', nil, 'zsyq-tx-01', nil, { 'PopMgr.getWindow("SoldierUI").listView:levelUpById(10701)'} ),        
        [18] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'SoldierUI', 'listView.top.btnBack', 'zsyq-tx-01', nil, {'PopMgr.getWindow("SoldierUI").listView:toModel()'} ),
        [19] = getData( const.kTypeFun, const.kResponseTpyeClick,'BackButton', 'btn', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("SoldierInfo")', 'PopMgr.removeWindowByName("SoldierUI")'} )     
    },
    [42] =
    {   --21、2-1副本布阵,上阵女刺客
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_formation', 'zsyq-tx-01', nil, {'Command.run("formation show ui" )'} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'ui.btn_1', 'zsyq-tx-01', nil, {'Command.run("formation ui changetab", 1 )'} ),
        [3] = getData( const.kTypeFun, const.kResponseTpyeClick,'PopMgr.getWindow("FormationWin"):getSoldierNodeForId(10701)', nil, 'zsyq-tx-01', nil, {'Command.run("formation up", const.kFormationTypeCommon, 4, const.kAttrSoldier )', 'EventMgr.dispatch(EventType.UserFormationUpdate)'}, nil, true ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'ui.item_br.btn', 'zsyq-tx-01', nil, {'Command.run("formation hide ui" )'} ),
        [5] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },
    [43]=
    {   --43、点击进入1-6开始至1-12的副本
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'BossInfoUI', 'btn_fight', 'zsyq-tx-01', { 'Command.run("cmd DesWin show", CopyData.getNextCopyId(const.kCopyMopupTypeNormal))'}, nil, {x=85, y=25}, nil, nil, {{type=const.kDataTypeOther, event=EventType.CloseBossInfo, data=nil}, {type=const.kDataTypeOther, event=EventType.SceneClose, data='copyUI'}} )
    },   
    [44]=
    {   --44、点击1-6开战指引
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, nil, {x=70, y=55}, nil, nil, {{type=const.kDataTypeOther, event=EventType.FormationBtnFight, data=nil}, {type=const.kDataTypeOther, event=EventType.SceneClose, data='fight'}, {type=const.kDataTypeOther, event=EventType.HideWinName, data='FormationWin'}} )
    },
    [45]=
    {   --引导领取邮箱钻石
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getMainChat()', 'bg.mailbtn', 'zsyq-tx-01', nil, {'MainUIMgr.getMainChat().mailbtnTouch()'} )  
    },
    [46]=
    {   --引导任务开启
        [1] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'OpenFuncUI', 'btn_open', 'zsyq-tx-01', {'PopMgr.removeAllWindow()','InductMgr:openTask()'}, {'PopMgr.getWindow("OpenFuncUI").onOpenClick()'} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleRight()', 'btn_task', 'zsyq-tx-01', nil, {'Command.run( "ui show", "TaskUI", PopUpType.SPECIAL )', 'PopMgr.getWindow("TaskUI"):setAchieveSelect(1)'} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'mainView', 'zsyq-tx-01' ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'branchView_1.btn', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI").onBranchViewBtn(PopMgr.getWindow("TaskUI").branchView_1.btn)'} ),
        [5] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'RewardGetUI', 'btnOk', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("RewardGetUI")'} ),
        [6] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'branchView_1.btn', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI").onBranchViewBtn(PopMgr.getWindow("TaskUI").branchView_1.btn)'} ),
        [7] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'RewardGetUI', 'btnOk', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("RewardGetUI")'} ),
        [8] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'mainView.btn_go', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI").onMainViewBtnGo()'} )
    },
    [47]=
    {   --资源采集引导
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'SceneMgr.getCurrentScene()', 'mainUI.material_points_1', 'zsyq-tx-01', nil, {'SceneMgr.getCurrentScene().mainUI.material_points_1.onTouchBegin()'} )
    },    
    [48] =
    {    --48、第1-11副本 石化图腾引导
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'FightDataMgr:fightTotemBtn()', nil, 'zsyq-tx-01',{'FightDataMgr:fightPause()'}, {'FightDataMgr:fightTotemFire()', 'FightDataMgr:fightContinue()'} )
    },
    [49] =
    {   --49、精英副本1
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', nil, nil, {x=915, y=390} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },    
    [50] =
    {    --50、精英副本2
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', nil, nil, {x=990, y=270} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeDrag, 'SceneMgr.getCurrentScene()', nil, 'yiwei-tx-01', nil, {'FormationData.switchIndex(const.kFormationTypeCommon, 2, 5)','EventMgr.dispatch(EventType.UserFormationUpdate)'}, {x=310, y=260, x1=-90, y1=130, x2=180,y2=245}),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },   
    [51] =
    {   --51、精英副本4
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', nil, nil, {x=825, y=280} ),
        [2] = getData( const.kTypeFun, const.kResponseTpyeDrag, 'SceneMgr.getCurrentScene()', nil, 'yiwei-tx-02', nil, {'FormationData.switchIndex(const.kFormationTypeCommon, 4, 5)','EventMgr.dispatch(EventType.UserFormationUpdate)'}, {x=365, y=160, x1=-40, y1=60, x2=175,y2=230}),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick,'FormationWin', 'btn_fight', 'zsyq-tx-01', nil, {'Command.run("formation fight" )'} )
    },   
    [52] =
    {   --52、精英副本5
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'SceneMgr.getCurrentScene()', nil, 'zsyq-tx-01', nil, nil, {x=925, y=385} )
    },
    [53] =
    {   --53、副本建筑指引
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene():getBuild(CopyData.getNextCopyId(CopyData.area_type))', nil, 'zsyq-tx-01', nil, nil, {x=0, y=10}, nil, nil, {{type=const.kDataTypeOther, event=EventType.ShowWinNames, data='BossInfoUI'}, {type=const.kDataTypeOther, event=EventType.SceneClose, data='copyUI'}, {type=const.kDataTypeOther, event=EventType.CopySelect, data=nil}} )
    },   
    [54]=
    {   --54 第一次交主线任务
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleRight()', 'btn_task', 'zsyq-tx-01', {'PopMgr.removeWindowByName("RewardGetUI")'}, {'Command.run( "ui show", "TaskUI", PopUpType.SPECIAL )', 'PopMgr.getWindow("TaskUI"):setAchieveSelect(1)'} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'mainView.btn_get', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI").onMainViewBtnGet()'} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'RewardGetUI', 'btnOk', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("RewardGetUI")'} ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'mainView.btn_go', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI").onMainViewBtnGo()'} )
    },
    [55]=
    {   --55 第二次交主线任务
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick, 'MainUIMgr.getRoleRight()', 'btn_task', 'zsyq-tx-01', {'PopMgr.removeWindowByName("RewardGetUI")'}, {'Command.run( "ui show", "TaskUI", PopUpType.SPECIAL )', 'PopMgr.getWindow("TaskUI"):setAchieveSelect(1)'} ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'mainView.btn_get', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI").onMainViewBtnGet()'} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'RewardGetUI', 'btnOk', 'zsyq-tx-01', nil, {'PopMgr.removeWindowByName("RewardGetUI")'} ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'mainView.btn_go', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI").onMainViewBtnGo()'} )
    },    
    [56]=
    {   --56 第3次交主线任务
        [1] = getData( const.kTypeFun, const.kResponseTpyeClick,'SceneMgr.getCurrentScene()', 'mainUI.btn_right', 'zsyq-tx-01', {'PopMgr.removeWindowByName("RewardGetUI")'}, {"AlteractData.showByData(const.kCoinTeamXp)"}, nil, nil, true ),
        [2] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'AlteractyTipsUI', 'item1', 'zsyq-tx-01', nil, {'Command.run( "ui show", "TaskUI", PopUpType.SPECIAL )', 'PopMgr.getWindow("TaskUI"):setAchieveSelect(1)'} ),
        [3] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'mainView.btn_go', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI"):setAchieveSelect(2)'} ),
        [4] = getData( const.kTypeWindow, const.kResponseTpyeClick, 'TaskUI', 'btn_2', 'zsyq-tx-01' ),
        [5] = getData( const.kTypeFun, const.kResponseTpyeClick, 'PopMgr.getWindow("TaskUI"):getItemById(30005)', 'btn_get', 'zsyq-tx-01', nil, {'PopMgr.getWindow("TaskUI"):getItemById(30005):getHandler()'} )
    }     
}


local function getStartData( eventList, checkList, checkIndexList, readyGut, notRecord, optional, mustEvent )
    local data = {}
    data.eventList = eventList
    data.checkList = checkList
    data.checkIndexList = checkIndexList
    data.readyGut = readyGut
    data.notRecord = notRecord
    data.optional = optional
    data.mustEvent = mustEvent
    return data
end

InductData.StartData =
{
    [1] = getStartData(),
    --2、第一场战斗
    [2] = getStartData( {EventType.FightInduct}, nil, {{type=const.kIndexTypeEvent, event=EventType.FightInduct, data=1, index=1}}, nil, true, nil, true ),
    --3、点击进入第二个副本
    [3] = getStartData( {EventType.UpdateCopyLog, EventType.SceneShows, EventType.InductEnd, EventType.CopyNewBuilding}, {'CopyData.checkNotClearance(1011, 1021, 1)', 'InductMgr:checkCanRunCopy()'} ),
    --4、第2个副本，加上原来的战斗介绍（就是介绍图腾和图腾怒气条之类的）
    [4] = getStartData( {EventType.FightInduct}, nil, {{type=const.kIndexTypeEvent, event=EventType.FightInduct, data=5, index=1}}, nil, true, nil, true ),
    --5、第2场战斗
    [5] = getStartData( {EventType.FightInduct}, nil, {{type=const.kIndexTypeEvent, event=EventType.FightInduct, data=2, index=1}}, nil, true, nil, true ),
    --6、关闭升级界面
    [6] = getStartData( {EventType.ShowWinName, EventType.InductEnd}, {'not GameData.checkLevel(6)', 'PopMgr.getIsShow("TeamUpgradeUI")'}, {{type=const.kIndexTypeEvent, event=EventType.ShowWinName, data='TeamUpgradeUI', index=1}}, nil, true, true ),
    --7、返回主界面，抽卡引导
    [7] = getStartData( {EventType.InductEnd, EventType.SceneShows, EventType.TaskAdd}, {'CopyData.checkClearance(1021)', 'TaskData.hasOrOnceTask(10012)', 'SoldierData.notHaveSoldier(10202)', 'InductMgr:checkNoFightScene()' },  {{type=const.kIndexTypeFun, data='SceneMgr.isSceneName("copyUI")', index=1}, {type=const.kIndexTypeFun, data='SceneMgr.isSceneName("main")', index=2}}),
    --8、抽卡完成进入副本引导1
    [8] = getStartData( {EventType.GutInductEnd, EventType.SceneShows, EventType.InductEnd}, {'InductMgr:checkRunEnd(7)', 'not CopyData.checkClearance( 1031 )', 'SceneMgr.isSceneName("main")'} ),
    --9、点击进入第三个副本
    [9] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd, EventType.CopyNewBuilding}, {'CopyData.checkNotClearance(1021, 1031, 1)', 'InductMgr:checkRunEnd(7)', 'InductMgr:checkCanRunCopy()' } ),
    --10、第三个副本后老牛升阶   
    [10] = getStartData( {EventType.SceneShows, EventType.UserItemAdd, EventType.InductEnd}, {'ItemData.getItemCount(24041) > 0', 'InductMgr:checkNoFightScene()', 'SoldierData.getSoldierBySId(10801).quality == 1'} ),
    --11、点击进入第四个副本
    [11] = getStartData( {EventType.SceneShows, EventType.InductEnd, EventType.UpdateCopyLog, EventType.CopyNewBuilding}, {'InductMgr:checkRunEnd(10)', 'CopyData.checkNotClearance(1031, 1041, 1)', 'InductMgr:checkCanRunCopy()'} ),
    --12、第四个副本，进入战斗的时候指向血条，告诉玩家只要学了技能书的英雄，怒气槽满了就可以放大招
    [12] = getStartData( {EventType.FightInduct}, nil, {{type=const.kIndexTypeEvent, event=EventType.FightInduct, data=6, index=1}}, nil, true, nil, true ),
    --13、图腾升级
    [13] = getStartData( {EventType.UpdateCopyLog, EventType.SceneShows, EventType.InductEnd, EventType.TaskAdd}, {'CopyData.checkClearance(1041)', 'TotemData.checkCanBless(TotemData.getTotemById(80301))', 'InductMgr:checkNoFightScene()', 'TaskData.hasOrOnceTask(10016)'} ),
    --14、点击进入第五个副本
    -- [14] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd, EventType.CopyNewBuilding }, {'InductMgr:checkRunEnd(13)', 'CopyData.checkNotClearance(3061, 3071, 3)', 'InductMgr:checkCanRunCopy()'} ),
    [14] = getStartData(),
    --15、打完第五副本之后 领取宝箱
    [15] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd}, {'CopyData.checkClearance(1051)', 'SceneMgr.isSceneName("copyUI")', 'CopyData.area_id == 1'} ),
    --16、打完第五副本，去召唤小黑
    [16] = getStartData( {EventType.SceneShows, EventType.TaskAdd, EventType.InductEnd}, {'CopyData.checkClearance(1051)', 'TaskData.hasOrOnceTask(10018)', 'SoldierData.notHaveSoldier(10401)', 'InductMgr:checkNoFightScene()', 'not SceneMgr.isSceneName("copy")' }, {{type=const.kIndexTypeFun, data='SceneMgr.isSceneName("copyUI")', index=1}, {type=const.kIndexTypeFun, data='SceneMgr.isSceneName("main")', index=2}}),
    --17、太阳井按钮
    [17] = getStartData( {EventType.InductEnd, EventType.SceneShows}, {'InductMgr:checkRunEnd(16)', 'SceneMgr.isSceneName("main")'} ),    
    --18、给小黑提升等级
    [18] = getStartData( {EventType.InductEnd, EventType.SceneShows, EventType.TaskAdd}, {'InductMgr:checkRunEnd(16)', 'InductMgr:checkNoFightScene()', 'TaskData.hasOrOnceTask(10019)'} ),
    --19、抽卡完成副本引导2
    [19] = getStartData( {EventType.InductEnd, EventType.SceneShows}, {'InductMgr:checkRunEnd(18)', 'not CopyData.checkClearance( 2011 )', 'SceneMgr.isSceneName("main")'} ),
    --20、点击进入1-6副本
    -- [20] = getStartData( {EventType.SceneShows, EventType.InductEnd }, {'InductMgr:checkRunEnd(18)', 'CopyData.checkNotClearance(1051, 2011, 2)'} ),
    [20] = getStartData(),
    --21、1-6副本布阵,上阵小黑
    [21] = getStartData( {EventType.SceneShows}, {'FormationData.oppExData == 2011', 'FormationData.getCanUpById(10401)', 'SceneMgr.isSceneName("fight")'} ),
    --22、打完后，让小黑升阶
    [22] = getStartData( {EventType.SceneShows, EventType.UserItemAdd, EventType.InductEnd, EventType.TaskAdd}, {'InductMgr:checkNoFightScene()', 'ItemData.getItemCount(24061) > 0', 'SoldierData.getSoldierBySId(10401).quality == 1', 'TaskData.hasOrOnceTask(10021)'} ),
    --23、点击进入1-7副本
    -- [23] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd }, {'InductMgr:checkRunEnd(22)','CopyData.checkNotClearance(2011, 2021, 2)'} ),
    [23] = getStartData(),
    --24、1-9打完 英雄升级
    [24] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd}, {'CopyData.checkClearance(2041)', 'InductMgr:checkNoFightScene()'} ),
    --25、领取女刺客魂石任务奖励
    [25] = getStartData({EventType.SceneShows, EventType.TeamUpgradeHide, EventType.InductEnd, EventType.TaskAdd }, {'GameData.checkLevel(15)', 'TaskData.checkTaskCanFinsh(10035)', 'InductMgr:checkNoFightScene()'} ),
    --26、招募混血女刺客
    [26] = getStartData( {EventType.SceneShows, EventType.UserItemAdd, EventType.InductEnd}, { 'ItemData.getItemCount(30701) >= 30', 'InductMgr:checkNoFightScene()', 'SoldierData.notHaveSoldier(10701)' } ),
    --27、点击进入1-10副本
    -- [27] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd, EventType.InductEnd}, {'CopyData.checkNotClearance(2041, 2051, 2)', 'InductMgr:checkRunEnd(41)'} ),
    [27] = getStartData(),
    --28、点击进入1-11副本
    -- [28] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd}, {'CopyData.checkNotClearance(2051, 2061, 2)'} ),
    [28] = getStartData(),
    --29、图腾上阵
    [29] = getStartData( {EventType.SceneShows}, {'CopyData.checkClearance(2051)', 'SceneMgr.isSceneName("fight")', 'TotemData.hasTotem(80201)'} ),   
    --30、打完后，让三季稻升阶
    [30] = getStartData( {EventType.SceneShows, EventType.UserItemAdd, EventType.TaskAdd, EventType.InductEnd}, {'InductMgr:checkNoFightScene()', 'ItemData.getItemCount(24161) > 0', 'SoldierData.getSoldierBySId(10202).quality == 1', 'TaskData.hasOrOnceTask(10029)'} ),
    --31、10级获得装备
    [31] = getStartData( {EventType.SceneShows, EventType.UpdateCopyLog, EventType.InductEnd}, {'CopyData.checkClearance(2071)','not SceneMgr.isSceneName("copy")', 'InductMgr:checkNoFightScene()'}, nil, true ),
    --32、转屏开启竞技场建筑 
    [32] = getStartData( {EventType.SceneShows, EventType.TeamUpgradeHide, EventType.InductEnd}, {'GameData.checkLevel(22)', 'not SceneMgr.isSceneName("copy")', 'InductMgr:checkNoFightScene()' }, nil, true ),
    --33、竞技场引导
    [33] = getStartData( {EventType.ScenePageBuilding, EventType.SceneShows}, {'InductMgr:checkRunEnd(32)','SceneMgr.isSceneName("main")', 'InductMgr.isJJCFight==false' },{{type=const.kIndexTypeFun, data='PageData.getCurrPage()==1', index=1}, {type=const.kIndexTypeFun, data='PageData.getCurrPage()==8', index=2}}),
    --34、商店引导
    [34] = getStartData( {EventType.SceneShows, EventType.HideWinName}, {'InductMgr:checkRunEnd(33)', 'not TotemData.hasTotem(80201)','FightDataMgr:isNotFight()', 'ArenaData.outShowFlag==false', 'ArenaData.lishiflag==false'}, {{type=const.kIndexTypeEvent, event=EventType.HideWinName, data='ArenaUI', index=1}} ),
    --35、精英副本引导
    [35] = getStartData( {EventType.SceneShows, EventType.InductEnd, EventType.TeamUpgradeHide}, {'GameData.checkLevel(12)', 'SceneMgr.isSceneName("copyUI")'} ),
    --36、引导-装备-领取任务奖励
    [36] = getStartData( {EventType.TeamUpgradeHide, EventType.SceneShows}, {'GameData.checkLevel(20)', 'TaskData.checkTaskCanFinsh(50007)', 'InductMgr:checkNoFightScene()'} ),
    --37、引导-装备-制作
    [37] = getStartData( {EventType.InductEnd, EventType.SceneShows, EventType.UserItemAdd}, {'not SceneMgr.isSceneName("copy")', 'InductMgr:checkNoFightScene()', 'EquipmentData:checkMade( 13001 )'}, nil, true ),        
    --38、引导制作图纸
    [38] = getStartData( {EventType.GutInductEnd, EventType.SceneShows}, {'InductMgr:checkRunEnd(37)', 'SceneMgr.isSceneName("main")', 'PageData.getCurrPage()==1'} ),
    --39、1-5探索指引
    [39] = getStartData( {EventType.CopySearchShow}, {'SceneMgr.isSceneName("copy")', 'not GameData.checkLevel(16)'}, nil, nil, true, true ),
    --40、1-5开战指引
    [40] = getStartData( {EventType.ShowMonsterMet}, {'SceneMgr.isSceneName("copy")', 'not GameData.checkLevel(16)'}, nil, nil, true, true ),
    --41、给女刺客提升等级
    [41] = getStartData( {EventType.InductEnd, EventType.SceneShows}, {'InductMgr:checkRunEnd(26)', 'InductMgr:checkNoFightScene()'} ),    
    --42、2-1副本布阵,上阵女刺客
    -- [42] = getStartData( {EventType.SceneShows}, {'FormationData.oppExData == 2051', 'FormationData.getCanUpById(10701)', 'SceneMgr.isSceneName("fight")'} ),    
    [42] = getStartData(),
    --43、点击进入1-6副本
    [43] = getStartData( {EventType.SceneShows, EventType.CopyPage, EventType.InductEnd, EventType.GutInductEnd, EventType.CopyNewBuilding, EventType.ShowWinName}, { 'not GameData.checkLevel(10)', 'CopyData.checkClearance(1041)', 'SceneMgr.isSceneName("copyUI")', 'InductMgr:checkCanRunCopy()' }, nil, nil, true, true ),
    --44、点击1-6开战指引
    [44] = getStartData( {EventType.SceneShows, EventType.CopyPage, EventType.InductEnd, EventType.GutInductEnd, EventType.ShowWinName}, { 'not GameData.checkLevel(10)', 'CopyData.checkClearance(1041)', 'not CopyData.checkClearance(CopyData.getNextCopyId(const.kCopyMopupTypeNormal))', 'SceneMgr.isSceneName("fight")', 'PopMgr.getIsShow( "FormationWin")'}, nil, nil, true, true ),
    --引导领取邮箱钻石
    [45] = getStartData( {EventType.SceneShows, EventType.HideWinName }, {'InductMgr:checkRunEnd(34)', 'not PopMgr.getIsShow("TotemUI")'}, {{type=const.kIndexTypeEvent, event=EventType.HideWinName, data='TotemUI', index=1}, {type=const.kIndexTypeEvent, event=EventType.SceneShows, data=nil, index=1}}, nil, nil, nil, true ),
    --引导任务开启
    [46] = getStartData( {EventType.SceneShows, EventType.InductEnd }, { 'InductMgr:checkRunEnd(31)'}),
    --资源采集引导
    [47] = getStartData( {EventType.ShowMaterialUI }, {'SceneMgr.isSceneName("copyUI")', 'CopyData.curSelectUI == const.kCopyMaterial'}, {{type=const.kIndexTypeEvent, event=EventType.ShowMaterialUI, data=nil, index=1}}, nil, nil, nil, true ),
    --48、第1-11副本 石化图腾引导
    [48] = getStartData( {EventType.FightInduct}, nil, {{type=const.kIndexTypeEvent, event=EventType.FightInduct, data=7, index=1}}, nil, true, nil, true ),  
    --精英副本1
    [49] = getStartData( {EventType.SceneShows}, {'CopyData.fightBossCopyId == 1011', 'CopyData.area_type==const.kCopyMopupTypeElite', 'SceneMgr.isSceneName("fight")'} ),
    --精英副本2
    [50] = getStartData( {EventType.SceneShows}, {'CopyData.fightBossCopyId == 1021', 'CopyData.area_type==const.kCopyMopupTypeElite', 'SceneMgr.isSceneName("fight")'} ),
    --精英副本4
    -- [51] = getStartData( {EventType.SceneShows}, {'CopyData.fightBossCopyId == 1041', 'CopyData.area_type==const.kCopyMopupTypeElite', 'SceneMgr.isSceneName("fight")'} ),
    [51] = getStartData(),
    --精英副本5
    -- [52] = getStartData( {EventType.SceneShows}, {'CopyData.fightBossCopyId == 1051', 'CopyData.area_type==const.kCopyMopupTypeElite', 'SceneMgr.isSceneName("fight")'} ),
    [52] = getStartData(),
    --副本建筑指引
    [53] = getStartData( {EventType.SceneShows, EventType.CopyPage, EventType.InductEnd, EventType.GutInductEnd, EventType.HideWinName, EventType.CopyNewBuilding, EventType.CopySelects}, {'InductMgr:checkRunCopyBuilding()', 'not PopMgr.getIsShow("BossInfoUI")', 'SceneMgr.isSceneName("copyUI")', 'InductMgr:checkCanRunCopy()' }, {{type=const.kIndexTypeEvent, event=EventType.HideWinName, data='BossInfoUI', index=1}}, nil, true, true ),
     --54 第一次交主线任务
    [54] = getStartData( {EventType.SceneShows, EventType.UserTaskLogUpdate }, {'TaskData.checkTaskCanFinsh(10033)', 'not SceneMgr.isSceneName("fight")'} ),
     --55 第二次交主线任务
    [55] = getStartData( {EventType.SceneShows, EventType.UserTaskLogUpdate }, {'TaskData.checkTaskCanFinsh(10036)', 'not SceneMgr.isSceneName("fight")'} ),  
    --56 第3次交主线任务
    [56] = getStartData( {EventType.SceneShows, EventType.UserTaskLogUpdate }, {'CopyData.checkClearance(3071)', 'TaskData.checkTaskCanFinsh(30005)', 'SceneMgr.isSceneName("copyUI")'} ),    
}