#ifndef _SFightResult_H_
#define _SFightResult_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S2UInt32.h>

/*战斗结果*/
class SFightResult : public wd::CSeq
{
public:
    uint32 camp_win;
    std::vector< S2UInt32 > coin_list;

    SFightResult() : camp_win(0)
    {
    }

    virtual ~SFightResult()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightResult(*this) );
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
            && TFVarTypeProcess( camp_win, eType, stream, uiSize )
            && TFVarTypeProcess( coin_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightResult";
    }
};

#endif
