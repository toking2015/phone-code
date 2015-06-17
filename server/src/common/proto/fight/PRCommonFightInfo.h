#ifndef _PRCommonFightInfo_H_
#define _PRCommonFightInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightPlayerInfo.h>

/*返回战斗人员信息*/
class PRCommonFightInfo : public SMsgHead
{
public:
    uint32 fight_id;    //战斗id
    uint32 fight_type;    //战斗类型
    uint32 fight_randomseed;    //战斗随机种子
    std::vector< SFightPlayerInfo > fight_info_list;

    PRCommonFightInfo() : fight_id(0), fight_type(0), fight_randomseed(0)
    {
        msg_cmd = 1926767447;
    }

    virtual ~PRCommonFightInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCommonFightInfo(*this) );
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
            && TFVarTypeProcess( fight_type, eType, stream, uiSize )
            && TFVarTypeProcess( fight_randomseed, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCommonFightInfo";
    }
};

#endif
