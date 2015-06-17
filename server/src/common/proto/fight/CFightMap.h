#ifndef _CFightMap_H_
#define _CFightMap_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFight.h>
#include <proto/fight/CFightData.h>

/*============================数据中心========================*/
class CFightMap : public wd::CSeq
{
public:
    std::map< uint32, SFight > fight_map;    //战斗数据
    std::map< uint32, CFightData > fight_lua_map;    //Lua战斗数据
    uint32 fight_id;

    CFightMap() : fight_id(0)
    {
    }

    virtual ~CFightMap()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CFightMap(*this) );
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
            && TFVarTypeProcess( fight_map, eType, stream, uiSize )
            && TFVarTypeProcess( fight_lua_map, eType, stream, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CFightMap";
    }
};

#endif
