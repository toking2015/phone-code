#ifndef _CFriend_H_
#define _CFriend_H_

#include <weedong/core/seq/seq.h>
#include <proto/friend/SFriendData.h>

/*============================数据中心========================*/
class CFriend : public wd::CSeq
{
public:
    std::map< uint32, SFriendData > user_id_friend;

    CFriend()
    {
    }

    virtual ~CFriend()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CFriend(*this) );
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
            && TFVarTypeProcess( user_id_friend, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CFriend";
    }
};

#endif
