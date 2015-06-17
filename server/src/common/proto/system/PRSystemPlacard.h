#ifndef _PRSystemPlacard_H_
#define _PRSystemPlacard_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRSystemPlacard : public SMsgHead
{
public:
    uint8 order;    //优先级, 值越大越高级, 最高255, 默认为0
    uint8 flag;    //广播类型( 位移 ), kPlacardFlagXXX
    std::string text;

    PRSystemPlacard() : order(0), flag(0)
    {
        msg_cmd = 1396856249;
    }

    virtual ~PRSystemPlacard()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemPlacard(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( order, eType, stream, uiSize )
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && TFVarTypeProcess( text, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSystemPlacard";
    }
};

#endif
