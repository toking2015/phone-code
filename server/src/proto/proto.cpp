// 序列化解释器.cpp : 定义控制台应用程序的入口点。
//

#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdarg.h>

#include <list>
#include <map>
#include <string>
#include <iostream>

#include <weedong/core/os.h>
#include <weedong/core/seq/seq_parser.h>
#include <weedong/core/seq/seq_writer.h>

#include "md5.h"

struct SLine
{
    uint32 value;
    std::string name;
    std::string desc;

    SLine() : value(0){}
};

std::string strprintf( const char* format, ... )
{
    std::string str;

    int32 length = 0;
    {
        va_list args;
        va_start(args, format);
        length = vsnprintf( NULL, 0, format, args );
        va_end(args);
    }

    if ( length <= 0 )
        return str;

    va_list args;
    va_start(args, format);

    str.resize( length );
    vsprintf( &str[0], format, args );

    va_end(args);

    return str;
}

struct SMd5Value
{
    union
    {
        uint8 digest[16];
        uint32 values[4];
    };
    SMd5Value()
    {
        values[0] = 0;
        values[1] = 0;
        values[2] = 0;
        values[3] = 0;
    }
    SMd5Value( const SMd5Value& r )
    {
        values[0] = r.values[0];
        values[1] = r.values[1];
        values[2] = r.values[2];
        values[3] = r.values[3];
    }
    bool equal( const SMd5Value& value )
    {
        return values[0] == value.values[0]
            && values[1] == value.values[1]
            && values[2] == value.values[2]
            && values[3] == value.values[3];
    }
    bool operator == ( const SMd5Value& r )
    {
        return equal( r );
    }
    bool operator != ( const SMd5Value& r )
    {
        return !equal( r );
    }
};
char chr_p[] = "0123456789abcdef";
SMd5Value md5_value( uint8* data, uint32 len )
{
    SMd5Value md5_value;

    md5_state_t state;

    md5_init( &state );
    md5_append( &state, data, len );
    md5_finish( &state, md5_value.digest );

    return md5_value;
}

bool gotoNextLine( char* &start, char *end )
{
    while ( start < end && *start != '\r' && *start != '\n' )
        ++start;

    while ( start < end && ( *start == '\r' || *start == '\n' ) )
        ++start;

    return true;
}
SLine parseConstLine( std::string line )
{
    SLine data;

    char space[256] = {0};
    char key[256] = {0};
    char desc[256] = {0};
    unsigned int value = 0;

    //测试是否为无值声明
    int32 count = sscanf( line.c_str(), "%[^ |^\t]%[^0-9]%d", key, space, &value );
    if ( count < 1 )
        return data;

    data.name = key;
    if ( count >= 3 )
    {
        data.value = value;

        //有值声明
        count = sscanf( line.c_str(), "%[^ |^\t]%[^0-9]%d%[^/]//%[^\r|^\n]", key, space, &value, space, desc );

        if ( count >= 5 )
            data.desc = desc;
    }
    else
    {
        data.value = md5_value( (uint8*)data.name.c_str(), (uint32)data.name.size() ).values[0] & 0x7FFFFFFF;

        //无值声明
        count = sscanf( line.c_str(), "%[^ |^\t]%[^/]//%[^\r|^\n]", key, space, desc );

        if ( count >= 3 )
            data.desc = desc;
    }

    return data;
}
SLine parseConstLine( char* &start, char *end )
{
    char* begin = start;

    for ( ;start < end && *start != '\0'; ++start)
    {
        if ( *start == '\r' || *start == '\n' )
            break;
    }

    if ( begin >= start )
        return SLine();

    return parseConstLine( std::string( begin, start ) );
}
std::list< SLine > const_parse( char* cur, char* end )
{
    std::list< SLine > const_list;

    for ( ;cur < end && *cur != '\0'; )
    {
        char chr = *cur;
        switch( chr )
        {
        case '#':
            {
                cur += 1;
                SLine data = parseConstLine( cur, end );
                if ( !data.name.empty() )
                    const_list.push_back( data );
            }
            break;
        default:
            gotoNextLine( cur, end );
            break;
        }
    }

    return const_list;
}

std::string serverPath;
std::string protocolPath;
std::string constantPath;
std::string client_ignore_path;

std::string seqDir;
std::string luaDir;
std::string serverDir;

std::map< std::string, uint32 > proData;
std::list< SLine > consData;

std::map< std::string, bool > clientIgnoreData;
std::map< uint32, std::string > defCmdMap;

std::map< std::string, std::list< wd::CSeqLog > > seqData;
std::map< std::string, std::list< SLine > > constData;
std::map< std::string, uint32 > pathData;

char tabs[] = "    ";

