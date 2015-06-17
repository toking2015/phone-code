#ifndef _PRChatSound_H_
#define _PRChatSound_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRChatSound : public SMsgHead
{
public:
    uint32 result;    //0为正常, 非0 为错误码
    uint32 target_id;
    uint32 sound_index;    //请求语音数据
    wd::CStream sound_data;    //语音内容

    PRChatSound() : result(0), target_id(0), sound_index(0)
    {
        msg_cmd = 1516629421;
    }

    virtual ~PRChatSound()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRChatSound(*this) );
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
            && TFVarTypeProcess( result, eType, stream, uiSize )
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( sound_index, eType, stream, uiSize )
            && TFVarTypeProcess( sound_data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRChatSound";
    }
};

#endif
