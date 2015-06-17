#ifndef _SLocalData_H_
#define _SLocalData_H_

#include <weedong/core/seq/seq.h>
/*==========================閫氳繀缁撴瀯==========================*/
class SLocalData : public wd::CSeq
{
public:
    std::string data;

    SLocalData()
    {
    }

    virtual ~SLocalData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SLocalData(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SLocalData";
    }
};

#endif
