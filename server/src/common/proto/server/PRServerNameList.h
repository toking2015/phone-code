#ifndef _PRServerNameList_H_
#define _PRServerNameList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRServerNameList : public SMsgHead
{
public:
    std::map< std::string, uint32 > user_name_id;
    std::map< std::string, uint32 > guild_name_id;

    PRServerNameList()
    {
        msg_cmd = 1696743470;
    }

    virtual ~PRServerNameList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRServerNameList(*this) );
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
            && TFVarTypeProcess( user_name_id, eType, stream, uiSize )
            && TFVarTypeProcess( guild_name_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRServerNameList";
    }
};

#endif
