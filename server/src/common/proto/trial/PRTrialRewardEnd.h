#ifndef _PRTrialRewardEnd_H_
#define _PRTrialRewardEnd_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRTrialRewardEnd : public SMsgHead
{
public:
    uint32 id;    //试炼ID

    PRTrialRewardEnd() : id(0)
    {
        msg_cmd = 1907887097;
    }

    virtual ~PRTrialRewardEnd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTrialRewardEnd(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTrialRewardEnd";
    }
};

#endif
