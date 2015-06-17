#ifndef _PQFriendMakeByName_H_
#define _PQFriendMakeByName_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@加好友*/
class PQFriendMakeByName : public SMsgHead
{
public:
    std::string target_name;    //对方角色名字  默认为好友分组

    PQFriendMakeByName()
    {
        msg_cmd = 606583061;
    }

    virtual ~PQFriendMakeByName()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendMakeByName(*this) );
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
            && TFVarTypeProcess( target_name, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendMakeByName";
    }
};

#endif
