#ifndef _GAMESVR_SINGLEARENA_DC_H_
#define _GAMESVR_SINGLEARENA_DC_H_

#include "common.h"
#include "proto/user.h"
#include "proto/singlearena.h"
#include "dc.h"

class CSingleArenaDC : public TDC< CSingleArenaMap >
{
public:
    CSingleArenaDC() : TDC< CSingleArenaMap >( "singlearena" )
    {
    }

    ~CSingleArenaDC()
    {
    }


    SSingleArenaInfo*   find_info( uint32 target_id );
    void    del_info( uint32 target_id );
    void    set_info_data( uint32 target_id, SSingleArenaInfo &info );

    SSingleArenaOpponent*   find_rank( uint32 rank );
    void    del_rank( uint32 rank );
    void    set_rank_data( uint32 rank, SSingleArenaOpponent &opp );


    SSingleArenaOpponent*   find_rank_by_targetid( uint32 target_id );
    uint32  get_rank_data_count();


    SSingleArenaOpponent*   find_show( uint32 rank );
    void    set_show_data( uint32 rank, SSingleArenaOpponent &opp );
    uint32  get_show_data_count();

    void    find_formation( uint32 guid, uint32 target_id, std::vector<SUserFormation> &formation_list );

    void    list_rank( uint32 index, uint32 count, std::vector<SSingleArenaOpponent> &list );

    SSingleArenaOpponent*   find_opp( uint32 guid, uint32 target_id );

    void    set_id_rank( uint32 target_id, uint32 rank );
    uint32  get_rank_id( uint32 target_id );

    uint32  get_guid();
    void    InitGuid();

    void    UpdateLevel( uint32 role_id, uint32 level );
    void    UpdateAvatar( uint32 role_id, uint16 avatar );
    void    UpdateName( uint32 role_id, std::string name );
    void    UpdateFightValue( SUser* puser);

    //初始化加载标志
    void    InitLoadLog();
    //检测竞技场数据是否加载成功
    bool    CheckLoadLog();
    //设置竞技场数据加载标志
    void    SetLoadLog();

    //判断对手的排名是否有变动
    bool    check_rank( uint32 guid, uint32 target_id );

};
#define theSingleArenaDC TSignleton< CSingleArenaDC >::Ref()

#endif

