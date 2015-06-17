# lastdate:2011-8-15 14:21 version 1.1 
import glob,os
import sys
import codecs
import xlrd #http://pypi.python.org/pypi/xlrd


def FloatToString (aFloat):
    if type(aFloat) != float:
        return ""
    strTemp = str(aFloat)
    strList = strTemp.split(".")
    if len(strList) == 1 :
        return strTemp
    else:
        if strList[1] == "0" :
            return strList[0]
        else:
            return strTemp
 
def servertype(type):
    index = type.find("array")
    if -1 == index :
        if 0 == cmp(type, "int"):
            return "uint32";
        elif 0 == cmp(type, "string"):
            return "std::string";
        elif 0 == cmp(type, "S3UInt32"):
            return "S3UInt32";
        elif 0 == cmp(type, "S2UInt32"):
            return "S2UInt32";
    else:
        new_type = type[index+len("array|"):len(type)]
        list = new_type.rsplit("|")
        return "std::vector<"+servertype(list[0])+">"
    return ""
    
def serverstr( f,type,jsonfilename,key):
    if 0 == cmp(type, "int"):
        f.write(u'''        p'''+jsonfilename.lower()+'''->'''+key.ljust(20)+'''            = to_uint(aj[i]["'''+key+'''"]);\n''');
    elif 0 == cmp(type, "string"):
        f.write(u'''        p'''+jsonfilename.lower()+'''->'''+key.ljust(20)+'''            = to_str(aj[i]["'''+key+'''"]);\n''');
    elif 0 == cmp(type, "S3UInt32"):
        f.write(u'''        std::string '''+key+ '''_string = aj[i]["'''+key+'''"].asString();\n''')
        f.write(u'''        sscanf( ''' + key +'''_string.c_str(), "%u%%%u%%%u", &p'''+jsonfilename.lower()+'''->'''+key+'''.cate, &p'''+jsonfilename.lower()+'''->'''+key+'''.objid, &p'''+jsonfilename.lower()+'''->'''+key+'''.val );\n''' )
    elif 0 == cmp(type, "S2UInt32"):
        f.write(u'''        std::string '''+key+ '''_string = aj[i]["'''+key+'''"].asString();\n''')
        f.write(u'''        sscanf( ''' + key +'''_string.c_str(), "%u%%%u", &p'''+jsonfilename.lower()+'''->'''+key+'''.first, &p'''+jsonfilename.lower()+'''->'''+key+'''.second );\n''')
    
