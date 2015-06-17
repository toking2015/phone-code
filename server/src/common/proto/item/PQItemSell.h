#ifndef _PQItemSell_H_
#define _PQItemSell_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@物品售出*/
class PQItemSell : public SMsgHead
{
public:
    uint32 bag_type;    //kBag
    std::vector< S2UInt32 > item_list;    //{ [guid], count} 

    PQItemSell() : bag_type(0)
    {
        msg_cmd = 222047555;
    }

    virtual ~PQItemSell()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQItemSell(*this) );
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
            && TFVarTypeProcess( bag_type, eType, stream, uiSize )
            && TFVarTypeProcess( item_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQItemSell";
    }
};

#endif
