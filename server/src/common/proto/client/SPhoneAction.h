#ifndef _SPhoneAction_H_
#define _SPhoneAction_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SPhoneActionEffect.h>

class SPhoneAction : public wd::CSeq
{
public:
    std::string flag;
    uint16 frame;
    uint8 count;
    int16 targetFocusX;
    uint8 attribute;
    uint8 play;
    uint8 line;
    std::vector< SPhoneActionEffect > listEffect;

    SPhoneAction() : frame(0), count(0), targetFocusX(0), attribute(0), play(0), line(0)
    {
    }

    virtual ~SPhoneAction()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SPhoneAction(*this) );
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
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && TFVarTypeProcess( frame, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && TFVarTypeProcess( targetFocusX, eType, stream, uiSize )
            && TFVarTypeProcess( attribute, eType, stream, uiSize )
            && TFVarTypeProcess( play, eType, stream, uiSize )
            && TFVarTypeProcess( line, eType, stream, uiSize )
            && TFVarTypeProcess( listEffect, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SPhoneAction";
    }
};

#endif
