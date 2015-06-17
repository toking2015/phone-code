#ifndef _PRFightEnd_H_
#define _PRFightEnd_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*战斗结束*/
class PRFightEnd : public SMsgHead
{
public:
    uint32 fight_id;
    uint32 winCamp;    //胜利方

    PRFightEnd() : fight_id(0), winCamp(0)
    {
        msg_cmd = 1930696995;
    }

    virtual ~PRFightEnd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFightEnd(*this) );
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
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( winCamp, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFightEnd";
    }
};

#endif
