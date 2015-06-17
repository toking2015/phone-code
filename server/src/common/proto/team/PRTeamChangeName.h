#ifndef _PRTeamChangeName_H_
#define _PRTeamChangeName_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRTeamChangeName : public SMsgHead
{
public:
    std::string name;    //修改OK的名字

    PRTeamChangeName()
    {
        msg_cmd = 1105012732;
    }

    virtual ~PRTeamChangeName()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTeamChangeName(*this) );
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
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTeamChangeName";
    }
};

#endif
