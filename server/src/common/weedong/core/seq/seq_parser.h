#ifndef _WEEDONG_CORE_SEQ_SEQPARSER_H_
#define _WEEDONG_CORE_SEQ_SEQPARSER_H_

#include <weedong/core/seq/seq.h>

#include <string>
#include <list>
#include <fstream>

namespace wd
{

/*************************************************
  Description:      // 序列化记录类的成员类结构
  Other:            // 记录序列化类的成员基本信息
*************************************************/
class CSeqEle : public wd::CSeq
{
public:
    enum EVarType
    {
        eUnknow,
        eInt8,
        eUint8,
        eInt16,
        eUint16,
        eInt32,
        eUint32,
        eFloat,
        eDouble,
        eString,
        eObject,
        eArray,
        eMap,
        eIndices,
        eBytes,
    };
public:
    std::string eleType;    //变量类型
    std::string eleName;    //变量名称
    std::string eleDefault;    //变量默认值
    std::string eleDescript;    //变量说明
    std::vector< CSeqEle > eleObject;    //对象数组类型

    CSeqEle()
    {
    }

    bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eWrite, uiSize );
    }
    bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, CSeq::ELoopType type, uint32 &uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( eleType, type, stream, uiSize )
            && TFVarTypeProcess( eleName, type, stream, uiSize )
            && TFVarTypeProcess( eleDefault, type, stream, uiSize )
            && TFVarTypeProcess( eleDescript, type, stream, uiSize )
            && TFVarTypeProcess( eleObject, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }

    static EVarType name2type( std::string type );
};

/*************************************************
  Description:      // 序列化记录类的初始化结构
  Other:            // 记录序列化类的初始化基本信息
*************************************************/
class CSeqInit : public wd::CSeq
{
public:
    std::string eleName;    //变量名称
    std::string eleDefault;    //变量默认值
    std::string eleDescript;    //变量说明

    CSeqInit()
    {
    }

    bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eWrite, uiSize );
    }
    bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, CSeq::ELoopType type, uint32 &uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( eleName, type, stream, uiSize )
            && TFVarTypeProcess( eleDefault, type, stream, uiSize )
            && TFVarTypeProcess( eleDescript, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
};

/*************************************************
  Description:      // 序列化记录类的信息结构
  Other:            // 记录序列化类的基本信息
*************************************************/
class CSeqLog : public wd::CSeq
{
public:
    std::string className;    //类名称
    std::string classParent;    //父类名称
    std::string classDescript;    //类说明
    std::vector< CSeqEle > eleList;    //成员数组
    std::vector< CSeqInit > initList;    //初始化数组

    CSeqLog()
    {
    }

    bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eWrite, uiSize );
    }
    bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, CSeq::ELoopType type, uint32 &uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( className, type, stream, uiSize )
            && TFVarTypeProcess( classParent, type, stream, uiSize )
            && TFVarTypeProcess( classDescript, type, stream, uiSize )
            && TFVarTypeProcess( eleList, type, stream, uiSize )
            && TFVarTypeProcess( initList, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
};

class CSeqParser
{
public:
    enum EParseState
    {
        eClassDef = 1,
        eConstruct = 2,
    };
    typedef std::list< std::pair< int32, std::string > > TError;

public:
    /*************************************************
    Description:    将序列化记录基本信息解释为seqlog
    Input:          start 需要解释的基本信息起始指针
                    end 需要解释的基本信息结束指针
    Output:         errors 解释器出现错误的行数
    Return:         类记录列表
    *************************************************/
    static std::list< CSeqLog > parse( char *start, char *end, TError& errors );

private:
    static bool parseClassDeclare( char* &start, char *end, wd::CSeqLog &log, std::list< std::pair< char*, std::string > > &error_info );
    static bool parseClassInfo( char* &start, char *end, wd::CSeqLog &log, std::list< std::pair< char*, std::string > > &error_info );
    static bool parseClassConstruct( char* &start, char *end, wd::CSeqLog &log, std::list< std::pair< char*, std::string > > &error_info );
    static bool parseElement( char* &start, char *end, CSeqEle &ele, std::list< std::pair< char*, std::string > > &error_info );
    static bool parseInit( char* &start, char *end, CSeqInit &init, std::list< std::pair< char*, std::string > > &error_info );

private:
    static void pushErrorInfo( std::list< std::pair< char*, std::string > > &error_info, char* address, const char* info );
    static int32 getLineNum( char* start, char* end );

private:
    static bool checkChar( char chr );
    static bool gotoNextChar( char* &start, char *end );
    static bool gotoNextLine( char* &start, char *end );
    static std::string takeNext( char* &start, char *end );
    static std::string takeNextRemake( char* &start, char *end );
    static std::string takeNextSyntax( char* &start, char *end );
    static std::string takeNextWord( char* &start, char *end );
};

}

#endif

