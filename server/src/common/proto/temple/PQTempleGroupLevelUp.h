#ifndef _PQTempleGroupLevelUp_H_
#define _PQTempleGroupLevelUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 升级组合*/
class PQTempleGroupLevelUp : public SMsgHead
{
public:
    uint32 group_id;    // 需要升级的组合id

    PQTempleGroupLevelUp() : group_id(0)
    {
        msg_cmd = 452599552;
    }

    virtual ~PQTempleGroupLevelUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTempleGroupLevelUp(*this) );
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
            && TFVarTypeProcess( group_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTempleGroupLevelUp";
    }
};

#endif
