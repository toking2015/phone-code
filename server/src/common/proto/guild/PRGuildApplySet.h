#ifndef _PRGuildApplySet_H_
#define _PRGuildApplySet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*申请人更新*/
class PRGuildApplySet : public SMsgHead
{
public:
    uint32 set_type;
    uint32 target_id;

    PRGuildApplySet() : set_type(0), target_id(0)
    {
        msg_cmd = 1471431520;
    }

    virtual ~PRGuildApplySet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildApplySet(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildApplySet";
    }
};

#endif