bool DeleteDir( std::string dirname )
{
    DIR* dir = opendir( dirname.c_str() );
    if ( dir == NULL )
        return false;

    for ( dirent* ent = readdir( dir ); ent != NULL; ent = readdir( dir ) )
    {
        std::string filename = ent->d_name;
        if ( filename[0] == '.' )
            continue;

        std::string fullname = dirname + "/" + filename;

        if ( ent->d_type & DT_DIR )
        {
            if ( !DeleteDir( fullname ) )
                return false;
        }
        else
        {
            if ( remove( fullname.c_str() ) != 0 )
                return false;
        }
    }

    if ( remove( dirname.c_str() ) != 0 )
        return false;

    return true;
}

bool ClearEmptyDir( std::string dirname )
{
    DIR* dir = opendir( dirname.c_str() );
    if ( dir == NULL )
        return false;

    bool empty_dir = true;
    for ( dirent* ent = readdir( dir ); ent != NULL; ent = readdir( dir ) )
    {
        std::string filename = ent->d_name;
        if ( filename[0] == '.' )
            continue;

        if ( ent->d_type & DT_DIR )
        {
            if ( !ClearEmptyDir( dirname + "/" + filename ) )
                empty_dir = false;
            else
                DeleteDir( dirname + "/" + filename );
            continue;
        }

        empty_dir = false;
    }

    if ( empty_dir )
        DeleteDir( dirname );

    return empty_dir;
}

std::string GetFileDir( std::string filename )
{
    int idx = (int)filename.find_last_of( "/" );
    if ( idx < 0 )
        return std::string();

    return filename.substr( 0, idx );
}

bool ExistDataFile( std::string dirname )
{
    DIR* dir = opendir( dirname.c_str() );
    if ( dir == NULL )
        return false;

    for ( dirent* ent = readdir( dir ); ent != NULL; ent = readdir( dir ) )
    {
        std::string filename = ent->d_name;
        if ( filename[0] == '.' )
            continue;

        if ( ent->d_type & DT_DIR )
            return true;

        int idx = (int)filename.find_last_of(".");
        if ( idx < 0 )
            continue;

        std::string extname = filename.substr( idx + 1 );
        if ( extname == "h" || extname == "as" )
            return true;
    }

    return false;
}

std::map< std::string, bool > GetFileLogs( std::string dirname )
{
    std::map< std::string, bool > fileLogs;

    DIR* dir = opendir( dirname.c_str() );
    if ( dir == NULL )
        return fileLogs;

    for ( dirent* ent = readdir( dir ); ent != NULL; ent = readdir( dir ) )
    {
        std::string filename = ent->d_name;
        if ( filename[0] == '.' )
            continue;

        if ( ent->d_type & DT_DIR )
        {
            std::map< std::string, bool > logs = GetFileLogs( dirname + filename + "/" );
            fileLogs.insert( logs.begin(), logs.end() );
            continue;
        }

        fileLogs[ dirname + filename ] = true;
    }

    return fileLogs;
}

void ClearFileLogs( std::map< std::string, bool > &fileLogs )
{
    for ( std::map< std::string, bool >::iterator iter = fileLogs.begin();
        iter != fileLogs.end();
        ++iter )
    {
        if ( iter->second )
            remove( iter->first.c_str() );
    }
}

int GetCheckSum( const char *buff, int size )
{
    int sum = 0;
    for ( int i=0; i<size; ++i )
    {
        unsigned char uc = ((unsigned char*)buff)[i];
        sum += uc << ( i % 4 );
    }
    return sum;
}

int GetCheckSum( const char *filename )
{
    std::ifstream input( filename, std::ios_base::in | std::ios_base::binary );
    if ( !input.is_open() )
        return 0;

    std::vector<char> buff;
    input.seekg( 0, std::ios_base::end );
    buff.resize( input.tellg() );
    input.seekg( 0, std::ios_base::beg );

    if ( buff.size() <= 0 )
        return 0;

    input.read( &buff[0], (std::streamsize)buff.size() );
    input.close();

    return GetCheckSum( &buff[0], (int)buff.size() );
}

void WriteToFile( const char *filename, const char *buff, int size )
{
    int chk1 = GetCheckSum( filename );
    int chk2 = GetCheckSum( buff, size );

    if ( chk1 != chk2 )
    {
        std::ofstream output( filename, std::ios_base::out | std::ios_base::binary );
        output.write( buff, size );
        output.close();
    }
}

