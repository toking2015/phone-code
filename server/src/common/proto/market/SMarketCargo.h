#ifndef _SMarketCargo_H_
#define _SMarketCargo_H_

#include <weedong/core/seq/seq.h>
/*==========================通迅结构==========================*/
class SMarketCargo : public wd::CSeq
{
public:
    uint32 role_id;    //上架货物主人
    uint32 cargo_type;    //上架货物类型

    SMarketCargo() : role_id(0), cargo_type(0)
    {
    }

    virtual ~SMarketCargo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMarketCargo(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( role_id, type, stream, uiSize )
            && TFVarTypeProcess( cargo_type, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "SMarketCargo";
    }
};

#endif
