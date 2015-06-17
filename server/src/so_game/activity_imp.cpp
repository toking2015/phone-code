#include "activity_imp.h"
#include "activity_event.h"
#include "activity_dc.h"
#include "var_imp.h"
#include "coin_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "server.h"
#include "misc.h"
#include "local.h"
#include "settings.h"
#include "proto/constant.h"

namespace activity
{

    void    LoadReward( std::vector< SActivityReward > &list )
    {
        for( std::vector< SActivityReward >::iterator iter = list.begin();
            iter != list.end();
            ++ iter )
        {
            SActivityReward  &reward = *iter;

            if( CheckReward( reward ) == false )
            {
                LOG_ERROR("check SActivityReward is error guid=%u",reward.guid);
                continue;
            }

            theActivityDC.set_reward( reward );
        }
    }

    void    LoadFactor( std::vector< SActivityFactor > &list )
    {
        for( std::vector< SActivityFactor >::iterator iter = list.begin();
            iter != list.end();
            ++ iter )
        {
            SActivityFactor &factor = *iter;

            if( CheckFactor( factor ) == false )
            {
                LOG_ERROR("check SActivityFactor is error guid=%u",factor.guid);
                continue;
            }

            theActivityDC.set_factor( factor );
        }
    }

    void    LoadOpen( std::vector< SActivityOpen > &list )
    {
        for( std::vector< SActivityOpen >::iterator iter = list.begin();
            iter != list.end();
            ++ iter )
        {
            SActivityOpen  &open = *iter;

            if( CheckOpen( open ) == false )
            {
                LOG_ERROR("check SActivityOpen is error guid=%u",open.guid);
                continue;
            }

            theActivityDC.set_open( open );
        }
    }

    void    LoadData( std::vector< SActivityData > &list )
    {
        for( std::vector< SActivityData >::iterator iter = list.begin();
            iter != list.end();
            ++ iter )
        {
            SActivityData &data = *iter;

            if( CheckData( data ) == false )
            {
                LOG_ERROR("check SActivityData is error guid=%u",data.guid);
                continue;
            }

            theActivityDC.set_data( data );
        }
    }

    void    ReplyActivityList( SUser* user )
    {
        PRActivityList rep;
        bccopy( rep, user->ext );

        theActivityDC.ReplyActivityList( rep.activity_open_list, rep.activity_data_list, rep.activity_factor_list, rep.activity_reward_list );

        local::write( local::access, rep );

    }

    bool    CheckReward( SActivityReward &reward )
    {
        std::string g_group = settings::json()[ "group" ].asString();
        if( reward.group != "" && g_group != reward.group )
            return false;

        S3UInt32 coin;
        for( std::vector< std::string >::iterator iter = reward.value_list.begin();
            iter != reward.value_list.end();
            ++iter )
        {
            //奖励值字段错误
            if ( 3 != sscanf( (*iter).c_str(), "%u%%%u%%%u", &coin.cate, &coin.objid, &coin.val ) )
            {
                return false;
            }
        }

        return true;
    }

    bool    CheckFactor( SActivityFactor &factor )
    {
        std::string g_group = settings::json()[ "group" ].asString();
        if( factor.group != "" && g_group != factor.group )
            return false;

        if( factor.type >= kActivityFactorTypeMax )
        {
            //条件功能未实现
            return false;
        }

        return true;
    }

    bool    CheckOpen( SActivityOpen &open )
    {
        /**
          SActivityData* p_data = theActivityDC.find_data( open.data_id );
          if( p_data == NULL )
          {
        //没有些活动实体
        return false;
        }
         **/

        std::string g_group = settings::json()[ "group" ].asString();
        if( open.group != "" && g_group != open.group )
            return false;

        SActivityOpen* p_open = theActivityDC.find_open_by_name( open.name );
        if( p_open && p_open->data_id != open.data_id )
        {
            //同一name的open，data_id 必须要一致
            //以第一次加载进来的open为参照物
            return false;
        }

        if ( open.type == kActivityTimeTypeBound )
        {
            uint32 first_time   = activity_open_time_to_uint( open.first_time.c_str() );
            uint32 second_time  = activity_open_time_to_uint( open.second_time.c_str() );

            //时间格式不对
            if( first_time == 0 || second_time == 0 )
                return false;
        }

        return true;
    }

