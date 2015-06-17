#ifndef _SGuildPanel_H_
#define _SGuildPanel_H_

#include <weedong/core/seq/seq.h>
#include <proto/guild/SGuildSimple.h>
#include <proto/guild/SGuildInfo.h>

/*公会浏览面板信息结构*/
class SGuildPanel : public wd::CSeq
{
public:
    SGuildSimple simple;
    SGuildInfo info;

    SGuildPanel()
    {
    }

    virtual ~SGuildPanel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildPanel(*this) );
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
        return "SGuildPanel";
    }
};

#endif
