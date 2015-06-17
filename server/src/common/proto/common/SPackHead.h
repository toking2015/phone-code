#ifndef _SPackHead_H_
#define _SPackHead_H_

#include <weedong/core/seq/seq.h>
/*通讯包头-黄少卿*/
class SPackHead : public wd::CSeq
{
public:
    uint16 pack_flag;    //数据包头标识
    uint8 pack_st;    //位移标志 第1位1表示压缩协议0表示未压缩协议
    uint8 pack_crypt;    //加密标志, 0 为不加密
    uint32 pack_length;    //数据包长度
    uint32 pack_checksum;    //数据校验和

    SPackHead()
    {
        pack_flag = 0xe1c7;
        pack_st = 0;
        pack_crypt = 1;
        pack_length = 0;
        pack_checksum = 0;
    }

    virtual ~SPackHead()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SPackHead(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eWrite, uiSize ) &&
            loopend( stream, CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( pack_flag, type, stream, uiSize )
            && TFVarTypeProcess( pack_st, type, stream, uiSize )
            && TFVarTypeProcess( pack_crypt, type, stream, uiSize )
            && TFVarTypeProcess( pack_length, type, stream, uiSize )
            && TFVarTypeProcess( pack_checksum, type, stream, uiSize );
    }
};

#endif
