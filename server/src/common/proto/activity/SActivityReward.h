#ifndef _SActivityReward_H_
#define _SActivityReward_H_

#include <weedong/core/seq/seq.h>
/*活动奖励*/
class SActivityReward : public wd::CSeq
{
public:
    uint32 guid;    //唯一
    std::string group;
    std::vector< std::string > value_list;

    SActivityReward() : guid(0)
    {
    }

    virtual ~SActivityReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SActivityReward(*this) );
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
            && TFVarTypeProcess( value_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SActivityReward";
    }
};

#endif
