#ifndef _SAuthRunData_H_
#define _SAuthRunData_H_

#include <weedong/core/seq/seq.h>
/*用于全局循环执行指令数据*/
class SAuthRunData : public wd::CSeq
{
public:
    uint32 guid;    //唯一guid, 由 mysql insert 时生成
    uint32 loop_id;    //AddLoop 后生成的 loop_id
    std::string json_string;    //执行数据

    SAuthRunData() : guid(0), loop_id(0)
    {
    }

    virtual ~SAuthRunData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SAuthRunData(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( loop_id, eType, stream, uiSize )
            && TFVarTypeProcess( json_string, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SAuthRunData";
    }
};

#endif
