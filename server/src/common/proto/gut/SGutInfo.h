#ifndef _SGutInfo_H_
#define _SGutInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>

/*剧情-黄少卿*/
class SGutInfo : public wd::CSeq
{
public:
    uint32 gut_id;
    int32 index;    //当前事件索引, 从0开始( 不保存数据库 )
    std::vector< S3UInt32 > event;    //剧情列表, cate见 kGutTypeXXX

    SGutInfo() : gut_id(0), index(0)
    {
    }

    virtual ~SGutInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGutInfo(*this) );
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
            && TFVarTypeProcess( gut_id, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && TFVarTypeProcess( event, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGutInfo";
    }
};

#endif
