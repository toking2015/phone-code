#ifndef _PQFormationList_H_
#define _PQFormationList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求物品列表*/
class PQFormationList : public SMsgHead
{
public:
    uint32 formation_type;    //阵型类型

    PQFormationList() : formation_type(0)
    {
        msg_cmd = 776361237;
    }

    virtual ~PQFormationList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFormationList(*this) );
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
            && TFVarTypeProcess( formation_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFormationList";
    }
};

#endif
