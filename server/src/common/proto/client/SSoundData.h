#ifndef _SSoundData_H_
#define _SSoundData_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SBodySound.h>

class SSoundData : public wd::CSeq
{
public:
    std::vector< SBodySound > list;

    SSoundData()
    {
    }

    virtual ~SSoundData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSoundData(*this) );
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
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSoundData";
    }
};

#endif
