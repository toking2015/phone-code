#ifndef _CSingleArenaMap_H_
#define _CSingleArenaMap_H_

#include <weedong/core/seq/seq.h>
#include <proto/singlearena/SSingleArenaInfo.h>
#include <proto/singlearena/SSingleArenaOpponent.h>

/*============================数据中心========================*/
class CSingleArenaMap : public wd::CSeq
{
public:
    std::map< uint32, SSingleArenaInfo > singlearena_info_map;    //玩家信息
    std::map< uint32, SSingleArenaOpponent > singlearena_rank_map;    //排行榜信息
    std::map< uint32, SSingleArenaOpponent > singlearena_show_map;    //用来显示的排行榜信息<暂定前50名>
    std::map< uint32, uint32 > id_rank_map;    //id 与排名 对应表
    uint32 target_guid;    //假人的guid递增
    uint32 load_log;    //从DB加载数据标志,2 加载完成

    CSingleArenaMap() : target_guid(0), load_log(0)
    {
    }

    virtual ~CSingleArenaMap()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CSingleArenaMap(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType eType, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( singlearena_info_map, eType, stream, uiSize )
            && TFVarTypeProcess( singlearena_rank_map, eType, stream, uiSize )
            && TFVarTypeProcess( singlearena_show_map, eType, stream, uiSize )
            && TFVarTypeProcess( id_rank_map, eType, stream, uiSize )
            && TFVarTypeProcess( target_guid, eType, stream, uiSize )
            && TFVarTypeProcess( load_log, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CSingleArenaMap";
    }
};

#endif