//WriteH
std::string WriteH( const std::string &path, wd::CSeqLog &log, std::map< std::string, std::string > &classDir, std::map< std::string, bool > &fileLogs )
{
    if ( path == "test" )
        log = log;
    std::stringstream stream;

    //include头
    stream << "#ifndef _" << log.className << "_H_" << std::endl;
    stream << "#define _" << log.className << "_H_" << std::endl;
    stream << std::endl;
    stream << "#include <weedong/core/seq/seq.h>" << std::endl;
    std::list< std::string > classes = wd::CSeqWriter::filtrateClass( log );
    if ( !classes.empty() )
    {
        for ( std::list< std::string >::iterator iter = classes.begin();
            iter != classes.end();
            ++iter )
        {
            std::string s = *iter;
            for(std::string::iterator jter = s.begin();
                jter != s.end();
                ++jter)
            {
                if ( *jter == '*' )
                {
                    s.erase(jter);
                    break;
                }
            }
            std::map< std::string, std::string >::iterator i = classDir.find( s );
            if ( i == classDir.end () )
            {
                printf( "%s: object not found! %s\r\n", log.className.c_str(), s.c_str() );
                exit(0);
            }
            stream << "#include <" << classDir[ s ] << ".h>" << std::endl;
        }
        stream << std::endl;
    }

    stream << wd::CSeqWriter::transformCPP( log );
    stream << std::endl;
    stream << "#endif" << std::endl;

    std::string filename = serverDir + "/" + path + "/" + log.className + ".h";

    std::map< std::string, bool >::iterator iter = fileLogs.find( filename );
    if ( iter != fileLogs.end() )
        fileLogs.erase( iter );

    WriteToFile( filename.c_str(), stream.str().c_str(), (std::streamsize)stream.str().length() );

    return log.className + ".h";
}
void WriteHList( const std::string &filename, std::list< wd::CSeqLog > &logs, std::map< std::string, std::string > &classDir, std::map< std::string, bool > &fileLogs )
{
    mkdir( ( serverDir + "/" + filename ).c_str(), 0775 );
    std::list<std::string> hList;
    for ( std::list< wd::CSeqLog >::iterator iter = logs.begin();
        iter != logs.end();
        ++iter )
    {
        hList.push_back( WriteH( filename, *iter, classDir, fileLogs ) );
    }

    std::stringstream stream;
    stream << "#ifndef _" << filename << "_H_" << std::endl;
    stream << "#define _" << filename << "_H_" << std::endl;
    stream << std::endl;

    stream << "#include \"proto/common.h\"" << std::endl;
    stream << std::endl;

    std::list< SLine >& const_list = constData[ filename ];
    for ( std::list< SLine >::iterator iter = const_list.begin();
        iter != const_list.end();
        ++iter )
    {
        char buff[512] = {0};
        sprintf( buff, "const uint32 %s = %u;", iter->name.c_str(), iter->value );
        stream << buff << std::endl;

        if ( iter->name.find( "kPath" ) == 0 )
            pathData[ iter->name ] = iter->value;
    }
    stream << std::endl;

    for ( std::list<std::string>::iterator iter = hList.begin();
        iter != hList.end();
        ++iter )
    {
        stream << "#include \"";
        if ( !serverPath.empty() )
            stream << serverPath << "/";
        stream << filename << "/" << *iter << "\"" << std::endl;
    }
    stream << std::endl;
    stream << "#endif" << std::endl;

    //移除文件记录
    std::map< std::string, bool >::iterator iter = fileLogs.find( serverDir + "/" + filename + ".h" );
    if ( iter != fileLogs.end() )
        fileLogs.erase( iter );

    WriteToFile( ( serverDir + "/" + filename + ".h" ).c_str(), stream.str().c_str(), (int)stream.str().length() );
}
void WriteHAll( std::map< std::string, std::list< wd::CSeqLog > > &seqData )
{
    std::stringstream stream;

    stream << "#ifndef _SEQ_ALL_H_" << std::endl;
    stream << "#define _SEQ_ALL_H_" << std::endl;
    stream << std::endl;

    for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator iter = seqData.begin();
        iter != seqData.end();
        ++iter )
    {
        stream << "#include \"";
        if ( !serverPath.empty() )
            stream << serverPath << "/";
        stream << iter->first << ".h\"" << std::endl;
    }

    stream << std::endl;
    stream << "#endif" << std::endl;

    std::string filename = serverDir + "/all.h";
    WriteToFile( filename.c_str(), stream.str().c_str(), (int)stream.str().length() );
}
bool CheckMsgHead( std::string &className, std::map< std::string, wd::CSeqLog > &logs )
{
    if ( className.empty() )
        return false;

    if ( className == "SMsgHead" )
        return true;

    wd::CSeqLog &log = logs[ className ];

    return CheckMsgHead( log.classParent, logs );
}
uint32 GetMsgCmd(
    std::string& className,
    std::map< std::string, uint32 > &proData )
{
    if ( className.size() <= 2 || className[0] != 'P' )
        return 0;

    std::map< std::string, unsigned int >::iterator iter = proData.find( className );
    if ( iter != proData.end() )
        return iter->second;

    SMd5Value value = md5_value( (uint8*)&className[0], (uint32)className.size() );
    uint32 cmd = value.values[0] & 0x3FFFFFFF;

    if ( className[1] != 'Q' )
        cmd |= 0x40000000;

    proData[ className ] = cmd;

    return cmd;
}

