#ifndef _PRFightApply_H_
#define _PRFightApply_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRFightApply : public SMsgHead
{
public:
    uint16 fight_type;    //战斗类型
    uint32 target_id;    //目标的怪物id
    uint32 box_randomseed;    //宝箱随机种子
    uint32 fight_randomseed;    //战斗随机种子

    PRFightApply() : fight_type(0), target_id(0), box_randomseed(0), fight_randomseed(0)
    {
        msg_cmd = 1284627732;
    }

    virtual ~PRFightApply()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFightApply(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( fight_type, type, stream, uiSize )
            && TFVarTypeProcess( target_id, type, stream, uiSize )
            && TFVarTypeProcess( box_randomseed, type, stream, uiSize )
            && TFVarTypeProcess( fight_randomseed, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
};

#endif
