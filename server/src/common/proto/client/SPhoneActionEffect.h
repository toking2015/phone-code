#ifndef _SPhoneActionEffect_H_
#define _SPhoneActionEffect_H_

#include <weedong/core/seq/seq.h>
class SPhoneActionEffect : public wd::CSeq
{
public:
    uint8 index;
    std::string ackEffect;
    std::string fireEffect;
    std::string targetEffect;
    std::vector< int16 > timeShaftDataList;

    SPhoneActionEffect() : index(0)
    {
    }

    virtual ~SPhoneActionEffect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SPhoneActionEffect(*this) );
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
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && TFVarTypeProcess( ackEffect, eType, stream, uiSize )
            && TFVarTypeProcess( fireEffect, eType, stream, uiSize )
            && TFVarTypeProcess( targetEffect, eType, stream, uiSize )
            && TFVarTypeProcess( timeShaftDataList, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SPhoneActionEffect";
    }
};

#endif
