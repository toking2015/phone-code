#ifndef _PRSingleArenaReplyCD_H_
#define _PRSingleArenaReplyCD_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRSingleArenaReplyCD : public SMsgHead
{
public:
    uint32 time_cd;    //CD时间， 用现在的时间与此时间作比较，

    PRSingleArenaReplyCD() : time_cd(0)
    {
        msg_cmd = 1609156980;
    }

    virtual ~PRSingleArenaReplyCD()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaReplyCD(*this) );
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
        return "PRSingleArenaReplyCD";
    }
};

#endif