    bool    CheckData( SActivityData &data )
    {
        std::string g_group = settings::json()[ "group" ].asString();
        if( data.group != "" && g_group != data.group )
            return false;

        if( data.type >= kActivityDataTypeMax )
        {
            //活动类型未实现
            return false;
        }

        S2UInt32  temp;
        for( std::vector< std::string >::iterator iter = data.value_list.begin();
            iter != data.value_list.end();
            ++iter )
        {

            //条件奖励值字段规则错误
            if ( 2 != sscanf( (*iter).c_str(), "%u%%%u", &temp.first, &temp.second ) )
            {
                return false;
            }
        }

        return true;
    }

    void split(std::string& s, std::string& delim,std::vector< std::string >& list)
    {
        size_t last = 0;
        size_t index=s.find_first_of(delim,last);
        while (index!=std::string::npos)
        {
            list.push_back(s.substr(last,index-last));
            last=index+1;
            index=s.find_first_of(delim,last);
        }
        if (index-last>0)
        {
            list.push_back(s.substr(last,index-last));
        }
    }

    /**
      void    OpenSet( uint32 guid, uint32 type, SActivityOpen &open )
      {
      switch( type )
      {
      case kObjectDel:
      {
    //theActivityDC.del_open( guid );
    }
    break;
    case kObjectAdd:
    {
    //合法性检测
    if( CheckOpen( open ) == false )
    return;


    PQActivityOpenSet rep;
    rep.guid =  0;
    rep.type = type;
    rep.open = open;
    local::write(local::realdb, rep);
    }
    break;
    }
    }

    void    DataSet( uint32 guid, uint32 type, SActivityData &data )
    {
    switch( type )
    {
    case kObjectDel:
    {
    //theActivityDC.del_data( guid );
    }
    break;
    case kObjectAdd:
    {
    //合法性检测
    if( CheckData( data ) == false )
    return;


    PQActivityDataSet rep;
    rep.guid =  0;
    rep.type = type;
    rep.data = data;
    local::write(local::realdb, rep);
    }
    break;
    }
    }
     **/

    std::string time_key( const std::string& name )
    {
        return std::string( "activity_" ) + name + std::string( "_reset_time" );
    }

    struct activity_process
    {
        SUser* user;
        uint32 local_time;

        activity_process( SUser* u, uint32 t ) : user(u), local_time(t){}

        bool operator()( std::string open_name )
        {
            //活动名称
            std::string& activity_name = open_name;

            SActivityOpen* p_open = theActivityDC.find_open_by_name( open_name );
            if( p_open == NULL )
                return true;

            //取出活动基本信息
            SActivityData* p_data = theActivityDC.find_data( p_open->data_id );

            if ( p_data == NULL )
                return true;

            //拼接活动键名
            std::string reset_time_key = time_key( activity_name );

            //取出用户活动开启时间
            uint32 reset_time_value = var::get( user, reset_time_key );

            std::pair< uint32, uint32 > bound;

            //非活动时间
            bound = GetActivityBound( user, activity_name, local_time );
            if ( bound.first == 0xFFFFFFFF || bound.second == 0 )
            {
                //活动关闭后未清理过的用户处理
                if ( reset_time_value != 0 )
                {
                    //活动关闭事件
                    event::dispatch( SEventActivityUserClose( user, kPathActivityClose, activity_name ) );

                    //清除活动周期
                    var::delOnActivity( user, reset_time_key );

                    //清除数据
                    ClearVar( user, activity_name );
                }
                return true;
            }

            //从未参与活动
            if ( reset_time_value == 0 )
            {
                var::setOnActivity( user, reset_time_key, local_time );

                //活动开启事件
                event::dispatch( SEventActivityUserOpen( user, kPathActivityOpen, activity_name ) );
                return true;
            }

            //上次 reset 时间截不在活动时间范围内
            if ( bound != GetActivityBound( user, activity_name, reset_time_value ) )
            {
                //活动关闭事件
                event::dispatch( SEventActivityUserClose( user, kPathActivityClose, activity_name ) );

                //清除数据
                ClearVar( user, activity_name );

                var::setOnActivity( user, reset_time_key, local_time );

                //活动开启事件
                event::dispatch( SEventActivityUserOpen( user, kPathActivityOpen, activity_name ) );

                //活动开启事件
                return true;
            }

            //活动刷新周期处理
            if ( p_data->cycle > 0 )
            {
                uint32 day = ( local_time - bound.first ) / 86400;
                uint32 current_cycle_time_limit = ( day / p_data->cycle ) * p_data->cycle * 86400 + bound.first;

                //达到刷新周期
                if ( reset_time_value < current_cycle_time_limit ||
                    reset_time_value >= current_cycle_time_limit + p_data->cycle * 86400 )
                {
                    //活动关闭事件
                    event::dispatch( SEventActivityUserClose( user, kPathActivityClose, activity_name ) );

                    //清除数据
                    ClearVar( user, activity_name );

                    var::setOnActivity( user, reset_time_key, local_time );

                    //活动开启事件
                    event::dispatch( SEventActivityUserOpen( user, kPathActivityOpen, activity_name ) );
                }
            }


            return true;
        }
    };

