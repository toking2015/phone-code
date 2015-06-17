#ifndef _PRPlayerFightInfo_H_
#define _PRPlayerFightInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightPlayerInfo.h>

/*返回战斗人员信息*/
class PRPlayerFightInfo : public SMsgHead
{
public:
    uint32 fight_id;    //战斗id 
    std::vector< SFightPlayerInfo > fight_info_list;

    PRPlayerFightInfo() : fight_id(0)
    {
        msg_cmd = 1136960421;
    }

    virtual ~PRPlayerFightInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPlayerFightInfo(*this) );
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
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPlayerFightInfo";
    }
};

#endif
