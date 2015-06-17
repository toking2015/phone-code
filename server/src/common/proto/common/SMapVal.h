#ifndef _SMapVal_H_
#define _SMapVal_H_

#include <weedong/core/seq/seq.h>
/*地图结构*/
class SMapVal : public wd::CSeq
{
public:
    uint16 id;    //ID
    uint8 x;    //X
    uint8 y;    //Y

    SMapVal() : id(0), x(0), y(0)
    {
    }

    virtual ~SMapVal()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMapVal(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( x, eType, stream, uiSize )
            && TFVarTypeProcess( y, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SMapVal";
    }
};

#endif
