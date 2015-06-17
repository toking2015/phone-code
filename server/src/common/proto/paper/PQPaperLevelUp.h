#ifndef _PQPaperLevelUp_H_
#define _PQPaperLevelUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@升级手工技能*/
class PQPaperLevelUp : public SMsgHead
{
public:
    uint32 skill_type;    //技能类型（仅用于第一次学习）

    PQPaperLevelUp() : skill_type(0)
    {
        msg_cmd = 1036717831;
    }

    virtual ~PQPaperLevelUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPaperLevelUp(*this) );
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
            && TFVarTypeProcess( skill_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPaperLevelUp";
    }
};

#endif
