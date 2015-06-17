#ifndef _GAMESVR_ACTIVITY_DC_H_
#define _GAMESVR_ACTIVITY_DC_H_

#include "common.h"
#include "proto/user.h"
#include "proto/activity.h"
#include "dc.h"

struct FindActivityRewardByGuid
{
    uint32 m_guid;

    FindActivityRewardByGuid(uint32 guid) : m_guid(guid) { }

    bool operator()(const SActivityReward &data)
    {
        return (data.guid == m_guid);
    }
};

struct FindActivityFactorByGuid
{
    uint32 m_guid;

    FindActivityFactorByGuid(uint32 guid) : m_guid(guid) { }

    bool operator()(const SActivityFactor &data)
    {
        return (data.guid == m_guid);
    }
};

struct FindActivityDataByGuid
{
    uint32 m_guid;

    FindActivityDataByGuid(uint32 guid) : m_guid(guid) { }

    bool operator()(const SActivityData &data)
    {
        return (data.guid == m_guid);
    }
};

class CActivityDC : public TDC< CActivity >
{
public:
    CActivityDC() : TDC< CActivity >( "activity" )
    {
    }

    ~CActivityDC()
    {
    }

    void clear_reward( void );
    void clear_factor( void );
    void clear_open( void );
    void clear_data( void );

    SActivityReward* find_reward( uint32 guid );
    //void del_reward( uint32 guid );
    void set_reward( SActivityReward &data );

    SActivityFactor* find_factor( uint32 guid );
    //void del_factor( uint32 guid );
    void set_factor( SActivityFactor &factor );

    SActivityData* find_data( uint32 guid );
    //void del_data( uint32 guid );
    void set_data( SActivityData &data );

    SActivityOpen* find_open_by_guid( uint32 guid );
    SActivityOpen* find_open_by_name( std::string& name );
    //void del_open( uint32 guid );
    void set_open( SActivityOpen &open);


    void ReplyActivityList( std::vector< SActivityOpen > &open_list, std::vector< SActivityData > &data_list, std::vector< SActivityFactor > &factor_list, std::vector< SActivityReward > &reward_list );

public:

    template< typename T >
        void EachOpenInfo( T call )
        {
            for ( std::map< uint32, SActivityOpen >::iterator iter = db().open_map.begin();
                iter != db().open_map.end();
                ++iter )
            {
                if ( !call( iter->second ) )
                    break;
            }
        }

    template< typename T >
        void EachOpenName( T call )
        {
            for ( std::map< std::string, uint32 >::iterator iter = db().open_name_map.begin();
                iter != db().open_name_map.end();
                ++iter )
            {
                if ( !call( iter->first ) )
                    break;
            }
        }
};

#define theActivityDC TSignleton< CActivityDC >::Ref()

#endif