void WriteTransfromRegister(
    std::string seqName,
    std::list< wd::CSeqLog > &seqList,
    std::map< std::string, uint32 > &proData,
    std::map< std::string, std::string > &classDir,
    std::map< std::string, wd::CSeqLog > &logs )
{
    //输出 h
    {
        std::stringstream stream;

        stream << "#ifndef _MSG_TRANSFROM_REGISTER_" << seqName << "_H_" << std::endl;
        stream << "#define _MSG_TRANSFROM_REGISTER_" << seqName << "_H_" << std::endl;
        stream << std::endl;

        stream << "#include \"proto/common.h\"" << std::endl;
        stream << std::endl;

        //输出class
        stream << "class class_transfrom_" << seqName << std::endl;
        stream << "{" << std::endl;
        stream << "public:" << std::endl;
        stream << "    template< typename T >" << std::endl;
        stream << "    static SMsgHead* msg_transfrom( wd::CStream& stream )" << std::endl;
        stream << "    {" << std::endl;
        stream << "        T *msg = new T;" << std::endl;
        stream << std::endl;
        stream << "        if ( !msg->read( stream ) )" << std::endl;
        stream << "        {" << std::endl;
        stream << "            delete msg;" << std::endl;
        stream << "            return NULL;" << std::endl;
        stream << "        }" << std::endl;
        stream << std::endl;
        stream << "        return msg;" << std::endl;
        stream << "    }" << std::endl;
        stream << std::endl;
        stream << "    static std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > get_handles(void);" << std::endl;
        stream << "};" << std::endl;
        stream << std::endl;

        stream << "#endif" << std::endl;
        stream << std::endl;

        std::string filename = serverDir + "/transfrom/transfrom_" + seqName + ".h";
        WriteToFile( filename.c_str(), stream.str().c_str(), (int)stream.str().length() );
    }

    //输出 cpp
    {
        std::stringstream stream;

        stream << "#include \"proto/transfrom/transfrom_" << seqName << ".h\"" << std::endl;
        stream << std::endl;

        //输出include
        for ( std::list< wd::CSeqLog >::iterator iter = seqList.begin();
            iter != seqList.end();
            ++iter )
        {
            stream << "#include \"" << classDir[ iter->className ] << ".h\"" << std::endl;
        }
        stream << std::endl;

        //输出实现
        stream << "std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >" << std::endl;
        stream << "class_transfrom_" << seqName << "::get_handles(void)" << std::endl;
        stream << "{" << std::endl;
        stream << "    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;" << std::endl;
        stream << std::endl;

        char buff[16];
        for ( std::list< wd::CSeqLog >::iterator iter = seqList.begin();
            iter != seqList.end();
            ++iter )
        {
            uint32 cmd = GetMsgCmd( iter->className, proData );
            if ( cmd == 0 )
                continue;

            if ( !defCmdMap[ cmd ].empty() )
            {
                printf( "\033[1;32;31mredefine protocol handle: %s - %s\033[0\n", defCmdMap[ cmd ].c_str(), iter->className.c_str() );
                printf( "\033[m\033[m" );
                continue;
            }
            defCmdMap[ cmd ] = iter->className;

            snprintf( buff, sizeof( buff ) - 1, "%u", cmd );
            stream << "    handles[ " << buff << " ] = std::make_pair( \"" << iter->className << "\", msg_transfrom< " << iter->className << " > );" << std::endl;
        }
        stream << std::endl;

        stream << "    return handles;" << std::endl;
        stream << "}" << std::endl;
        stream << std::endl;

        std::string filename = serverDir + "/transfrom/transfrom_" + seqName + ".cpp";
        WriteToFile( filename.c_str(), stream.str().c_str(), (int)stream.str().length() );
    }
}

