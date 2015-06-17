#ifndef _PQTrialRewardList_H_
#define _PQTrialRewardList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQTrialRewardList : public SMsgHead
{
public:
    uint32 id;    //试炼ID

    PQTrialRewardList() : id(0)
    {
        msg_cmd = 644273634;
    }

    virtual ~PQTrialRewardList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTrialRewardList(*this) );
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
        return "PQTrialRewardList";
    }
};

#endif
