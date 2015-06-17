#ifndef _PQAccessBroadCastSet_H_
#define _PQAccessBroadCastSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@设置频道监听*/
class PQAccessBroadCastSet : public SMsgHead
{
public:
    uint32 channel;
    uint8 set_type;    //kObjectAdd, kObjectDel

    PQAccessBroadCastSet() : channel(0), set_type(0)
    {
        msg_cmd = 195628525;
    }

    virtual ~PQAccessBroadCastSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQAccessBroadCastSet(*this) );
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
            && TFVarTypeProcess( channel, eType, stream, uiSize )
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQAccessBroadCastSet";
    }
};

#endif
