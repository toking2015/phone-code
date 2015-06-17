#ifndef _PRSingleArenaClearCD_H_
#define _PRSingleArenaClearCD_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRSingleArenaClearCD : public SMsgHead
{
public:
    uint32 time_cd;    //CD时间， 其实，只要监听到此协议，就代表清空CD成功

    PRSingleArenaClearCD() : time_cd(0)
    {
        msg_cmd = 2133531346;
    }

    virtual ~PRSingleArenaClearCD()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaClearCD(*this) );
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
            && TFVarTypeProcess( time_cd, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaClearCD";
    }
};

#endif
