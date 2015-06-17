#ifndef _PQFriendMake_H_
#define _PQFriendMake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@加好友*/
class PQFriendMake : public SMsgHead
{
public:
    uint32 target_id;    //对方角色id
    uint8 group;    //好友分组

    PQFriendMake() : target_id(0), group(0)
    {
        msg_cmd = 227513378;
    }

    virtual ~PQFriendMake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendMake(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( group, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendMake";
    }
};

#endif
