#ifndef _PQSoldierDel_H_
#define _PQSoldierDel_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@删除武将*/
class PQSoldierDel : public SMsgHead
{
public:
    uint32 soldier_type;    //武将类型
    S2UInt32 soldier;    //武将 first:武将背包类型 second:武将guid

    PQSoldierDel() : soldier_type(0)
    {
        msg_cmd = 1026501369;
    }

    virtual ~PQSoldierDel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierDel(*this) );
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
            && TFVarTypeProcess( soldier_type, eType, stream, uiSize )
            && TFVarTypeProcess( soldier, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSoldierDel";
    }
};

#endif
