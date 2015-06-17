#ifndef _PRSoldierList_H_
#define _PRSoldierList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/soldier/SUserSoldier.h>

/*返回武将列表*/
class PRSoldierList : public SMsgHead
{
public:
    uint32 soldier_type;    //武将类型
    std::map< uint32, SUserSoldier > soldier_map;    //武将列表

    PRSoldierList() : soldier_type(0)
    {
        msg_cmd = 1666924443;
    }

    virtual ~PRSoldierList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSoldierList(*this) );
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
            && TFVarTypeProcess( soldier_type, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSoldierList";
    }
};

#endif
