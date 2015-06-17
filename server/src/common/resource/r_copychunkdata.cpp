#include "jsonconfig.h"
#include "r_copychunkdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CCopyChunkData::CCopyChunkData()
{
}

CCopyChunkData::~CCopyChunkData()
{
    resource_clear(id_copychunk_map);
}

void CCopyChunkData::LoadData(void)
{
    CJson jc = CJson::Load( "CopyChunk" );

    theResDataMgr.insert(this);
    resource_clear(id_copychunk_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pcopychunk                    = new SData;
        pcopychunk->id                              = to_uint(aj[i]["id"]);
        S3UInt32 event;
        for ( uint32 j = 1; j <= 16; ++j )
        {
            std::string buff = strprintf( "event%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &event.cate, &event.objid, &event.val ) )
                break;
            pcopychunk->event.push_back(event);
        }

        Add(pcopychunk);
        ++count;
        LOG_DEBUG("id:%u,", pcopychunk->id);
    }
    LOG_INFO("CopyChunk.xls:%d", count);
}

void CCopyChunkData::ClearData(void)
{
    for( UInt32CopyChunkMap::iterator iter = id_copychunk_map.begin();
        iter != id_copychunk_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_copychunk_map.clear();
}

CCopyChunkData::SData* CCopyChunkData::Find( uint32 id )
{
    UInt32CopyChunkMap::iterator iter = id_copychunk_map.find(id);
    if ( iter != id_copychunk_map.end() )
        return iter->second;
    return NULL;
}

void CCopyChunkData::Add(SData* pcopychunk)
{
    id_copychunk_map[pcopychunk->id] = pcopychunk;
}
