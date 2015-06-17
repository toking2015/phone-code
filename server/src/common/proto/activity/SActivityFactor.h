#ifndef _SActivityFactor_H_
#define _SActivityFactor_H_

#include <weedong/core/seq/seq.h>
/*活动条件*/
class SActivityFactor : public wd::CSeq
{
public:
    uint32 guid;    //唯一
    std::string group;
    std::string desc;
    uint32 type;    //kActivityFactorTypeFirstPay
    uint32 value;
    uint32 value1;

    SActivityFactor() : guid(0), type(0), value(0), value1(0)
    {
    }

    virtual ~SActivityFactor()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SActivityFactor(*this) );
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
            && TFVarTypeProcess( group, eType, stream, uiSize )
            && TFVarTypeProcess( desc, eType, stream, uiSize )
            && TFVarTypeProcess( type, eType, stream, uiSize )
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && TFVarTypeProcess( value1, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SActivityFactor";
    }
};

#endif