void WriteTransfrom(
    std::map< std::string, std::list< wd::CSeqLog > > &seqData,
    std::map< std::string, uint32 > &proData,
    std::map< std::string, std::string > &classDir )
{
    mkdir( ( serverDir + "/transfrom" ).c_str(), 0775 );

    //创建类映射
    std::map< std::string, wd::CSeqLog > logs;
    for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator iter = seqData.begin();
        iter != seqData.end();
        ++iter )
    {
        std::list< wd::CSeqLog > &list = iter->second;
        for ( std::list< wd::CSeqLog >::iterator i = list.begin();
            i != list.end();
            ++i )
        {
            logs[ i->className ] = *i;
        }
    }

    //输出注册类 transfrom
    for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator iter = seqData.begin();
        iter != seqData.end();
        ++iter )
    {
        WriteTransfromRegister( iter->first, iter->second, proData, classDir, logs );
    }

    //输出 h
    {
        std::stringstream stream;

        stream << "#ifndef _MSG_TRANSFROM_REGISTER_H_" << std::endl;
        stream << "#define _MSG_TRANSFROM_REGISTER_H_" << std::endl;
        stream << std::endl;

        //输出 include
        stream << "#include \"proto/common.h\"" << std::endl;
        stream << std::endl;

        //输出 class
        stream << "class class_transfrom" << std::endl;
        stream << "{" << std::endl;
        stream << "public:" << std::endl;
        stream << "    static std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > get_handles(void);" << std::endl;
        stream << "};" << std::endl;
        stream << std::endl;
        stream << "#endif" << std::endl;
        stream << std::endl;

        std::string filename = serverDir + "/transfrom.h";
        WriteToFile( filename.c_str(), stream.str().c_str(), (int)stream.str().length() );
    }

    //输出 cpp
    {
        std::stringstream stream;

        //输出 include
        stream << "#include \"proto/transfrom.h\"" << std::endl;
        stream << std::endl;

        for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator iter = seqData.begin();
            iter != seqData.end();
            ++iter )
        {
            stream << "#include \"proto/transfrom/transfrom_" << iter->first << ".h\"" << std::endl;
        }
        stream << std::endl;

        //输出处理函数
        stream << "void transfrom_register_handles(" << std::endl;
        stream << "    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >& handles," << std::endl;
        stream << "    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > map )" << std::endl;
        stream << "{" << std::endl;
        stream << "    for ( std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >::iterator iter = map.begin();" << std::endl;
        stream << "        iter != map.end();" << std::endl;
        stream << "        ++iter )" << std::endl;
        stream << "    {" << std::endl;
        stream << "        handles[ iter->first ] = iter->second;" << std::endl;
        stream << "    }" << std::endl;
        stream << "}" << std::endl;
        stream << std::endl;

        //输出句柄返回函数
        stream << "std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > class_transfrom::get_handles(void)" << std::endl;
        stream << "{" << std::endl;
        stream << "    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;" << std::endl;
        stream << std::endl;

        for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator iter = seqData.begin();
            iter != seqData.end();
            ++iter )
        {
            stream << "    transfrom_register_handles( handles, class_transfrom_";
            stream << iter->first << "::get_handles() );" << std::endl;
        }
        stream << std::endl;
        stream << "    return handles;" << std::endl;
        stream << "}" << std::endl;
        stream << std::endl;

        std::string filename = serverDir + "/transfrom.cpp";
        WriteToFile( filename.c_str(), stream.str().c_str(), (int)stream.str().length() );
    }
}
void WriteProH(
    std::map< std::string, std::pair< unsigned int, std::string > > &data,
    std::map< std::string, bool > &fileLogs,
    std::string &pathName )
{
    std::stringstream stream;

    stream << "#ifndef _PROTO_" << pathName << "_H_" << std::endl;
    stream << "#define _PROTO_" << pathName << "_H_" << std::endl;
    stream << std::endl;
    stream << "#include <weedong/core/os.h>" << std::endl;
    stream << std::endl;

    for ( std::map< std::string, std::pair< unsigned int, std::string > >::iterator iter = data.begin();
        iter != data.end();
        ++iter )
    {
        char buff[512];
        sprintf( buff,  "const uint32 %s = %u;", iter->first.c_str(), iter->second.first );
        stream << buff << std::endl;
    }

    stream << std::endl;
    stream << "#endif" << std::endl;

    std::map< std::string, bool >::iterator iter = fileLogs.find( serverDir + "/" + pathName + ".h" );
    if ( iter != fileLogs.end() )
        fileLogs.erase( iter );

    WriteToFile( ( serverDir + "/" + pathName + ".h" ).c_str(), stream.str().c_str(), (int)stream.str().length() );
}
void WriteConstantHPP(
    std::map< std::string, bool > &fileLogs,
    std::string &pathName )
{
    char buff[256];

    //输出constant.h
    {
        std::stringstream stream;

        stream << "#ifndef _PROTO_" << pathName << "_H_" << std::endl;
        stream << "#define _PROTO_" << pathName << "_H_" << std::endl;
        stream << std::endl;
        stream << "#include <weedong/core/os.h>" << std::endl;
        stream << std::endl;

        for ( std::list< SLine >::iterator iter = consData.begin();
            iter != consData.end();
            ++iter )
        {
            sprintf( buff,  "const uint32 %s = %u;", iter->name.c_str(), iter->value );
            stream << buff << std::endl;
        }
        stream << std::endl;

        stream << "namespace constant" << std::endl;
        stream << "{" << std::endl;

        //输出扩展接口声明
        stream << "    const char* get_path_name( uint32 val );" << std::endl;

        stream << "}" << std::endl;
        stream << std::endl;

        stream << "#endif" << std::endl;

        std::map< std::string, bool >::iterator iter = fileLogs.find( serverDir + "/" + pathName + ".h" );
        if ( iter != fileLogs.end() )
            fileLogs.erase( iter );

        WriteToFile( ( serverDir + "/" + pathName + ".h" ).c_str(), stream.str().c_str(), (int)stream.str().length() );
    }

    //输出constant.cpp
    {
        std::stringstream stream;

        stream << "#include \"proto/constant.h\"" << std::endl;
        stream << "#include <map>" << std::endl;
        stream << std::endl;
        stream << "namespace constant" << std::endl;
        stream << "{" << std::endl;
        stream << std::endl;

        //输出扩展接口实现
            stream << "const char* get_path_name( uint32 val )" << std::endl;
            stream << "{" << std::endl;
            stream << "    static std::map< uint32, const char* > map;" << std::endl;
            stream << "    if ( map.empty() )" << std::endl;
            stream << "    {" << std::endl;
            for ( std::map< std::string, uint32 >::iterator iter = pathData.begin();
                iter != pathData.end();
                ++iter )
            {
                sprintf( buff, "        map[ %u ]\t\t= \"%s\";", iter->second, iter->first.c_str() );
                stream << buff << std::endl;
            }
            stream << "    }" << std::endl;
            stream << std::endl;
            stream << "    return map[ val ];" << std::endl;
            stream << "}" << std::endl;
            stream << std::endl;

        stream << "}" << std::endl;

        WriteToFile( ( serverDir + "/" + pathName + ".cpp" ).c_str(), stream.str().c_str(), (int)stream.str().length() );
    }
}
void ProgressCpp( std::map< std::string, std::list< wd::CSeqLog > > seqData )
{
    //获取当前文件路径记录
    std::map< std::string, bool > fileLogs = GetFileLogs( serverDir + "/" );

    //移除文件记录(因为后面会将 fileLogs的文件名删除)
    fileLogs[ serverDir + "/all.h" ] = false;
    fileLogs[ serverDir + "/transfrom.h" ] = false;

    std::string frontPath;
    if ( !serverPath.empty() )
        frontPath = serverPath + "/";

    std::map< std::string, std::string > classDir;
    for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator iter = seqData.begin();
        iter != seqData.end();
        ++iter )
    {
        std::list< wd::CSeqLog > &logs = iter->second;
        for ( std::list< wd::CSeqLog >::iterator i = logs.begin();
            i != logs.end();
            ++i )
        {
            classDir[ i->className ] = frontPath + iter->first + "/" + i->className;
        }
    }

    for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator iter = seqData.begin();
        iter != seqData.end();
        ++iter )
    {
        WriteHList( iter->first, iter->second, classDir, fileLogs );
    }

    WriteHAll( seqData );
    WriteConstantHPP( fileLogs, constantPath );
    WriteTransfrom( seqData, proData, classDir );
}

