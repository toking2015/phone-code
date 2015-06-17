#ifndef _PQFriendUpdate_H_
#define _PQFriendUpdate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@好友分组修改*/
class PQFriendUpdate : public SMsgHead
{
public:
    uint32 target_id;    //对方角色id
    uint8 set_type;    //操作方式(只接受 kObjectUpdate, kObjectDel)
    uint8 group;    //分组修改

    PQFriendUpdate() : target_id(0), set_type(0), group(0)
    {
        msg_cmd = 455135086;
    }

    virtual ~PQFriendUpdate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendUpdate(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( group, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendUpdate";
    }
};

#endif
