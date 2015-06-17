#ifndef _PRTopData_H_
#define _PRTopData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/top/SUserTop.h>

class PRTopData : public SMsgHead
{
public:
    SUserTop top_data;

    PRTopData()
    {
        msg_cmd = 1986846505;
    }

    virtual ~PRTopData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTopData(*this) );
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
            && TFVarTypeProcess( top_data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTopData";
    }
};

#endif
