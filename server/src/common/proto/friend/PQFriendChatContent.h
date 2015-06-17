#ifndef _PQFriendChatContent_H_
#define _PQFriendChatContent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@聊天*/
class PQFriendChatContent : public SMsgHead
{
public:
    uint32 friend_id;    //好友guid
    std::string text;    //文本内容
    wd::CStream sound;    //声音内容
    uint32 length;    //声音长度(ms)
    uint32 avater;    //角色头像
    std::string text_ext;    //文本扩展

    PQFriendChatContent() : friend_id(0), length(0), avater(0)
    {
        msg_cmd = 952948261;
    }

    virtual ~PQFriendChatContent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendChatContent(*this) );
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
            && TFVarTypeProcess( text, eType, stream, uiSize )
            && TFVarTypeProcess( sound, eType, stream, uiSize )
            && TFVarTypeProcess( length, eType, stream, uiSize )
            && TFVarTypeProcess( avater, eType, stream, uiSize )
            && TFVarTypeProcess( text_ext, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendChatContent";
    }
};

#endif
