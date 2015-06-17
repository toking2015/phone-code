#ifndef _SUserPanel_H_
#define _SUserPanel_H_

#include <weedong/core/seq/seq.h>
#include <proto/user/SUserSimple.h>
#include <proto/user/SUserInfo.h>

/*用户浏览面板信息结构*/
class SUserPanel : public wd::CSeq
{
public:
    SUserSimple simple;
    SUserInfo info;

    SUserPanel()
    {
    }

    virtual ~SUserPanel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserPanel(*this) );
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
            && TFVarTypeProcess( simple, eType, stream, uiSize )
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserPanel";
    }
};

#endif
