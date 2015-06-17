#ifndef _PQServerFriendList_H_
#define _PQServerFriendList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQServerFriendList : public SMsgHead
{
public:
    uint32 level;    //team_level >= level的数据全要

    PQServerFriendList() : level(0)
    {
        msg_cmd = 1011284555;
    }

    virtual ~PQServerFriendList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQServerFriendList(*this) );
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
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQServerFriendList";
    }
};

#endif
