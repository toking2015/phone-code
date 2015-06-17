#ifndef _PQFriendOK_H_
#define _PQFriendOK_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@确定加好友*/
class PQFriendOK : public SMsgHead
{
public:
    uint32 target_id;    //发送加好友者id，对应SFriendRMake中targetid

    PQFriendOK() : target_id(0)
    {
        msg_cmd = 518108368;
    }

    virtual ~PQFriendOK()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendOK(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendOK";
    }
};

#endif