void WriteConstLua(
    std::string name,
    std::list< SLine >& const_list,
    std::list< wd::CSeqLog > seq_list )
{
    std::stringstream stream;

    stream << "local const = trans.const" << std::endl;
    stream << "local err = trans.err" << std::endl;
    stream << "local base = trans.base" << std::endl;
    stream << std::endl;

    for ( std::list< SLine >::iterator iter = const_list.begin();
        iter != const_list.end();
        ++iter )
    {
        if ( iter->name.substr( 0, 4 ) != "kErr" )
        {
            char buff[16] = {0};
            snprintf( buff, sizeof( buff ), "%u", iter->value );
            stream << "const." << iter->name << "\t\t= " << buff;
            if ( !iter->desc.empty() )
                stream << "\t\t-- " << iter->desc;
            stream << std::endl;
        }
    }
    stream << std::endl;

    for ( std::list< SLine >::iterator iter = const_list.begin();
        iter != const_list.end();
        ++iter )
    {
        if ( iter->name.substr( 0, 4 ) == "kErr" )
        {
            char buff[16] = {0};
            snprintf( buff, sizeof( buff ), "%u", iter->value );
            stream << "err." << iter->name << "\t\t= " << buff;
            if ( !iter->desc.empty() )
                stream << "\t\t--" << iter->desc;
            stream << std::endl;
        }
    }
    stream << std::endl;

    //trans.call
    //stream << "if g_platform_server then" << std::endl;
    //stream << "    return" << std::endl;
    //stream << "end" << std::endl;
    //stream << std::endl;

    for ( std::list< wd::CSeqLog >::iterator iter = seq_list.begin();
        iter != seq_list.end();
        ++iter )
    {
        if ( !iter->classDescript.empty() )
            stream << "-- " << iter->classDescript << std::endl;

        stream << "base.reg( '" << iter->className << "', ";
        if ( iter->classParent.empty() )
            stream << "nil," << std::endl;
        else
            stream << "'" << iter->classParent << "'," << std::endl;
        stream << "    {" << std::endl;
        for ( std::vector< wd::CSeqEle >::iterator i = iter->eleList.begin();
            i != iter->eleList.end();
            ++i )
        {
            stream << "        { '" << i->eleName << "', ";
            if ( i->eleObject.empty() )
                stream << "'" << i->eleType << "'";
            else
            {
                stream << "{ ";

                wd::CSeqEle* pEle = &(*i);
                while ( pEle != NULL )
                {
                    stream << "'" << pEle->eleType << "'";

                    if ( pEle->eleObject.empty() || pEle->eleObject[0].eleType.empty() )
                        pEle = NULL;
                    else
                    {
                        pEle = &pEle->eleObject[0];

                        stream << ", ";
                    }
                }

                stream << " }";
            }

            stream << " },";
            if ( !i->eleDescript.empty() )
                stream << "\t\t-- " << i->eleDescript;
            stream << std::endl;
        }
        stream << "    }";

        uint32 cmd = GetMsgCmd( iter->className, proData );
        if ( cmd != 0 )
        {
            char buff[16];
            snprintf( buff, sizeof( buff ), "%u", cmd );
            stream << ", " << buff << std::endl;
        }
        else
            stream << std::endl;
        stream << ")" << std::endl;
        stream << std::endl;
    }
    stream << std::endl;

    WriteToFile( ( luaDir + "/" + name + ".lua" ).c_str(), stream.str().c_str(), (int)stream.str().size() );
}
void WriteConstantLua(void)
{
    WriteConstLua( "constant", consData, std::list< wd::CSeqLog >() );
}
void WriteLuaTrans(void)
{
    std::stringstream stream;

    //trans
    stream << "if trans == nil then" << std::endl;
    stream << "    trans = {}" << std::endl;
    stream << "end" << std::endl;
    stream << std::endl;

    //trans.const
    stream << "if trans.const == nil then" << std::endl;
    stream << "    trans.const = {}" << std::endl;
    stream << "end" << std::endl;
    stream << std::endl;

    //trans.err
    stream << "if trans.err == nil then" << std::endl;
    stream << "    trans.err = {}" << std::endl;
    stream << "end" << std::endl;
    stream << std::endl;

    //trans.call
    stream << "if trans.call == nil then" << std::endl;
    stream << "    trans.call = {}" << std::endl;
    stream << "end" << std::endl;
    stream << std::endl;

    stream << "require \"lua/trans/constant\"" << std::endl;
    for ( std::map< std::string, std::list< SLine > >::iterator iter = constData.begin();
        iter != constData.end();
        ++iter )
    {
        stream << "require \"lua/trans/" << iter->first << "\"" << std::endl;
    }
    stream << std::endl;

    //const, err
    stream << "const = trans.const" << std::endl;
    stream << "err = trans.err" << std::endl;

    WriteToFile( ( luaDir + "/trans.lua" ).c_str(), stream.str().c_str(), (int)stream.str().size() );
}
void ProgressLua( std::map< std::string, std::list< wd::CSeqLog > > seqData )
{
    for ( std::map< std::string, std::list< SLine > >::iterator iter = constData.begin();
        iter != constData.end();
        ++iter )
    {
        WriteConstLua( iter->first, iter->second, seqData[ iter->first ] );
    }

    WriteConstantLua();
    WriteLuaTrans();
}

