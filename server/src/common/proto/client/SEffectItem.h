#ifndef _SEffectItem_H_
#define _SEffectItem_H_

#include <weedong/core/seq/seq.h>
class SEffectItem : public wd::CSeq
{
public:
    std::string flag;
    uint8 layer;
    uint8 count;
    int16 coordX;
    int16 coordY;
    int16 focusX;
    int8 mirror;
    std::string binding;
    int16 scale;

    SEffectItem() : layer(0), count(0), coordX(0), coordY(0), focusX(0), mirror(0), scale(0)
    {
    }

    virtual ~SEffectItem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SEffectItem(*this) );
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
            && TFVarTypeProcess( layer, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && TFVarTypeProcess( coordX, eType, stream, uiSize )
            && TFVarTypeProcess( coordY, eType, stream, uiSize )
            && TFVarTypeProcess( focusX, eType, stream, uiSize )
            && TFVarTypeProcess( mirror, eType, stream, uiSize )
            && TFVarTypeProcess( binding, eType, stream, uiSize )
            && TFVarTypeProcess( scale, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SEffectItem";
    }
};

#endif
