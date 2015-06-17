#ifndef _CCopy_H_
#define _CCopy_H_

#include <weedong/core/seq/seq.h>
#include <proto/copy/SCopyBossFight.h>
#include <proto/copy/SCopyFightLog.h>

/*=========================数据中心========================*/
class CCopy : public wd::CSeq
{
public:
    std::map< uint32, SCopyBossFight > boss_fight;
    std::map< uint32, std::vector< SCopyFightLog > > copy_log_map;    //副本战斗记录保存
    uint32 is_load_copyfight_log;    //是否已经load副本记录

    CCopy() : is_load_copyfight_log(0)
    {
    }

    virtual ~CCopy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CCopy(*this) );
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
            && TFVarTypeProcess( boss_fight, eType, stream, uiSize )
            && TFVarTypeProcess( copy_log_map, eType, stream, uiSize )
            && TFVarTypeProcess( is_load_copyfight_log, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CCopy";
    }
};

#endif
