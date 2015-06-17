#ifndef _PQEquipMerge_H_
#define _PQEquipMerge_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@合成*/
class PQEquipMerge : public SMsgHead
{
public:
    uint32 id;    //物品合成的ID

    PQEquipMerge() : id(0)
    {
        msg_cmd = 499293600;
    }

    virtual ~PQEquipMerge()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQEquipMerge(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQEquipMerge";
    }
};

#endif
