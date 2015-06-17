#include <weedong/core/seq/seq_parser.h>

namespace wd
{

CSeqEle::EVarType CSeqEle::name2type( std::string type )
{
    if ( type == "int8" )
        return CSeqEle::eInt8;
    if ( type == "uint8" )
        return CSeqEle::eUint8;
    if ( type == "int16" )
        return CSeqEle::eInt16;
    if ( type == "uint16" )
        return CSeqEle::eUint16;
    if ( type == "int32" )
        return CSeqEle::eInt32;
    if ( type == "uint32" )
        return CSeqEle::eUint32;
    if ( type == "float" )
        return CSeqEle::eFloat;
    if ( type == "double" )
        return CSeqEle::eDouble;
    if ( type == "string" )
        return CSeqEle::eString;
    if ( type == "array" )
        return CSeqEle::eArray;
    if ( type == "map" )
        return CSeqEle::eMap;
    if ( type == "indices" )
        return CSeqEle::eIndices;
    if ( type == "bytes" )
        return CSeqEle::eBytes;
    return CSeqEle::eObject;
}

std::list< CSeqLog > CSeqParser::parse( char *start, char *end, CSeqParser::TError& errors )
{
    char* cache_start = start;

    std::list< CSeqLog > classLog;

    std::list< std::pair< char*, std::string > > error_info;

    while ( gotoNextChar( start, end ) )
    {
        CSeqLog log;
        if ( parseClassDeclare( start, end, log, error_info ) )
            classLog.push_back( log );
        else
            break;
    }

    for ( std::list< std::pair< char*, std::string > >::iterator iter = error_info.begin();
        iter != error_info.end();
        ++iter )
    {
        errors.push_back( std::pair< int32, std::string >( getLineNum( cache_start, iter->first ), iter->second ) );
    }

    return classLog;
}

int32 CSeqParser::getLineNum( char* start, char* end )
{
    int32 num = 1;

    for ( ; start != '\0' && start < end; ++start )
    {
        if ( *start == '\n' )
            ++num;
    }

    return num;
}

bool CSeqParser::parseClassDeclare( char* &start, char *end, wd::CSeqLog &log, std::list< std::pair< char*, std::string > > &error_info )
{
    for( char chr = *start; chr != '\0'; chr = *start )
    {
        switch ( chr )
        {
            //类注释
        case '/':
            log.classDescript = takeNextRemake( start, end );
            break;

            //取得下一个可解释字符串
        case '\r':
        case '\n':
        case ' ':
        case '\t':
            gotoNextChar( start, end );
            break;

        case '#':
            gotoNextLine( start, end );
            break;

            //不应该出现;号
        case ';':
            ++start;
            pushErrorInfo( error_info, start, "不应该出现的符号 ';'" );
            break;
        case ':':
            log.classParent = takeNextWord( ++start, end );
            if ( log.classParent.empty() )
                pushErrorInfo( error_info, start, "类继承缺少父类名称" );
            break;
        case '{':
            parseClassInfo( ++start, end, log, error_info );
            return true;
        default:
            if ( !checkChar( chr ) )
            {
                pushErrorInfo( error_info, start, "遇到不可解释的符号, 期望是一个字母、数字和半角下划线" );
                return false;
            }

            log.className = takeNextWord( start, end );
            if ( log.className.empty() )
            {
                pushErrorInfo( error_info, start, "声明类时缺失类名声明" );
                return false;
            }
            break;
        }
    }

    pushErrorInfo( error_info, start, ( "找不到类 [" + log.className + "] 的 '{' , 类定义失败" ).c_str() );
    return false;
}

bool CSeqParser::parseClassInfo( char* &start, char *end, wd::CSeqLog &log, std::list< std::pair< char*, std::string > > &error_info )
{
    std::string str;

    for( char chr = *start; chr != '\0'; chr = *start )
    {
        switch ( chr )
        {
        //类注释
        case '/':
            takeNextRemake( start, end );
            break;
        case '{':
            parseClassConstruct( ++start, end, log, error_info );
            break;
        case '}':
            ++start;
            return true;
        case '\r':
        case '\n':
        case ' ':
        case '\t':
            gotoNextChar( start, end );
            break;
        case ';':
            {
                if ( !str.empty() )
                    pushErrorInfo( error_info, start, "不可解释的语法分号 ';' " );

                gotoNextLine( start, end );
            }
            break;
        case ':':
            {
                CSeqEle data;
                data.eleName = str;
                str.clear();

                parseElement( ++start, end, data, error_info );

                if ( data.eleType.empty() )
                {
                    pushErrorInfo( error_info, start, "变量类型解释失败" );
                    break;
                }

                log.eleList.push_back( data );
            }
            break;
        default:
            {
                if ( !str.empty() )
                    pushErrorInfo( error_info, start, ( "解释器未使用的字符串 [" + str + "]" ).c_str() );

                str = takeNextWord( start, end );
                if ( str.empty() )
                {
                    pushErrorInfo( error_info, start, "解释字符串错误" );
                    return false;
                }
            }
            break;
        }
    }

    return false;
}

bool CSeqParser::parseClassConstruct( char* &start, char *end, wd::CSeqLog &log, std::list< std::pair< char*, std::string > > &error_info )
{
    std::string str;

    gotoNextChar( start, end );

    for( char chr = *start; chr != '\0'; chr = *start )
    {
        switch ( chr )
        {
        case '}':
            ++start;
            return true;
        case '\r':
        case '\n':
        case ' ':
        case '\t':
            gotoNextChar( start, end );
            break;
        case '=':
            {
                CSeqInit data;
                data.eleName = str;

                str.clear();

                parseInit( ++start, end, data, error_info );

                if ( data.eleName.empty() )
                {
                    pushErrorInfo( error_info, start, "缺少变量名" );
                    break;
                }
                if ( data.eleDefault.empty() )
                {
                    pushErrorInfo( error_info, start, "变量缺少符值" );
                    break;
                }

                log.initList.push_back( data );
            }
            break;
        case ';':
            gotoNextLine( start, end );
            break;
        default:
            if ( !str.empty() )
                pushErrorInfo( error_info, start, ( "字符串 [" + str + "] 解释器未正确使用" ).c_str() );

            str = takeNextWord( start, end );
            break;
        }
    }

    return false;
}

bool CSeqParser::parseElement( char* &start, char *end, CSeqEle &ele, std::list< std::pair< char*, std::string > > &error_info )
{
    ele.eleType = takeNextWord( start, end );

    for( char chr = *start; chr != '\0'; chr = *start )
    {
        switch ( chr )
        {
        case ';':
            ++start;
            break;
        case ' ':
        case '\t':
        case '\r':
            ++start;
            break;
        case '\n':
            ++start;
            return true;
        case '}':
            return true;
        case '>':
            ++start;
            break;
        case '=':
            ele.eleDefault = takeNextSyntax( ++start, end );
            if ( ele.eleDefault.empty() )
                pushErrorInfo( error_info, start, "变量声明初始化错误" );
            break;
        case '/':
            ele.eleDescript = takeNextRemake( start, end );
            break;
        case '<':
            ele.eleObject.resize(1);
            parseElement( ++start, end, *ele.eleObject.begin(), error_info );
            ele.eleDescript = ele.eleObject.begin()->eleDescript;
            break;
        default:
            return true;
        }
    }

    return true;
}

bool CSeqParser::parseInit( char* &start, char *end, CSeqInit &init, std::list< std::pair< char*, std::string > > &error_info )
{
    for( char chr = *start; chr != '\0'; chr = *start )
    {
        switch ( chr )
        {
        case ';':
            ++start;
            break;
        case ' ':
        case '\t':
        case '\r':
            ++start;
            break;
        case '\n':
            ++start;
            return true;
        case '}':
            return true;
        case '/':
            init.eleDescript = takeNextRemake( start, end );
            break;
        default:
            init.eleDefault = takeNextSyntax( start, end );
            break;
        }
    }

    pushErrorInfo( error_info, start, "找不到构造函数行结束符" );

    return false;
}

bool CSeqParser::checkChar( char chr )
{
    return ( ( chr >= 'a' && chr <= 'z' ) || ( chr >= 'A' && chr <= 'Z' ) || ( chr >= '0' && chr <= '9' ) ||  chr == '_' || chr == '*' );
}

bool CSeqParser::gotoNextChar( char* &start, char *end )
{
    while ( start < end && *start != '\0' )
    {
        switch ( *start )
        {
        case ' ':
        case '\t':
        case '\r':
        case '\n':
            ++start;
            break;
        default:
            return true;
        }
    }

    return false;
}

bool CSeqParser::gotoNextLine( char* &start, char *end )
{
    while ( *start != '\r' && *start != '\n' )
        ++start;

    while ( *start == '\r' || *start == '\n' )
        ++start;

    return true;
}

std::string CSeqParser::takeNext( char* &start, char *end )
{
    while ( !checkChar( *start ) && *start != '/' )
        ++start;

    if ( checkChar( *start ) )
        return takeNextWord( start, end );

    return takeNextRemake( start, end );
}

std::string CSeqParser::takeNextRemake( char* &start, char *end )
{
    while ( *start != '/' )
        ++start;

    char *src = start + 2;
    int makeChrCount = 0;

    if ( start[1] == '/' )
    {
        makeChrCount = 1;

        while ( *start != '\r' && *start != '\n' )
            ++start;
    }
    else
    {
        makeChrCount = 2;

        for ( ++start; !(start[0] == '*' && start[1] == '/'); )
            ++start;
    }

    std::string str( start - src, 0 );
    memcpy( &str[0], src, start - src );

    start += makeChrCount;

    return str;
}

std::string CSeqParser::takeNextSyntax( char* &start, char *end )
{
    gotoNextChar( start, end );

    char *src = start;
    while ( *start != ';' )
        ++start;

    std::string str( start - src, 0 );
    memcpy( &str[0], src, start - src );

    ++start;

    return str;
}

std::string CSeqParser::takeNextWord( char* &start, char *end )
{
    gotoNextChar( start, end );

    char *src = start;
    for ( ; *start != '\0' && start < end; ++start)
    {
        if ( checkChar( *start ) )
            continue;
        break;
    }

    std::string str( start - src, 0 );
    memcpy( &str[0], src, start - src );

    return str;
}

void CSeqParser::pushErrorInfo( std::list< std::pair< char*, std::string > > &error_info, char* address, const char* info )
{
    error_info.push_back( std::pair< char*, std::string >( address, info ) );
}

}

