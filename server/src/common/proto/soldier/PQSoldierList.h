#ifndef _PQSoldierList_H_
#define _PQSoldierList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求武将列表*/
class PQSoldierList : public SMsgHead
{
public:
    uint32 soldier_type;    //武将类型 kSoldierTypeCommon:1

    PQSoldierList() : soldier_type(0)
    {
        msg_cmd = 961013796;
    }

    virtual ~PQSoldierList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierList(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSoldierList";
    }
};

#endif
