#ifndef _PRChatGetTotem_H_
#define _PRChatGetTotem_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/totem/STotem.h>

class PRChatGetTotem : public SMsgHead
{
public:
    uint32 target_id;
    STotem totem_data;

    PRChatGetTotem() : target_id(0)
    {
        msg_cmd = 1814824376;
    }

    virtual ~PRChatGetTotem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRChatGetTotem(*this) );
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
            && TFVarTypeProcess( totem_data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRChatGetTotem";
    }
};

#endif
