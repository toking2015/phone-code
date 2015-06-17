#ifndef _SPhoneData_H_
#define _SPhoneData_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SPhoneBody.h>

class SPhoneData : public wd::CSeq
{
public:
    std::vector< SPhoneBody > list;

    SPhoneData()
    {
    }

    virtual ~SPhoneData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SPhoneData(*this) );
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
        return "SPhoneData";
    }
};

#endif
