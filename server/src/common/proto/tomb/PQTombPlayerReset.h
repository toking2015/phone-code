#ifndef _PQTombPlayerReset_H_
#define _PQTombPlayerReset_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*玩家重置*/
class PQTombPlayerReset : public SMsgHead
{
public:
    uint32 player_index;    //玩家位置

    PQTombPlayerReset() : player_index(0)
    {
        msg_cmd = 663519283;
    }

    virtual ~PQTombPlayerReset()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTombPlayerReset(*this) );
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
            && TFVarTypeProcess( player_index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTombPlayerReset";
    }
};

#endif
