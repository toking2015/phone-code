#ifndef _PRFightExtAbleList_H_
#define _PRFightExtAbleList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fightextable/SFightExtAbleInfo.h>

class PRFightExtAbleList : public SMsgHead
{
public:
    uint32 attr;    //武将
    std::vector< SFightExtAbleInfo > fightextable_list;    //二级属性

    PRFightExtAbleList() : attr(0)
    {
        msg_cmd = 1830637631;
    }

    virtual ~PRFightExtAbleList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFightExtAbleList(*this) );
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
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( fightextable_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFightExtAbleList";
    }
};

#endif
