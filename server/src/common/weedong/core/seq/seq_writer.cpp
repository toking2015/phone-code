#include <weedong/core/seq/seq_writer.h>

#include <list>

namespace wd
{

char taps[] = "    ";

bool checkBaseType( std::string &str )
{
    if ( str == "int8" || str == "uint8"
        || str == "int16" || str == "uint16"
        || str == "int32" || str == "uint32"
        || str == "float" || str == "double" )
    {
        return true;
    }

    return false;
}

//=================================================CPP=========================================
std::string output_element_cpp( CSeqEle& ele )
{
    std::stringstream stream;

    if ( ele.eleType == "array" )
        stream << "std::vector< " << output_element_cpp( *ele.eleObject.begin() ) << " >";
    else if ( ele.eleType == "map" )
        stream << "std::map< std::string, " << output_element_cpp( *ele.eleObject.begin() ) << " >";
    else if ( ele.eleType == "indices" )
        stream << "std::map< uint32, " << output_element_cpp( *ele.eleObject.begin() ) << " >";
    else if ( ele.eleType == "string" )
        stream << "std::string";
    else if ( ele.eleType == "bytes" )
        stream << "wd::CStream";
    else
        stream << ele.eleType;

    return stream.str();
}
std::string CSeqWriter::transformCPP( CSeqLog &log )
{
    std::stringstream stream;

    //输出注释
    if ( !log.classDescript.empty() )
        stream << "/*" << log.classDescript << "*/" << std::endl;

    //输出类名
    stream << "class " << log.className;

    //输出父类名
    stream << " : public ";
    if ( !log.classParent.empty() )
        stream << log.classParent;
    else
        stream << "wd::CSeq";
    stream << std::endl;

    //输出 '{'
    stream << '{' << std::endl;
    stream << "public:" << std::endl;

    //输出成员声明
    for ( std::vector< CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        stream << taps << output_element_cpp( *iter ) << ' ' << iter->eleName << ';';

        if ( !iter->eleDescript.empty() )
            stream << taps << "//" << iter->eleDescript;
        stream << std::endl;
    }

    stream << std::endl;

    //输出构造
    stream << taps << log.className << "()";

    //输出构造基本初始化
    std::list< std::string > baseInitList;
    for ( std::vector< CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        if ( !iter->eleDefault.empty() )
            continue;

        if ( checkBaseType( iter->eleType ) )
            baseInitList.push_back( iter->eleName );
    }
    if ( !baseInitList.empty() )
    {
        stream << " : ";
        for ( std::list< std::string >::iterator iter = baseInitList.begin();
            iter != baseInitList.end();
            ++iter )
        {
            if ( iter != baseInitList.begin() )
                stream << ", ";
            stream << *iter << "(0)";
        }
    }

    //输出构造行结束
    stream << std::endl;
    stream << taps << '{' << std::endl;

    //输出构造项
    for ( std::vector< CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        if ( iter->eleDefault.empty() )
            continue;

        stream << taps << taps << iter->eleName << " = " << iter->eleDefault;
        if ( iter->eleType == "float" && iter->eleDefault[ iter->eleDefault.length() - 1 ] != 'f' )
            stream << 'f';
        stream << ';' << std::endl;
    }
    for ( std::vector< CSeqInit >::iterator iter = log.initList.begin();
        iter != log.initList.end();
        ++iter )
    {
        stream << taps << taps << iter->eleName << " = " << iter->eleDefault << ';' << std::endl;
    }

    //结束构造
    stream << taps << '}' << std::endl;
    stream << std::endl;

    //输出析构
    stream << taps << "virtual ~" << log.className << "()" << std::endl;
    stream << taps << "{" << std::endl;
    stream << taps << "}" << std::endl;
    stream << std::endl;

    //输出clone
    stream << taps << "virtual wd::CSeq* clone(void)" << std::endl;
    stream << taps << "{" << std::endl;
    stream << taps << taps << "return ( new " << log.className << "(*this) );" << std::endl;
    stream << taps << "}" << std::endl;
    stream << std::endl;

    //输出成员处理函数
    stream << taps << "virtual bool write( wd::CStream &stream )" << std::endl;
    stream << taps << "{" << std::endl;
    stream << taps << taps << "uint32 uiSize = 0;" << std::endl;
    stream << taps << taps << "return loop( stream, wd::CSeq::eWrite, uiSize );" << std::endl;
    stream << taps << "}" << std::endl;

    stream << taps << "virtual bool read( wd::CStream &stream )" << std::endl;
    stream << taps << "{" << std::endl;
    stream << taps << taps << "uint32 uiSize = 0;" << std::endl;
    stream << taps << taps << "return loop( stream, wd::CSeq::eRead, uiSize );" << std::endl;
    stream << taps << "}" << std::endl;
    stream << std::endl;

    //输出成员遍历处理函数
    stream << taps << "bool loop( wd::CStream &stream, wd::CSeq::ELoopType eType, uint32& uiSize )" << std::endl;
    stream << taps << '{' << std::endl;

    //输出父类遍历函数
    if ( !log.classParent.empty() )
    {
        stream << taps << taps << "uint32 _uiSize = 0;" << std::endl;
        stream << taps << taps << "return ";
        stream << log.classParent << "::loop( stream, eType, _uiSize )" << std::endl;
        stream << taps << taps << taps << "&& wd::CSeq::loop( stream, eType, uiSize )" << std::endl;
    }
    else
    {
        stream << taps << taps << "return ";
        stream << "wd::CSeq::loop( stream, eType, uiSize )" << std::endl;
    }

    //输出成员遍历
    if ( !log.eleList.empty() )
    {
        for ( std::vector< wd::CSeqEle >::iterator iter = log.eleList.begin();
            iter != log.eleList.end();
            ++iter )
        {
            stream << taps << taps << taps << "&& TFVarTypeProcess( " << iter->eleName << ", eType, stream, uiSize )" << std::endl;
        }
    }

    stream << taps << taps << taps << "&& loopend( stream, eType, uiSize );" << std::endl;

    //输出成员处理 '}'
    stream << taps << '}' << std::endl;

    //输出 operator const char*
    stream << taps << "operator const char* ()" << std::endl;
    stream << taps << '{' << std::endl;
    stream << taps << taps << "return \"" << log.className << "\";" << std::endl;
    stream << taps << '}' << std::endl;

    //输出 '}'
    stream << "};" << std::endl;

    return stream.str();
}

//===================================================AS===========================================
std::string VarType2As( std::string &str )
{
    if ( str == "int8" || str == "int16" || str == "int32" )
        return "int";
    else if ( str == "uint8" || str == "uint16" || str == "uint32" )
        return "uint";
    else if ( str == "float" || str == "double" )
        return "Number";
    else if ( str == "string" )
        return "String";
    else if ( str == "array" )
        return "Vector";
    else if ( str == "map" )
        return "Object";
    else if ( str == "indices" )
        return "Object";
    else if ( str == "bytes" )
        return "ByteArray";

    return str;
}

void parseImport( CSeqLog &log, std::map< std::string, std::string > &classDir, std::list<std::string> &importList )
{
    std::list<std::string> classes = CSeqWriter::filtrateClass( log );
    for ( std::list<std::string>::iterator iter = classes.begin();
        iter != classes.end();
        ++iter )
    {
        std::map< std::string, std::string >::iterator i = classDir.find( *iter );
        if ( i != classDir.end() )
            importList.push_back( i->second );
    }
}
std::string CSeqWriter::transformAS( CSeqLog &log )
{
    std::list<std::string> importDir;
    std::map< std::string, std::string > classDir;
    return transformAS( log, NULL, importDir, classDir );
}
std::string output_element_as( CSeqEle& ele, std::string& init_type )
{
    std::stringstream stream;

    std::string Type = VarType2As( ele.eleType );
    std::string temp;

    if ( Type == "int" || Type == "uint" )
    {
        if ( !ele.eleDefault.empty() )
            init_type = ele.eleDefault;
        return Type;
    }
    else if ( Type == "Number" )
        init_type = "Number";
    else if ( Type == "String" )
        init_type = "String";
    else if ( Type == "Vector" )
        init_type = "Vector.<" + output_element_as( *ele.eleObject.begin(), temp ) + ">";
    else if ( Type == "Object" )
        init_type = "Object";
    else //object
        init_type = Type;

    stream << init_type;

    init_type = "new " + init_type;
    if ( !ele.eleDefault.empty() )
        init_type = ele.eleDefault;

    return stream.str();
}
std::string output_register_as( CSeqEle& ele )
{
    std::stringstream stream;

    std::string Type = VarType2As( ele.eleType );
    std::string Object;

    stream << "new CSeqEleInfo( '";
    if ( Type != "int" && Type != "uint" && Type != "Number" && Type != "String" && Type != "Vector" && Type != "ByteArray" && Type != "Object"/*这个Object是对应 map<> 或 indices<> 的变量类型*/ )
    {
        stream << "object";/*这里的 Object 是客户端的枚举类型*/

        Object = ele.eleType;
    }
    else
    {
        stream << ele.eleType;
    }
    stream << "', '" << ele.eleName << "'";

    if ( Type == "Vector" || Type == "Object" )
        stream << ", " << output_register_as( *ele.eleObject.begin() );
    else if ( !Object.empty() )
        stream << ", '" << Object << '\'';
    stream << " )";

    return stream.str();
}
std::string CSeqWriter::transformAS( CSeqLog &log, const char* packetPath, std::list<std::string> &import, std::map< std::string, std::string > &classDir )
{
    if ( log.className == "SPackHead" )
        log.className = "SPackHead";
    std::list<std::string> importList = import;

    //import 统计
    if ( !classDir.empty() )
        parseImport( log, classDir, importList );

    std::stringstream stream;

    //输出package{
    stream << "package";
    if ( packetPath != NULL && packetPath[0] != '\0' )
        stream << " " << packetPath;
    stream << std::endl;
    stream << '{' << std::endl;

    //输出import
    for ( std::vector< wd::CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        if ( VarType2As( iter->eleType ) == "ByteArray" )
        {
            stream << taps << "import flash.utils.ByteArray;" << std::endl;
            break;
        }
    }
    if ( !importList.empty() )
    {
        for ( std::list<std::string>::iterator iter = importList.begin();
            iter != importList.end();
            ++iter )
        {
            stream << taps << "import " << *iter << ";" << std::endl;
        }
    }
    stream << std::endl;

    //输出注释
    if ( !log.classDescript.empty() )
    {
        std::string descript = log.classDescript;
        for ( int i = (int)descript.find_first_of( '\n' ); i >= 0 && i < (int)descript.length(); )
        {
            if ( descript[i] == '\n' )
            {
                descript.insert( i + 1, taps );
                i += sizeof( taps );
            }
            else
                ++i;
        }
        stream << taps << "/*" << descript << "*/" << std::endl;
    }

    //输出类名
    stream << taps << "public class " << log.className;

    //输出父类
    if ( !log.classParent.empty() )
        stream << " extends " << log.classParent;
    else
        stream << " extends CSeq";
    stream << std::endl;

    //类 {
    stream << taps << '{' << std::endl;

    for ( std::vector< wd::CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        std::string init_type;
        stream << taps << taps << "public var " << iter->eleName << ':' << output_element_as( *iter, init_type );

        if ( !init_type.empty() )
            stream << " = " << init_type;
        stream << ";";

        if ( !iter->eleDescript.empty() )
            stream << taps << "//" << iter->eleDescript;

        stream << std::endl;
    }
    stream << std::endl;

    //输出构造
    stream << taps << taps << "public function " << log.className << "()" << std::endl;
    stream << taps << taps << '{' << std::endl;
    stream << taps << taps << taps << "elementInfo = static_element_info;" << std::endl;

    //输出构造项
    if ( !log.initList.empty() )
    {
        stream << std::endl;

        for ( std::vector< CSeqInit >::iterator iter = log.initList.begin();
            iter != log.initList.end();
            ++iter )
        {
            stream << taps << taps << taps << iter->eleName << " = " << iter->eleDefault << ';' << std::endl;
        }
    }

    stream << taps << taps << '}' << std::endl;

    stream << std::endl;

    //输出父类结构继承
    stream << taps << taps << "static protected var static_element_info:Vector.<CSeqEleInfo> = ";
    if ( !log.classParent.empty() )
        stream << log.classParent;
    else
        stream << "CSeq";
    stream << ".static_element_info" << std::endl;
    stream << taps << taps << taps << ".concat" << std::endl;
    stream << taps << taps << taps << '(' << std::endl;
    stream << taps << taps << taps << taps << "new <CSeqEleInfo>" << std::endl;
    stream << taps << taps << taps << taps << '[' << std::endl;
    for ( std::vector< wd::CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        stream << taps << taps << taps << taps << taps;

        stream << output_register_as( *iter );

        if ( iter + 1 != log.eleList.end() )
            stream << ',';
        stream << std::endl;
    }
    stream << taps << taps << taps << taps << ']' << std::endl;
    stream << taps << taps << taps << ");" << std::endl;

    //类 }
    stream << taps << '}' << std::endl;

    //package }
    stream << '}' << std::endl;

    return stream.str();
}

std::string output_element_seq( CSeqEle& ele )
{
    std::stringstream stream;

    stream << ele.eleType;
    if ( ele.eleType == "array" || ele.eleType == "map" || ele.eleType == "indices" )
        stream << "<" << output_element_seq( *ele.eleObject.begin() ) << ">";

    return stream.str();
}
std::string CSeqWriter::transformSEQ( CSeqLog &log )
{
    std::stringstream stream;

    //输出注释
    if ( !log.classDescript.empty() )
        stream << "/*" << log.classDescript << "*/" << std::endl;

    //输出类名
    stream << log.className;

    //输出父类名
    if ( !log.classParent.empty() )
        stream << " : " << log.classParent;
    stream << std::endl;

    //输出 '{'
    stream << '{' << std::endl;

    if ( !log.initList.empty() )
    {
        //输出构造
        stream << taps << log.className << std::endl;
        stream << taps << '{' << std::endl;

        //输出构造项
        for ( std::vector< CSeqInit >::iterator iter = log.initList.begin();
            iter != log.initList.end();
            ++iter )
        {
            stream << taps << taps << iter->eleName << " = " << iter->eleDefault << ';' << std::endl;
        }

        //结束构造
        stream << taps << '}' << std::endl;
        stream << std::endl;
    }

    //输出成员声明
    for ( std::vector< CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        stream << taps << iter->eleName << " : " << output_element_seq( *iter );

        if ( !iter->eleDefault.empty() )
            stream << " = " << iter->eleDefault;

        stream << ';';

        if ( !iter->eleDescript.empty() )
            stream << taps << "//" << iter->eleDescript;

        stream << std::endl;
    }

    //输出 '}'
    stream << "}" << std::endl;

    return stream.str();
}

void addClass( std::string &name, std::list<std::string> &classes )
{
    for ( std::list<std::string>::iterator iter = classes.begin();
        iter != classes.end();
        ++iter )
    {
        if ( name == *iter )
            return;
    }

    classes.push_back( name );
}

void import_element_class( CSeqEle& ele, std::list<std::string>& classes )
{
     std::string Type = VarType2As( ele.eleType );

    if ( Type == "Number" || Type == "String" || Type == "ByteArray" )
        return;

    if ( Type == "int" || Type == "uint" )
        return;

    if ( Type == "Vector" || Type == "Object" )
        import_element_class( *ele.eleObject.begin(), classes );
    else //object
        addClass( Type, classes );
}
std::list<std::string> CSeqWriter::filtrateClass( CSeqLog &log )
{
    std::list<std::string> classes;

    //父类import
    if ( !log.classParent.empty() )
        addClass( log.classParent, classes );

    //成员import
    for ( std::vector< wd::CSeqEle >::iterator iter = log.eleList.begin();
        iter != log.eleList.end();
        ++iter )
    {
        import_element_class( *iter, classes );
    }

    return classes;
}


}