    void ClearVar( SUser* user, std::string & activity_name )
    {
        //清除首充数据
        var::delOnActivity( user, "activity_" + activity_name + "first_pay");
        //清除累积充值数据
        var::delOnActivity( user, "activity_" + activity_name + "add_pay");
        //清除活动期间累积消费钻石
        var::delOnActivity( user, "activity_" + activity_name + "time_tatal_gold" );
        //清除活动期间累积消费金币
        var::delOnActivity( user, "activity_" + activity_name + "time_tatal_money" );
        //清除活动期间进行钻石抽卡
        var::delOnActivity( user, "activity_" + activity_name + "time_tatal_bet_gold" );
        //清除活动期间进行金币抽卡
        var::delOnActivity( user, "activity_" + activity_name + "time_tatal_bet_money" );

        //清除领取奖励标志
        for(uint32 i=0; i<10;++i)
        {
            std::string buff = strprintf( "activity_%s_present_%d", activity_name.c_str(),i);
            var::delOnActivity( user, buff);
        }
    }

    void Process( SUser* user )
    {
        theActivityDC.EachOpenName( activity_process( user, server::local_time() ) );
    }

    /**
      void SetPersonalBound( SUser* user, std::string name, uint32 begin_time, uint32 end_time )
      {
      CActivityData::SData* pActivityInfo = theActivityExt.Find( name );
      if ( pActivityInfo == NULL )
      return;

      var::set( user, name + "_begin", begin_time );
      var::set( user, name + "_end", end_time );

      process( user );
      }

      activity::SBound GetPersonalBound( SUser* user, std::string name )
      {
      std::pair< uint32, uint32 > bound;
      CActivityData::SData* pActivityInfo = theActivityExt.Find( name );
      if ( pActivityInfo == NULL )
      return bound;

      bound.first = var::get( user, name + "_begin" );
      bound.second = var::get( user, name + "_end" );

      return bound;
      }
     **/

    uint32 activity_open_time_to_uint( const char* timestr )
    {
        struct tm t_tm = {0};
        if ( strptime( timestr, "%Y-%m-%d-%H-%M", &t_tm ) != NULL )
        {
            //LOG_DEBUG("===%s,%d-%d-%d-%d-%d",timestr,t_tm.tm_year+1900,t_tm.tm_mon+1,t_tm.tm_mday,t_tm.tm_hour,t_tm.tm_min);
            return (uint32)mktime( &t_tm );
        }

        return 0;
    }

    struct activity_bound_each_open_unite
    {
        SUser* user;
        std::list< std::pair< uint32, uint32 > >& time_list;
        SActivityOpen* p_open;

        activity_bound_each_open_unite( SUser* u, std::list< std::pair< uint32, uint32 > >& l, SActivityOpen* p )
            : user(u), time_list(l), p_open(p){}

