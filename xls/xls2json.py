# lastdate:2011-8-15 14:21 version 1.1 
import glob,os
import sys
import codecs
import gzip
import time
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

def fake_time():
    return 123456789
 
def table2jsn2(table, jsonfilename, table2):
    nrows = table.nrows
    ncols = table.ncols

    str_local_dir = "../client/War/xls/"
    if os.path.exists("../.local/client-xls"):
        str_local_dir = "../.local/client-xls/"

    f = codecs.open( str_local_dir + jsonfilename+ '.json','wb',"utf-8")
    f.write(u"{\n\t\"Array\":[\n")

    nrows2 = table2.nrows
    ncols2 = table2.ncols
    nowshow_c = 0
    for c2 in range(ncols2):
        strCellValueF2 = u""
        CellObj2 = table2.cell_value(0,c2)
        if type(CellObj2) == unicode:
            strCellValueF2 = CellObj2
        elif type(CellObj2) == float:
            strCellValueF2 = FloatToString(CellObj2)
        else:
            strCellValueF2 = str(CellObj2)

        if 0 == cmp(strCellValueF2,"noshow"):
            nowshow_c = c2

    list_c = []
    for r2 in range(nrows2-1):
        if nowshow_c == 0:
            break
        strCellValueF2 = u""
        CellObj2 = table2.cell_value(r2+1,nowshow_c)

        if type(CellObj2) == unicode:
            strCellValueF2 = CellObj2
        elif type(CellObj2) == float:
            strCellValueF2 = FloatToString(CellObj2)
        else:
            strCellValueF2 = str(CellObj2)
        if "" != strCellValueF2:
            list_c.append(strCellValueF2)

    temp_need_c = 0
    list_l = []
    for c in range(ncols):
        CellObj = table.cell_value(0,c)
        if type(CellObj) == unicode:
            strCellValueF = CellObj
        elif type(CellObj) == float:
            strCellValueF = FloatToString(CellObj)
        else:
            strCellValueF = str(CellObj)

        if 0 != list_c.count(strCellValueF) or "" == strCellValueF:
            list_l.append(c)
            continue
        temp_need_c = temp_need_c + 1

    if ncols != len(list_c):  
        for r in range(nrows-1):
            temp_c = 0
            f.write(u"\t\t\t{ ")
            for c in range(ncols):
                if 0 != list_l.count(c):
                    continue

                temp_c = temp_c + 1
                strCellValue = u""
                CellObj = table.cell_value(r+1,c)
                if type(CellObj) == unicode:
                    strCellValue = CellObj
                elif type(CellObj) == float:
                    strCellValue = FloatToString(CellObj)
                else:
                    strCellValue = str(CellObj)

                strCellValueF = u""
                CellObj = table.cell_value(0,c)
                if type(CellObj) == unicode:
                    strCellValueF = CellObj
                elif type(CellObj) == float:
                    strCellValueF = FloatToString(CellObj)
                else:
                    strCellValueF = str(CellObj)
                strTmp = u"\""  + strCellValueF + u"\":"+ u"\"" + strCellValue + u"\""
                
                if temp_c < temp_need_c :
                    strTmp += u",\t"
                f.write(strTmp)
            f.write(u" }")
            if r < nrows-2:
                f.write(u",")
            f.write(u"\n")

    f.write(u"\t\t]\n}\n")
    f.close()
    return
   
