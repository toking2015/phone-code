#ifndef _PRFriendList_H_
#define _PRFriendList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SUserFriend.h>

/*返回好友列表*/
class PRFriendList : public SMsgHead
{
public:
    std::vector< SUserFriend > friend_list;    //好友列表

    PRFriendList()
    {
        msg_cmd = 1257022854;
    }

    virtual ~PRFriendList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendList(*this) );
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
            && TFVarTypeProcess( friend_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendList";
    }
};

#endif
