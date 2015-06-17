#ifndef _PRFriendChatContent_H_
#define _PRFriendChatContent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRFriendChatContent : public SMsgHead
{
public:
    uint32 target_id;    //说话者id
    std::string name;    //角色名
    uint32 level;    //等级
    std::string text;
    wd::CStream sound;
    uint32 length;    //声音长度(ms)
    uint32 avater;    //角色头像
    std::string text_ext;    //文本扩展

    PRFriendChatContent() : target_id(0), level(0), length(0), avater(0)
    {
        msg_cmd = 1507929832;
    }

    virtual ~PRFriendChatContent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendChatContent(*this) );
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
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( text, eType, stream, uiSize )
            && TFVarTypeProcess( sound, eType, stream, uiSize )
            && TFVarTypeProcess( length, eType, stream, uiSize )
            && TFVarTypeProcess( avater, eType, stream, uiSize )
            && TFVarTypeProcess( text_ext, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendChatContent";
    }
};

#endif