def table2jsn(table, jsonfilename):
    nrows = table.nrows
    ncols = table.ncols
    f = codecs.open("../server/extras/xls/" +jsonfilename + ".json","w","utf-8")
    f.write(u"{\n\t\"Array\":[\n")

    for r in range(nrows-1):
        f.write(u"\t\t\t{ ")
        for c in range(ncols):
            strCellValue = u""
            CellObj = table.cell_value(r+1,c)
            if type(CellObj) == unicode:
                strCellValue = CellObj
            elif type(CellObj) == float:
                strCellValue = FloatToString(CellObj)
            else:
                strCellValue = str(CellObj)

            strCellValueF = u""
            CellObj = table.cell_value(0,c)
            if type(CellObj) == unicode:
                strCellValueF = CellObj
            elif type(CellObj) == float:
                strCellValueF = FloatToString(CellObj)
            else:
                strCellValueF = str(CellObj)
            strTmp = u"\""  + strCellValueF + u"\":"+ u"\"" + strCellValue + u"\""
            
            if c< ncols-1:
                strTmp += u",\t"
            f.write(strTmp)
        f.write(u" }")
        if r < nrows-2:
            f.write(u",")
        f.write(u"\n")
    f.write(u"\t\t]\n}\n")
    f.close()
    return

def table2as(table, jsonfilename, table2):
    nrows = table.nrows
    ncols = table.ncols
    f = codecs.open("../client/src/data/json/json" + jsonfilename + ".as","w","utf-8")
    f.write(u"package data.json\n{\n")
    f.write(u"\tinternal class json" + jsonfilename + u" extends data.json.json_\n\t{\n")
    f.write(u"\t\tstatic private var _instance:json" + jsonfilename +u" = null;\n")
    f.write(u"\t\tstatic public function Instance():json" + jsonfilename +u"\n\t\t{\n")
    f.write(u"\t\t\treturn _instance ||= new json" + jsonfilename +u";\n\t\t}\n\n")
    f.write(u"\t\tpublic function json" + jsonfilename + u"()\n\t\t{\n")
    f.write(u"\t\t\tinit( title, data );\n\t\t}\n")
    f.write(u"\t\tprivate var title:Object = \n\t\t{\n")

    nrows2 = table2.nrows
    ncols2 = table2.ncols
    nowshow_c = 0
    for c2 in range(ncols2):
        strCellValueF2 = u""
        CellObj2 = table2.cell_value(0,c2)
        if type(CellObj2) == unicode:
            strCellValueF2 = CellObj2
        elif type(CellObj2) == float:
            strCellValueF2 = FloatToString(CellObj2)
        else:
            strCellValueF2 = str(CellObj2)

        if 0 == cmp(strCellValueF2,"noshow"):
            nowshow_c = c2

    list_c = []
    for r2 in range(nrows2-1):
        if nowshow_c == 0:
            break
        strCellValueF2 = u""
        CellObj2 = table2.cell_value(r2+1,nowshow_c)

        if type(CellObj2) == unicode:
            strCellValueF2 = CellObj2
        elif type(CellObj2) == float:
            strCellValueF2 = FloatToString(CellObj2)
        else:
            strCellValueF2 = str(CellObj2)
        if "" != strCellValueF2:
            list_c.append(strCellValueF2)

    temp_need_c = 0
    list_l = []
    for c in range(ncols):
        CellObj = table.cell_value(0,c)
        if type(CellObj) == unicode:
            strCellValueF = CellObj
        elif type(CellObj) == float:
            strCellValueF = FloatToString(CellObj)
        else:
            strCellValueF = str(CellObj)

        if 0 != list_c.count(strCellValueF) or "" == strCellValueF:
            list_l.append(c)
            continue
        temp_need_c = temp_need_c + 1
        
    temp_c = 0
    for c in range(ncols):
        strCellValueF = u""
        CellObj = table.cell_value(0,c)
        if type(CellObj) == unicode:
            strCellValueF = CellObj
        elif type(CellObj) == float:
            strCellValueF = FloatToString(CellObj)
        else:
            strCellValueF = str(CellObj)

        if 0 != list_c.count(strCellValueF) or "" == strCellValueF:
            list_l.append(c)
            continue
        strTmp = u"\t\t\t\""  + strCellValueF + u"\":" + str(temp_c)
        temp_c = temp_c + 1

        if temp_c < temp_need_c:
            strTmp += u",\n"
        f.write(strTmp)
    f.write(u"\n\t\t};\n\n")
    f.write(u"\t\tprivate var data:Array =\n\t\t[\n")    


    if ncols != len(list_c):
        for r in range(nrows-1):
            f.write(u"\t\t\t[ ")
            null_count = 0

            temp_c = 0;
            for c in range(ncols):
                if 0 != list_l.count(c):
                    continue
                
                strCellValue = u""
                CellObj = table.cell_value(r+1,c)
                if type(CellObj) == unicode:
                    strCellValue = CellObj
                elif type(CellObj) == float:
                    strCellValue = FloatToString(CellObj)
                else:
                    strCellValue = str(CellObj)

                strTmp = u""
                if strCellValue == "":
                    null_count = null_count + 1;
                else:
                    if null_count > 0:
                        while null_count > 0:
                            strTmp = u",\tnull"
                            f.write(strTmp)
                            null_count = null_count - 1;
                        strTmp = u",\t\"" + strCellValue + u"\""
                        f.write(strTmp)
                    else:
                        if temp_c == 0:
                            strTmp = u"\"" + strCellValue + u"\""
                        else:
                            strTmp = u",\t\"" + strCellValue + u"\""
                        f.write(strTmp)
                temp_c = temp_c + 1
            f.write(u" ]")
            if r < nrows-2:
                f.write(u",")
            f.write(u"\n")

    f.write(u"\t\t];\n\t}\n}\n")

    f.close()
    return

