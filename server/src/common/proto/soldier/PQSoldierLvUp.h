#ifndef _PQSoldierLvUp_H_
#define _PQSoldierLvUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@等级升级*/
class PQSoldierLvUp : public SMsgHead
{
public:
    S2UInt32 soldier;    //武将 first:武将背包类型 second:武将guid

    PQSoldierLvUp()
    {
        msg_cmd = 915576268;
    }

    virtual ~PQSoldierLvUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierLvUp(*this) );
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
        return "PQSoldierLvUp";
    }
};

#endif
