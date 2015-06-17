#ifndef _PQTeamChangeAvatar_H_
#define _PQTeamChangeAvatar_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQTeamChangeAvatar : public SMsgHead
{
public:
    uint32 avatar;    //头像id

    PQTeamChangeAvatar() : avatar(0)
    {
        msg_cmd = 374520175;
    }

    virtual ~PQTeamChangeAvatar()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTeamChangeAvatar(*this) );
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
            && TFVarTypeProcess( avatar, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTeamChangeAvatar";
    }
};

#endif
