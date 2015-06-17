#ifndef _PRCopyBossMopup_H_
#define _PRCopyBossMopup_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

/*返回扫荡结果*/
class PRCopyBossMopup : public SMsgHead
{
public:
    uint8 mopup_type;
    uint32 boss_id;
    std::vector< std::vector< S3UInt32 > > coins;    //扫荡获得, 一维数组为扫荡次数索引

    PRCopyBossMopup() : mopup_type(0), boss_id(0)
    {
        msg_cmd = 2079542214;
    }

    virtual ~PRCopyBossMopup()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyBossMopup(*this) );
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
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyBossMopup";
    }
};

#endif
