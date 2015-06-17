#ifndef _SActivityOpen_H_
#define _SActivityOpen_H_

#include <weedong/core/seq/seq.h>
/*活动时间数据*/
class SActivityOpen : public wd::CSeq
{
public:
    uint32 guid;
    std::string group;    //平台   NULL所有平台
    std::string name;
    uint32 data_id;    //<对应 SActivityData中的guid>
    uint32 type;    //kActivityTimeTypeBound
    std::string first_time;
    std::string second_time;
    uint32 show_time;
    uint32 hide_time;

    SActivityOpen() : guid(0), data_id(0), type(0), show_time(0), hide_time(0)
    {
    }

    virtual ~SActivityOpen()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SActivityOpen(*this) );
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
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( data_id, eType, stream, uiSize )
            && TFVarTypeProcess( type, eType, stream, uiSize )
            && TFVarTypeProcess( first_time, eType, stream, uiSize )
            && TFVarTypeProcess( second_time, eType, stream, uiSize )
            && TFVarTypeProcess( show_time, eType, stream, uiSize )
            && TFVarTypeProcess( hide_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SActivityOpen";
    }
};

#endif
