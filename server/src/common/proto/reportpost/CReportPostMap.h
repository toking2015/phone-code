#ifndef _CReportPostMap_H_
#define _CReportPostMap_H_

#include <weedong/core/seq/seq.h>
#include <proto/reportpost/SReportPostInfo.h>

/*============================数据中心========================*/
class CReportPostMap : public wd::CSeq
{
public:
    std::map< uint32, SReportPostInfo > reportpost_info_map;    //玩家信息

    CReportPostMap()
    {
    }

    virtual ~CReportPostMap()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CReportPostMap(*this) );
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
            && TFVarTypeProcess( reportpost_info_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CReportPostMap";
    }
};

#endif
