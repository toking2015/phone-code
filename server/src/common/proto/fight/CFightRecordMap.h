#ifndef _CFightRecordMap_H_
#define _CFightRecordMap_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S2UInt32.h>

class CFightRecordMap : public wd::CSeq
{
public:
    uint32 is_init;    //是否初始化
    uint32 version;    //版本
    uint32 fight_record_id;    //战斗LOG保存id
    std::map< uint32, S2UInt32 > fight_guid_time_map;    //开始time, <start,end>
    std::map< uint32, uint32 > fight_record_access_map;    //time, 访问时间
    std::map< uint32, uint32 > fight_record_save_map;    //time, 保存时间
    std::map< uint32, std::map< uint32, wd::CStream > > fight_record_map;    //time, 记录List

    CFightRecordMap() : is_init(0), version(0), fight_record_id(0)
    {
    }

    virtual ~CFightRecordMap()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CFightRecordMap(*this) );
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
            && TFVarTypeProcess( is_init, eType, stream, uiSize )
            && TFVarTypeProcess( version, eType, stream, uiSize )
            && TFVarTypeProcess( fight_record_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_guid_time_map, eType, stream, uiSize )
            && TFVarTypeProcess( fight_record_access_map, eType, stream, uiSize )
            && TFVarTypeProcess( fight_record_save_map, eType, stream, uiSize )
            && TFVarTypeProcess( fight_record_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CFightRecordMap";
    }
};

#endif
