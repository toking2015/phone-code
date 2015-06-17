#ifndef _PRReplyFristPayReward_H_
#define _PRReplyFristPayReward_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*废弃*/
class PRReplyFristPayReward : public SMsgHead
{
public:
    uint32 flag;    //领取标识

    PRReplyFristPayReward() : flag(0)
    {
        msg_cmd = 1488769700;
    }

    virtual ~PRReplyFristPayReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRReplyFristPayReward(*this) );
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
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRReplyFristPayReward";
    }
};

#endif