def table2ser(table, jsonfilename, table2):
    nrows = table.nrows
    ncols = table.ncols
   
    nrows2 = table2.nrows
    ncols2 = table2.ncols
    
    type_c = 0
    for c2 in range(ncols2):
        strCellValueF2 = u""
        CellObj = table2.cell_value(0,c2)
        if type(CellObj) == unicode:
            strCellValueF2 = CellObj
        elif type(CellObj) == float:
            strCellValueF2 = FloatToString(CellObj)
        else:
            strCellValueF2 = str(CellObj)     
        strCellValueF2.strip()
        if 0 == cmp(strCellValueF2, "type"):
            type_c = c2
    
    pri_key = ""
    if 0 != type_c:
        pri_key = str(table2.cell_value(1,type_c+1))
        
    definetype = "UInt32"+jsonfilename+"Map"
    definename = "id_"+jsonfilename.lower()+"_map"

    f = codecs.open("../server/src/common/resource/r_"+jsonfilename.lower()+"data.h","w","utf-8")
    f.write(u"#ifndef IMMORTAL_COMMON_RESOURCE_R_" + jsonfilename.upper() + "DATA_H_\n")
    f.write(u"#define IMMORTAL_COMMON_RESOURCE_R_" + jsonfilename.upper() + "DATA_H_\n\n")
    f.write(u'#include "proto/common.h"\n')
    f.write(u'#include "r_basedata.h"\n')
    f.write(u'#include "resource.h"\n\n')
         
    list_c = []
    map_c = {}
    for r2 in range(nrows2-1):
        if type_c == 0:
            break

        CellObj1 = table2.cell_value(r2+1,0)
        CellObj2 = table2.cell_value(r2+1,type_c)  
        strCellValueF1 = str(CellObj1)    
        strCellValueF2 = str(CellObj2)

        strCellValueF1.strip()
        strCellValueF2.strip()
        
        list_c.append(strCellValueF1)              
        if strCellValueF2 != '':
            map_c[strCellValueF1] = strCellValueF2    
        
    f.write(u"class C" + jsonfilename + "Data : public CBaseData\n{\n")
    f.write(u"public:\n")

    f.write(u"    struct SData\n    {\n")
    for key in list_c:
        if not map_c.has_key(key):
            continue
        f.write(u"        " + servertype(map_c[key]).ljust(40) + key +";\n");
    f.write(u"    };\n\n")

    if pri_key != '':
        f.write(u"\ttypedef std::map<"+servertype(map_c[pri_key])+", SData*> "+definetype+";\n\n")
    else:
        f.write(u"\ttypedef std::map<"+servertype(map_c[list_c[0]])+", std::map<"+servertype(map_c[list_c[1]])+", SData*> >"+definetype+";\n\n")
    f.write(u"\tC"+jsonfilename+"Data();\n")
    f.write(u"\tvirtual ~C"+jsonfilename+"Data();\n")
    f.write(u"\tvirtual void LoadData(void);\n")
    f.write(u"\tvoid ClearData(void);\n")
    if pri_key != '':
        f.write(u"\tSData * Find( " + servertype(map_c[list_c[0]]) +" "+list_c[0]+ " );\n")
    else:
        f.write(u"\tSData * Find( " + servertype(map_c[list_c[0]]) +" "+list_c[0]+", " + servertype(map_c[list_c[1]]) +" "+list_c[1]+" );\n\n")

    f.write(u"protected:\n")
    f.write(u"\t"+definetype + " " +definename+";\n")
    f.write(u"\tvoid Add(SData* "+jsonfilename.lower()+");\n")
    f.write(u"};\n")
    f.write(u"#endif  //IMMORTAL_COMMON_RESOURCE_R_"+jsonfilename.upper()+"MGR_H_\n")
    f.close()
    
    f = codecs.open("../server/src/common/resource/r_"+jsonfilename.lower()+"data.cpp","w","utf-8")
    f.write(u'''#include "jsonconfig.h"
#include "r_'''+jsonfilename.lower()+'''data.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

C'''+jsonfilename+'''Data::C'''+jsonfilename+'''Data()
{
}

C'''+jsonfilename+'''Data::~C'''+jsonfilename+'''Data()
{
    resource_clear('''+definename+''');
}

void C'''+jsonfilename+'''Data::LoadData(void)
{
    CJson jc = CJson::Load( "'''+jsonfilename+'''" );

    theResDataMgr.insert(this);
    resource_clear('''+definename+''');
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *p'''+jsonfilename.lower().ljust(20)+'''         = new SData;\n''')
    
    for key in list_c:
        if not map_c.has_key(key):
            continue
        index = map_c[key].find("array")
        if -1 == index:
            serverstr(f, map_c[key],jsonfilename,key)
        else:
            new_type = map_c[key][index+len("array|"):len(map_c[key])]
            list = new_type.rsplit("|") 
            f.write('''        ''' + servertype(list[0]) + ''' ''' + key + ''';
        for ( uint32 j = 1; j <= '''+list[1]+'''; ++j )
        {
            std::string buff = strprintf( "'''+key+'''%d", j);\n''')
            if 0 == cmp(list[0], "int"):
                f.write(u'''            ''' + key + ''' = to_uint(aj[i][buff]);\n''');
                f.write(u'''            p'''+jsonfilename.lower()+'''->'''+key+'''.push_back('''+ key +''');\n''');
            elif 0 == cmp(list[0], "string"):
                f.write(u'''            ''' + key + ''' = to_str(aj[i][buff]);\n''');
                f.write(u'''            p'''+jsonfilename.lower()+'''->'''+key+'''.push_back('''+ key +''');\n''');
            elif 0 == cmp(list[0], "S3UInt32"):
                f.write(u'''            std::string value_string = aj[i][buff].asString();\n''')
                f.write(u'''            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &'''+key+'''.cate, &'''+key+'''.objid, &'''+key+'''.val ) )
                break;
            p'''+jsonfilename.lower()+'''->'''+key+'''.push_back('''+key+''');\n''') 
            elif 0 == cmp(list[0], "S2UInt32"):
                f.write(u'''            std::string value_string = aj[i][buff].asString();\n''')
                f.write(u'''            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &'''+key+'''.first, &'''+key+'''.second ) )
                break;
            p'''+jsonfilename.lower()+'''->'''+key+'''.push_back('''+key+''');\n''')
            f.write('        }\n')
         
    f.write('\n')
    f.write('        Add(p'+jsonfilename.lower()+');\n')
    f.write(u'''        ++count;
        LOG_DEBUG("''')
            
    for key in list_c:
        if not map_c.has_key(key):
            continue
        if 0 == cmp(map_c[key], "int"):
            f.write(key+u''':%u,''');
        elif 0 == cmp(map_c[key], "string"):
            f.write(key+u''':%s,''');
    f.write(u'"')
    for key in list_c:
        if not map_c.has_key(key):
            continue
        if 0 == cmp(map_c[key], "int"):
            f.write(u', p'+ jsonfilename.lower() +'->'+key);
        elif 0 == cmp(map_c[key], "string"):
            f.write(u', p'+ jsonfilename.lower() + '->'+key+u'.c_str()');
    f.write(u');\n')
    f.write(u'''    }
    LOG_INFO("'''+jsonfilename+'''.xls:%d", count);
}\n\n''')

    f.write('''void C'''+jsonfilename+'''Data::ClearData(void)
{
    for( '''+definetype+'''::iterator iter = '''+definename+'''.begin();
        iter != '''+definename+'''.end();
        ++iter )
    {
        ''')
    if pri_key != '':
        f.write('''delete iter->second;
    }\n''')
    else:
        f.write('''for(std::map<'''+servertype(map_c[list_c[1]])+''',SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }\n''')
    f.write("    " +definename+ ".clear();\n")
    f.write("}\n\n")
    
    if pri_key != '':
        f.write(u'''C'''+jsonfilename+'''Data::SData* C'''+jsonfilename+'''Data::Find( ''' + servertype(map_c[list_c[0]]) +''' '''+list_c[0]+ ''' )
{
    '''+definetype+'''::iterator iter = '''+definename+'''.find('''+list_c[0]+''');
    if ( iter != '''+definename+'''.end() )
        return iter->second;
    return NULL;
}''')
    else:
        f.write(u'''C'''+jsonfilename+'''Data::SData* C'''+jsonfilename+'''Data::Find( ''' + servertype(map_c[list_c[0]]) +''' '''+list_c[0]+ ''',''' + servertype(map_c[list_c[1]]) +''' '''+list_c[1] + ''' )
{
    return '''+definename+'''['''+list_c[0]+''']['''+list_c[1]+'''];
}''')
    f.write('\n')
    f.write('''
void C'''+jsonfilename+'''Data::Add(SData* p'''+jsonfilename.lower()+''')
{\n''')
    if pri_key != '':
        f.write('''    '''+definename+'''[p'''+jsonfilename.lower()+'''->'''+list_c[0]+'''] = p'''+jsonfilename.lower()+';\n')
    else:
        f.write('''    '''+definename+'''[p'''+jsonfilename.lower()+'''->'''+list_c[0]+'''][p'''+jsonfilename.lower()+'''->'''+list_c[1]+'''] = p'''+jsonfilename.lower()+''';\n''')
    f.write('}\n')
    f.close()

    if not os.path.isfile( "../server/src/common/resource/r_"+jsonfilename.lower()+"ext.h" ):
        f = codecs.open("../server/src/common/resource/r_"+jsonfilename.lower()+"ext.h","w","utf-8")
        f.write(u"#ifndef IMMORTAL_COMMON_RESOURCE_R_" + jsonfilename.upper() + "EXT_H_\n")
        f.write(u"#define IMMORTAL_COMMON_RESOURCE_R_" + jsonfilename.upper() + "EXT_H_\n\n")
        f.write(u'''#include "r_'''+jsonfilename.lower()+'''data.h"\n\n''')
        f.write(u'''class C'''+jsonfilename+'''Ext : public C'''+jsonfilename+'''Data
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( '''+definetype+'''::iterator iter = '''+definename+'''.begin();
            iter != '''+definename+'''.end();
            ++iter )
        {
            ''')
        if pri_key != '':
            f.write('''if ( !call( *iter ) )
                break;
        }\n''')
        else:
            f.write('''for(std::map<'''+servertype(map_c[list_c[1]])+''',SData*>::iterator jter = iter->second.begin();
                jter != iter->second.end();
                ++jter )
            {
                if ( !call( jter->second ) )
                    break;
            }
        }\n''')
        f.write('''    }
};

#define the'''+jsonfilename+'''Ext TSignleton<C'''+jsonfilename+'''Ext>::Ref()
#endif\n''')
        f.close()
    if not os.path.isfile( "../server/src/common/resource/r_"+jsonfilename.lower()+"ext.cpp"):
        f = codecs.open("../server/src/common/resource/r_"+jsonfilename.lower()+"ext.cpp","w","utf-8")
        f.write('''#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_'''+jsonfilename.lower()+'''ext.h"

''')
        f.close()
    
    return

