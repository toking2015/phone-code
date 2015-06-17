#include "singlearena_imp.h"
#include "building_imp.h"
#include "singlearena_dc.h"
#include "singlearena_event.h"
#include "formation_imp.h"
#include "proto/constant.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "coin_imp.h"
#include "rank_imp.h"
#include "var_imp.h"
#include "user_imp.h"
#include "mail_imp.h"
#include "back_imp.h"
#include "fightextable_imp.h"
#include "bias_imp.h"
#include "name_imp.h"
#include "user_dc.h"
#include "util.h"
#include "misc.h"
#include "local.h"
#include "server.h"
#include "common.h"
#include "log.h"
#include "pro.h"
#include "resource/r_singlearenasoldierext.h"
#include "resource/r_singlearenatotemext.h"
#include "resource/r_singlearenadayrewardext.h"
#include "resource/r_singlearenabattlerewardext.h"
#include "resource/r_totemextext.h"
#include "resource/r_totemext.h"
#include "resource/r_soldierextext.h"
#include "resource/r_soldierext.h"
#include "resource/r_globalext.h"
#include "resource/r_levelext.h"
#include "resource/r_packetext.h"
#include "resource/r_rewardext.h"
#include "resource/r_avatarext.h"


namespace singlearena
{

    struct FormationCmp
    {
        uint32 m_index;
        FormationCmp(uint32 index) : m_index(index) { }
        bool operator()(SUserFormation &formation )
        {
            return (formation.formation_index == m_index);
        }
    };

    void    GetFormation( uint32 rank, std::vector<SUserFormation>& formation_list )
    {
        std::vector<uint32> soldier_list = theSingleArenaSoldierExt.GetSoldier(rank);
        std::map<uint32, std::vector<uint32> > index_map;

        index_map[1].push_back(1);
        index_map[1].push_back(4);
        index_map[1].push_back(7);
        index_map[1].push_back(2);
        index_map[1].push_back(5);
        index_map[1].push_back(8);
        index_map[4].push_back(4);
        index_map[4].push_back(1);
        index_map[4].push_back(7);
        index_map[4].push_back(2);
        index_map[4].push_back(5);
        index_map[4].push_back(8);
        index_map[7].push_back(7);
        index_map[7].push_back(4);
        index_map[7].push_back(1);
        index_map[7].push_back(2);
        index_map[7].push_back(5);
        index_map[7].push_back(8);
        index_map[2].push_back(5);
        index_map[2].push_back(2);
        index_map[2].push_back(8);
        index_map[2].push_back(1);
        index_map[2].push_back(4);
        index_map[2].push_back(7);
        index_map[5].push_back(8);
        index_map[5].push_back(5);
        index_map[5].push_back(2);
        index_map[5].push_back(1);
        index_map[5].push_back(4);
        index_map[5].push_back(7);
        index_map[8].push_back(8);
        index_map[8].push_back(5);
        index_map[8].push_back(2);
        index_map[8].push_back(1);
        index_map[8].push_back(4);
        index_map[8].push_back(7);

        uint32 count = 0;
        for( std::vector<uint32>::iterator iter = soldier_list.begin();
            iter != soldier_list.end();
            ++iter )
        {
            CSingleArenaSoldierData::SData *psoldier_data = theSingleArenaSoldierExt.Find(*iter);
            if( NULL == psoldier_data )
                continue;

            //上阵数量限制
            if( count >= psoldier_data->count )
                break;

            CSoldierExtData::SData *pext_data = theSoldierExtExt.Find( psoldier_data->id );
            if( NULL == pext_data )
                continue;

            CSoldierData::SData *pdata = theSoldierExt.Find( pext_data->soldier_id );
            if ( NULL == pdata )
                continue;

            std::vector<uint32> pos_list = index_map[pdata->formation];

            for( std::vector<uint32>::iterator jter = pos_list.begin();
                jter != pos_list.end();
                ++jter )
            {
                std::vector<SUserFormation>::iterator target_iter = std::find_if( formation_list.begin(), formation_list.end(), FormationCmp( *jter ));
                if( target_iter == formation_list.end() )
                {
                    SUserFormation formation;
                    formation.guid = psoldier_data->id;
                    formation.formation_type = kFormationTypeSingleArenaDef;
                    formation.attr = kAttrSoldier;
                    formation.formation_index = *jter;
                    formation_list.push_back(formation);
                    ++count;
                    break;
                }
            }
        }

        //添加图腾
        //图腾站位{0,3,6}
        std::vector<uint32> totem_index;
        totem_index.push_back(0);
        totem_index.push_back(3);
        totem_index.push_back(6);
        std::vector<uint32> totem_list = theSingleArenaTotemExt.GetTotem(rank);
        uint32 index = 0;
        count = 0;
        for( std::vector<uint32>::iterator iter = totem_list.begin();
            iter != totem_list.end();
            ++iter )
        {
            CSingleArenaTotemData::SData *ptotem_data = theSingleArenaTotemExt.Find(*iter);
            if( NULL == ptotem_data )
                continue;

            //上阵数量限制
            if( count >= ptotem_data->count )
                break;
            if( index >= totem_index.size() )
                break;

            CTotemExtData::SData *pext_data = theTotemExtExt.Find( ptotem_data->id );
            if( NULL == pext_data )
                continue;

            CTotemData::SData *pdata = theTotemExt.Find( pext_data->totem_id );
            if ( NULL == pdata )
                continue;

            SUserFormation formation;
            formation.guid = ptotem_data->id;
            formation.formation_type = kFormationTypeSingleArenaDef;
            formation.attr = kAttrTotem;
            formation.formation_index = totem_index[index];
            formation_list.push_back(formation);
            ++index;
            ++count;
        }

        uint32 size = (uint32)formation_list.size();
        if( size == 0 )
        {
            back::write( "singlearena.debug", "formation size:%u,rank:%u",size,rank );
        }
    }

