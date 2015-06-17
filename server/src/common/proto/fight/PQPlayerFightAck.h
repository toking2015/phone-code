#ifndef _PQPlayerFightAck_H_
#define _PQPlayerFightAck_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightOrder.h>

/*战斗请求技能*/
class PQPlayerFightAck : public SMsgHead
{
public:
    uint32 fight_id;
    SFightOrder fight_order;

    PQPlayerFightAck() : fight_id(0)
    {
        msg_cmd = 108217511;
    }

    virtual ~PQPlayerFightAck()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPlayerFightAck(*this) );
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
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_order, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPlayerFightAck";
    }
};

#endif
