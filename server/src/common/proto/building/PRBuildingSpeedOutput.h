#ifndef _PRBuildingSpeedOutput_H_
#define _PRBuildingSpeedOutput_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRBuildingSpeedOutput : public SMsgHead
{
public:
    uint32 building_type;    //建筑类型
    std::vector< uint32 > list_crit_times;    //暴击列表 
    uint32 add_value;    //加速得到的产出

    PRBuildingSpeedOutput() : building_type(0), add_value(0)
    {
        msg_cmd = 1539609863;
    }

    virtual ~PRBuildingSpeedOutput()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRBuildingSpeedOutput(*this) );
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
            && TFVarTypeProcess( building_type, eType, stream, uiSize )
            && TFVarTypeProcess( list_crit_times, eType, stream, uiSize )
            && TFVarTypeProcess( add_value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRBuildingSpeedOutput";
    }
};

#endif