    /******************/

    void    LoadData( std::vector< SSingleArenaOpponent >& list )
    {
        //初始化完成
        if ( list.empty() )
        {
            CreateRank();

            theSingleArenaDC.SetLoadLog();

            event::dispatch( SEventSingleArenaRankLoad() );
            return;
        }

        for ( std::vector< SSingleArenaOpponent >::iterator iter = list.begin();
            iter != list.end();
            ++iter )
        {
            theSingleArenaDC.set_rank_data( (*iter).rank, *iter );
            theSingleArenaDC.set_id_rank( (*iter).target_id, (*iter).rank );
        }
    }

    void    LoadLog( std::vector< SSingleArenaLog >& list )
    {
        //初始化完成
        if ( list.empty() )
        {
            theSingleArenaDC.SetLoadLog();
            event::dispatch( SEventSingleArenaLogLoad() );
            return;
        }

        SSingleArenaInfo* info    = NULL;

        for ( std::vector< SSingleArenaLog >::iterator iter = list.begin();
            iter != list.end();
            ++iter )
        {
            info    = theSingleArenaDC.find_info( iter->target_id );
            if( info )
            {
                info->fightlog_list.push_back( *iter );
            }
            else
            {
                info = new SSingleArenaInfo;

                info->fightlog_list.push_back( *iter );
                theSingleArenaDC.set_info_data( iter->target_id, *info );
            }
        }
    }

    void    CreateRank()
    {
        //如果排行榜为空，就生成50个数据
        uint32 count = theSingleArenaDC.get_show_data_count();

        if ( count >= SHOW_RANK_COUNT )
            return;

        for( uint32 rank = 1; rank <= SHOW_RANK_COUNT; ++rank )
        {
            if( theSingleArenaDC.find_show( rank ) == NULL )
                CreateOpponent( rank );
        }
    }

    void    SaveDataToDB( SSingleArenaOpponent &data, uint8 set_type )
    {
        PQSingleArenaSave rep;

        rep.set_type  = set_type;
        rep.data      = data;

        local::write(local::realdb, rep);
    }

    void    SaveLogToDB( uint32 target_id, std::vector< SSingleArenaLog >& list )
    {
        PQSingleArenaLogSave rep;

        rep.target_id = target_id;
        rep.list      = list;

        local::write(local::realdb, rep);
    }

    void    RandOpponent( SUser* puser )
    {
        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if( info == NULL )
        {
            info = new SSingleArenaInfo;

            SetInfoBase( puser, info );

            theSingleArenaDC.set_info_data( puser->guid, *info );
        }

        SetInfoOpp( puser, info );

        theSingleArenaDC.set_info_data( puser->guid, *info );
    }

    SSingleArenaOpponent    CreateOpponent( uint32 rank )
    {
        //查找排行榜是否有此对手，没有就创建一个假人
        SSingleArenaOpponent *pOpp = theSingleArenaDC.find_rank( rank );

        if ( pOpp )
        {
            return *pOpp;
        }

        SSingleArenaOpponent data;
        data.target_id = theSingleArenaDC.get_guid();
        std::stringstream stream;
        //随机取名，有可能会出现一个玩家四个对手有同名的情况
        data.name        = name::random_name();//stream.str();
        data.avatar      = theAvatarExt.RandNum();
        data.team_level  = 30;
        data.rank        = rank;
        data.fight_value = 500;

        GetFormation( rank, data.formation_list );

        //找到最大的level
        std::vector< uint32 > list;
        for( std::vector<SUserFormation>::iterator iter = data.formation_list.begin();
            iter != data.formation_list.end();
            ++iter )
        {
            if( (*iter).attr == kAttrSoldier )
            {
                list.push_back( (*iter).guid );
            }
        }

        data.team_level  = theSoldierExtExt.GetMaxLevel( list );
        data.fight_value = theSoldierExtExt.GetSumFighting( list );

        theSingleArenaDC.set_rank_data( rank, data );
        theSingleArenaDC.set_id_rank( data.target_id, rank );

        return data;
    }

    bool    CheckRefresh( SUser* puser )
    {
        uint32 free_times  = var::get( puser, "singlearena_battle_free" );

        if( free_times > 0 )
        {
            S3UInt32 coin;
            coin.cate =  kCoinGold;
            coin.val  =  theGlobalExt.get<uint32>("singlearena_refresh_coin");

            if( coin::check_take( puser, coin ) == coin.cate )
            {
                HandleErrCode(puser, kErrSingleArenaGold, 0);
                return false;
            }

            coin::take( puser, coin, kPathSingleArena );
        }
        else
            var::set( puser, "singlearena_battle_free", 1 );

        return true;

    }

