#ifndef _PRSingleBattleReply_H_
#define _PRSingleBattleReply_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

class PRSingleBattleReply : public SMsgHead
{
public:
    uint32 cur_rank;    //当前排名（最高排名也是这）
    uint32 win_flag;    //羸：kFightLeft 输: kFightRight
    uint32 add_rank;    //增加的名次
    S3UInt32 coin;    //奖励

    PRSingleBattleReply() : cur_rank(0), win_flag(0), add_rank(0)
    {
        msg_cmd = 1876563788;
    }

    virtual ~PRSingleBattleReply()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleBattleReply(*this) );
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
            && TFVarTypeProcess( cur_rank, eType, stream, uiSize )
            && TFVarTypeProcess( win_flag, eType, stream, uiSize )
            && TFVarTypeProcess( add_rank, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleBattleReply";
    }
};

#endif