        bool operator()( SActivityOpen data )
        {
            if ( data.name != p_open->name )
                return true;

            uint32 first_time  = 0;
            uint32 second_time = 0;
            switch ( data.type )
            {
            case kActivityTimeTypeBound:
                first_time  = activity_open_time_to_uint( data.first_time.c_str() );
                second_time = activity_open_time_to_uint( data.second_time.c_str() );
                break;
            default:
                first_time  = (uint32)atoi( data.first_time.c_str() );
                second_time = (uint32)atoi( data.second_time.c_str() );
                break;
            }

            uint32 start_time = 0, end_time = 0;

            switch ( data.type )
            {
            case kActivityTimeTypeBound:
                {
                    //固定开始时间
                    start_time  = first_time;
                    end_time    = second_time;
                }
                break;

            case kActivityTimeTypeOpen:
                {
                    //开服开始时间
                    start_time  = server::local_6_time( server::get<uint32>( "open_time" ) ) + first_time * 86400;
                    end_time = start_time + second_time * 86400;
                }
                break;

            case kActivityTimeTypeUnite:
                {
                    //合服开始时间
                    start_time  = server::local_6_time( server::get<uint32>( "unite_time" ) ) + first_time * 86400;
                    end_time = start_time + second_time * 86400;
                }
                break;
            case kActivityTimeTypeLevel:
                {
                    //个人等级
                    if ( user != NULL )
                    {
                        if( user->data.simple.team_level >= first_time && user->data.simple.team_level <= second_time )
                        {
                            start_time = 1;
                            end_time   = 0xFFFFFFFF;
                        }
                    }
                }
                break;
            default:
                return true;
            }

            if ( start_time == 0 || start_time >= end_time )
                return true;

            //开始结束时间对齐
            /**
            if ( data.type == kActivityTimeTypeOpen || data.type == kActivityTimeTypeUnite )
            {
                time_t t_start_time = start_time;
                time_t t_end_time = end_time;
                struct tm t_tm = {0};

                localtime_r( &t_start_time, &t_tm );
                if ( t_tm.tm_hour != 0 || t_tm.tm_min != 0 || t_tm.tm_sec != 0 )
                    start_time += 0 - ( t_tm.tm_hour * 3600 + t_tm.tm_min * 60 + t_tm.tm_sec );

                localtime_r( &t_end_time, &t_tm );
                if ( t_tm.tm_hour != 0 || t_tm.tm_min != 0 || t_tm.tm_sec != 0 )
                    end_time += 0 - ( t_tm.tm_hour * 3600 + t_tm.tm_min * 60 + t_tm.tm_sec );
            }
            **/

            //合并时间段
            bool unite = false;
            for ( std::list< std::pair< uint32, uint32 > >::iterator i = time_list.begin();
                i != time_list.end();
                ++i )
            {
                uint32 fact_length = ( i->second - i->first ) + ( end_time - start_time );
                uint32 wrap_length = std::max( i->second, end_time ) - std::min( i->first, start_time );

                if ( wrap_length < fact_length )
                {
                    i->first = std::min( i->first, start_time );
                    i->second = std::max( i->second, end_time );

                    unite = true;
                    break;
                }
            }

            //将未合并的时间段压入列表
            if ( !unite )
                time_list.push_back( std::make_pair( start_time, end_time ) );


            return true;
        }
    };


    struct activity_bound_each_open_mutex
    {
        SUser* user;
        std::string name;
        std::list< std::pair< uint32, uint32 > >& time_list;
        std::pair< uint32, uint32 >& bound;

        activity_bound_each_open_mutex( SUser* u, std::string& n , std::list< std::pair< uint32, uint32 > >& l, std::pair< uint32, uint32 >& b )
            : user(u), name(n), time_list(l), bound(b){}

