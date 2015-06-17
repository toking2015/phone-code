#ifndef _PRTombPlayerReset_H_
#define _PRTombPlayerReset_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/tomb/STombTarget.h>

class PRTombPlayerReset : public SMsgHead
{
public:
    uint32 player_index;
    STombTarget target;    //对战人员嘻嘻 

    PRTombPlayerReset() : player_index(0)
    {
        msg_cmd = 1853519620;
    }

    virtual ~PRTombPlayerReset()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTombPlayerReset(*this) );
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
            && TFVarTypeProcess( player_index, eType, stream, uiSize )
            && TFVarTypeProcess( target, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTombPlayerReset";
    }
};

#endif
