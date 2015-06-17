#ifndef _PQFriendBlack_H_
#define _PQFriendBlack_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@拉黑*/
class PQFriendBlack : public SMsgHead
{
public:
    uint32 target_id;    //对方角色id

    PQFriendBlack() : target_id(0)
    {
        msg_cmd = 951417580;
    }

    virtual ~PQFriendBlack()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendBlack(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendBlack";
    }
};

#endif
