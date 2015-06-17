#ifndef _PRPresentGlobalTake_H_
#define _PRPresentGlobalTake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRPresentGlobalTake : public SMsgHead
{
public:
    uint32 err_code;    //错误码
    uint32 reward_id;    //礼包reward

    PRPresentGlobalTake() : err_code(0), reward_id(0)
    {
        msg_cmd = 1336200323;
    }

    virtual ~PRPresentGlobalTake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPresentGlobalTake(*this) );
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
            && TFVarTypeProcess( err_code, eType, stream, uiSize )
            && TFVarTypeProcess( reward_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPresentGlobalTake";
    }
};

#endif
