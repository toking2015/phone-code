#ifndef _PQFormationMove_H_
#define _PQFormationMove_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求阵型移动*/
class PQFormationMove : public SMsgHead
{
public:
    uint32 formation_type;    //kFormationTypeCommon
    uint32 guid;    //guid
    uint32 attr;    //kAttrSoldier
    uint32 index;    //index[0-8]

    PQFormationMove() : formation_type(0), guid(0), attr(0), index(0)
    {
        msg_cmd = 75458213;
    }

    virtual ~PQFormationMove()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFormationMove(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFormationMove";
    }
};

#endif