def table2as2(table, jsonfilename):
    nrows = table.nrows
    ncols = table.ncols
    f = codecs.open("../client/src/data/json" +jsonfilename + ".json","w","utf-8")
    f.write(u"package data.json\n\{\n")
    f.write(u"\tpublic class json_proxy\n\t{\n")
    f.write(u"\t\tpublic function json_proxy()\n\t\t{\n\n\t\t}\n")
    f.write(u"\t\tstatic public function init():void\n\t\t{\n")
    f.write(u"\t\t\tJsonMgr.Instance().Set( '" + jsonfilename + "', json" + jsonfilename + ".Instance() );\n")
    f.close()
#print "Create ",jsonfilename," OK"
    return


def table2php(table, jsonfilename):
    nrows = table.nrows
    ncols = table.ncols
    f = codecs.open("../background/s2/phpjson/json_" +jsonfilename + ".class.php","w","utf-8")

    f.write(u"<?php \nclass json_" + jsonfilename + "{\n\tprivate static $data = array (\n")

    for r in range(nrows-1):
        f.write(u"  " + str(r) + " =>\n  array (\n")
        for c in range(ncols):
            strCellValue = u""
            CellObj = table.cell_value(r+1,c)
            if type(CellObj) == unicode:
                strCellValue = CellObj
            elif type(CellObj) == float:
                strCellValue = FloatToString(CellObj)
            else:
                strCellValue = str(CellObj)

            strCellValueF = u""
            CellObj = table.cell_value(0,c)
            if type(CellObj) == unicode:
                strCellValueF = CellObj
            elif type(CellObj) == float:
                strCellValueF = FloatToString(CellObj)
            else:
                strCellValueF = str(CellObj)
            strTmp = u"\t\'"  + strCellValueF + u"\' => "+ u"\'" + strCellValue + u"\',\n"
            f.write(strTmp)
        f.write(u"  )")
        if r < nrows-2:
            f.write(u",")
        f.write(u"\n")

    f.write(u");\n")
    f.write(u"    public static function getData($conditions=null){\n")
    f.write(u"        if(!empty($conditions)){\n")
    f.write(u"            $match_data=array();\n")
    f.write(u"            preg_match_all(\"/_(\w+)/i\",$conditions,$matchs);\n")
    f.write(u"            foreach($matchs[0] as $k=>$v)\n")
    f.write(u"                $conditions = str_replace($v, '$value[\"'.$matchs[1][$k].'\"]', $conditions);\n\n")
    f.write(u"            foreach (self::$data as $k=>$value)\n")
    f.write(u"                @if(eval(\"return (\".$conditions.\");\"))\n")
    f.write(u"                     $match_data[] = $value;\n")
    f.write(u"            return $match_data;\n")
    f.write(u"        }else{\n")
    f.write(u"            return self::$data;\n        }\n    }\n")
    f.write(u"}\n?>\n")
    
    f.close()
