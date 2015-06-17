#ifndef _PRFormationList_H_
#define _PRFormationList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/formation/SUserFormation.h>

/*返回物品列表*/
class PRFormationList : public SMsgHead
{
public:
    uint32 formation_type;    //所处背包类型
    std::vector< SUserFormation > formation_list;    //好友列表

    PRFormationList() : formation_type(0)
    {
        msg_cmd = 1602266981;
    }

    virtual ~PRFormationList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFormationList(*this) );
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
            && TFVarTypeProcess( formation_type, eType, stream, uiSize )
            && TFVarTypeProcess( formation_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFormationList";
    }
};

#endif
