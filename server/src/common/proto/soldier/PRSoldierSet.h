#ifndef _PRSoldierSet_H_
#define _PRSoldierSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/soldier/SUserSoldier.h>

/*返回武将*/
class PRSoldierSet : public SMsgHead
{
public:
    uint32 set_type;    //set_type
    uint32 set_path;    //set_path
    SUserSoldier soldier;    //武将

    PRSoldierSet() : set_type(0), set_path(0)
    {
        msg_cmd = 1949745294;
    }

    virtual ~PRSoldierSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSoldierSet(*this) );
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
            && TFVarTypeProcess( set_path, eType, stream, uiSize )
            && TFVarTypeProcess( soldier, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSoldierSet";
    }
};

#endif
