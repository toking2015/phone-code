#ifndef _PQSoldierSkillReset_H_
#define _PQSoldierSkillReset_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@洗点*/
class PQSoldierSkillReset : public SMsgHead
{
public:
    S2UInt32 soldier;    //武将 first:武将背包类型 second:武将guid

    PQSoldierSkillReset()
    {
        msg_cmd = 56411694;
    }

    virtual ~PQSoldierSkillReset()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierSkillReset(*this) );
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
            && TFVarTypeProcess( soldier, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSoldierSkillReset";
    }
};

#endif
