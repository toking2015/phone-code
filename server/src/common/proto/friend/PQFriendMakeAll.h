#ifndef _PQFriendMakeAll_H_
#define _PQFriendMakeAll_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@全部加好友*/
class PQFriendMakeAll : public SMsgHead
{
public:
    std::vector< uint32 > target_id_list;    //对方角色id列表    默认为好友分组

    PQFriendMakeAll()
    {
        msg_cmd = 698155518;
    }

    virtual ~PQFriendMakeAll()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendMakeAll(*this) );
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
            && TFVarTypeProcess( target_id_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendMakeAll";
    }
};

#endif
