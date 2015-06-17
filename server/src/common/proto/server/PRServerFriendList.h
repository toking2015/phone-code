#ifndef _PRServerFriendList_H_
#define _PRServerFriendList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SFriendData.h>

class PRServerFriendList : public SMsgHead
{
public:
    std::map< uint32, SFriendData > user_id_friend;

    PRServerFriendList()
    {
        msg_cmd = 1624405534;
    }

    virtual ~PRServerFriendList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRServerFriendList(*this) );
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
            && TFVarTypeProcess( user_id_friend, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRServerFriendList";
    }
};

#endif
