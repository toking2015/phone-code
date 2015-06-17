#ifndef _SFightOdd_H_
#define _SFightOdd_H_

#include <weedong/core/seq/seq.h>
/*BUFF或者DEBUFF*/
class SFightOdd : public wd::CSeq
{
public:
    uint32 id;    //异常ID                                                
    uint8 level;    //异常等级                                              
    uint16 start_round;    //异常开始回合 会更新
    uint16 begin_round;    //异常开始回合 不会更新
    uint16 status_id;    //产生状态ID
    uint32 status_value;    //产生状态ID对应的Value
    uint32 ext_value;    //用于各种特殊情况
    uint32 use_guid;    //使用者的id
    uint32 use_count;    //使用次数
    uint32 now_count;    //现在的层数
    uint32 delFlag;    //删除标记

    SFightOdd() : id(0), level(0), start_round(0), begin_round(0), status_id(0), status_value(0), ext_value(0), use_guid(0), use_count(0), now_count(0), delFlag(0)
    {
    }

    virtual ~SFightOdd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightOdd(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( start_round, eType, stream, uiSize )
            && TFVarTypeProcess( begin_round, eType, stream, uiSize )
            && TFVarTypeProcess( status_id, eType, stream, uiSize )
            && TFVarTypeProcess( status_value, eType, stream, uiSize )
            && TFVarTypeProcess( ext_value, eType, stream, uiSize )
            && TFVarTypeProcess( use_guid, eType, stream, uiSize )
            && TFVarTypeProcess( use_count, eType, stream, uiSize )
            && TFVarTypeProcess( now_count, eType, stream, uiSize )
            && TFVarTypeProcess( delFlag, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightOdd";
    }
};

#endif
