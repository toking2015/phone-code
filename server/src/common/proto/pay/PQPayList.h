#ifndef _PQPayList_H_
#define _PQPayList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求新增加的订单*/
class PQPayList : public SMsgHead
{
public:
    uint32 target_id;    //目标ID

    PQPayList() : target_id(0)
    {
        msg_cmd = 393345959;
    }

    virtual ~PQPayList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPayList(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPayList";
    }
};

#endif
