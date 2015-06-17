#ifndef _SUserStar_H_
#define _SUserStar_H_

#include <weedong/core/seq/seq.h>
/*==========================通迅结构==========================*/
class SUserStar : public wd::CSeq
{
public:
    uint32 copy;    //副本获得星星总数
    uint32 hero;    //英雄系统星星总数
    uint32 totem;    //图腾系统星星总数

    SUserStar() : copy(0), hero(0), totem(0)
    {
    }

    virtual ~SUserStar()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserStar(*this) );
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
            && TFVarTypeProcess( copy, eType, stream, uiSize )
            && TFVarTypeProcess( hero, eType, stream, uiSize )
            && TFVarTypeProcess( totem, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserStar";
    }
};

#endif
