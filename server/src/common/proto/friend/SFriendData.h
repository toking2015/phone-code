#ifndef _SFriendData_H_
#define _SFriendData_H_

#include <weedong/core/seq/seq.h>
class SFriendData : public wd::CSeq
{
public:
    uint32 target_id;
    uint16 target_avatar;
    uint32 target_level;
    std::string target_name;

    SFriendData() : target_id(0), target_avatar(0), target_level(0)
    {
    }

    virtual ~SFriendData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFriendData(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( target_avatar, eType, stream, uiSize )
            && TFVarTypeProcess( target_level, eType, stream, uiSize )
            && TFVarTypeProcess( target_name, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFriendData";
    }
};

#endif
