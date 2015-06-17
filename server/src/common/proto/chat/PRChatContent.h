#ifndef _PRChatContent_H_
#define _PRChatContent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRChatContent : public SMsgHead
{
public:
    std::string name;    //角色名
    uint32 level;    //等级
    uint32 avater;    //角色头像
    std::string text;
    std::string text_ext;    //文本扩展
    uint32 sound_length;    //语音长度(ms)
    uint32 sound_index;    //语音索引, 由客户端构造(自增值在登录时由客户端随机初始化0~65535)

    PRChatContent() : level(0), avater(0), sound_length(0), sound_index(0)
    {
        msg_cmd = 2089793380;
    }

    virtual ~PRChatContent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRChatContent(*this) );
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
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( avater, eType, stream, uiSize )
            && TFVarTypeProcess( text, eType, stream, uiSize )
            && TFVarTypeProcess( text_ext, eType, stream, uiSize )
            && TFVarTypeProcess( sound_length, eType, stream, uiSize )
            && TFVarTypeProcess( sound_index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRChatContent";
    }
};

#endif