        bool operator()( SActivityOpen data )
        {
            if ( data.name != name )
                return true;

            uint32 start_time = 0, end_time = 0;

            uint32 first_time  = 0;
            uint32 second_time = 0;
            switch ( data.type )
            {
            case kActivityTimeTypeBound:
                first_time  = activity_open_time_to_uint( data.first_time.c_str() );
                second_time = activity_open_time_to_uint( data.second_time.c_str() );
                break;
            default:
                first_time  = (uint32)atoi( data.first_time.c_str() );
                second_time = (uint32)atoi( data.second_time.c_str() );
                break;
            }

            switch ( data.type )
            {
            case kActivityTimeTypeLimitOpen:
                {
                    //开服互斥开始时间
                    start_time  = server::local_6_time( server::get<uint32>( "open_time" ) ) + first_time * 86400;
                }
                break;

            case kActivityTimeTypeLimitUnite:
                {
                    //合服互斥开始时间
                    start_time  = server::local_6_time( server::get<uint32>( "unite_time" ) ) + first_time * 86400;
                }
                break;

            default:
                return true;
            }

            //结束互斥时间
            end_time = start_time + second_time * 86400;

            /**
            //开始结束时间对齐
            time_t t_start_time = start_time;
            time_t t_end_time = end_time;
            struct tm t_tm = {0};

            localtime_r( &t_start_time, &t_tm );
            if ( t_tm.tm_hour != 0 || t_tm.tm_min != 0 || t_tm.tm_sec != 0 )
                start_time += 0 - ( t_tm.tm_hour * 3600 + t_tm.tm_min * 60 + t_tm.tm_sec );

            localtime_r( &t_end_time, &t_tm );
            if ( t_tm.tm_hour != 0 || t_tm.tm_min != 0 || t_tm.tm_sec != 0 )
                end_time += 86400 - ( t_tm.tm_hour * 3600 + t_tm.tm_min * 60 + t_tm.tm_sec );
                **/

            //互斥时间重叠计算
            uint32 fact_length = ( bound.second - bound.first ) + ( end_time - start_time );
            uint32 wrap_length = std::max( bound.second, end_time ) - std::min( bound.first, start_time );

            //存在重叠互斥
            if ( wrap_length < fact_length )
            {
                bound.first = 0xFFFFFFFF;
                bound.second = 0;
                return false;
            }

            return true;
        }
    };

    activity::SBound GetActivityBound( SUser* user, std::string& name, uint32 time )
    {
        std::pair< uint32, uint32 > bound( 0xFFFFFFFF, 0 );

        SActivityOpen* p_open = theActivityDC.find_open_by_name( name );
        if ( p_open == NULL )
            return bound;

        //活动开启时间段计算
        std::list< std::pair< uint32, uint32 > > time_list;
        theActivityDC.EachOpenInfo( activity_bound_each_open_unite( user, time_list, p_open ) );

        //捡索有效时间段
        for ( std::list< std::pair< uint32, uint32 > >::iterator i = time_list.begin();
            i != time_list.end();
            ++i )
        {
            if ( time >= i->first && time < i->second )
            {
                bound = *i;
                break;
            }
        }

        //活动有效时间不存在
        if ( bound.first == 0xFFFFFFFF || bound.second == 0 )
            return bound;

        //活动互斥处理
        theActivityDC.EachOpenInfo( activity_bound_each_open_mutex( user, name, time_list, bound ) );

        return bound;
    }

    struct activity_replay_list
    {
        SUser* user;
        std::vector< SActivityInfo >& list;
        uint32 local_time;

        activity_replay_list( SUser* u, std::vector< SActivityInfo >& l, uint32 t ) : user(u), list(l), local_time(t){}

        bool operator()( std::string open_name )
        {
            std::string& activity_name =open_name;

            std::pair< uint32, uint32 > bound = GetActivityBound( user, activity_name, local_time );
            if ( bound.first != 0xFFFFFFFF && bound.second != 0 )
            {
                SActivityInfo info;

                info.name = activity_name;
                info.start_time = bound.first;
                info.end_time = bound.second;

                list.push_back( info );
            }

            return true;
        }
    };

    void ReplyActivityInfoList( SUser* user )
    {
        PRActivityInfoList rep;
        bccopy( rep, user->ext );

        theActivityDC.EachOpenName( activity_replay_list( user, rep.list, server::local_time() ) );

        local::write( local::access, rep );
    }

    bool IsActivityOpen( SUser* user, std::string& name )
    {
        std::pair< uint32, uint32 > bound = GetActivityBound( user, name, server::local_time() );
        if ( bound.first == 0xFFFFFFFF || bound.second == 0 )
            return false;

        return true;
    }

    void TakeReward( SUser* user, uint32  open_guid, uint32 index )
    {
        SActivityOpen* p_open = theActivityDC.find_open_by_guid( open_guid );

        if( IsActivityOpen( user, p_open->name ) == false )
            return;

        if( CheckActivityData( user, p_open->guid, index ) == false )
            return;

        if( SendReward( user, p_open->data_id, index ) )
        {
            std::string buff = strprintf( "activity_%s_present_%d", p_open->name.c_str(),index);
            var::setOnActivity( user, buff, 1);

            PRActivityTakeReward rep;
            rep.open_guid = open_guid;
            rep.index     = index;
            bccopy( rep, user->ext );
            local::write( local::access, rep );
        }
    }

