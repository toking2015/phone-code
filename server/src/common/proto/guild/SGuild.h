#ifndef _SGuild_H_
#define _SGuild_H_

#include <weedong/core/seq/seq.h>
#include <proto/guild/SGuildData.h>
#include <proto/guild/SGuildExt.h>

/*公会数据集合*/
class SGuild : public wd::CSeq
{
public:
    uint32 guid;
    SGuildData data;
    SGuildExt ext;

    SGuild() : guid(0)
    {
    }

    virtual ~SGuild()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuild(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && TFVarTypeProcess( ext, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuild";
    }
};

#endif
