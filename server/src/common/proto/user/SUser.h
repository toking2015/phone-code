#ifndef _SUser_H_
#define _SUser_H_

#include <weedong/core/seq/seq.h>
#include <proto/user/SUserData.h>
#include <proto/user/SUserExt.h>

/*用户数据集合*/
class SUser : public wd::CSeq
{
public:
    uint32 guid;
    SUserData data;
    SUserExt ext;

    SUser() : guid(0)
    {
    }

    virtual ~SUser()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUser(*this) );
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
        return "SUser";
    }
};

#endif
