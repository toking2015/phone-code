#ifndef _SUserSingleArenaPanel_H_
#define _SUserSingleArenaPanel_H_

#include <weedong/core/seq/seq.h>
#include <proto/user/SUserPanel.h>
#include <proto/formation/SUserFormation.h>
#include <proto/soldier/SUserSoldier.h>
#include <proto/totem/STotemInfo.h>

class SUserSingleArenaPanel : public SUserPanel
{
public:
    std::vector< SUserFormation > formation_map;    //玩家阵型
    std::map< uint32, SUserSoldier > soldier_map;    //武将列表
    STotemInfo totem_info;    //图腾信息

    SUserSingleArenaPanel()
    {
    }

    virtual ~SUserSingleArenaPanel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserSingleArenaPanel(*this) );
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
        return SUserPanel::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( formation_map, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_map, eType, stream, uiSize )
            && TFVarTypeProcess( totem_info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserSingleArenaPanel";
    }
};

#endif
