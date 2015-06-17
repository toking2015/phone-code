#ifndef _PQActivityDataSet_H_
#define _PQActivityDataSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityData.h>

/*更新数据  -SActivityData*/
class PQActivityDataSet : public SMsgHead
{
public:
    uint32 guid;    //type = kObjectDel 有用
    uint32 type;    //kObjectAdd  kObjectDel
    SActivityData data;    //type = kObjectAdd 有用        data.id ＝ 0

    PQActivityDataSet() : guid(0), type(0)
    {
        msg_cmd = 1072449212;
    }

    virtual ~PQActivityDataSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQActivityDataSet(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQActivityDataSet";
    }
};

#endif
