#ifndef _PQFriendBlackByName_H_
#define _PQFriendBlackByName_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@拉黑*/
class PQFriendBlackByName : public SMsgHead
{
public:
    std::string target_name;    //对方角色名字

    PQFriendBlackByName()
    {
        msg_cmd = 510925146;
    }

    virtual ~PQFriendBlackByName()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendBlackByName(*this) );
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
        return "PQFriendBlackByName";
    }
};

#endif
