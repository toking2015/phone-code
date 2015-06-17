#ifndef _SActivityData_H_
#define _SActivityData_H_

#include <weedong/core/seq/seq.h>
/*活动数据*/
class SActivityData : public wd::CSeq
{
public:
    uint32 guid;    //唯一
    std::string group;
    uint32 type;    //kActivityDataTypeFirtPay
    uint32 cycle;    //周期      天
    std::string name;
    std::string desc;
    std::vector< std::string > value_list;    //条件奖励值  1%2    1=if_map.key   2=reward_map.key   

    SActivityData() : guid(0), type(0), cycle(0)
    {
    }

    virtual ~SActivityData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SActivityData(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( group, eType, stream, uiSize )
            && TFVarTypeProcess( type, eType, stream, uiSize )
            && TFVarTypeProcess( cycle, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( desc, eType, stream, uiSize )
            && TFVarTypeProcess( value_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SActivityData";
    }
};

#endif
