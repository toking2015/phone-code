#ifndef _CGuildMap_H_
#define _CGuildMap_H_

#include <weedong/core/seq/seq.h>
#include <proto/guild/SGuild.h>
#include <proto/guild/SGuildSimple.h>

/*============================数据中心========================*/
class CGuildMap : public wd::CSeq
{
public:
    std::map< uint32, SGuild > guild_map;    //公会数据集合
    std::map< uint32, SGuildSimple > simple_map;    //公会基本数据集合
    std::vector< uint32 > order_member_count;    //根据成员总数排序的公会id列表
    int32 save_index;    //数据保存索引
    std::map< std::string, uint32 > guild_name_id;    //名称映射id
    std::map< uint32, std::string > guild_id_name;    //id映射名称

    CGuildMap() : save_index(0)
    {
    }

    virtual ~CGuildMap()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CGuildMap(*this) );
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
            && TFVarTypeProcess( guild_map, eType, stream, uiSize )
            && TFVarTypeProcess( simple_map, eType, stream, uiSize )
            && TFVarTypeProcess( order_member_count, eType, stream, uiSize )
            && TFVarTypeProcess( save_index, eType, stream, uiSize )
            && TFVarTypeProcess( guild_name_id, eType, stream, uiSize )
            && TFVarTypeProcess( guild_id_name, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CGuildMap";
    }
};

#endif
