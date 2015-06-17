#ifndef _SUserMysteryGoods_H_
#define _SUserMysteryGoods_H_

#include <weedong/core/seq/seq.h>
/*神秘商店商品*/
class SUserMysteryGoods : public wd::CSeq
{
public:
    uint32 id;    //商品id
    uint16 buyed_count;    //已购买数量

    SUserMysteryGoods() : id(0), buyed_count(0)
    {
    }

    virtual ~SUserMysteryGoods()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserMysteryGoods(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( buyed_count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserMysteryGoods";
    }
};

#endif