    bool CheckActivityData( SUser* user, uint32 open_guid, uint32 index )
    {

        SActivityOpen* p_open = theActivityDC.find_open_by_guid( open_guid );

        if( p_open == NULL )
            return false;

        SActivityData* p_data = theActivityDC.find_data( p_open->data_id );

        if( p_data == NULL )
            return false;

        std::string& activity_name = p_open->name;

        uint32 var_value = 0;

        //判断是否已领取
        std::string buff = strprintf( "activity_%s_present_%d", activity_name.c_str(),index);
        var_value = var::get( user, buff);
        if( var_value > 0 )
            return false;


        S2UInt32  temp;
        SActivityFactor* p_factor = NULL;

        //没有这个条件
        if( (uint32)p_data->value_list.size() < index )
            return false;

        std::string if_string = p_data->value_list[index];

        //for( std::vector< std::string >::iterator iter = p_data->value_list.begin();
        //    iter != p_data->value_list.end();
        //    ++iter )
        //{
        if ( 2 == sscanf(  if_string.c_str(), "%u%%%u", &temp.first, &temp.second ) )
        {
            p_factor = theActivityDC.find_factor( temp.first );

            if( p_factor )
            {
                switch( p_factor->type )
                {
                case kActivityFactorTypeFirstPay:
                    {
                        var_value = var::get( user, "activity_" + activity_name + "first_pay");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeAddPay:
                    {
                        var_value = var::get( user, "activity_" + activity_name + "add_pay");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeSerialLogin:
                    {
                        var_value = var::get( user, "login_continuous_day");
                        if( p_factor->value > var_value )
                            return false;
                    }
                case kActivityFactorTypeLevel:
                    {
                        if( p_factor->value > user->data.simple.team_level )
                            return false;
                    }
                    break;
                case kActivityFactorTypeGetSoldier:
                    {
                        if( p_factor->value > soldier::GetSoldierCount( user ) )
                            return false;
                    }
                    break;
                case kActivityFactorTypeUpSoldier:
                    {
                        if( p_factor->value > soldier::GetSoldierCountByQuality( user, p_factor->value1 ) )
                            return false;
                    }
                    break;
                case kActivityFactorTypeGetTotem:
                    {
                        if( p_factor->value > totem::GetTotemLevelCount( user, 0 ) )
                            return false;
                    }
                    break;
                case kActivityFactorTypeMaxStartTotem:
                    {
                        if( p_factor->value >totem::GetTotemTotalLevel( user ) )
                            return false;
                    }
                    break;
                case kActivityFactorTypePassTomb:
                    {
                        if( p_factor->value > user->data.tomb_info.win_count )
                            return false;
                    }
                    break;
                case kActivityFactorTypeVipLevel:
                    {
                        if( p_factor->value > user->data.simple.vip_level )
                            return false;
                    }
                    break;
                case kActivityFactorTypeTimeTatalGold:
                    {
                        var_value = var::get( user, "activity_" + activity_name + "time_tatal_gold");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeDayTatalGold:
                    {
                        var_value = var::get( user, "day_cost_gold");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeTimeTatalMoney:
                    {
                        var_value = var::get( user, "activity_" + activity_name + "time_tatal_money");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeDayTatalMoney:
                    {
                        var_value = var::get( user, "day_cost_money");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeTimeTatalBetGold:
                    {
                        var_value = var::get( user, "activity_" + activity_name + "time_tatal_bet_gold");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeDayTatalBetGold:
                    {
                        var_value = var::get( user, "day_bet_gold");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeTimeTatalBetMoney:
                    {
                        var_value = var::get( user, "activity_" + activity_name + "time_tatal_bet_money");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeDayTatalBetMoney:
                    {
                        var_value = var::get( user, "day_bet_money");
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                case kActivityFactorTypeDayTimesPayTimesGold:
                    {
                        std::string buff = strprintf( "activity_day_times_pay_times_gold_%d", p_factor->value1);
                        var_value = var::get( user, buff);
                        if( p_factor->value > var_value )
                            return false;
                    }
                    break;
                default:
                    return false;
                }
            }
        }
        //}


        return true;
    }

    bool SendReward( SUser* user, uint32 data_guid, uint32 index )
    {
        SActivityData* p_data = theActivityDC.find_data( data_guid );

        if( p_data == NULL )
            return false;

        S2UInt32  temp;
        S3UInt32  coin;
        std::vector< S3UInt32  > coin_list;
        SActivityReward* p_reward = NULL;

        if( p_data->value_list.size() < index )
            return false;

        std::string if_string = p_data->value_list[index];

        if ( 2 == sscanf( if_string.c_str(), "%u%%%u", &temp.first, &temp.second ) )
        {
            p_reward = theActivityDC.find_reward( temp.second );
            if( p_reward )
            {
                for( std::vector< std::string >::iterator i_iter = p_reward->value_list.begin();
                    i_iter != p_reward->value_list.end();
                    ++i_iter )
                {
                    if ( 3 == sscanf( (*i_iter).c_str(), "%u%%%u%%%u", &coin.cate, &coin.objid, &coin.val ) )
                    {
                        coin_list.push_back( coin );
                    }
                }

            }
        }

        if( !coin_list.empty() )
            coin::give( user, coin_list, kPathActivityReward );

        return true;
    }

    struct activity_cheak
    {
        SUser* user;
        uint32 value;
        uint32 type;

        activity_cheak( SUser* u, uint32 v, const uint32 t ) : user(u), value(v), type(t){}

        bool operator()( std::string open_name )
        {
            //活动名称
            std::string& activity_name = open_name;

            SActivityOpen* p_open = theActivityDC.find_open_by_name( open_name );
            if( p_open == NULL )
                return true;


            if( IsActivityOpen( user, p_open->name ) == false )
                return true;

            //取出活动基本信息
            SActivityData* p_data = theActivityDC.find_data( p_open->data_id );

            if ( p_data == NULL )
                return true;

            SActivityFactor* p_factor = NULL;
            S2UInt32 temp;
            uint32  var_value = 0;
            std::map<uint32,uint32> check_map;
            for( std::vector< std::string >::iterator iter = p_data->value_list.begin();
                iter != p_data->value_list.end();
                ++iter )
            {

                if ( 2 == sscanf( (*iter).c_str(), "%u%%%u", &temp.first, &temp.second ) )
                {
                    p_factor = theActivityDC.find_factor( temp.first );

                    if( p_factor && p_factor->type == type )
                    {
                        if( check_map.find( type ) != check_map.end() )
                            continue;

                        check_map[type] = 1;

                        switch( type )
                        {
                        case kActivityFactorTypeFirstPay:
                            {
                                var_value = var::get( user, "activity_" + activity_name + "first_pay");
                                var::setOnActivity( user, "activity_" + activity_name + "first_pay", var_value + value );
                            }
                            break;
                        case kActivityFactorTypeAddPay:
                            {
                                var_value = var::get( user, "activity_" + activity_name + "add_pay");
                                var::setOnActivity( user, "activity_" + activity_name + "add_pay", var_value + value );
                            }
                            break;
                        case kActivityFactorTypeTimeTatalGold:
                            {
                                var_value = var::get( user, "activity_" + activity_name + "time_tatal_gold");
                                var::setOnActivity( user, "activity_" + activity_name + "time_tatal_gold", var_value + value );
                            }
                            break;
                        case kActivityFactorTypeTimeTatalMoney:
                            {
                                var_value = var::get( user, "activity_" + activity_name + "time_tatal_money");
                                var::setOnActivity( user, "activity_" + activity_name + "time_tatal_money", var_value + value );
                            }
                            break;
                        case kActivityFactorTypeTimeTatalBetGold:
                            {
                                var_value = var::get( user, "activity_" + activity_name + "time_tatal_bet_gold");
                                var::setOnActivity( user, "activity_" + activity_name + "time_tatal_bet_gold", var_value + value );
                            }
                            break;
                        case kActivityFactorTypeTimeTatalBetMoney:
                            {
                                var_value = var::get( user, "activity_" + activity_name + "time_tatal_bet_money");
                                var::setOnActivity( user, "activity_" + activity_name + "time_tatal_bet_money", var_value + value );
                            }
                            break;
                        default:
                            break;
                        }
                    }
                }

            }
            return true;
        }
    };

    void    ActivityCheak( SUser* user, uint32 &value, const uint32 type )
    {
        theActivityDC.EachOpenName( activity_cheak( user, value, type ) );
    }

} // namespace activity
