#ifndef _PRTempleInfo_H_
#define _PRTempleInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/temple/STempleInfo.h>

class PRTempleInfo : public SMsgHead
{
public:
    STempleInfo info;

    PRTempleInfo()
    {
        msg_cmd = 1890641118;
    }

    virtual ~PRTempleInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTempleInfo(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTempleInfo";
    }
};

#endif
