#ifndef _PQOpenTargetTake_H_
#define _PQOpenTargetTake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*领取奖励*/
class PQOpenTargetTake : public SMsgHead
{
public:
    uint32 day;    //天      OpenTarget.xls中的day
    uint32 guid;    //唯一id  OpenTarget.xls中的id

    PQOpenTargetTake() : day(0), guid(0)
    {
        msg_cmd = 989782867;
    }

    virtual ~PQOpenTargetTake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQOpenTargetTake(*this) );
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
            && TFVarTypeProcess( day, eType, stream, uiSize )
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQOpenTargetTake";
    }
};

#endif