def clienttype(type):
    index = type.find("array")
    if -1 == index :
        if 0 == cmp(type, "int"):
            return "uint";
        elif 0 == cmp(type, "string"):
            return 'String';
        elif 0 == cmp(type, "S3UInt32"):
            return "S3UInt32";
        elif 0 == cmp(type, "S2UInt32"):
            return "S2UInt32";
    else:
        new_type = type[index+len("array|"):len(type)]
        list = new_type.rsplit("|")
        return "Vector.<"+clienttype(list[0])+">"
    return ""
    
def table2cli(table, jsonfilename, table2):
    
    nrows = table.nrows
    ncols = table.ncols
   
    nrows2 = table2.nrows
    ncols2 = table2.ncols
    
    type_c = 0
    for c2 in range(ncols2):
        strCellValueF2 = u""
        CellObj = table2.cell_value(0,c2)
        if type(CellObj) == unicode:
            strCellValueF2 = CellObj
        elif type(CellObj) == float:
            strCellValueF2 = FloatToString(CellObj)
        else:
            strCellValueF2 = str(CellObj)     
        strCellValueF2.strip()
        if 0 == cmp(strCellValueF2, "type"):
            type_c = c2

    list_c = []
    map_c = {}
    for r2 in range(nrows2-1):
        if type_c == 0:
            break

        CellObj1 = table2.cell_value(r2+1,0)
        CellObj2 = table2.cell_value(r2+1,type_c)  
        strCellValueF1 = str(CellObj1)    
        strCellValueF2 = str(CellObj2)

        strCellValueF1.strip()
        strCellValueF2.strip()
        
        list_c.append(strCellValueF1)              
        map_c[strCellValueF1] = strCellValueF2    

    f = codecs.open("../client/src/data/jsonas/J"+jsonfilename+".as","w","utf-8")
    f.write(u'''package data.jsonas 
{
    import data.json.json_;
    import proxy.struct.s_common.*;
    
    public class J'''+jsonfilename+''' extends JBase 
    {
        static private var _json:json_;
        static private var _typeData:Array = [\n''')

    temp_index = 0;
    for key in list_c:
        
        if 0 != temp_index :
            f.write(u',\n')
        else:
            temp_index = 1
        
        my_type = map_c[key]
        index = my_type.find("array")
        list = my_type.rsplit("|") 
        if -1 == index:
            f.write(u'            ["' + key + '", ' + clienttype(list[0]) + ']' )
        else:
            f.write(u'''            ["'''+key+'''", Vector.<'''+clienttype(list[1])+'''>, '''+clienttype(list[1])+''', '''+list[2]+''']''')

    f.write('\n        ];\n')

    for key in list_c:
        f.write(u"        public var " + key + ":" + clienttype(map_c[key]) +";\n");

    f.write('\n')
    f.write('''        public function J'''+jsonfilename+'''(line:Array = null) 
        {
            super(line);
        }
        
        static public function get json():json_
        {
            return _json ||= JsonMgr.Instance().Get("'''+jsonfilename+'''");
        }
        
        static public function getData(key:*):J'''+jsonfilename+'''
        {
            return json.get_data(key, J'''+jsonfilename+''');
        }
        
        override protected function get jsonData():json_ 
        {
            return json;
        }

        override protected function get typeData():Object
        {   
            return _typeData;
        }
    }
}\n''')

    return

if len(sys.argv) == 2 :
    filenames = sys.argv[1:]

for name in filenames:
    print(name)
    data = xlrd.open_workbook(name)
    desttable = data.sheet_by_index(0)
    desttable2 = data.sheet_by_index(1)
    outfile = name[:-4]
    table2ser(desttable,outfile, desttable2)
#table2cli(desttable,outfile, desttable2)

print "Create Data OK"
