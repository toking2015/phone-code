#ifndef _PRTrialUpdate_H_
#define _PRTrialUpdate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/trial/SUserTrial.h>

class PRTrialUpdate : public SMsgHead
{
public:
    SUserTrial user_trial;    //更新    

    PRTrialUpdate()
    {
        msg_cmd = 1768293067;
    }

    virtual ~PRTrialUpdate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTrialUpdate(*this) );
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
            && TFVarTypeProcess( user_trial, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTrialUpdate";
    }
};

#endif
