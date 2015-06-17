#ifndef _PRTombReset_H_
#define _PRTombReset_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/tomb/SUserTomb.h>
#include <proto/tomb/STombTarget.h>

class PRTombReset : public SMsgHead
{
public:
    SUserTomb tomb_info;    //墓地信息
    std::vector< STombTarget > tomb_target_list;    //对战信息 

    PRTombReset()
    {
        msg_cmd = 1929444106;
    }

    virtual ~PRTombReset()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTombReset(*this) );
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
            && TFVarTypeProcess( tomb_info, eType, stream, uiSize )
            && TFVarTypeProcess( tomb_target_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTombReset";
    }
};

#endif
