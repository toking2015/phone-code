#ifndef _SPhoneBody_H_
#define _SPhoneBody_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SPhoneAction.h>

class SPhoneBody : public wd::CSeq
{
public:
    std::string style;
    int16 headX;
    int16 headY;
    int16 bodyX;
    int16 bodyY;
    int16 footX;
    int16 footY;
    int16 scale;
    std::vector< SPhoneAction > list;

    SPhoneBody() : headX(0), headY(0), bodyX(0), bodyY(0), footX(0), footY(0), scale(0)
    {
    }

    virtual ~SPhoneBody()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SPhoneBody(*this) );
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
            && TFVarTypeProcess( style, eType, stream, uiSize )
            && TFVarTypeProcess( headX, eType, stream, uiSize )
            && TFVarTypeProcess( headY, eType, stream, uiSize )
            && TFVarTypeProcess( bodyX, eType, stream, uiSize )
            && TFVarTypeProcess( bodyY, eType, stream, uiSize )
            && TFVarTypeProcess( footX, eType, stream, uiSize )
            && TFVarTypeProcess( footY, eType, stream, uiSize )
            && TFVarTypeProcess( scale, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SPhoneBody";
    }
};

#endif
