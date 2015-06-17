#ifndef _GAME_COMMON_SYSTIME_MGR_H_
#define _GAME_COMMON_SYSTIME_MGR_H_

#include "common.h"

struct SMillisecond
{
	uint32 sec;
	uint32 msec;

	SMillisecond()
	{
		sec = 0;
		msec = 0;
	}

	SMillisecond( uint64 ms )
	{
		reset( ms );
	}

	SMillisecond& operator = ( const SMillisecond &data )
	{
		sec = data.sec;
		msec = data.msec;
		return (*this);
	}

	void reset( uint64 ms )
	{
		sec = ms / 1000;
		msec = ms % 1000;
	}

	bool empty(void)
	{
		return sec == 0 && msec == 0;
	}

	void unset(void)
	{
		sec = 0;
		msec = 0;
	}

	SMillisecond& operator += ( const SMillisecond &data )
	{
		reset( ToMSec() + data.ToMSec() );
		return (*this);
	}

	SMillisecond& operator -= ( const SMillisecond &data )
	{
		reset( ToMSec() - data.ToMSec() );
		return (*this);
	}

	uint64 ToMSec(void) const
	{
		return (uint64)sec * 1000 + msec;
	}

	bool operator == ( const SMillisecond &data )
	{
		return sec == data.sec && msec == data.msec;
	}

	bool operator != ( const SMillisecond &data )
	{
		return !( operator == (data) );
	}

	bool operator > ( const SMillisecond &data )
	{
		if ( sec > data.sec )
			return true;
		else if ( sec < data.sec )
			return false;

		return msec > data.msec;
	}

	bool operator >= ( const SMillisecond &data )
	{
		return operator > (data) || operator == (data);
	}

	bool operator < ( const SMillisecond &data )
	{
		return !( operator >= (data ) );
	}

	bool operator <= ( const SMillisecond &data )
	{
		return operator < (data) || operator == (data);
	}
};
SMillisecond operator - ( SMillisecond &ms1, SMillisecond &ms2 );
SMillisecond operator + ( SMillisecond &ms1, SMillisecond &ms2 );
SMillisecond GetMSec(void);

struct SSysTime
{
	int Year;
	int Month;
	int Day;
	int Hour;
	int Minute;
	int Second;
	int Millisecond;

	SSysTime( bool initTimeNow = false )
	{
        Year = 0;
        Month = 0;
        Day = 0;
        Hour = 0;
        Minute = 0;
        Second = 0;
        Millisecond = 0;

		if ( initTimeNow )
			InitTime();
	}

	SSysTime& operator = ( const SSysTime &data )
	{
		memcpy( this, &data, sizeof(*this) );
		return (*this);
	}

	SSysTime& operator = ( const struct tm _tm )
	{
		Year = _tm.tm_year + 1900;
		Month = _tm.tm_mon + 1;
		Day = _tm.tm_mday;
		Hour = _tm.tm_hour;
		Minute = _tm.tm_min;
		Second = _tm.tm_sec;
		Millisecond = GetMSec().msec;

		return (*this);
	}

	void Init(void)
	{
		memset( this, 0, sizeof(*this) );
	}

	void InitTime(void)
	{
		struct tm _tm;
#ifdef LINUX
		time_t t;
		time(&t);
		localtime_r( &t, &_tm );
#else
		__time64_t long_time;
		_time64( &long_time );
		_localtime64_s( &_tm, &long_time );
#endif
		(*this) = _tm;
	}

	bool Empty(void)
	{
		return ( Year == 0 && Month == 0 && Day == 0 && Hour == 0 && Minute == 0 && Second == 0 && Millisecond == 0 );
	}

    uint32 GetSec(void)
    {
        struct tm _tm = {0};

        _tm.tm_year     = Year - 1900;
        _tm.tm_mon      = Month - 1;
        _tm.tm_mday     = Day;
        _tm.tm_hour     = Hour;
        _tm.tm_min      = Minute;
        _tm.tm_sec      = Second;

        return (uint32)( mktime( &_tm ) );
    }
};
bool operator < ( SSysTime &_l, SSysTime &_r );
bool operator <= ( SSysTime &_l, SSysTime &_r );

bool IsLeapYear( const tm *pTM );
bool IsLeapYear( uint32 Year );
uint32 GetMaxYearDay( const tm *pTM );
uint32 GetMaxMonthDay( const tm *pTM );
uint32 GetMaxMonthDay( uint32 Year, uint32 Month );

