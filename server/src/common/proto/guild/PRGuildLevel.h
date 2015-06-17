#ifndef _PRGuildLevel_H_
#define _PRGuildLevel_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*等级经验更新*/
class PRGuildLevel : public SMsgHead
{
public:
    uint32 level;
    uint32 xp;

    PRGuildLevel() : level(0), xp(0)
    {
        msg_cmd = 1322202085;
    }

    virtual ~PRGuildLevel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildLevel(*this) );
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
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( xp, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildLevel";
    }
};

#endif
