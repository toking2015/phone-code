#ifndef _PRGuildCreate_H_
#define _PRGuildCreate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRGuildCreate : public SMsgHead
{
public:
    uint32 guild_id;    //公会id
    std::string name;    //公会名称
    uint32 create_time;    //创建时间

    PRGuildCreate() : guild_id(0), create_time(0)
    {
        msg_cmd = 1833501751;
    }

    virtual ~PRGuildCreate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildCreate(*this) );
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
            && TFVarTypeProcess( guild_id, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( create_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildCreate";
    }
};

#endif
