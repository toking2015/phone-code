#ifndef _PQFriendFightApply_H_
#define _PQFriendFightApply_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@好友挑战*/
class PQFriendFightApply : public SMsgHead
{
public:
    uint32 friend_id;    //好友角色id

    PQFriendFightApply() : friend_id(0)
    {
        msg_cmd = 1017508629;
    }

    virtual ~PQFriendFightApply()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendFightApply(*this) );
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
            && TFVarTypeProcess( friend_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendFightApply";
    }
};

#endif
