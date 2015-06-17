#ifndef _PQItemUse_H_
#define _PQItemUse_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@装备使用 */
class PQItemUse : public SMsgHead
{
public:
    S2UInt32 item;    //装备物品[first:bag_index, second:item_guid]
    uint32 count;    //数量
    uint32 index;    //指定index

    PQItemUse() : count(0), index(0)
    {
        msg_cmd = 1004860592;
    }

    virtual ~PQItemUse()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQItemUse(*this) );
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
            && TFVarTypeProcess( item, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQItemUse";
    }
};

#endif
