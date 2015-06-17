#ifndef _PQCopyBossMopup_H_
#define _PQCopyBossMopup_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*副本扫荡*/
class PQCopyBossMopup : public SMsgHead
{
public:
    uint8 mopup_type;    //副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
    uint32 boss_id;    //monster_id
    uint32 count;    //扫荡次数

    PQCopyBossMopup() : mopup_type(0), boss_id(0), count(0)
    {
        msg_cmd = 730523402;
    }

    virtual ~PQCopyBossMopup()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyBossMopup(*this) );
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
            && TFVarTypeProcess( mopup_type, eType, stream, uiSize )
            && TFVarTypeProcess( boss_id, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCopyBossMopup";
    }
};

#endif
