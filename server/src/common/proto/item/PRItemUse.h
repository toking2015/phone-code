#ifndef _PRItemUse_H_
#define _PRItemUse_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRItemUse : public SMsgHead
{
public:
    uint32 item_id;    //物品id    
    uint32 count;    //数量

    PRItemUse() : item_id(0), count(0)
    {
        msg_cmd = 1222770932;
    }

    virtual ~PRItemUse()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRItemUse(*this) );
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
            && TFVarTypeProcess( item_id, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRItemUse";
    }
};

#endif
