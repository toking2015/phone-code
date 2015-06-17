#ifndef _PQFightSingleArenaApply_H_
#define _PQFightSingleArenaApply_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*触发竞技场战斗*/
class PQFightSingleArenaApply : public SMsgHead
{
public:
    uint32 attr;    //kAttrPlayer,kAttrMonster
    uint32 target_id;    //人物为guid,怪物为rank

    PQFightSingleArenaApply() : attr(0), target_id(0)
    {
        msg_cmd = 157609641;
    }

    virtual ~PQFightSingleArenaApply()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightSingleArenaApply(*this) );
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
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFightSingleArenaApply";
    }
};

#endif
