#include <sys/stat.h>
#include <sys/types.h>
#include "fightlog_dc.h"
#include "server.h"
#include "timer.h"
#include "settings.h"
#include "util.h"
#include "local.h"
#include "log.h"

TIMER( clear_timeout_record )
{
    theFightRecordDC.FightLogTick();
}

void CFightRecordDC::Init()
{
    //添加定时器
    theSysTimeMgr.AddLoop
    (
        "clear_timeout_record",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Minute,
        1,
        0
    );

    if ( 0 != db().is_init )
        return;

    //创建目录 不管存在与否都创建目录
    std::string path = settings::json()["fightlog_path"].asString();
    mkdir(path.c_str(), 664 );

    //读取guid time文件
    std::string _file_name = path + "/guidtime.dat";
    const char* file_name = _file_name.c_str();

    //设置version
    db().version = sizeof(SFightRecord) + sizeof(SFightPlayerInfo) + sizeof( SFightSoldier )
        + sizeof(SFightLog) + sizeof(SFightOrderTarget);
    db().fight_record_id = 1;
    db().is_init = 1;

    FILE *inFile = fopen( file_name, "rb" );
    if ( NULL == inFile )
        return;

    uint32 &fight_record_id = db().fight_record_id;
    if ( fread( &fight_record_id, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
        return;

    uint32 time_now = (uint32)time(NULL);
    uint32 _time = TimeToTime( time_now );
    for(;;)
    {
        uint32 time = 0;
        if ( fread( &time, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
            break;
        if ( 0 == time )
            break;

        if ( time_now < time )
            break;

        //超过30天的记录 不加载
        if ( time_now - time > 3600 * 24 * 30 )
            continue;

        S2UInt32 guid;
        if ( fread( &guid.first, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
            break;
        if ( 0 == guid.first )
            break;
        if ( fread( &guid.second, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
            break;
        if ( 0 == guid.second)
            break;

        db().fight_guid_time_map[time] = guid;
    }

    //加载当前时间的记录
    LoadRecord(_time );
}

uint32 CFightRecordDC::LoadRecord( uint32 time )
{
    std::string s_file_name = TimeToPath(time) + TimeToFile(time);
    const char* file_name = s_file_name.c_str();
    uint32 time_n = TimeToTime(time);

    FILE *inFile = fopen( file_name, "rb" );
    if ( NULL == inFile )
    {
        return kErrFightLogNotFind;
    }

    uint32 _version = 0;
    if ( fread( &_version, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
    {
        return kErrFightLogNotFind;
    }

    if ( db().version != _version )
    {
        return kErrFightLogVersion;
    }

    uint32 _time = 0;
    if ( fread( &_time, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
    {
        return kErrFightLogNotFind;
    }

    if ( time != _time )
    {
        return kErrFightLogVersion;
    }

    std::vector<char> buffer;
    for(;;)
    {
        uint32 length = 0;
        if ( fread( &length, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
            break;
        if ( 0 == length )
            break;
        uint32 guid = 0;
        if ( fread( &guid, 1, sizeof( uint32 ), inFile ) != sizeof( uint32 ) )
            break;
        if ( 0 == guid )
            break;

        if ( length > buffer.size() )
            buffer.resize( length );

        size_t result = fread( &buffer[0], 1, length, inFile );
        if ( result != length )
        {
            LOG_DEBUG("LOAD ERROR");
            break;
        }

        wd::CStream &stream = db().fight_record_map[time_n][guid];
        stream.write( &buffer[0], length );
    }
    return 0;
}

uint32 CFightRecordDC::Set( SFightRecord &fightrecord )
{
    uint32 time_now = (uint32)time(NULL);
    uint32 time = TimeToTime( time_now );
    TFightRecordMap &fightrecord_list = db().fight_record_map[time];
    db().fight_record_id = db().fight_record_id > fightrecord.guid ? db().fight_record_id : fightrecord.guid;
    TFightRecordMap::iterator iter = fightrecord_list.find( db().fight_record_id );
    if ( iter != fightrecord_list.end() )
        return 0;

    fightrecord.guid = db().fight_record_id;
    wd::CStream stream;
    fightrecord.create_time = time_now;
    stream.position(0);
    stream << fightrecord;
    fightrecord_list[ db().fight_record_id ] = stream;
    std::map<uint32, S2UInt32>::iterator iter_find = db().fight_guid_time_map.find( time );

    db().fight_record_id++;

    if ( iter_find == db().fight_guid_time_map.end() )
    {
        S2UInt32 temp;
        temp.first = fightrecord.guid;
        temp.second = fightrecord.guid;
        db().fight_guid_time_map[time] = temp;
    }
    else
    {
        S2UInt32 &temp = iter_find->second;
        temp.second = fightrecord.guid;
    }
    db().fight_record_save_map[time]=time;
    return fightrecord.guid;
}

uint32 CFightRecordDC::Get( uint32 guid, SFightRecord &fight_record )
{
    uint32 _time = GuidToTime( guid );
    if ( 0 == _time )
        return kErrFightLogNotFind;

    //先找在不在保存列表里面
    std::map<uint32,TFightRecordMap>::iterator iter = db().fight_record_map.find( _time );
    if ( iter == db().fight_record_map.end() )
    {
        //再没找到就去load文件
        uint32 ret = LoadRecord( _time );
        if ( 0 != ret )
            return ret;

        iter = db().fight_record_map.find( _time );
        if ( iter == db().fight_record_map.end() )
            return kErrFightLogNotFind;
    }

    TFightRecordMap &fightrecord_list = iter->second;
    TFightRecordMap::iterator iter2 = fightrecord_list.find(guid);
    if ( iter2 != fightrecord_list.end() )
    {
        iter2->second.position(0);
        iter2->second >> fight_record;
        db().fight_record_access_map[_time] = (uint32)time(NULL);
    }
    else
        return kErrFightLogNotFind;
    return 0;
}

void CFightRecordDC::Save(uint32 time)
{
    std::string s_file_path = TimeToPath(time);
    std::string s_file_name = TimeToPath(time) + TimeToFile(time);
    mkdir( s_file_path.c_str(), 664 );

    const char* file_name = s_file_name.c_str();
    TFightRecordMap &fightrecord_list = db().fight_record_map[time];

    if ( fightrecord_list.empty() )
        return;

    FILE *outFile = fopen( file_name, "wb" );
    if ( NULL == outFile )
        return;
    uint32 &version = db().version;
    fwrite( &version, 1, sizeof(uint32), outFile );
    fwrite( &time, 1, sizeof(uint32), outFile );
    for ( std::map< uint32, wd::CStream >::iterator iter2 = fightrecord_list.begin();
        iter2 != fightrecord_list.end();
        ++iter2 )
    {
        wd::CStream &stream = iter2->second;
        uint32 size = stream.length();
        uint32 guid = iter2->first;

        fwrite( &size, 1, sizeof(uint32), outFile );
        fwrite( &guid, 1, sizeof(uint32), outFile );
        fwrite( &stream[0], 1, stream.length(), outFile );
    }

    fclose( outFile );
}

void CFightRecordDC::SaveGuidTime()
{
    std::string path = settings::json()[ "fightlog_path" ].asString();
    //读取guid time文件
    std::string _file_name2 = path + "/guidtime.dat";
    const char* file_name2 = _file_name2.c_str();
    FILE *outFile = fopen( file_name2, "wb" );
    if ( NULL == outFile )
        return;

    uint32 &fight_record_id = db().fight_record_id;
    fwrite( &fight_record_id, 1, sizeof(uint32), outFile );
    for( std::map<uint32, S2UInt32>::iterator iter = db().fight_guid_time_map.begin();
        iter != db().fight_guid_time_map.end();
        ++iter )
    {
        S2UInt32 guid = iter->second;
        uint32 time = iter->first;
        fwrite( &time, 1, sizeof(uint32), outFile );
        fwrite( &guid.first, 1, sizeof(uint32), outFile );
        fwrite( &guid.second, 1, sizeof(uint32), outFile );
    }
    fclose( outFile );
}

void CFightRecordDC::SaveFightLog()
{
    for( std::map<uint32, uint32>::iterator iter = db().fight_record_save_map.begin();
        iter != db().fight_record_save_map.end();
        ++iter )
    {
        Save(iter->first);
    }
    SaveGuidTime();
}

void CFightRecordDC::FightLogTick()
{
    uint32 time_now = (uint32)time(NULL);
    uint32 _time = TimeToTime(time_now);
    for( std::map<uint32, uint32>::iterator iter = db().fight_record_save_map.begin();
        iter != db().fight_record_save_map.end();)
    {
        if( _time != iter->first )
        {
            Save(iter->first);
            db().fight_record_save_map.erase(iter++);
            SaveGuidTime();
        }
        else
            ++iter;
    }

    for( std::map<uint32, uint32>::iterator iter = db().fight_record_access_map.begin();
        iter != db().fight_record_access_map.end();
        ++iter )
    {
        uint32 time_now = (uint32)time(NULL);
        uint32 _time = TimeToTime(time_now);
        if ( time_now < iter->second )
            continue;

        //当前记录不释放
        if ( _time == iter->first )
            continue;

        if( time_now - iter->second > (uint32)(settings::json()["free_log_step"].asInt() * 60) )
        {
            std::map< uint32, TFightRecordMap >::iterator iter_find = db().fight_record_map.find( iter->first );
            if ( iter_find != db().fight_record_map.end() )
            {
                db().fight_record_map.erase(iter_find);
            }
        }
    }
}

std::string CFightRecordDC::TimeToPath( time_t time )
{
    struct tm time_tm = {0};
    localtime_r( &time, &time_tm );
    std::string dir_path;
    std::string str = settings::json()["fightlog_path"].asString() + "/%u/";
    dir_path = strprintf(str.c_str(), time_tm.tm_mday);
    return dir_path;
}

std::string CFightRecordDC::TimeToFile( time_t time )
{
    struct tm time_tm = {0};
    localtime_r(&time, &time_tm);
    std::string file_name;
    uint32 hour = (time_tm.tm_hour / settings::json()["save_log_step"].asInt()) * settings::json()["save_log_step"].asInt();
    file_name = strprintf( "%u.dat", hour );
    return file_name;
}

uint32 CFightRecordDC::TimeToTime( time_t time )
{
    struct tm time_tm = {0};
    localtime_r(&time, &time_tm);
    uint32 hour = (time_tm.tm_hour / settings::json()["save_log_step"].asInt()) * settings::json()["save_log_step"].asInt();
    time_tm.tm_hour = hour;
    time_tm.tm_min = 0;
    time_tm.tm_sec = 0;
    return mktime(&time_tm);
}

uint32 CFightRecordDC::GuidToTime( uint32 guid )
{
    for( std::map<uint32, S2UInt32>::iterator iter = db().fight_guid_time_map.begin();
        iter != db().fight_guid_time_map.end();
        ++iter )
    {
        if ( iter->second.second >= guid && iter->second.first <= guid )
            return iter->first;
    }
    return 0;
}

void CFightRecordDC::ReplyId()
{
    PRFightRecordID rep;
    rep.id = db().fight_record_id;
    local::write(local::game, rep);
}

SO_LOAD( fightlog_timer_reg )
{
    theFightRecordDC.Init();
}

