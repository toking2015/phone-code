#ifndef _PQChatSound_H_
#define _PQChatSound_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求语音播放*/
class PQChatSound : public SMsgHead
{
public:
    uint32 target_id;    //请求用户角色id
    uint32 sound_index;    //请求语音数据

    PQChatSound() : target_id(0), sound_index(0)
    {
        msg_cmd = 810765027;
    }

    virtual ~PQChatSound()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQChatSound(*this) );
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
            && TFVarTypeProcess( sound_index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQChatSound";
    }
};

#endif
