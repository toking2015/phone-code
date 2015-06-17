#ifndef _PQCommonFightApply_H_
#define _PQCommonFightApply_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*触发战斗*/
class PQCommonFightApply : public SMsgHead
{
public:
    uint32 attr;    //kAttrPlayer,kAttrMonster
    uint32 target_id;    //目标的怪物id

    PQCommonFightApply() : attr(0), target_id(0)
    {
        msg_cmd = 477321402;
    }

    virtual ~PQCommonFightApply()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCommonFightApply(*this) );
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
        return "PQCommonFightApply";
    }
};

#endif
