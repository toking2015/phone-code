#ifndef _PQItemEquip_H_
#define _PQItemEquip_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@装备穿戴*/
class PQItemEquip : public SMsgHead
{
public:
    S2UInt32 src;    //装备物品[first:bag_index, second:item_guid]

    PQItemEquip()
    {
        msg_cmd = 708926413;
    }

    virtual ~PQItemEquip()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQItemEquip(*this) );
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
            && TFVarTypeProcess( src, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQItemEquip";
    }
};

#endif
