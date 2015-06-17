#ifndef _PQItemList_H_
#define _PQItemList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求物品列表*/
class PQItemList : public SMsgHead
{
public:
    uint32 bag_index;    //所处背包类型

    PQItemList() : bag_index(0)
    {
        msg_cmd = 857480699;
    }

    virtual ~PQItemList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQItemList(*this) );
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
            && TFVarTypeProcess( bag_index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQItemList";
    }
};

#endif
