#ifndef _GAMESVR_FIGHTLOG_DC_H_
#define _GAMESVR_FIGHTLOG_DC_H_

#include "common.h"
#include "proto/fight.h"
#include "dc.h"

class CFightRecordDC : public TDC< CFightRecordMap >
{
public:
    CFightRecordDC() : TDC< CFightRecordMap >( "fightlog" )
    {
    }

    ~CFightRecordDC()
    {
    }

    typedef std::map<uint32, wd::CStream> TFightRecordMap;

    void Init();
    uint32 Set( SFightRecord &fight_record );
    uint32 Get( uint32 guid, SFightRecord &fight_record );
    uint32 LoadRecord( uint32 time );
    void Save(uint32 time);
    void SaveFightLog();
    void SaveGuidTime();
    void FightLogTick(void);        //保存LOG并且删除很久没有访问的记录
    std::string TimeToPath( time_t time );
    std::string TimeToFile( time_t time );
    uint32 TimeToTime( time_t time );
    uint32 GuidToTime( uint32 guid );
    void ReplyId();
};
#define theFightRecordDC TSignleton< CFightRecordDC >::Ref()

#endif

