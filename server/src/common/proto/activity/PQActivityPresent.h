#ifndef _PQActivityPresent_H_
#define _PQActivityPresent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*领取奖励*/
class PQActivityPresent : public SMsgHead
{
public:
    uint32 present_id;

    PQActivityPresent() : present_id(0)
    {
        msg_cmd = 637892388;
    }

    virtual ~PQActivityPresent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQActivityPresent(*this) );
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
            && TFVarTypeProcess( present_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQActivityPresent";
    }
};

#endif
