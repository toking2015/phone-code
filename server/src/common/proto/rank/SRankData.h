#ifndef _SRankData_H_
#define _SRankData_H_

#include <weedong/core/seq/seq.h>
#include <proto/rank/SRankInfo.h>

/*用户排行榜数据*/
class SRankData : public wd::CSeq
{
public:
    SRankInfo info;
    std::map< std::string, uint32 > data;    //排行榜自定义数据

    SRankData()
    {
    }

    virtual ~SRankData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SRankData(*this) );
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
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SRankData";
    }
};

#endif
