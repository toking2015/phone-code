#ifndef _IMMORTAL_SO_GAME_RAnk_IMP_H_
#define _IMMORTAL_SO_GAME_RANK_IMP_H_

#include "common.h"
#include "proto/rank.h"
#include "proto/user.h"

namespace rank
{
    //排序函数
    typedef bool(*FRankCompare)( const SRankInfo&, const SRankInfo& );

    //默认升序
    bool rank_compare_asc( const SRankInfo& l, const SRankInfo& r );

    //默认降序
    bool rank_compare_desc( const SRankInfo& l, const SRankInfo& r );

    //first降second升
    bool rank_compare_market( const SRankInfo& l, const SRankInfo& r );

    //获取排行榜对比函数
    std::map< uint32, FRankCompare >& rank_compare_map(void);

    //注册排行榜
    void Register( uint32 rank_type, FRankCompare compare );

    //清空排行榜数据
    void ClearData( uint32 rank_type, uint32 attr );

    //加载记录排行榜数据
    void LoadData( uint32 rank_type, std::vector< SRankData >& rank_list, uint32 attr );

    //设置实时排行榜数据
    void SetData( uint32 rank_type, SRankData& data );

    //实时删除排行榜数据
    void DelData( uint32 rank_type, uint32 id );

    //查找排行榜位置
    int32 FindIndex( uint32 rank_type, uint32 id, uint32 attr, uint32 limit );

    //取得排行榜总条数
    uint32 GetCount( uint32 rank_type, uint32 attr, uint32 limit );

    //根据 index 往下填充 count 数量的 id 到 rank_list, 并返回排行榜总条数
    uint32 GetRank( uint32 rank_type, uint32 index, uint32 count, uint32 attr, uint32 limit, std::vector< SRankData >& rank_list );

    //根据 index 获得SRankData
    void GetData( uint32 rank_type, uint32 index, uint32 attr, uint32 limit, SRankData& data );

    //创建排行榜记录点
    void CopyRank( uint32 rank_type, uint32 day = 0 );

    //根据排行榜类型获取排行榜数据
    std::map< uint32, CRank >& switch_rank_map( uint32 attr );

//private:
    //同步记录排行榜到 realdb
    void sync_copy_rank( uint32 rank_type );

    //开启定时排行榜刷新规则
    void start_rank_copy_rule( uint32 rank_type );

    //恢复丢失的记录排行榜
    void resume_rank_copy( uint32 rank_type );


    //初始化kRankAttrReal中SRankInfo.index
    void InitCopyIndex( uint32 rank_type );

    ////////////////////////
    void UpdateSingleArena( uint32 target_id, uint16 avatar, std::string& name, uint32 level,  uint32 first );
    void QuerySingleArena( uint32 target_id, uint32 first, uint32 second, std::vector<uint32> &list );
    void UpdateSoldier( SUser* puser );
    void UpdateTotem( SUser* puser );
    void UpdateCopy( SUser* puser );
    void UpdateEquip( SUser* puser );
    void UpdateMarket( SUser* puser );
    void UpdateTeamLevel( SUser* puser );
    void UpdateTemple( SUser* puser );
    bool InitUpdateData( SUser* puser, SRankData& data );

} // namespace rank

#endif

