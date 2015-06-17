#ifndef _SFightRecord_H_
#define _SFightRecord_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightRecordSimple.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightPlayerInfo.h>

class SFightRecord : public SFightRecordSimple
{
public:
    uint32 fight_id;    //战斗
    uint32 fight_type;    //战斗类型
    uint32 fight_randomseed;    //战斗随机种子
    std::vector< SFightOrder > order_list;    //战斗技能出手LOG
    std::vector< SFightPlayerInfo > fight_info_list;    //战斗人员时候的信息

    SFightRecord() : fight_id(0), fight_type(0), fight_randomseed(0)
    {
    }

    virtual ~SFightRecord()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightRecord(*this) );
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
        return SFightRecordSimple::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_type, eType, stream, uiSize )
            && TFVarTypeProcess( fight_randomseed, eType, stream, uiSize )
            && TFVarTypeProcess( order_list, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightRecord";
    }
};

#endif
