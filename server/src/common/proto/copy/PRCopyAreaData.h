#ifndef _PRCopyAreaData_H_
#define _PRCopyAreaData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/copy/SAreaLog.h>

/*副本区域通关协议返回*/
class PRCopyAreaData : public SMsgHead
{
public:
    SAreaLog data;    //副本区域数据

    PRCopyAreaData()
    {
        msg_cmd = 1607507845;
    }

    virtual ~PRCopyAreaData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyAreaData(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyAreaData";
    }
};

#endif
