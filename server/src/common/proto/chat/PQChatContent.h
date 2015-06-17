#ifndef _PQChatContent_H_
#define _PQChatContent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求发送, 发送类型与对象参考 broadcast 模块相关说明*/
class PQChatContent : public SMsgHead
{
public:
    uint32 avater;    //角色头像
    std::string text;    //文本内容
    std::string text_ext;    //文本扩展
    wd::CStream sound_data;    //语音数据
    uint32 sound_length;    //语音长度(ms)
    uint32 sound_index;    //语音索引, 由客户端构造(自增值在登录时由客户端随机初始化0~65535)

    PQChatContent() : avater(0), sound_length(0), sound_index(0)
    {
        msg_cmd = 1012322907;
    }

    virtual ~PQChatContent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQChatContent(*this) );
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
            && TFVarTypeProcess( avater, eType, stream, uiSize )
            && TFVarTypeProcess( text, eType, stream, uiSize )
            && TFVarTypeProcess( text_ext, eType, stream, uiSize )
            && TFVarTypeProcess( sound_data, eType, stream, uiSize )
            && TFVarTypeProcess( sound_length, eType, stream, uiSize )
            && TFVarTypeProcess( sound_index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQChatContent";
    }
};

#endif
