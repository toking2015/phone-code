#ifndef _PQSoldierAdd_H_
#define _PQSoldierAdd_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@添加武将*/
class PQSoldierAdd : public SMsgHead
{
public:
    uint16 soldier_id;    //武将id

    PQSoldierAdd() : soldier_id(0)
    {
        msg_cmd = 717748738;
    }

    virtual ~PQSoldierAdd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierAdd(*this) );
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
            && TFVarTypeProcess( soldier_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSoldierAdd";
    }
};

#endif
