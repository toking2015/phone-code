#ifndef _CUserMap_H_
#define _CUserMap_H_

#include <weedong/core/seq/seq.h>
#include <proto/user/SUser.h>

/*============================数据中心========================*/
class CUserMap : public wd::CSeq
{
public:
    std::map< uint32, SUser > user_map;    //用户数据集合
    int32 save_index;    //数据保存索引
    std::map< std::string, uint32 > user_name_id;    //名称映射id
    std::map< uint32, std::string > user_id_name;    //id映射名称

    CUserMap() : save_index(0)
    {
    }

    virtual ~CUserMap()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CUserMap(*this) );
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
            && TFVarTypeProcess( user_map, eType, stream, uiSize )
            && TFVarTypeProcess( save_index, eType, stream, uiSize )
            && TFVarTypeProcess( user_name_id, eType, stream, uiSize )
            && TFVarTypeProcess( user_id_name, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CUserMap";
    }
};

#endif