class CSysTimeMgr
{
public:
	enum ETimeType
	{
		Unknow = 0,
		Year = 1,
		Month = 2,
		Day = 3,
		Hour = 4,
		Minute = 5,
		Second = 6,
		Millisecond = 7,
	};

	class CLoopData
	{
	public:
		uint32 LoopId;

		uint32 LoopMax;
		uint32 LoopCount;

		SSysTime Time;
		SSysTime EndTime;

		uint32 Type;
		uint32 Delay;

		bool Delete;
        std::string key;
        std::string param;

		CLoopData()
		{
            LoopId = 0;

			LoopMax = 0;
            LoopCount = 0;

            Type = 0;
            Delay = 0;

			Delete = false;
		}

		//检查执行日期是否已超出结束日期
		bool CheckOvertime(void)
		{
			//EndTime 为 Empty 没有超出日期限制
			if ( EndTime.Empty() )
				return false;

			return ( EndTime < Time );
		}
	};

public:
	std::list< CLoopData* > LoopList;
	std::map< uint32, CLoopData* > LoopById;

    //< key, < LoopId > >
    std::map< std::string, std::set< uint32 > > LoopKeyList;
	//std::map< std::string, uint32 > TimeByName;
    std::vector< std::list< CLoopData* >* > CallVec;

    SMillisecond CallTime;

    void (*OnTime)( uint32 LoopId, std::string& key, std::string& param, uint32 );

    wd::CMutex m_mutex;
public:
	CSysTimeMgr();
	~CSysTimeMgr();

	uint32 AllocLoopId(void);

	// [2010/02/10 14:00:00] or [2010/02/10] or [14:00:00]
	//Timeset == NULL || Timeset[0] == '\0' use timenow
	//Loop = 0 don't stop off, if Loop > 0 to run [Loop] times
	uint32 AddLoop
    (
        std::string key,                //执行键, key[0] == '#' 即允许重复注册定时回调, key[0] != '#' 只允许注册一次
        std::string param,              //执行参数
        const char *Timeset,
        const char *EndTimeset,
        int Type,
        int Delay,
        int Loop
    );

    //256秒内的定时器池, 高效接口
	uint32 AddCall( std::string key, std::string param, uint32 Seconds );

    //不使用秒池的接口, 点用资源较大
	uint32 AddOLDCall( std::string key, std::string param, uint32 Seconds );

    std::string GetLoopList();
    std::string ListDetail( uint32 loop_id );

private:
	void AddLoop( CLoopData *pLoopData );
	void DelLoop( uint32 LoopId );		//DelLoop只在内部使用, 会删除对象, 如果外部调用删除后对象可能被时间排序列表继续使用

public:
	CLoopData* GetLoop( uint32 LoopId );
	bool CheckLoop( uint32 LoopId );
	void RemoveLoop( uint32 LoopId );		//外部使用RemoveLoop, 打上Delete标记, 在下次超时时再进行删除, 不直接删除
    void RemoveLoop( std::string key );

    bool Valid( uint32 LoopId );

	void SetEndTime( uint32 LoopId, const char *Timeset );	//设置循环时间结束时间点

    void SetOnTime( void(*call)( uint32, std::string&, std::string&, uint32 ) );

    void Process(void);
/*
	void SetTime( const char *Key, uint32 Time );
	uint32 GetTime( const char *Key );
*/
    uint32 GetKeyCount( std::string key );

    //获取下次执行时间截
    uint32 GetNextTime( uint32 LoopId );
private:
	void UpdateLoopNextTime( CSysTimeMgr::CLoopData &LoopData );
	void UpdateLoopDataDay( CSysTimeMgr::CLoopData &LoopData );

	void InsertToLoopList( CSysTimeMgr::CLoopData *pLoopData );
    void InsertToCallList( CSysTimeMgr::CLoopData *pLoopData, int32 index );

public:
	static SSysTime TimesetToSystime( const char *Timeset, SSysTime reTime = SSysTime() );
    static time_t TimeStrToValue(const char *time_str);
    static std::string TimestrDecrease(const char *time_str, ETimeType time_type, int value);
    static void OnTimeoutMsg( void* msg, void* pStatic, void* pDynamic );
};
#define theSysTimeMgr TSignleton< CSysTimeMgr >::Ref()

#endif


