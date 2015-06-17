#ifndef _PQActivityRewardLoad_H_
#define _PQActivityRewardLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*从share 加载数据 -SActivityReward*/
class PQActivityRewardLoad : public SMsgHead
{
public:

    PQActivityRewardLoad()
    {
        msg_cmd = 173095659;
    }

    virtual ~PQActivityRewardLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQActivityRewardLoad(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQActivityRewardLoad";
    }
};

#endif