std::string trim( std::string str )
{
    int index = (int)str.find_last_not_of( " \t\r\n" );
    if ( index >= 0 && index < (int)( str.length() - 1 ) )
        str.erase( str.begin() + index + 1, str.end() );

    index = (int)str.find_first_not_of( " \t\r\n" );
    if ( index > 0 )
        str.erase( str.begin(), str.begin() + index );

    return str;
}
void LoadConsData( std::string filename )
{
    std::ifstream input( filename.c_str() );

    std::string line;
    do
    {
        line.clear();
        std::getline( input, line );
        line = trim( line );

        if ( !line.empty() && line.size() > 2 && line[0] == '#' )
        {
            line.erase( line.begin() );
            SLine data = parseConstLine( line );
            if ( !data.name.empty() )
                consData.push_back( data );
        }
    }
    while( !input.eof() );

    input.close();
}

void LoadIgnoreData( std::string filename, std::map< std::string, bool >& ignoreData )
{
    std::ifstream input( filename.c_str() );

    std::string line;
    do
    {
        line.clear();
        std::getline( input, line );
        if ( !line.empty() )
        {
            line = trim( line );

            if ( line.empty() || line.size() < 2 || line[0] == '/' )
                continue;

            ignoreData[ line ] = true;
        }
    }
    while( !input.eof() );

    input.close();
}

