#ifndef _WEEDONG_CORE_TIMER_H_
#define _WEEDONG_CORE_TIMER_H_

#include <weedong/core/os.h>

#include <vector>
#include <list>
#include <map>
#include <algorithm>

namespace wd
{

class CTimer
{
public:
	enum EType
	{
		eRemove = 0,        //已删除

		eYear = 1,
		eMonth = 2,
		eDay = 3,
		eHour = 4,
		eMinute = 5,
		eSecond = 6,
	};

	class CLoopData
	{
	public:
		uint32 LoopId;

		int16 LoopMax;
		int16 LoopCount;

        EType Type;
        uint32 Delay;

		struct tm NextTime;
		struct tm EndTime;

		CLoopData();
        virtual ~CLoopData();

		bool CheckOvertime(void);

		virtual void OnTimeout(void) = 0;
	};

	template< typename T >
	class TLoopData : public CLoopData
	{
	public:
		T Timeout;

	public:
        TLoopData( T timeout ) : Timeout( timeout ){};
        virtual ~TLoopData(){};
		virtual void OnTimeout(void)
		{
			Timeout();
		}
	};

public:
	std::vector< CLoopData* > LoopList;
	std::map< uint32, CLoopData* > LoopById;

	mutex_t mutex;
public:
	CTimer();
	~CTimer();

	// return value:
	// [2010/02/10 14:00:00] or [2010/02/10] or [14:00:00]
	//Timeset == NULL || Timeset[0] == '\0' use timenow
	//Loop = 0 don't stop off, if Loop > 0 to run [Loop] times
	template< typename T >
	uint32 AddLoop( 
			const char *Timeset,
            CTimer::EType Type,
			int Delay,
			int Loop,
			T OnTimeout )
	{
		if ( Type < 1 || Type > 7 || Delay == 0 )
			return 0;

        struct tm timenow = localtime();

        mutex_lock( &mutex );

        uint32 LoopId = AllocLoopId();

		struct tm LoopTime = formation( Timeset, timenow );

		CLoopData *pLoopData = new TLoopData<T>( OnTimeout );
		pLoopData->LoopId = LoopId;

		pLoopData->LoopMax = Loop; 
		pLoopData->LoopCount = 0; 
		pLoopData->NextTime = LoopTime; 
		pLoopData->Type = Type; 
		pLoopData->Delay = Delay; 

		while( tm_compare_less( pLoopData->NextTime, timenow ) )
		{
			pLoopData->LoopCount++;
			UpdateLoopNextTime( *pLoopData );	
		}

		if ( pLoopData->LoopMax != 0 && pLoopData->LoopCount >= pLoopData->LoopMax )
		{
			delete pLoopData;

            mutex_unlock( &mutex );
			return 0;
		}

		AddLoop( pLoopData );
		InsertToLoopList( pLoopData );

        mutex_unlock( &mutex );

		return LoopId;
	}

	template< typename T >
	uint32 AddCall( uint32 Seconds, T OnTimeout )
	{
        mutex_lock( &mutex );

        uint32 LoopId = AllocLoopId();

		CLoopData *pLoopData = new TLoopData<T>( OnTimeout );
		pLoopData->LoopId = LoopId;

		pLoopData->LoopMax = 1;
		pLoopData->LoopCount = 0;
		pLoopData->Time = localtime();
		pLoopData->Type = CTimer::Second;
		pLoopData->Delay = Seconds;

		UpdateLoopNextTime( *pLoopData );

		AddLoop( pLoopData );
		InsertToLoopList( pLoopData );

        mutex_unlock( &mutex );

		return LoopId;
	}

private:
	void AddLoop( CLoopData *pLoopData );
	void DelLoop( uint32 LoopId );		//从列表中删除一个循环
	uint32 AllocLoopId(void);

public:
	CLoopData* GetLoop( uint32 LoopId );
	bool CheckLoop( uint32 LoopId );
	void RemoveLoop( uint32 LoopId );		//在循环体中打上remove标志, 下次循环时再delete

	void SetEndTime( uint32 LoopId, const char *Timeset );	//设置循环体结束时间, 超过结束时间时会被delete

	void Update(void);

private:
	void UpdateLoopNextTime( CTimer::CLoopData &LoopData );
	void UpdateLoopDataDay( CTimer::CLoopData &LoopData );

	void InsertToLoopList( CTimer::CLoopData *pLoopData );

private:
	static struct tm formation( const char *format, struct tm &_tm );
};

bool tm_compare_less ( tm &_l, tm &_r );

}

#endif

