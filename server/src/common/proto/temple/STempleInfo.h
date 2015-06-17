#ifndef _STempleInfo_H_
#define _STempleInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/temple/STempleGroup.h>
#include <proto/temple/STempleGlyph.h>
#include <proto/common/S2UInt32.h>

/* 神殿信息*/
class STempleInfo : public wd::CSeq
{
public:
    uint32 hole_cloth;    // 布甲神符格数量
    uint32 hole_leather;    // 皮甲神符格数量
    uint32 hole_mail;    // 锁甲神符格数量
    uint32 hole_plate;    // 板甲神符格数量
    std::vector< STempleGroup > group_list;    // 组合列表
    std::vector< STempleGlyph > glyph_list;    // 神符列表
    std::vector< uint32 > score_taken_list;    // 积分奖励领取列表
    std::map< uint32, S2UInt32 > score_current;    // 当前积分，key为kTempleScoreXXX，first为次数，second为积分
    std::map< uint32, S2UInt32 > score_yesterday;    // 昨日积分，key为kTempleScoreXXX，first为次数，second为积分

    STempleInfo() : hole_cloth(0), hole_leather(0), hole_mail(0), hole_plate(0)
    {
    }

    virtual ~STempleInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STempleInfo(*this) );
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
            && TFVarTypeProcess( hole_cloth, eType, stream, uiSize )
            && TFVarTypeProcess( hole_leather, eType, stream, uiSize )
            && TFVarTypeProcess( hole_mail, eType, stream, uiSize )
            && TFVarTypeProcess( hole_plate, eType, stream, uiSize )
            && TFVarTypeProcess( group_list, eType, stream, uiSize )
            && TFVarTypeProcess( glyph_list, eType, stream, uiSize )
            && TFVarTypeProcess( score_taken_list, eType, stream, uiSize )
            && TFVarTypeProcess( score_current, eType, stream, uiSize )
            && TFVarTypeProcess( score_yesterday, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STempleInfo";
    }
};

#endif
