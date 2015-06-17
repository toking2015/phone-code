#ifndef _PQTaskDayValReward_H_
#define _PQTaskDayValReward_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*日常活动积分领奖*/
class PQTaskDayValReward : public SMsgHead
{
public:
    uint32 id;

    PQTaskDayValReward() : id(0)
    {
        msg_cmd = 994921066;
    }

    virtual ~PQTaskDayValReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTaskDayValReward(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTaskDayValReward";
    }
};

#endif
