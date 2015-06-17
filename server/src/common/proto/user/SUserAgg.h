#ifndef _SUserAgg_H_
#define _SUserAgg_H_

#include <weedong/core/seq/seq.h>
#include <proto/user/SUserData.h>
#include <proto/user/SUserExt.h>

/*用户数据集合*/
class SUserAgg : public wd::CSeq
{
public:
    uint32 guid;
    SUserData data;
    SUserExt ext;

    SUserAgg() : guid(0)
    {
    }

    virtual ~SUserAgg()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserAgg(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eWrite, uiSize ) &&
            loopend( stream, CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( guid, type, stream, uiSize )
            && TFVarTypeProcess( data, type, stream, uiSize )
            && TFVarTypeProcess( ext, type, stream, uiSize );
    }
};

#endif
