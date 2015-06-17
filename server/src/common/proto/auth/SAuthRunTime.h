#ifndef _SAuthRunTime_H_
#define _SAuthRunTime_H_

#include <weedong/core/seq/seq.h>
/*=========================通迅结构============================*/
class SAuthRunTime : public wd::CSeq
{
public:
    uint32 guid;    //运行时id
    std::string data;

    SAuthRunTime() : guid(0)
    {
    }

    virtual ~SAuthRunTime()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SAuthRunTime(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SAuthRunTime";
    }
};

#endif
