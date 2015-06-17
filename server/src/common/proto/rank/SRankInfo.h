#ifndef _SRankInfo_H_
#define _SRankInfo_H_

#include <weedong/core/seq/seq.h>
/*用户排行榜基本信息*/
class SRankInfo : public wd::CSeq
{
public:
    uint32 id;    //用户id, 军团id
    uint16 avatar;    //头像
    std::string name;    //名字
    uint32 team_level;    //战队等级
    uint32 limit;    //分阶
    uint32 first;    //排行值1
    uint32 second;    //排行值2
    uint32 index;    //记录排行榜的名次

    SRankInfo() : id(0), avatar(0), team_level(0), limit(0), first(0), second(0), index(0)
    {
    }

    virtual ~SRankInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SRankInfo(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( avatar, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( team_level, eType, stream, uiSize )
            && TFVarTypeProcess( limit, eType, stream, uiSize )
            && TFVarTypeProcess( first, eType, stream, uiSize )
            && TFVarTypeProcess( second, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SRankInfo";
    }
};

#endif
