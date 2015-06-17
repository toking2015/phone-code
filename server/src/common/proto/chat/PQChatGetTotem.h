#ifndef _PQChatGetTotem_H_
#define _PQChatGetTotem_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*图腾*/
class PQChatGetTotem : public SMsgHead
{
public:
    uint32 target_id;
    uint32 totem_guid;

    PQChatGetTotem() : target_id(0), totem_guid(0)
    {
        msg_cmd = 490478920;
    }

    virtual ~PQChatGetTotem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQChatGetTotem(*this) );
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
            && TFVarTypeProcess( totem_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQChatGetTotem";
    }
};

#endif
