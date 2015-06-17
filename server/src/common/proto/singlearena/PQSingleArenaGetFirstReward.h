#ifndef _PQSingleArenaGetFirstReward_H_
#define _PQSingleArenaGetFirstReward_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*引导过后发送此协议，可获得奖励等*/
class PQSingleArenaGetFirstReward : public SMsgHead
{
public:

    PQSingleArenaGetFirstReward()
    {
        msg_cmd = 327353176;
    }

    virtual ~PQSingleArenaGetFirstReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleArenaGetFirstReward(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSingleArenaGetFirstReward";
    }
};

#endif
