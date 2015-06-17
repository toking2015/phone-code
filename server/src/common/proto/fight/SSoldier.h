#ifndef _SSoldier_H_
#define _SSoldier_H_

#include <weedong/core/seq/seq.h>
class SSoldier : public wd::CSeq
{
public:
    uint32 role_id;    //玩家或者怪物ID
    uint16 attr;    //人物标识 玩家/怪物/宠物
    uint16 camp;    //阵营
    uint32 seqno;    //战斗同步id

    SSoldier() : role_id(0), attr(0), camp(0), seqno(0)
    {
    }

    virtual ~SSoldier()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSoldier(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( role_id, eType, stream, uiSize )
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( camp, eType, stream, uiSize )
            && TFVarTypeProcess( seqno, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSoldier";
    }
};

#endif
