#ifndef _PRFriendRecommend_H_
#define _PRFriendRecommend_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SUserFriend.h>

/*好友推荐回复*/
class PRFriendRecommend : public SMsgHead
{
public:
    std::vector< uint32 > target_id_list;    //好友列表，没有好友可推荐，则列表为空 <兼容>
    std::vector< SUserFriend > friend_list;

    PRFriendRecommend()
    {
        msg_cmd = 1933510749;
    }

    virtual ~PRFriendRecommend()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendRecommend(*this) );
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
            && TFVarTypeProcess( target_id_list, eType, stream, uiSize )
            && TFVarTypeProcess( friend_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendRecommend";
    }
};

#endif
