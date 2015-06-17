#include "dataproxy.h"

CDataProxy::CDataProxy()
{
}

CDataProxy::~CDataProxy()
{

}

//=====================静态处理==================
std::map< std::string, std::pair< CDataProxy*, wd::CStream* > > db_map;
void CDataProxy::register_module( std::string& name, CDataProxy* pointer )
{
    std::map< std::string, std::pair< CDataProxy*, wd::CStream* > >::iterator iter = db_map.find( name );
    if ( iter == db_map.end() )
    {
        //新模块加入
        db_map.insert( std::make_pair( name, std::make_pair( pointer, new wd::CStream( 1024 * 1024 ) ) ) );
        return;
    }

    //正常逻辑下不存在同一个模块重复注册的可能性
    assert( iter->second.first == NULL );

    //数据恢复
    if ( iter->second.second->length() > 0 )
    {
        wd::CStream& stream = *iter->second.second;

        stream.position(0);
        pointer->trans_to_db( stream );
    }

    //设置新的模块指针
    iter->second.first = pointer;
}

void CDataProxy::trans_to_stream_and_reset(void)
{
    for ( std::map< std::string, std::pair< CDataProxy*, wd::CStream* > >::iterator iter = db_map.begin();
        iter != db_map.end();
        ++iter )
    {
        //模块指针为空时因为上次数据保存到本次数据保存为止未出现注册操作导致, 忽略本次操作并保持原有数据流
        if ( iter->second.first == NULL )
            continue;

        //转换数据流
        CDataProxy* pointer = iter->second.first;
        wd::CStream& stream = *iter->second.second;

        stream.clear();
        pointer->trans_to_stream( stream );
        delete pointer;

        //重置模块指针
        iter->second.first = NULL;
    }
}