    void    Refresh( SUser* puser )
    {
        RandOpponent( puser );

        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if( info == NULL )
        {
            back::write( "singlearena.debug", "Refresh info not find guid : %u", puser->guid );
            return;
        }

        PRSingleArenaRefresh rep;
        bccopy( rep, puser->ext );

        rep.opponent_list = info->opponent_list;

        local::write(local::access, rep);

    }

    void    ResetRefresh( SUser* puser )
    {
        var::set( puser, "singlearena_battle_free", 0 );
    }

    void    ClearCD( SUser* puser )
    {
        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if( info == NULL )
        {
            back::write( "singlearena.debug", "ClearCD info not find guid : %u", puser->guid );
            return;
        }

        uint32 cd_time  = var::get( puser, "singlearena_battle_cd" );
        uint32 now_time = server::local_time();

        //CD时间已过
        if ( now_time >= cd_time )
        {
            return;
        }

        uint32 pay_time = 1;

        S3UInt32 coin;
        coin.cate =  kCoinGold;
        coin.val  =  pay_time * theGlobalExt.get<uint32>("singlearena_clear_time_coin");

        if( coin::check_take( puser, coin ) == coin.cate )
        {
            HandleErrCode(puser, kErrSingleArenaGold, 0);
            return;
        }

        coin::take( puser, coin, kPathSingleArena );

        var::set( puser, "singlearena_battle_cd", 0 );

        PRSingleArenaClearCD rep;
        bccopy( rep, puser->ext );

        rep.time_cd = 0;
        local::write(local::access, rep);

        info->time_cd = 0;
    }

    void    ReplyCD( SUser* puser )
    {
        uint32 cd_time  = var::get( puser, "singlearena_battle_cd" );

        PRSingleArenaReplyCD rep;
        bccopy( rep, puser->ext );

        rep.time_cd = cd_time;
        local::write(local::access, rep);

    }

    bool    CheckCD( SUser* puser )
    {
        uint32 cd_time  = var::get( puser, "singlearena_battle_cd" );
        uint32 now_time = server::local_time();

        //CD时间已过
        if ( now_time >= cd_time )
            return true;


        return false;
    }

    void    SetCD( SUser* puser )
    {
        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if ( info == NULL )
            return;

        uint32 now_time = server::local_time();

        now_time  =  now_time + theGlobalExt.get<uint32>("singlearena_cd_time_coin") * 60;

        var::set( puser, "singlearena_battle_cd", now_time );

        info->time_cd = now_time;
        theSingleArenaDC.set_info_data( puser->guid, *info );
    }

    bool    CheckTimes( SUser* puser )
    {
        uint32 def_times = theGlobalExt.get<uint32>("singlearena_challenge_times");
        uint32 add_times = var::get( puser, "singlearena_add_times" );

        uint32 cur_times = var::get( puser, "singlearena_cur_times" );

        uint32 add_base  = theGlobalExt.get<uint32>("singlearena_add_times_base");

        if ( cur_times < add_times * add_base + def_times )
            return  true;

        return false;
    }

    void    SetTimes( SUser* puser )
    {
        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if ( info == NULL )
            return;

        uint32 cur_times = var::get( puser, "singlearena_cur_times" );
        var::set( puser, "singlearena_cur_times", cur_times + 1);

        info->cur_times = cur_times + 1;
        theSingleArenaDC.set_info_data( puser->guid, *info );
    }


    void    AddTimes( SUser* puser )
    {
        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if ( info == NULL )
            return;

        CLevelData::SData *pData = theLevelExt.Find( puser->data.simple.vip_level );
        if( pData == NULL )
            return;

        uint32 add_times = var::get( puser, "singlearena_add_times" );


        if ( add_times >= pData->singlearena_times )
            return;

        pData = theLevelExt.Find( add_times + 1 );
        if ( pData == NULL )
            return;

        S3UInt32 coin;
        coin.cate =  kCoinGold;
        coin.val  =  pData->singlearena_price;;

        if( coin::check_take( puser, coin ) == coin.cate )
        {
            HandleErrCode(puser, kErrSingleArenaGold, 0);
            return;
        }
        coin::take( puser, coin, kPathSingleArena );

        var::set( puser, "singlearena_add_times", add_times + 1);

        PRSingleArenaAddTimes rep;
        bccopy( rep, puser->ext );
        rep.add_times = add_times + 1;
        rep.cur_times = var::get( puser, "singlearena_cur_times" );
        local::write(local::access, rep);

        info->add_times = add_times + 1;
        theSingleArenaDC.set_info_data( puser->guid, *info );
    }

    void    ReplyInfo( SUser* puser )
    {
        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );

        //生成数据
        if ( info == NULL )
        {
            RandOpponent( puser );

            info = theSingleArenaDC.find_info( puser->guid );
            if ( info == NULL )
            {
                back::write( "singlearena.debug", "ReplyInfo recarte info is fail : %u", puser->guid );
                return;
            }
        }
        else if( info->opponent_list.empty() )
        {
            //数据没有真正的初始化，只是因为离线时有人挑战过<也有可能是加载战报>
            SetInfoBase( puser, info );
            SetInfoOpp( puser, info );

            theSingleArenaDC.set_info_data( puser->guid, *info );
        }
        else
        {
            RandOpponent( puser );
        }