#print "Create ",jsonfilename," OK"
    return

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
        f.write(u'''        if ( 3 != sscanf( aj[i]["'''+key+'''"], "%u%%%u%%%u", &p'''+jsonfilename.lower()+'''->'''+key+'''.cate, &p'''+jsonfilename.lower()+'''->'''+key+'''.objid, &p'''+jsonfilename.lower()+'''->'''+key+'''.val ) )
            break;\n''' )
    elif 0 == cmp(type, "S2UInt32"):
        f.write(u'''        std::string '''+key+ '''_string = aj[i]["'''+key+'''"].asString();\n''')
        f.write(u'''        sscanf( ''' + key +'''_string.c_str(), "%u%%%u", &p'''+jsonfilename.lower()+'''->'''+key+'''.first, &p'''+jsonfilename.lower()+'''->'''+key+'''.second );\n''')

def clientstr( f,type,is_pri_key,key):
    if 1 == is_pri_key:
        if 0 == cmp(type, "int"):
            f.write(u'''        row_data.'''+key.ljust(20)+'''            = toMyNumber(v.'''+key+''')\n''')
        elif 0 == cmp(type, "string"):
            f.write(u'''        row_data.'''+key.ljust(20)+'''            = v.'''+key+'''\n''')
    else:
        if 0 == cmp(type, "int"):
            f.write(u'''        if 0 ~= toMyNumber(v.'''+key+''') then
            row_data.'''+key.ljust(20)+'''            = toMyNumber(v.'''+key+''')
        end\n''');
        elif 0 == cmp(type, "string"):
            f.write(u'''        if "" ~= v.'''+key+''' then
            row_data.'''+key.ljust(20)+'''            = v.'''+key+'''
        end\n''');
        elif 0 == cmp(type, "S2UInt32"):
            f.write(u'''        local temp_data = {}
        if nil ~= v.'''+key+''' then
            local x,y = string.match(v.'''+key+''',"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.'''+key.ljust(20)+'''          = temp_data
            end
        end\n''')
        elif 0 == cmp(type, "S3UInt32"):
            f.write(u'''        local temp_data = {}
        if nil ~= v.'''+key+''' then
            local x,y,z = string.match(v.'''+key+''',"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.'''+key.ljust(20)+'''          = temp_data
            end
        end\n''')

