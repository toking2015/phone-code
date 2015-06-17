#ifndef _SUserEquipGrade_H_
#define _SUserEquipGrade_H_

#include <weedong/core/seq/seq.h>
/*=========================常量声明=======================*/
class SUserEquipGrade : public wd::CSeq
{
public:
    uint32 equip_type;
    uint32 level;
    uint32 grade;

    SUserEquipGrade() : equip_type(0), level(0), grade(0)
    {
    }

    virtual ~SUserEquipGrade()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserEquipGrade(*this) );
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
            && TFVarTypeProcess( equip_type, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( grade, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserEquipGrade";
    }
};

#endif
