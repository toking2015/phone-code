#ifndef _WEEDONG_CORE_SEQ_WRITER_H_
#define _WEEDONG_CORE_SEQ_WRITER_H_

#include <weedong/core/seq/seq_parser.h>

#include <map>
#include <string>
#include <sstream>

namespace wd
{
    
class CSeqWriter
{
public:
    /*************************************************
    Description:     将序列化记录生成C++类文件
    Input:           log 需要生成的类记录文件
    Return:          类记录字符串
    *************************************************/
    static std::string transformCPP( CSeqLog &log );

    /*************************************************
    Description:     将序列化记录生成AS类文件
    Input:           log 需要生成的类记录文件
    Return:          类记录字符串
    *************************************************/
    static std::string transformAS( CSeqLog &log );
    static std::string transformAS( CSeqLog &log, const char* packetPath, std::list<std::string> &import, std::map< std::string, std::string > &classDir );

    /*************************************************
    Description:     将序列化记录生成Seq记录信息文件
    Input:           log 需要生成的类记录文件
    Return:          类记录字符串
    *************************************************/
    static std::string transformSEQ( CSeqLog &log );

    /*************************************************
    Description:     导出序列化记录所依赖的其它对象列表
    Input:           log 需要导出依赖列表的记录文件
    Return:          依赖对象列表
    *************************************************/
    static std::list<std::string> filtrateClass( CSeqLog &log );
};

}

#endif

