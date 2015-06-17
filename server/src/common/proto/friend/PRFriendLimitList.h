#ifndef _PRFriendLimitList_H_
#define _PRFriendLimitList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SFriendLimit.h>

/*返回好友限制列表*/
class PRFriendLimitList : public SMsgHead
{
public:
    std::vector< SFriendLimit > limit_list;    //好友限制列表

    PRFriendLimitList()
    {
        msg_cmd = 2023511142;
    }

    virtual ~PRFriendLimitList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendLimitList(*this) );
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
            && TFVarTypeProcess( limit_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendLimitList";
    }
};

#endif
