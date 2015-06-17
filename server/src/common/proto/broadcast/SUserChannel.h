#ifndef _SUserChannel_H_
#define _SUserChannel_H_

#include <weedong/core/seq/seq.h>
/*频道标识*/
class SUserChannel : public wd::CSeq
{
public:
    uint16 broad_cast;    //kCastXXX
    uint16 broad_type;    //二级标识
    uint32 broad_id;    //三级标识

    SUserChannel() : broad_cast(0), broad_type(0), broad_id(0)
    {
    }

    virtual ~SUserChannel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserChannel(*this) );
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
            && TFVarTypeProcess( broad_cast, eType, stream, uiSize )
            && TFVarTypeProcess( broad_type, eType, stream, uiSize )
            && TFVarTypeProcess( broad_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserChannel";
    }
};

#endif
