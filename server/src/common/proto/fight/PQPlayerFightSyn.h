#ifndef _PQPlayerFightSyn_H_
#define _PQPlayerFightSyn_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*战斗技能确认*/
class PQPlayerFightSyn : public SMsgHead
{
public:
    uint32 fight_id;
    uint32 seqno;    //确认序列号

    PQPlayerFightSyn() : fight_id(0), seqno(0)
    {
        msg_cmd = 472110993;
    }

    virtual ~PQPlayerFightSyn()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPlayerFightSyn(*this) );
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
            && TFVarTypeProcess( seqno, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPlayerFightSyn";
    }
};

#endif
