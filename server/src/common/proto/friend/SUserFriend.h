#ifndef _SUserFriend_H_
#define _SUserFriend_H_

#include <weedong/core/seq/seq.h>
/*好友-黄少卿*/
class SUserFriend : public wd::CSeq
{
public:
    uint32 friend_id;
    uint32 friend_favor;    //好感度
    uint8 friend_group;    //好友分组
    uint32 on_time;    //上线时间( on_time == 0 为不在线 )
    uint16 friend_avatar;    //好友头像
    uint32 friend_level;    //好友战队等级
    std::string friend_name;    //好友名字
    std::string friend_gname;    //好友公会名字

    SUserFriend() : friend_id(0), friend_favor(0), friend_group(0), on_time(0), friend_avatar(0), friend_level(0)
    {
    }

    virtual ~SUserFriend()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserFriend(*this) );
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
            && TFVarTypeProcess( friend_id, eType, stream, uiSize )
            && TFVarTypeProcess( friend_favor, eType, stream, uiSize )
            && TFVarTypeProcess( friend_group, eType, stream, uiSize )
            && TFVarTypeProcess( on_time, eType, stream, uiSize )
            && TFVarTypeProcess( friend_avatar, eType, stream, uiSize )
            && TFVarTypeProcess( friend_level, eType, stream, uiSize )
            && TFVarTypeProcess( friend_name, eType, stream, uiSize )
            && TFVarTypeProcess( friend_gname, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserFriend";
    }
};

#endif