        PRSingleArenaInfo rep;
        bccopy( rep, puser->ext );
        rep.info    = *info;

        local::write(local::access, rep);

        //第一次copy布阵
        std::vector<SUserFormation> formation_list;
        formation::GetFormation( puser, kFormationTypeSingleArenaAct, formation_list );
        if ( formation_list.empty() )
        {
            puser->data.formation_map[kFormationTypeSingleArenaAct] = puser->data.formation_map[kFormationTypeCommon];
            formation::ReplyList( puser, kFormationTypeSingleArenaAct );
        }
        formation_list.clear();
        formation::GetFormation( puser, kFormationTypeSingleArenaDef, formation_list );
        if ( formation_list.empty() )
        {
            puser->data.formation_map[kFormationTypeSingleArenaDef] = puser->data.formation_map[kFormationTypeCommon];
            formation::ReplyList( puser, kFormationTypeSingleArenaDef );
        }
        //墓地数据保存
        formation_list.clear();
        formation::GetFormation( puser, kFormationTypeYesterday, formation_list );
        if ( formation_list.empty() )
        {
            SaveYesterday(puser);
        }
    }

    void    SetInfoBase( SUser *puser, SSingleArenaInfo *info )
    {
        uint32 cd_time = var::get( puser, "singlearena_battle_cd" );
        if( cd_time == 0 )
        {
            cd_time = server::local_time();
            var::set( puser, "singlearena_battle_cd", cd_time );
        }

        uint32 add_times = var::get( puser, "singlearena_add_times" );

        info->time_cd     = cd_time;
        info->add_times   = add_times;
        info->cur_times   = var::get( puser, "singlearena_cur_times" );
        info->fight_value = fightextable::GetFightValue( puser, kFormationTypeSingleArenaAct);
        info->max_rank    = puser->data.other.single_arena_rank;
        info->cur_rank    = theSingleArenaDC.get_rank_id( puser->guid );

    }

    void    SetInfoOpp( SUser *puser, SSingleArenaInfo *info )
    {
        SSingleArenaOpponent *opp = theSingleArenaDC.find_rank_by_targetid( puser->guid );

        uint32 rank = 0;
        uint32 isfirst = 0;
        if( opp )
        {
            isfirst = opp->rank;
            rank    = opp->rank;
        }

        rank = rank != 0 ? rank : server::get<uint32>( "single_arena_real_count" ) + MAX_CREATE_OPPONENT + 1;

        info->opponent_list.clear();

        uint32 rank_one, rank_two, rank_three, rank_four;

        GetRank( rank, rank_one, rank_two, rank_three, rank_four );

        //第一次必给假人
        if(  isfirst == 0 )
        {
            CheackFirstRank( rank, rank_one, rank_two, rank_three, rank_four );
            CheackFirstRank( rank, rank_two, rank_one, rank_three, rank_four );
            CheackFirstRank( rank, rank_three, rank_two, rank_one, rank_four );
            CheackFirstRank( rank, rank_four, rank_two, rank_three, rank_one );
        }

        //LOG_ERROR("one:%d,two:%d,three:%d,four:%d",rank_one,rank_two,rank_three,rank_four);

        info->opponent_list.push_back( CreateOpponent( rank_one ) );
        info->opponent_list.push_back( CreateOpponent( rank_two ) );
        info->opponent_list.push_back( CreateOpponent( rank_three ) );
        info->opponent_list.push_back( CreateOpponent( rank_four ) );
    }

    //把真人转换成假人
    void    CheackFirstRank( uint32 rank, uint32 &rank_s, uint32 rank_1, uint32 rank_2, uint32 rank_3 )
    {
        SSingleArenaOpponent *pOpp = theSingleArenaDC.find_rank( rank_s );
        if( pOpp )
        {
            if ( pOpp->target_id >= REAL_TARGET_GUID )
            {
                do
                {
                    --rank_s;
                    if( rank_s != rank && rank_s != rank_1 && rank_s != rank_2 && rank_s != rank_3 )
                    {
                        pOpp = theSingleArenaDC.find_rank( rank_s );
                        if( pOpp )
                        {
                            if ( pOpp->target_id < REAL_TARGET_GUID )
                                break;
                        }
                        else
                            break;
                    }
                }while(true);
            }
        }

    }

    void    AddLog( uint32 guid, uint32 fight_id, uint32 target_id, uint32 win_flag )
    {
        QU_ON( puser, guid );

        SSingleArenaInfo* info    = theSingleArenaDC.find_info( guid );
        if( info == NULL )
            return;

        //从自己的对手List匹配
        SSingleArenaOpponent* rank_opp = theSingleArenaDC.find_opp( puser->guid, target_id );
        if( rank_opp == NULL )
            return;

        //从排行榜中匹配
        rank_opp = theSingleArenaDC.find_rank_by_targetid( target_id);
        if( rank_opp == NULL )
            return;

        uint32 m_rank = info->cur_rank;     //自己当前名次
        uint32 h_rank = rank_opp->rank;     //对手当前名次

        uint32 m_rank_end = m_rank;         //自己最终名次

        //第一次打竞技场
        if ( m_rank == 0 )
            m_rank = server::get<uint32>( "single_arena_real_count" ) + MAX_CREATE_OPPONENT + 1;


        //如果赢了，才对换排名
        if( win_flag == kFightLeft )
            m_rank_end     = m_rank >  h_rank ? h_rank : m_rank;

        SSingleArenaLog log;
        log.target_id   = puser->guid;
        log.fight_id    = fight_id;
        log.ack_id      = puser->guid;
        log.def_id      = target_id;
        log.ack_level   = puser->data.simple.team_level;
        log.def_level   = rank_opp->team_level;
        log.ack_name    = puser->data.simple.name;
        log.ack_avatar  = puser->data.simple.avatar;
        log.def_name    = rank_opp->name;
        log.def_avatar  = rank_opp->avatar;
        log.win_flag    = win_flag;
        log.log_time    = time(NULL);
        if( win_flag == kFightLeft )
            log.rank_num    = m_rank - m_rank_end;
        else
            log.rank_num    = 0;

        if( info->fightlog_list.size() >= SHOW_LOG_COUNT )
            info->fightlog_list.erase( info->fightlog_list.begin() );

        info->fightlog_list.push_back( log );

        SaveLogToDB( puser->guid, info->fightlog_list );

        //如果对手是真实玩家，为对手增加log
        if( target_id >= REAL_TARGET_GUID )
        {
            log.target_id  = target_id;

            info    = theSingleArenaDC.find_info( target_id );
            if( info )
            {
                if( info->fightlog_list.size() >= SHOW_LOG_COUNT )
                    info->fightlog_list.erase( info->fightlog_list.begin() );

                info->fightlog_list.push_back( log );

            }
            else
            {
                info = new SSingleArenaInfo;

                info->fightlog_list.push_back( log );
                theSingleArenaDC.set_info_data( target_id, *info );
            }

            SaveLogToDB( target_id, info->fightlog_list );
        }
    }

    void    UpdateRank( uint32 guid, uint32 target_id, uint32 win_flag )
    {
        QU_ON( puser, guid );

        SSingleArenaInfo* info    = theSingleArenaDC.find_info( guid );
        if( info == NULL )
        {
            back::write( "singlearena.debug", "UpdateRank not find SSingleArenaInfo guid: %u", guid );
            return;
        }

        //输了
        if ( win_flag != kFightLeft )
        {
            //作一下统计《第一场输》
            if( info->cur_rank == 0 )
            {
                back::write( "singlearena.debug", "UpdateRank the first singlearena fighting is fail guid: %u", guid );
            }
            return;
        }

        //从自己的对手List匹配
        SSingleArenaOpponent* rank_opp = theSingleArenaDC.find_opp( puser->guid, target_id );
        if( rank_opp == NULL )
        {
            back::write( "singlearena.debug", "UpdateRank  not find target SSingleArenaOpponent  from own guid:%u", puser->guid );
            return;
        }

        //从排行榜中匹配
        rank_opp = theSingleArenaDC.find_rank_by_targetid( target_id);
        if( rank_opp == NULL )
        {
            back::write( "singlearena.debug", "UpdateRank  not find target SSingleArenaOpponent  from own guid:%u", puser->guid );
            return;
        }

        //copy一份对手的数据
        SSingleArenaOpponent battle_data;
        battle_data.target_id   = rank_opp->target_id;
        battle_data.name        = rank_opp->name;
        battle_data.avatar      = rank_opp->avatar;
        battle_data.team_level  = rank_opp->team_level;
        battle_data.fight_value = rank_opp->fight_value;

        uint32 m_rank = info->cur_rank;     //自己当前名次
        uint32 h_rank = rank_opp->rank;     //对手当前名次

        uint32 m_rank_end = m_rank;         //自己最终名次


        if ( m_rank == 0 )
        {
            back::write( "singlearena.debug", "UpdateRank  cur_rank is 0 guid:%u", puser->guid );
            return;
        }

        puser->data.other.single_arena_win_times += 1;

        m_rank_end = m_rank > h_rank ? h_rank : m_rank;

        //如果名次前进了
        if ( m_rank_end < m_rank )
        {

            info->cur_rank = m_rank_end;
            if( info->max_rank == 0 )
            {
                back::write( "singlearena.debug", "UpdateRank  max_rank is 0 guid:%u", puser->guid );
                return;
            }
            else
                info->max_rank = info->max_rank >  m_rank_end ? m_rank_end : info->max_rank;

            puser->data.other.single_arena_rank = info->max_rank;

            //自己
            SSingleArenaOpponent data;
            data.target_id   = guid;
            data.name        = puser->data.simple.name;
            data.avatar      = puser->data.simple.avatar;
            data.team_level  = puser->data.simple.team_level;
            data.rank        = m_rank_end;
            data.fight_value = fightextable::GetFightValue( puser, kFormationTypeSingleArenaDef);

            SaveDataToDB( data, kSingleArenaObjectDel );
            SaveDataToDB( data, kSingleArenaObjectAdd );
            theSingleArenaDC.set_rank_data( m_rank_end, data );
            theSingleArenaDC.set_id_rank( guid, m_rank_end );


            //对手数据
            battle_data.rank        = m_rank;
            if( target_id >= REAL_TARGET_GUID )
            {
                info    = theSingleArenaDC.find_info( target_id );
                if( info )
                {
                    info->cur_rank = m_rank;
                }

                SaveDataToDB( battle_data, kSingleArenaObjectDel );
                SaveDataToDB( battle_data, kSingleArenaObjectAdd );
            }
            else
            {
                //假人，重新以他的新排名生成数据
                battle_data.formation_list.clear();
                GetFormation( m_rank, battle_data.formation_list );
            }
            theSingleArenaDC.set_rank_data( m_rank, battle_data );
            theSingleArenaDC.set_id_rank( target_id, m_rank );

            SUser* target = theUserDC.find( target_id );
            if( target )
            {
                PRSingleArenaBattleed rep;
                bccopy( rep, target->ext );
                local::write(local::access, rep);
            }
        }
        else
        {
            //玩家从未打过竞技场，直接给他一个最末名
            //如果玩家有打过竞技场，因为对手的排名变了，玩家此次竞技不做排名更改
            if( info->cur_rank == 0 )
            {
                back::write( "singlearena.debug", "UpdateRank  fight fail and cur_rank is 0 guid:%u", puser->guid );
                return;
            }

        }
        user::ReplyUserOther(puser);
    }

    void    ReplyLog( SUser* puser )
    {
        PRSingleArenaLog rep;
        bccopy( rep, puser->ext );

        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );

        if ( info )
        {
            std::vector<SSingleArenaLog> list = info->fightlog_list;

            rep.fightlog_list  = list;
        }

        local::write(local::access, rep);
    }

    //这代码太扯了
    void    GetRank( uint32 rank, uint32 &rank_one, uint32 &rank_two, uint32 &rank_three, uint32 &rank_four )
    {

        if( rank > 400 )
        {
            rank_one   = TRand( rank*50/100, rank*55/100 );
            rank_two   = TRand( rank*65/100, rank*70/100 );
            rank_three = TRand( rank*80/100, rank*85/100 );
            rank_four  = TRand( rank*90/100, rank*95/100 );
        }
        else if( rank >= 11 )
        {
            rank_one   = TRand( rank*30/100, rank*35/100 );
            rank_two   = TRand( rank*45/100, rank*55/100 );
            rank_three = TRand( rank*65/100, rank*75/100 );
            rank_four  = TRand( rank*85/100, rank*95/100 );
        }
        else if ( rank > 4 )
        {
            rank_one   = TRand( rank*20/100, rank*35/100 );
            rank_two   = TRand( rank*45/100, rank*55/100 );
            rank_three = TRand( rank*65/100, rank*75/100 );
            rank_four  = rank*90/100;
        }
        else if ( rank == 4 )
        {
            rank_one   = 1;
            rank_two   = 2;
            rank_three = 3;
            rank_four  = 5;
        }
        else if ( rank == 3 )
        {
            rank_one   = 1;
            rank_two   = 2;
            rank_three = 4;
            rank_four  = 5;
        }
        else if ( rank == 2 )
        {
            rank_one   = 1;
            rank_two   = 3;
            rank_three = 4;
            rank_four  = 5;
        }
        else
        {
            rank_one   = 2;
            rank_two   = 3;
            rank_three = 4;
            rank_four  = 5;
        }

        /**
          if( rank > 20000 )
          {
          rank_one   = GetOpponentRank( 0, 0, rank-15000, rank-5001);
          rank_two   = GetOpponentRank( 0, 0, rank-5000, rank-1001);
          rank_three = GetOpponentRank( 0, 0, rank-1000, rank-201);
          rank_four  = GetOpponentRank( 0, 0, rank-200, rank-10);
          }
          else if( rank > 10000 )
          {
          rank_one   = GetOpponentRank( 0, 0, rank-5000, rank-2001);
          rank_two   = GetOpponentRank( 0, 0, rank-1500, rank-1001);
          rank_three = GetOpponentRank( 0, 0, rank-500, rank-101);
          rank_four  = GetOpponentRank( 0, 0, rank-100, rank-10);
          }
          **/

        //处理四个对手重复情况
        if( rank_two == rank_one )
            ++rank_two;

        while( rank_three == rank_one || rank_three == rank_two )
        {
            ++rank_three;
        }

        while( rank_four == rank_one || rank_four == rank_two || rank_four == rank_three )
        {
            ++rank_four;
        }

        //处理匹配自己的情况
        if( rank_one == rank )
        {
            do
            {
                ++rank_one;
            }
            while( rank_one == rank_two || rank_one == rank_three || rank_one == rank_four );
        }

        if( rank_two == rank )
        {
            do
            {
                ++rank_two;
            }
            while( rank_two == rank_one || rank_two == rank_three || rank_two == rank_four );
        }

        if( rank_three == rank )
        {
            do
            {
                ++rank_three;
            }
            while( rank_three == rank_one || rank_three == rank_two || rank_three == rank_four );
        }

        if( rank_four == rank )
        {
            do
            {
                ++rank_four;
            }
            while( rank_four == rank_one || rank_four == rank_two || rank_four == rank_three );
        }
    }

    uint32  GetOpponentRank( uint32 one, int32 two, uint32 first, uint32 second )
    {
        uint32 rank = one + two + TRand( first, second );
        return rank;
    }

    void    SendBattleReward( uint32 guid, uint32 target_id, uint32 win_flag )
    {
        QU_ON( puser, guid );

        SSingleArenaInfo* info    = theSingleArenaDC.find_info( guid );
        if( info == NULL )
            return;

        //首胜
        if( info->max_rank == 0 )
        {
            back::write( "singlearena.debug", "SendBattleReward send first win guid:%u", puser->guid );
            GetFirstReward( puser );
            return;
        }

        PRSingleArenaBattleEnd  end_rep;
        end_rep.win_flag = win_flag;
        bccopy( end_rep, puser->ext );

        //输了
        if( win_flag !=  kFightLeft )
        {
            uint32 reward_id = bias::PacketRandomReward( puser, theGlobalExt.get<uint32>("singlearena_battle_lose_packet_id") );
            CRewardData::SData *preward = theRewardExt.Find(reward_id);

            if (preward)
            {
                coin::give( puser, preward->coins, kPathSingleArena );
                end_rep.coins  =  preward->coins;
                local::write(local::access, end_rep);
            }

            return;
        }
        else
        {
            uint32 reward_id = bias::PacketRandomReward( puser, theGlobalExt.get<uint32>("singlearena_battle_win_packet_id") );
            CRewardData::SData *preward = theRewardExt.Find(reward_id);
            if ( preward )
            {
                coin::give( puser, preward->coins, kPathSingleArena );

                end_rep.coins  =  preward->coins;
                local::write(local::access, end_rep);
            }
        }


        //从自己的对手List匹配
        SSingleArenaOpponent* rank_opp = theSingleArenaDC.find_opp( puser->guid, target_id );
        if( rank_opp == NULL )
        {
            back::write( "singlearena.debug", "SendBattleReward  not find target SSingleArenaOpponent  from own guid:%u", puser->guid );
            return;
        }

        //从排行榜中匹配
        rank_opp = theSingleArenaDC.find_rank_by_targetid( target_id);
        if( rank_opp == NULL )
        {
            back::write( "singlearena.debug", "SendBattleReward  not find target SSingleArenaOpponent  from rank guid:%u", puser->guid );
            return;
        }


        uint32 m_rank   = info->cur_rank;     //自己当前名次
        uint32 h_rank   = rank_opp->rank;     //对手当前名次
        uint32 max_rank = info->max_rank;     //自己历史最高名次

        uint32 m_rank_end = m_rank;         //自己最终名次

        bool is_first = false;              //如果是第一次打，上前的名次为0
        //首胜不在处理
        if ( m_rank == 0 )
        {
            back::write( "singlearena.debug", "SendBattleReward  find the first win %u", puser->guid );
            return;
        }


        m_rank_end = m_rank > h_rank ? h_rank : m_rank;

        if ( m_rank_end < max_rank )
        {
            uint32 coin_value = theSingleArenaBattleRewardExt.GetReward( max_rank, m_rank_end );
            if ( coin_value != 0 )
            {
                S3UInt32 coin;
                coin.cate = kCoinGold;
                coin.val  = coin_value;

                PRSingleBattleReply rep;
                bccopy( rep, puser->ext );
                rep.win_flag    = win_flag;
                rep.coin        = coin;


                std::vector< S3UInt32 > list;
                list.push_back( coin );


                std::ostringstream detail;
                detail<<"恭喜你达到了历史最高排名"<< m_rank_end << ",原排名" << max_rank << ",系统奖励" << coin.val << "钻石，请注意查收！祝你在以后的战斗中连战连胜!";

                mail::send( kMailFlagSystem, puser->guid, "竞技场", "历史最高战绩", detail.str(), list, kPathSingleArena );
                rep.cur_rank = m_rank_end;
                rep.add_rank = is_first == true ? 0 :m_rank - m_rank_end;
                local::write(local::access, rep);
            }
        }

    }

    void    SendDayReward( SSingleArenaOpponent *opp )
    {
        if ( opp->target_id < REAL_TARGET_GUID )
            return;

        std::vector< S3UInt32 > list;
        theSingleArenaDayRewardExt.GetReward( opp->rank, list );

        uint32 reward_1 = 0, reward_2 = 0, reward_3 = 0;

        for( std::vector< S3UInt32 >::iterator iter = list.begin();
            iter != list.end();
            ++iter )
        {
            if( iter->cate == kCoinGold )
                reward_1 = iter->val;
            else if ( iter->cate == kCoinMedal )
                reward_2 = iter->val;
            else if ( iter->cate == kCoinMoney )
                reward_3 = iter->val;
        }
        std::ostringstream detail;
        detail<<"今日竞技场结算时你的排名为"<< opp->rank << ",系统奖励" << reward_1 << "钻石," << reward_2 << "勋章," << reward_3 << "金币,），请注意查收！祝你以后取得更好的成绩!";
        mail::send( kMailFlagSystem, opp->target_id, "竞技场", "竞技场每日结算", detail.str(), list, kPathSingleArena );
    }

    bool    IsOpenSingleArena( SUser* puser )
    {
        if ( building::GetCount( puser, kBuildingTypeSingleArena ) == 0 )
        {
            HandleErrCode(puser, kErrSingleArenaNotExist, 0);
            return false;
        }

        return true;
    }

    bool    CheckRank( SUser* puser, uint32 target_id, uint8 flag )
    {
        if( theSingleArenaDC.check_rank( puser->guid, target_id ) )
        {
            PRSingleArenaCheck rep;
            rep.flag = flag;
            bccopy( rep, puser->ext );
            local::write(local::access, rep);

            return true;
        }

        return false;
    }

    void    ReplyMyRank( SUser* puser )
    {
        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if( NULL == info )
            return;

        PRSingleArenaMyRank rep;
        rep.rank = info->cur_rank;
        bccopy( rep, puser->ext );
        local::write(local::access, rep);
    }

    void    TimeLimit( SUser* puser )
    {
        //清除每天增加的挑战次数
        var::set( puser, "singlearena_add_times", 0);

        //清除每天已挑战次数
        var::set( puser, "singlearena_cur_times", 0);

        SSingleArenaInfo *info = theSingleArenaDC.find_info( puser->guid );
        if( NULL == info )
            return;

        info->add_times = 0;
        info->cur_times = 0;

        PRSingleArenaInfo rep;
        bccopy( rep, puser->ext );
        rep.info    = *info;

        local::write(local::access, rep);
    }

    void    SaveYesterday( SUser *puser, bool fresh_fromation )
    {
        std::vector<SUserFormation> formation_list;
        formation::GetFormation( puser, kFormationTypeSingleArenaDef, formation_list );

        puser->data.formation_map[kFormationTypeYesterday] = formation_list;
        puser->data.soldier_map[kSoldierTypeYesterday] = puser->data.soldier_map[kSoldierTypeCommon];
        puser->data.fightextable_map[kAttrSoldierYesterday] = puser->data.fightextable_map[kAttrSoldier];
        puser->data.totem_map[kTotemPacketYesterday].totem_list = puser->data.totem_map[kTotemPacketNormal].totem_list;
        puser->data.totem_map[kTotemPacketYesterday].glyph_list = puser->data.totem_map[kTotemPacketNormal].glyph_list;
    }

    bool    GetFirstReward( SUser *puser )
    {
        SSingleArenaInfo* info    = theSingleArenaDC.find_info( puser->guid );
        if( info == NULL )
        {
            back::write( "singlearena.debug", "GetFirstReward info is null %u", puser->guid );
            return false;
        }

        if( info->max_rank == 0 )
        {


            info->cur_times = 1;
            uint32 now_time = server::local_time();

            now_time  =  now_time + theGlobalExt.get<uint32>("singlearena_cd_time_coin") * 60;
            var::set( puser, "singlearena_battle_cd", now_time );

            info->time_cd = now_time;

            info->max_rank = server::get<uint32>( "single_arena_real_count" ) + MAX_CREATE_OPPONENT + 1;
            server::set<uint32>( "single_arena_real_count", info->max_rank - MAX_CREATE_OPPONENT );
            info->cur_rank = info->max_rank;
            puser->data.other.single_arena_rank = info->max_rank;
            user::ReplyUserOther(puser);


            {
                SSingleArenaOpponent data;
                data.target_id   = puser->guid;
                data.name        = puser->data.simple.name;
                data.avatar      = puser->data.simple.avatar;
                data.team_level  = puser->data.simple.team_level;
                data.rank        = info->cur_rank;
                data.fight_value = fightextable::GetFightValue( puser, kFormationTypeSingleArenaDef);
                SaveDataToDB( data, kSingleArenaObjectDel );
                SaveDataToDB( data, kSingleArenaObjectAdd );
                theSingleArenaDC.set_rank_data( info->cur_rank, data );
                theSingleArenaDC.set_id_rank( puser->guid, info->cur_rank );
            }

            //胜利时获得的奖励
            uint32 reward_id = thePacketExt.RandomReward( theGlobalExt.get<uint32>("singlearena_battle_win_packet_id") );
            CRewardData::SData *preward = theRewardExt.Find(reward_id);
            if ( preward )
            {
                coin::give( puser, preward->coins, kPathSingleArena );

                PRSingleArenaBattleEnd  end_rep;
                end_rep.win_flag = kFightLeft;
                end_rep.coins  =  preward->coins;
                bccopy( end_rep, puser->ext );
                local::write(local::access, end_rep);
            }

            //首胜获得的奖励，通过邮件发放
            S3UInt32 coin;
            coin.cate = kCoinGold;
            coin.val  = theGlobalExt.get<uint32>("singlearena_battle_first_max_gold");
            std::vector< S3UInt32 > list;
            list.push_back( coin );

            std::ostringstream detail;
            detail<<"恭喜你达到了历史最高排名"<< info->max_rank << ",原排名 --"  << ",系统奖励" << coin.val << "钻石，请注意查收！祝你在以后的战斗中连战连胜!";
            mail::send( kMailFlagSystem, puser->guid, "竞技场", "历史最高战绩", detail.str(), list, kPathSingleArena );

            PRSingleBattleReply rep;
            rep.coin     = coin;
            rep.win_flag = kFightLeft;
            rep.cur_rank = info->cur_rank;
            rep.add_rank = 0;
            bccopy( rep, puser->ext );
            local::write(local::access, rep);

            return true;
        }

        back::write( "singlearena.debug", "GetFirstReward max_rank not equal 0 target_id:%u,gax_rank:%u", puser->guid, info->max_rank );
        return false;
    }

    void    ReplyRank( SUser* puser, uint32 index, uint32 count )
    {
        PRSingleArenaRank rep;
        bccopy( rep, puser->ext );

        theSingleArenaDC.list_rank( index, count, rep.list );

        local::write(local::access, rep);
    }

} // namespace singlearena

