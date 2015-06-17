#ifndef _SUserCopy_H_
#define _SUserCopy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>
#include <proto/fight/SFight.h>
#include <proto/common/SInteger.h>
#include <proto/gut/SGutInfo.h>

/*副本结构*/
class SUserCopy : public wd::CSeq
{
public:
    uint32 copy_id;    //副本Id
    int32 posi;    //当前进度(从0开始)
    int32 index;    //当前进度内的步骤索引
    uint32 status;    //副本状态[ kCopyStateXXX ]
    std::vector< S3UInt32 > chunk;    //事件列表, cate 见 kCopyEvnetXYZ
    std::vector< S3UInt32 > reward;    //奖励列表, [ cate: [0不要体力, 1需要体力], objid: reward_id, val: 完成度 ]
    std::vector< std::vector< S3UInt32 > > coins;    //掉落列表
    std::map< uint32, SFight > fight;    //chunk 对应的战斗Id
    std::map< uint32, SInteger > seed;    //chunk 对应的战斗种子
    std::map< uint32, SGutInfo > gut;    //剧情列表

    SUserCopy() : copy_id(0), posi(0), index(0), status(0)
    {
    }

    virtual ~SUserCopy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserCopy(*this) );
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
            && TFVarTypeProcess( copy_id, eType, stream, uiSize )
            && TFVarTypeProcess( posi, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && TFVarTypeProcess( status, eType, stream, uiSize )
            && TFVarTypeProcess( chunk, eType, stream, uiSize )
            && TFVarTypeProcess( reward, eType, stream, uiSize )
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && TFVarTypeProcess( fight, eType, stream, uiSize )
            && TFVarTypeProcess( seed, eType, stream, uiSize )
            && TFVarTypeProcess( gut, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserCopy";
    }
};

#endif
