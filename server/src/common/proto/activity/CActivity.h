#ifndef _CActivity_H_
#define _CActivity_H_

#include <weedong/core/seq/seq.h>
#include <proto/activity/SActivityOpen.h>
#include <proto/activity/SActivityData.h>
#include <proto/activity/SActivityFactor.h>
#include <proto/activity/SActivityReward.h>

/*=========================数据中心==========================*/
class CActivity : public wd::CSeq
{
public:
    std::map< uint32, SActivityOpen > open_map;    //活动时间
    std::map< uint32, SActivityData > data_map;    //活动内容
    std::map< uint32, SActivityFactor > factor_map;    //活动条件
    std::map< uint32, SActivityReward > reward_map;    //活动奖励
    std::map< std::string, uint32 > open_name_map;    //活动名字表        

    CActivity()
    {
    }

    virtual ~CActivity()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CActivity(*this) );
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
            && TFVarTypeProcess( open_map, eType, stream, uiSize )
            && TFVarTypeProcess( data_map, eType, stream, uiSize )
            && TFVarTypeProcess( factor_map, eType, stream, uiSize )
            && TFVarTypeProcess( reward_map, eType, stream, uiSize )
            && TFVarTypeProcess( open_name_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CActivity";
    }
};

#endif
