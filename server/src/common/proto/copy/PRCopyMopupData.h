#ifndef _PRCopyMopupData_H_
#define _PRCopyMopupData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*返回副本扫荡记录*/
class PRCopyMopupData : public SMsgHead
{
public:
    uint8 mopup_type;    //副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
    uint8 mopup_attr;    //副本值类型 [ kCopyMopupAttrRound | kCopyMopupAttrTimes | kCopyMopupAttrReset ]
    uint32 boss_id;    //0 为需要将相关类型所有扫荡次数同时重置为 value
    uint32 value;    //扫荡次数

    PRCopyMopupData() : mopup_type(0), mopup_attr(0), boss_id(0), value(0)
    {
        msg_cmd = 1230975462;
    }

    virtual ~PRCopyMopupData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyMopupData(*this) );
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
            && TFVarTypeProcess( mopup_type, eType, stream, uiSize )
            && TFVarTypeProcess( mopup_attr, eType, stream, uiSize )
            && TFVarTypeProcess( boss_id, eType, stream, uiSize )
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyMopupData";
    }
};

#endif
