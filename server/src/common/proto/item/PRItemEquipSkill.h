#ifndef _PRItemEquipSkill_H_
#define _PRItemEquipSkill_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRItemEquipSkill : public SMsgHead
{
public:
    uint32 result;    //结果

    PRItemEquipSkill() : result(0)
    {
        msg_cmd = 1691421581;
    }

    virtual ~PRItemEquipSkill()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRItemEquipSkill(*this) );
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
            && TFVarTypeProcess( result, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRItemEquipSkill";
    }
};

#endif
