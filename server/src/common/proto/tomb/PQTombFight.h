#ifndef _PQTombFight_H_
#define _PQTombFight_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/formation/SUserFormation.h>

/*战斗*/
class PQTombFight : public SMsgHead
{
public:
    uint32 player_index;    //玩家位置 从0开始
    uint32 player_guid;    //玩家GUID
    std::vector< SUserFormation > formation_list;    //试炼阵型

    PQTombFight() : player_index(0), player_guid(0)
    {
        msg_cmd = 934860173;
    }

    virtual ~PQTombFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTombFight(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( player_index, eType, stream, uiSize )
            && TFVarTypeProcess( player_guid, eType, stream, uiSize )
            && TFVarTypeProcess( formation_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTombFight";
    }
};

#endif