def clientstr2( f,type,jsonfilename,key):
    if 0 == cmp(type, "int"):
        f.write(u'''    if nil == data.'''+key+''' then
        data.'''+key+''' = 0
    end\n''')
    elif 0 == cmp(type, "string"):
        f.write(u'''    if nil == data.'''+key+''' then
        data.'''+key+''' = ""
    end\n''')
    elif 0 == cmp(type, "S2UInt32"):
        f.write(u'''    if nil == data.'''+key+''' then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.'''+key+''' = temp_data
    end\n''')
    elif 0 == cmp(type, "S3UInt32"):  
        f.write(u'''    if nil == data.'''+key+''' then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.'''+key+''' = temp_data
    end\n''')
    
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
        if 0 == cmp(strCellValueF2, "type"):
            type_c = c2
    
    pri_key = ""
    if 0 != type_c:
        pri_key = str(table2.cell_value(1,type_c+1))
        
    definetype = "UInt32"+jsonfilename+"Vec"
    definename = "id_"+jsonfilename.lower()+"_list"
    if pri_key != '':
        definetype = "UInt32"+jsonfilename+"Map"
        definename = "id_"+jsonfilename.lower()+"_map"
        
    f = codecs.open("../server/src/common/resource/r_"+jsonfilename.lower()+"mgr.h","w","utf-8")
    f.write(u"#ifndef IMMORTAL_COMMON_RESOURCE_R_" + jsonfilename.upper() + "MGR_H_\n")
    f.write(u"#define IMMORTAL_COMMON_RESOURCE_R_" + jsonfilename.upper() + "MGR_H_\n\n")
    f.write(u'#include "proto/s_common.h"\n')
    f.write(u'#include "common.h"\n\n')
    f.write(u"struct S" + jsonfilename + "\n{\n")
         
    list_c = []
    map_c = {}
    for r2 in range(nrows2-1):
        if type_c == 0:
            break

        CellObj1 = table2.cell_value(r2+1,0)
        CellObj2 = table2.cell_value(r2+1,type_c)  
        strCellValueF1 = str(CellObj1)    
        strCellValueF2 = str(CellObj2)
        
        list_c.append(strCellValueF1)              
        map_c[strCellValueF1] = strCellValueF2    
        
    for key in list_c:
        f.write(u"\t" + servertype(map_c[key]).ljust(40) + key +";\n");
        
    f.write(u"};\n\n")
    
    f.write(u"class C" + jsonfilename + "Mgr\n{\n")
    f.write(u"public:\n")
    if pri_key != '':
        f.write(u"\ttypedef std::map<"+servertype(map_c[pri_key])+", S"+ jsonfilename + "*> "+definetype+";\n\n")
    else:
        f.write(u"\ttypedef std::vector<S"+ jsonfilename + "*> UInt32"+jsonfilename+"Vec;\n\n")
    f.write(u"\tC"+jsonfilename+"Mgr();\n")
    f.write(u"\t~C"+jsonfilename+"Mgr();\n")
    f.write(u"\tvoid LoadData(void);\n")
    if pri_key != '':
        f.write(u"\tS"+jsonfilename+"* Find( " + servertype(map_c[list_c[0]]) +" "+list_c[0]+ " );\n")
    else:
        f.write(u"\tS"+jsonfilename+"* Find( " + servertype(map_c[list_c[0]]) +" "+list_c[0]+", " + servertype(map_c[list_c[1]]) +" "+list_c[1]+" );\n")
    f.write(u"private:\n")
    f.write(u"\t"+definetype + " " +definename+";\n")
    f.write(u"\tvoid Add(S"+jsonfilename+"* "+jsonfilename.lower()+");\n")
    f.write(u"};\n")
    f.write(u"#define the"+jsonfilename+"Mgr TSignleton<C"+jsonfilename+"Mgr>::Ref()\n")
    f.write(u"#endif  //IMMORTAL_COMMON_RESOURCE_R_"+jsonfilename.upper()+"MGR_H_\n")
    f.close()
    
    f = codecs.open("../server/src/common/resource/r_"+jsonfilename.lower()+"mgr.cpp","w","utf-8")
    f.write(u'''#include "jsonconfig.h"
#include "r_'''+jsonfilename.lower()+'''mgr.h"
#include "log.h"
#include "proto/constant.h"

C'''+jsonfilename+'''Mgr::C'''+jsonfilename+'''Mgr()
{
}

C'''+jsonfilename+'''Mgr::~C'''+jsonfilename+'''Mgr()
{
}

void C'''+jsonfilename+'''Mgr::LoadData(void)
{
    CJson jc = CJson::Load( "'''+jsonfilename.lower()+'''" );

    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        S'''+jsonfilename+''' *p'''+jsonfilename.lower().ljust(20)+'''         = new S'''+jsonfilename+''';\n''')
    
    for key in list_c:
        index = map_c[key].find("array")
        if -1 == index:
            serverstr(f, map_c[key],jsonfilename,key)
        else:
            new_type = map_c[key][index+len("array|"):len(map_c[key])]
            list = new_type.rsplit("|") 
            f.write('''        ''' + servertype(list[0]) + ''' ''' + key + ''';
        for ( uint32 j = 1; j <= '''+list[1]+'''; ++j )
        {
            char buff[128];
            snprintf(buff, sizeof(buff-1), "'''+key+'''%d", j);\n''')
            if 0 == cmp(list[0], "int"):
                f.write(u'''            p'''+jsonfilename.lower()+'''->'''+key+'''.push_back(to_uint(aj[i][buff]);\n''');
            elif 0 == cmp(list[0], "string"):
                f.write(u'''            p'''+jsonfilename.lower()+'''->'''+key+'''.push_back(to_str(aj[i][buff]);\n''');
            elif 0 == cmp(list[0], "S3UInt32"):
                f.write(u'''            std::string value_string = aj[i][buff].asString();\n''')
                f.write(u'''            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &'''+key+'''.cate, &'''+key+'''.objid, &'''+key+'''.val ) )
                break;
            p'''+jsonfilename.lower()+'''->'''+key+'''.push_back('''+key+''');\n''') 

    f.write('        }')
         
    f.write('\n')
    f.write('        Add(p'+jsonfilename.lower()+');\n')
    f.write(u'''        ++count;
        LOG_DEBUG("''')
            
    for key in list_c:
        if 0 == cmp(map_c[key], "int"):
            f.write(key+u''':%u,''');
        elif 0 == cmp(map_c[key], "string"):
            f.write(key+u''':%s,''');
    f.write(u'"')
    for key in list_c:
        if 0 == cmp(map_c[key], "int"):
            f.write(u', p'+ jsonfilename.lower() +'->'+key);
        elif 0 == cmp(map_c[key], "string"):
            f.write(u', p'+ jsonfilename.lower() + '->'+key+u'.c_str()');
    f.write(u');\n')
    f.write(u'''    }
    LOG_INFO("'''+jsonfilename+'''.xls:%d", count);
}\n\n''')
    
    if pri_key != '':
        f.write(u'''S'''+jsonfilename+'''* C'''+jsonfilename+'''Mgr::Find( ''' + servertype(map_c[list_c[0]]) +''' '''+list_c[0]+ ''' )
{
    '''+definetype+'''::iterator iter = '''+definename+'''.find('''+list_c[0]+''');
    if ( iter != '''+definename+'''.end() )
        return iter->second;
    return NULL;
}''')
    else:
        f.write(u'''S'''+jsonfilename+'''* C'''+jsonfilename+'''Mgr::Find( ''' + servertype(map_c[list_c[0]]) +''' '''+list_c[0]+ ''',''' + servertype(map_c[list_c[1]]) +''' '''+list_c[1] + ''' )
{
    for( ''' + definetype + '''::iterator iter = ''' + definename + '''.begin();
        iter != ''' + definename + '''.end();
        ++iter; )
    { 
        if( ''' + list_c[0] + ''' == iter->''' + list_c[0] + ''' && ''' + list_c[1] + ''' == iter->''' + list_c[1] + ''' )
        {
            return *iter;
        }
    }
    return NULL;
}''')
    f.write('\n')
    f.write('''
void C'''+jsonfilename+'''Mgr::Add(S'''+jsonfilename+'''* p'''+jsonfilename.lower()+''')
{\n''')
    if pri_key != '':
        f.write('''    '''+definename+'''[p'''+jsonfilename.lower()+'''->'''+list_c[0]+'''] = p'''+jsonfilename.lower()+';\n')
    else:
        f.write('''    '''+definename+'''.push_back(p'''+jsonfilename.lower() +');\n')
    f.write('}\n')
    
    return
    
