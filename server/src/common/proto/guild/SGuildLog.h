#ifndef _SGuildLog_H_
#define _SGuildLog_H_

#include <weedong/core/seq/seq.h>
/*公会日志*/
class SGuildLog : public wd::CSeq
{
public:
    uint32 type;
    uint32 time;
    std::string params;

    SGuildLog() : type(0), time(0)
    {
    }

    virtual ~SGuildLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildLog(*this) );
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
            && TFVarTypeProcess( type, eType, stream, uiSize )
            && TFVarTypeProcess( time, eType, stream, uiSize )
            && TFVarTypeProcess( params, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuildLog";
    }
};

#endif
