#ifndef _PRFriendGiveLimit_H_
#define _PRFriendGiveLimit_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*赠送时，如果对方不能接收时返回给赠送者的协议*/
class PRFriendGiveLimit : public SMsgHead
{
public:
    uint32 target_id;    //接受者id
    std::string target_name;    //接受者名字
    uint32 max_num;    //接受者现在最多能接受的赠品数量

    PRFriendGiveLimit() : target_id(0), max_num(0)
    {
        msg_cmd = 1699757452;
    }

    virtual ~PRFriendGiveLimit()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendGiveLimit(*this) );
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
            && TFVarTypeProcess( target_name, eType, stream, uiSize )
            && TFVarTypeProcess( max_num, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendGiveLimit";
    }
};

#endif