def table2cli(table, jsonfilename):
    
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
        if 0 == cmp(strCellValueF2, "type"):
            type_c = c2
    
    pri_key = ""
    if 0 != type_c:
        pri_key = str(table2.cell_value(1,type_c+1))
 
    return

def toproxy(jsonfilename):
    f = codecs.open("../client/src/data/json/json_proxy.as","w","utf-8")
    f.write(u"package data.json\n{\n")
    f.write(u"\timport data.jsonas.JsonMgrProxy;\n")
    f.write(u"\tpublic class json_proxy\n\t{\n")
    f.write(u"\t\tpublic function json_proxy()\n\t\t{\n\n\t\t}\n")
    f.write(u"\t\tstatic public function init():void\n\t\t{\n")
    f.write(u"\t\t\tvar mgr:JsonMgrProxy = JsonMgrProxy.Instance();\n");
    for name in jsonfilename:
        outfile = name[:-4]
        f.write(u"\t\t\tmgr.SetClass( '" + outfile + "', json" + outfile + " );\n")
    f.write(u"\t\t}\n\t}\n}\n")
    f.close()

def tomgr2(table,jsonfilename,table2):
    str_local_file = "../client/War/lua/server/StaticDataMgr.lua"
    if os.path.exists("../.local/lua/server"):
        str_local_file = "../.local/lua/server/StaticDataMgr.lua"

    f = codecs.open(str_local_file, "a","utf-8")

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


    f.write('''function ''' +jsonfilename+'''LoadData()
    if nil ~= json_table_data["xls/'''+jsonfilename+'''.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/'''+jsonfilename+'''.json")) do
        local row_data = {}\n''')
    temp_index = 0
    for key in list_c:
        temp_index = temp_index + 1

        index = map_c[key].find("array")
        if -1 == index:
            if pri_key == '':
                if temp_index < 3:
                    clientstr(f, map_c[key],1,key)
                else:
                    clientstr(f, map_c[key],0,key)
            else:
                if temp_index < 2:
                    clientstr(f, map_c[key],1,key)
                else:
                    clientstr(f, map_c[key],0,key)
        else:
            new_type = map_c[key][index+len("array|"):len(map_c[key])]
            list = new_type.rsplit("|")
            f.write(u'''        row_data.'''+key+''' = {}\n''')
            f.write(u'''        for i = 1,'''+list[1]+''' do
            local temp_str = "'''+key+'''" .. i\n''')
            if 0 == cmp(list[0], "int"):
                f.write(u'''            if "" ~= v[temp_str] then
                table.insert(row_data.'''+key+''', toMyNumber(v[temp_str]))
            end\n''')
            elif 0 == cmp(list[0], "string"):
                f.write(u'''            if "" ~= v[temp_str] then
                table.insert(row_data.'''+key+''', v[temp_str])
            end\n''')
            elif 0 == cmp(list[0], "S3UInt32"):
                f.write(u'''            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.'''+key+''', temp_data)
            end\n''')
            elif 0 == cmp(list[0], "S2UInt32"):
                f.write(u'''            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.'''+key+''', temp_data)
            end\n''')
            f.write(u'''        end\n''')
    if pri_key == '':
        f.write(u'''        if nil ~= row_data.'''+list_c[0]+''' and nil ~= row_data.'''+list_c[1]+''' then
            if nil == data[row_data.'''+list_c[0]+'''] then 
                data[row_data.'''+list_c[0]+'''] = {}
            end
            data[row_data.'''+list_c[0]+'''][row_data.'''+list_c[1]+'''] = row_data
        end\n''')
    else:
        f.write(u'''        if nil ~= row_data.'''+list_c[0]+''' then
            data[row_data.'''+list_c[0]+'''] = row_data
        end\n''')
    f.write('''    end\n''')
    f.write('''    json_table_data["xls/'''+jsonfilename+'''"] = data\n''')
    f.write('''    collectgarbage( 'collect' )\n''')
    f.write('''end\n\n''')

    if pri_key == '':
        f.write('''function find'''+jsonfilename+'''(first, second)
    if nil == json_table_data["xls/'''+jsonfilename+'''"] then
        ''' +jsonfilename+'''LoadData()
    end
    local temp_tb = json_table_data["xls/'''+jsonfilename+'''"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end\n''')
        for key in list_c:
            index = map_c[key].find("array")
            if -1 == index:
                clientstr2(f, map_c[key],jsonfilename,key)
        f.write('''    return temp_tb[first][second]\n''')
    else:
        f.write('''function find'''+jsonfilename+'''(first)
    if nil == json_table_data["xls/'''+jsonfilename+'''"] then
        ''' +jsonfilename+'''LoadData()
    end
    local temp_tb = json_table_data["xls/'''+jsonfilename+'''"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end\n''')
        for key in list_c:
            index = map_c[key].find("array")
            if -1 == index:
                clientstr2(f, map_c[key],jsonfilename,key)
        f.write('''    return temp_tb[first]\n''')
    f.write('''end\n''')
    f.write('\n')
    f.close()

