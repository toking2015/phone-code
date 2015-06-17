#ifndef _PRSingleArenaAddTimes_H_
#define _PRSingleArenaAddTimes_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*add_times  + Level.xls中的singlearena_times - cur_times就是今天还可以挑战的次数*/
class PRSingleArenaAddTimes : public SMsgHead
{
public:
    uint32 add_times;    //增加的挑战次数
    uint32 cur_times;    //当前挑战次数

    PRSingleArenaAddTimes() : add_times(0), cur_times(0)
    {
        msg_cmd = 1896427484;
    }

    virtual ~PRSingleArenaAddTimes()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaAddTimes(*this) );
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
            && TFVarTypeProcess( add_times, eType, stream, uiSize )
            && TFVarTypeProcess( cur_times, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaAddTimes";
    }
};

#endif