int main(int argc, char* argv[])
{
    std::locale::global( std::locale("") );

    serverPath = "proto";
    protocolPath = "protocol";
    constantPath = "constant";

    seqDir = "seq";
    serverDir = "../server/src/common/proto";

    //客户端协议文件夹
    luaDir = "../.local/lua/trans";
    DIR* dir = opendir( luaDir.c_str() );
    if ( dir == NULL )
        luaDir = "../client/War/lua/trans";
    else
        closedir( dir );

    client_ignore_path = "ignore";

    LoadConsData( constantPath + ".txt" );

    //忽略数据
    LoadIgnoreData( client_ignore_path + ".txt", clientIgnoreData );

    dir = opendir( seqDir.c_str() );
    if ( dir == NULL )
        return 0;

    std::map< std::string, std::list< std::pair< int32, std::string > > > err_map;
    for ( dirent* ent = readdir( dir ); ent != NULL; ent = readdir( dir ) )
    {
        std::string filename = ent->d_name;
        if ( filename[0] == '.' )
            continue;

        if ( ent->d_type & DT_DIR )
            continue;

        int idx = (int)filename.find_last_of(".");
        if ( idx < 0 )
            continue;

        std::string extname = filename.substr( idx + 1 );
        if ( extname != "seq" )
            continue;

        std::string fullname = seqDir + "/" + filename;
        std::ifstream input( fullname.c_str(), std::ios_base::in | std::ios_base::binary );
        if ( !input.is_open() )
        {
            printf( "file: %s open failed!", fullname.c_str() );
            return 0;
        }
        std::vector<char> buff;

        input.seekg( 0, std::ios_base::end );
        buff.resize( input.tellg() );
        input.seekg( 0, std::ios_base::beg );

        input.read( &buff[0], (std::streamsize)buff.size() );
        input.close();

        std::list< std::pair< int32, std::string > > errs;

        constData.insert
        (
            std::map< std::string, std::list< SLine > >::value_type
            (
                filename.substr( 0, filename.find_first_of('.') ),
                const_parse( &buff[0], &buff[0] + buff.size() )
            )
        );

        seqData.insert
        (
            std::map< std::string, std::list< wd::CSeqLog > >::value_type
            (
                filename.substr( 0, filename.find_first_of('.') ),
                wd::CSeqParser::parse( &buff[0], &buff[0] + buff.size(), errs )
            )
        );

        if ( !errs.empty() )
            err_map[ filename ] = errs;
    }

    if ( !err_map.empty() )
    {
        for ( std::map< std::string, std::list< std::pair< int32, std::string > > >::iterator iter = err_map.begin();
            iter != err_map.end();
            ++iter )
        {
            std::string filename = iter->first;
            std::list< std::pair< int32, std::string > > &errs = iter->second;

            for ( std::list< std::pair< int32, std::string > >::iterator i = errs.begin();
                i != errs.end();
                ++i )
            {
                printf( "%s:%d %s\r\n", filename.c_str(), i->first, i->second.c_str() );
            }
        }
    }

    //补正通讯协议声明数据
    for ( std::map< std::string, std::list< wd::CSeqLog > >::iterator i = seqData.begin();
        i != seqData.end();
        ++i )
    {
        for ( std::list< wd::CSeqLog >::iterator j = i->second.begin();
            j != i->second.end();
            ++j )
        {
            uint32 cmd = GetMsgCmd( j->className, proData );
            if ( cmd == 0 )
                continue;

            if ( j->classParent.empty() )
                j->classParent = "SMsgHead";

            std::vector< wd::CSeqInit >::iterator iter =
                j->initList.insert( j->initList.begin(), wd::CSeqInit() );

            iter->eleName = "msg_cmd";
            iter->eleDefault = strprintf( "%u", cmd );
        }
    }

    mkdir( serverDir.c_str(), 0775 );

    ProgressLua( seqData );
    ProgressCpp( seqData );

	return 0;
}