def tomgr(jsonfilename):
    
    str_local_file = "../client/War/lua/server/LoadStaticData.lua"
    if os.path.exists("../.local/lua/server"):
        str_local_file = "../.local/lua/server/LoadStaticData.lua"

    f = codecs.open(str_local_file, "w","utf-8")

    f.write('require("lua/server/StaticDataMgr")\n\n')
    f.write('''if nil ~= g_filePath then\n''')
    for name in jsonfilename:
        outfile = name[:-4]
        f.write('''    '''+outfile+"LoadData()\n")

    f.write('end\n')
    f.close()


    str_local_file = "../client/War/lua/server/StaticDataMgr.lua"
    if os.path.exists("../.local/lua/server"):
        str_local_file = "../.local/lua/server/StaticDataMgr.lua"

    f = codecs.open(str_local_file, "w","utf-8")
    f.write('require("lua/utils/JsonLoad")\n\n')

    f.write('''local json_table_data = {}

function toMyNumber(n)
    if "" == n then 
        return 0
    end  
                        
    if nil == n then 
        return 0
    end  
    return tonumber(n)
end

function ClearDataInList( clear_list )
    for _, key in pairs( clear_list ) do
        json_table_data[key] = nil
    end
    collectgarbage( 'collect' )
end

function InitDataList( list )
    for _, key in ipairs( list ) do
        GetDataList( key )
    end
end

function ClearDataExceptList( except_list )
    for key, v in pairs( json_table_data ) do
        local is_del = true
        for _, del_key in pairs( except_list ) do
            if del_key == key then
                is_del = false
                break
            end
        end
        if is_del then
            json_table_data[key] = nil
        end
    end
    collectgarbage( 'collect' )
end

function GetDataList( name )
    local data = json_table_data[ 'xls/' .. name ]
    if data ~= nil then
        return data
    end
    
    _G[ name .. 'LoadData' ]()
    
    return json_table_data[ 'xls/' .. name ]
end\n''')

    for name in jsonfilename:
        data = xlrd.open_workbook(name)
        desttable = data.sheet_by_index(0)
        desttable2 = data.sheet_by_index(1)
        outfile = name[:-4]
        tomgr2(desttable,outfile,desttable2)

    
if len(sys.argv) != 1 :
    filenames=sys.argv[1:]
else:
    filenames=glob.glob('*.xls')
    filenames.sort()

for name in filenames:
    print(name)
    data = xlrd.open_workbook(name)
    desttable = data.sheet_by_index(0)
    desttable2 = data.sheet_by_index(1)
    outfile = name[:-4]
#table2as(desttable,outfile, desttable2)
    table2jsn(desttable,outfile)
    table2jsn2(desttable,outfile, desttable2)
#table2php(desttable,outfile)
    #table2ser(desttable,outfile, desttable2)
    #table2cli(desttable,outfile)
if len(filenames) > 1 :
    tomgr(filenames)
#toproxy(filenames)

print "All OK"
