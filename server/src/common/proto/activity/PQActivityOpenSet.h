#ifndef _PQActivityOpenSet_H_
#define _PQActivityOpenSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityOpen.h>

/*更新数据  -SActivityOpen*/
class PQActivityOpenSet : public SMsgHead
{
public:
    uint32 guid;    //type = kObjectDel 有用
    uint32 type;    //kObjectAdd  kObjectDel
    SActivityOpen open;    //type = kObjectAdd 有用

    PQActivityOpenSet() : guid(0), type(0)
    {
        msg_cmd = 345420440;
    }

    virtual ~PQActivityOpenSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQActivityOpenSet(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( type, eType, stream, uiSize )
            && TFVarTypeProcess( open, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQActivityOpenSet";
    }
};

#endif
