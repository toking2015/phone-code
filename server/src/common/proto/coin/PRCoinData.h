#ifndef _PRCoinData_H_
#define _PRCoinData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/coin/SUserCoin.h>

class PRCoinData : public SMsgHead
{
public:
    SUserCoin data;

    PRCoinData()
    {
        msg_cmd = 2074117868;
    }

    virtual ~PRCoinData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCoinData(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( data, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PRCoinData";
    }
};

#endif
