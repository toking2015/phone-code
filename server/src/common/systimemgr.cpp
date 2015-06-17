#include "systimemgr.h"
#include <algorithm>

#include "pack.h"
#include "msg.h"
#include "misc.h"
#include "log.h"
#include "util.h"

#include "proto/constant.h"

SMillisecond operator - ( SMillisecond &ms1, SMillisecond &ms2 )
{
	SMillisecond ms(ms1);
	ms -= ms2;
	return ms;
}

SMillisecond operator + ( SMillisecond &ms1, SMillisecond &ms2 )
{
	SMillisecond ms(ms1);
	ms += ms2;
	return ms;
}

SMillisecond GetMSec(void)
{
#ifdef LINUX
	timeval tv;
	gettimeofday( &tv, 0 );
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;
#else
	return GetTickCount();
#endif
}

bool operator < ( SSysTime &_l, SSysTime &_r )
{
	if ( _l.Year	!= _r.Year )		return _l.Year		< _r.Year;
	if ( _l.Month	!= _r.Month )		return _l.Month		< _r.Month;
	if ( _l.Day		!= _r.Day )			return _l.Day		< _r.Day;
	if ( _l.Hour	!= _r.Hour )		return _l.Hour		< _r.Hour;
	if ( _l.Minute	!= _r.Minute )		return _l.Minute	< _r.Minute;
	if ( _l.Second	!= _r.Second )		return _l.Second	< _r.Second;
	return _l.Millisecond < _r.Millisecond;
}

bool operator <= ( SSysTime &_l, SSysTime &_r )
{
	if ( _l.Year	!= _r.Year )		return _l.Year		<= _r.Year;
	if ( _l.Month	!= _r.Month )		return _l.Month		<= _r.Month;
	if ( _l.Day		!= _r.Day )			return _l.Day		<= _r.Day;
	if ( _l.Hour	!= _r.Hour )		return _l.Hour		<= _r.Hour;
	if ( _l.Minute	!= _r.Minute )		return _l.Minute	<= _r.Minute;
	if ( _l.Second	!= _r.Second )		return _l.Second	<= _r.Second;
	return _l.Millisecond <= _r.Millisecond;
}
//===========================================
bool IsLeapYear( const tm *pTM )
{
	uint32 Year = pTM->tm_year + 1900;
	return IsLeapYear( Year );
}

bool IsLeapYear( uint32 Year )
{
	return Year % 400 == 0 || ( Year % 4 == 0 && Year % 100 != 0 );
}

uint32 GetMaxYearDay( const tm *pTM )
{
	return IsLeapYear( pTM ) ? 366 : 365;
}

uint32 GetMaxMonthDay( const tm *pTM )
{
	uint32 Year = pTM->tm_year + 1900;
	uint32 Month = pTM->tm_mon + 1;
	return GetMaxMonthDay( Year, Month );
}

uint32 GetMaxMonthDay( uint32 Year, uint32 Month )
{
	switch ( Month )
	{
		case 1:
		case 3:
		case 5:
		case 7:
		case 8:
		case 10:
		case 12:
			return 31;

		case 4:
		case 6:
		case 9:
		case 11:
			return 30;
	}

	return IsLeapYear( Year ) ? 29 : 28;
}

uint32 GetMaxMonthDay( CSysTimeMgr::CLoopData &LoopData )
{
	return GetMaxMonthDay( LoopData.Time.Year, LoopData.Time.Month );
}

void CSysTimeMgr::UpdateLoopDataDay( CSysTimeMgr::CLoopData &LoopData )
{
	while ( (uint32)LoopData.Time.Day > GetMaxMonthDay( LoopData ) )
	{
		LoopData.Time.Day -= GetMaxMonthDay( LoopData );
		if ( ++LoopData.Time.Month > 12 )
		{
			LoopData.Time.Month -= 12;
			LoopData.Time.Year++;
		}
	}
}
void CSysTimeMgr::UpdateLoopNextTime( CSysTimeMgr::CLoopData &LoopData )
{
	switch ( LoopData.Type )
	{
	case CSysTimeMgr::Year:
		LoopData.Time.Year += LoopData.Delay;
		break;
	case CSysTimeMgr::Month:
		LoopData.Time.Month += LoopData.Delay;
		break;
	case CSysTimeMgr::Day:
		LoopData.Time.Day += LoopData.Delay;
		break;
	case CSysTimeMgr::Hour:
		LoopData.Time.Hour += LoopData.Delay;
		break;
	case CSysTimeMgr::Minute:
		LoopData.Time.Minute += LoopData.Delay;
		break;
	case CSysTimeMgr::Second:
		LoopData.Time.Second += LoopData.Delay;
		break;
	case CSysTimeMgr::Millisecond:
		LoopData.Time.Millisecond += LoopData.Delay;
		break;
	}

	if ( LoopData.Time.Millisecond >= 1000 )
	{
		LoopData.Time.Second += LoopData.Time.Millisecond / 1000;
		LoopData.Time.Millisecond %= 1000;
	}

	if ( LoopData.Time.Second >= 60 )
	{
		LoopData.Time.Minute += LoopData.Time.Second / 60;
		LoopData.Time.Second %= 60;
	}

	if ( LoopData.Time.Minute >= 60 )
	{
		LoopData.Time.Hour += LoopData.Time.Minute / 60;
		LoopData.Time.Minute %= 60;
	}

	if ( LoopData.Time.Hour >= 24 )
	{
		LoopData.Time.Day += LoopData.Time.Hour / 24;
		LoopData.Time.Hour %= 24;
	}

	UpdateLoopDataDay( LoopData );
}

//===========================CSysTimeMgr================
CSysTimeMgr::CSysTimeMgr()
{
    OnTime = NULL;

    CallVec.resize( 256 );
    for ( uint32 i = 0; i < CallVec.size(); ++i )
        CallVec[i] = new std::list< CLoopData* >;
}

CSysTimeMgr::~CSysTimeMgr()
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	for ( std::list< CLoopData* >::iterator iter = LoopList.begin();
			iter != LoopList.end();
			++iter )
	{
		delete (*iter);
	}
	LoopList.clear();
	LoopById.clear();
    LoopKeyList.clear();
}

void CSysTimeMgr::RemoveLoop( uint32 LoopId )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	CLoopData *pLoopData = GetLoop( LoopId );
	if ( pLoopData != NULL )
		pLoopData->Delete = true;
}

void CSysTimeMgr::RemoveLoop( std::string key )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

    std::set< uint32 >& set = LoopKeyList[ key ];
    for ( std::set< uint32 >::iterator iter = set.begin();
        iter != set.end();
        ++iter )
    {
        CLoopData *pLoopData = GetLoop( *iter );
        if ( pLoopData != NULL )
            pLoopData->Delete = true;
    }
}

bool CSysTimeMgr::Valid( uint32 LoopId )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

    CLoopData *pLoopData = GetLoop( LoopId );
    if ( pLoopData == NULL || pLoopData->Delete )
        return false;

    return ( pLoopData->LoopMax == 0 || pLoopData->LoopCount < pLoopData->LoopMax );
}

void CSysTimeMgr::SetOnTime( void(*call)( uint32, std::string&, std::string&, uint32 ) )
{
    OnTime = call;
}

void CSysTimeMgr::SetEndTime( uint32 LoopId, const char *Timeset )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	CLoopData *pLoopData = GetLoop( LoopId );
	if ( pLoopData == NULL )
		return;

	if ( Timeset == NULL || Timeset[0] == '\0' )
	{
		new (&pLoopData->EndTime)SSysTime();
		return;
	}

	pLoopData->EndTime = TimesetToSystime( Timeset, SSysTime(true) );
	pLoopData->EndTime.Millisecond = 0;
}

bool CSysTimeMgr::CheckLoop( uint32 LoopId )
{
     wd::CGuard<wd::CMutex > safe(&m_mutex);

	 CLoopData *pLoopData = GetLoop( LoopId );
	 if ( pLoopData != NULL && !pLoopData->Delete )
		 return true;

	return false;
}

struct _systime_mgr_timer_data
{
    std::string time_key;
    std::string time_param;
    uint32      time_sec;
};
void CSysTimeMgr::Process(void)
{
	SSysTime TimeNow(true);
    SMillisecond MSecNow = GetMSec();

    std::list< std::pair< uint32, _systime_mgr_timer_data > > loopList;       //需要执行的loopId

    //获得循环处理单元
	std::list< CLoopData* > RunList;
	{
        wd::CGuard<wd::CMutex > safe(&m_mutex);

		std::list< CLoopData* >::iterator iter = LoopList.begin();
		for ( ; iter != LoopList.end(); ++iter )
		{
			CLoopData *pLoopData = (*iter);

			if ( pLoopData->Delete )
			{
				//删除元素
				DelLoop( pLoopData->LoopId );
				continue;
			}

			if ( TimeNow < pLoopData->Time )
				break;

			//压入运算表
			RunList.push_back( pLoopData );
		}

		//移除遍历过的元素
		LoopList.erase( LoopList.begin(), iter );
	}
	for ( std::list< CLoopData* >::iterator iter = RunList.begin();
			iter != RunList.end();
			++iter )
	{
		CLoopData *pLoopData = (*iter);

        uint32 LoopId = pLoopData->LoopId;

		//判断执行日期是否超过EndTime
		if ( pLoopData->CheckOvertime() )
		{
			DelLoop( pLoopData->LoopId );
			continue;
		}

        _systime_mgr_timer_data data;
        data.time_key   = pLoopData->key;
        data.time_param = pLoopData->param;
        data.time_sec   = pLoopData->Time.GetSec();
        loopList.push_back( std::make_pair( LoopId, data ) );
	}

    //获得秒表处理单元
    if ( MSecNow.ToMSec() > CallTime.ToMSec() + 1000 )
    {
        //更新时间
        CallTime = MSecNow;

        //取出执行Id
        std::list< CLoopData* >* pList = *CallVec.begin();
        for ( std::list< CLoopData* >::iterator iter = pList->begin();
            iter != pList->end();
            ++iter )
        {
            CLoopData *pLoopData = (*iter);

            if ( pLoopData->Delete )
            {
                //删除元素
                DelLoop( pLoopData->LoopId );
                continue;
            }

            _systime_mgr_timer_data data;
            data.time_key   = pLoopData->key;
            data.time_param = pLoopData->param;
            data.time_sec   = pLoopData->Time.GetSec();
            loopList.push_back( std::make_pair( pLoopData->LoopId, data ) );
        }

        //维护列表
        pList->clear();
        CallVec.erase( CallVec.begin() );
        CallVec.push_back( pList );
    }

    //协议处理
    for ( std::list< std::pair< uint32, _systime_mgr_timer_data > >::iterator iter = loopList.begin();
        iter != loopList.end();
        ++iter )
    {
        uint32 LoopId = iter->first;

        CSysTimeMgr::CLoopData *pLoopData = GetLoop( LoopId );

        //不太可能出现, 但加下判断为托
        if ( pLoopData == NULL )
            continue;

        //先增加运行次数, 会影响到 Valid 接口
        pLoopData->LoopCount++;

        //调用定时器回调处理函数( 同步调用, 非异步, 已经是逻辑处理线程 )
        OnTime( LoopId, iter->second.time_key, iter->second.time_param, iter->second.time_sec );

        //定时器有可能在执行 OnTime 时被删除
        if ( pLoopData->Delete )
            continue;

        //判断循环次数是否完结
        if ( pLoopData->LoopCount >= pLoopData->LoopMax && pLoopData->LoopMax != 0 )
        {
            DelLoop( LoopId );
            return;
        }

        //更新下次执行日期
        UpdateLoopNextTime( *pLoopData );

        //插入执行队列
        InsertToLoopList( pLoopData );
    }
}

uint32 CSysTimeMgr::AddLoop
(
    std::string key,                //执行键
    std::string param,              //执行参数
    const char *Timeset,
    const char *EndTimeset,
    int Type,
    int Delay,
    int Loop
    )
{
    if ( key.empty() || Type < 1 || Type > 7 || Delay == 0 )
        return 0;

    if ( key[0] != '#' )
        RemoveLoop( key );

    SSysTime TimeNow( true );

    SSysTime LoopTime = TimesetToSystime( Timeset, TimeNow );
    LoopTime.Millisecond = 0;

    SSysTime EndLoopTime(false);
    if ( EndTimeset != NULL && EndTimeset[0] != '\0' )
        EndLoopTime = TimesetToSystime( EndTimeset, TimeNow );
    EndLoopTime.Millisecond = 0;

    CLoopData *pLoopData = new CLoopData;
    pLoopData->LoopId = AllocLoopId();

    pLoopData->LoopMax = Loop;
    pLoopData->LoopCount = 0;
    pLoopData->Time = LoopTime;
    pLoopData->EndTime = EndLoopTime;
    pLoopData->Type = Type;
    pLoopData->Delay = Delay;
    pLoopData->key = key;
    pLoopData->param = param;

    while( pLoopData->Time < TimeNow )
    {
        pLoopData->LoopCount++;
        UpdateLoopNextTime( *pLoopData );
    }

    if ( pLoopData->LoopMax != 0 && pLoopData->LoopCount >= pLoopData->LoopMax )
    {
        delete pLoopData;
        return 0;
    }

    AddLoop( pLoopData );
    InsertToLoopList( pLoopData );

    return pLoopData->LoopId;
}

uint32 CSysTimeMgr::AddCall( std::string key, std::string param, uint32 Seconds )
{
    if ( key.empty() )
        return 0;

    if ( key[0] != '#' )
        RemoveLoop( key );

    //使用定时器
    SSysTime TimeNow( true );

    CLoopData *pLoopData = new CLoopData;

    pLoopData->LoopId = AllocLoopId();
    pLoopData->LoopMax = 1;
    pLoopData->LoopCount = 0;
    pLoopData->Time = TimeNow;
    pLoopData->Type = CSysTimeMgr::Second;
    pLoopData->Delay = Seconds;
    pLoopData->key = key;
    pLoopData->param = param;

    UpdateLoopNextTime( *pLoopData );

    if ( Seconds >= 256 )
        InsertToLoopList( pLoopData );
    else
        InsertToCallList( pLoopData, Seconds );

    AddLoop( pLoopData );

    return pLoopData->LoopId;
}

uint32 CSysTimeMgr::AddOLDCall( std::string key, std::string param, uint32 Seconds )
{
    if ( key.empty() )
        return 0;

    if ( key[0] != '#' )
        RemoveLoop( key );

    //使用定时器
    SSysTime TimeNow( true );

    CLoopData *pLoopData = new CLoopData;

    pLoopData->LoopId = AllocLoopId();
    pLoopData->LoopMax = 1;
    pLoopData->LoopCount = 0;
    pLoopData->Time = TimeNow;
    pLoopData->Type = CSysTimeMgr::Second;
    pLoopData->Delay = Seconds;
    pLoopData->key = key;
    pLoopData->param = param;

    UpdateLoopNextTime( *pLoopData );
    InsertToLoopList( pLoopData );

    AddLoop( pLoopData );
    return pLoopData->LoopId;
}

/*
void CSysTimeMgr::SetTime( const char *Key, uint32 Time )
{
	TimeByName[ Key ] = Time;
}

uint32 CSysTimeMgr::GetTime( const char *Key )
{
	return TimeByName[ Key ];
}
*/

bool LoopData_CompareByTime( CSysTimeMgr::CLoopData *l, CSysTimeMgr::CLoopData *r )
{
	return l->Time < r->Time;
}
void CSysTimeMgr::InsertToLoopList( CSysTimeMgr::CLoopData *pLoopData )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	std::list< CLoopData* >::iterator lower = std::lower_bound(
			LoopList.begin(),
			LoopList.end(),
			pLoopData,
			LoopData_CompareByTime );

	LoopList.insert( lower, pLoopData );
}
void CSysTimeMgr::InsertToCallList( CSysTimeMgr::CLoopData *pLoopData, int32 index )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

    CallVec[ index ]->push_back( pLoopData );
}

uint32 CSysTimeMgr::AllocLoopId(void)
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	static uint32 LoopId = 0;

	//往下抽出一个空的 LoopId 作为分配Id
	for (;;)
	{
		std::map< uint32, CLoopData* >::iterator iter = LoopById.find( ++LoopId );
		if ( iter == LoopById.end() )
			break;
	}

    return LoopId;
}

void CSysTimeMgr::AddLoop( CLoopData *pLoopData )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	LoopById[ pLoopData->LoopId ] = pLoopData;
    LoopKeyList[ pLoopData->key ].insert( pLoopData->LoopId );
}

void CSysTimeMgr::DelLoop( uint32 LoopId )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	std::map< uint32, CLoopData* >::iterator iter = LoopById.find( LoopId );
	if ( iter != LoopById.end() )
	{
        CLoopData* pLoop = iter->second;

        LoopKeyList[ pLoop->key ].erase( LoopId );
		LoopById.erase( iter );

        delete pLoop;
	}
}

CSysTimeMgr::CLoopData* CSysTimeMgr::GetLoop( uint32 LoopId )
{
    wd::CGuard<wd::CMutex > safe(&m_mutex);

	std::map< uint32, CLoopData* >::iterator iter = LoopById.find( LoopId );
	if ( iter != LoopById.end() )
		return iter->second;

	return NULL;
}

SSysTime CSysTimeMgr::TimesetToSystime( const char *Timeset, SSysTime reTime/* = SSysTime() */)
{
	SSysTime Time = reTime;

	if ( Timeset != NULL && Timeset[0] != '\0' )
	{
		if ( sscanf( Timeset, "%d/%d/%d %d:%d:%d",
					&Time.Year, &Time.Month, &Time.Day, &Time.Hour, &Time.Minute, &Time.Second ) != 6 )
		{
			Time = reTime;
			if ( sscanf( Timeset, "%d/%d/%d", &Time.Year, &Time.Month, &Time.Day ) != 3 )
			{
				Time = reTime;
				if ( sscanf( Timeset, "%d:%d:%d", &Time.Hour, &Time.Minute, &Time.Second ) != 3 )
					Time = reTime;
			}
		}
	}

	return Time;
}

time_t CSysTimeMgr::TimeStrToValue(const char *time_str)
{
    struct tm _tm = {0};
    if ( sscanf( time_str, "%d/%d/%d %d:%d:%d",
            &_tm.tm_year, &_tm.tm_mon, &_tm.tm_mday, &_tm.tm_hour, &_tm.tm_min, &_tm.tm_sec) != 6 )
    {
        return 0;
    }

    _tm.tm_year -= 1900;
    _tm.tm_mon -= 1;

    time_t time_value = mktime(&_tm);
    return time_value;
}

std::string CSysTimeMgr::TimestrDecrease(const char *time_str, ETimeType time_type, int value)
{
    std::string ret;

    time_t time_value = TimeStrToValue(time_str);
    if (time_value == 0)
        return ret;

    if (Hour == time_type)
        value *= 3600;
    else if (Minute == time_type)
        value *= 60;

    time_value -= value;
    struct tm _tm;
    localtime_r(&time_value, &_tm);
    char buff[64] = { 0 };
    strftime(buff, sizeof(buff), "%Y/%m/%d %H:%M:%S", &_tm);

    ret = buff;
    return ret;
}

std::string CSysTimeMgr::GetLoopList()
{
    std::string loop_list("\n");
    for ( std::list< CLoopData* >::iterator iter = LoopList.begin();
        iter != LoopList.end();
        iter++ )
    {
        if ( (*iter)->key.empty() )
            continue;
        std::string tmp = strprintf( "%u: ", (*iter)->LoopId );
        loop_list += tmp;
        loop_list += (*iter)->key;
        loop_list += "\n";
    }
    return loop_list;
}

struct EqualLoopKey
{
    std::string key;
    EqualLoopKey( const char *p ) : key(p) {}
    bool operator()( const CSysTimeMgr::CLoopData* p )
    {
        return key == p->key;
    }
};
std::string CSysTimeMgr::ListDetail( uint32 loop_id )
{
    std::string ret;
    CSysTimeMgr::CLoopData *pLoopData = theSysTimeMgr.GetLoop( loop_id );
    if ( pLoopData != NULL )
    {
        ret = pLoopData->key;
        ret += "\n";

        std::string buff = strprintf("loopId:%u, loopMax:%u, loopCount:%u, type:%u, delay:%u\n",
            pLoopData->LoopId, pLoopData->LoopMax, pLoopData->LoopCount, pLoopData->Type, pLoopData->Delay );

        std::string start_time = strprintf("start_time: %04d-%02d-%02d %02d:%02d:%02d\n",
            pLoopData->Time.Year, pLoopData->Time.Month, pLoopData->Time.Day,
            pLoopData->Time.Hour, pLoopData->Time.Minute, pLoopData->Time.Second );

        std::string end_time = strprintf("end_time: %04d-%02d-%02d %02d:%02d:%02d\n",
            pLoopData->EndTime.Year, pLoopData->EndTime.Month, pLoopData->EndTime.Day,
            pLoopData->EndTime.Hour, pLoopData->EndTime.Minute, pLoopData->EndTime.Second );

        ret += buff;
        ret += start_time;
        ret += end_time;
    }
    return ret;
}

uint32 CSysTimeMgr::GetKeyCount( std::string key )
{
    wd::CGuard< wd::CMutex > safe(&m_mutex);

    std::set< uint32 >& set = LoopKeyList[ key ];
    uint32 count = 0;

    for ( std::set< uint32 >::iterator iter = set.begin();
        iter != set.end();
        ++iter )
    {
        CLoopData* pData = GetLoop( *iter );
        if ( pData != NULL && !pData->Delete )
            ++count;
    }

    return count;
}

uint32 CSysTimeMgr::GetNextTime( uint32 LoopId )
{
    std::map< uint32, CLoopData* >::iterator iter = LoopById.find( LoopId );
    if ( iter == LoopById.end() )
        return ~0;

    struct tm t_tm = {0};
    t_tm.tm_year = iter->second->Time.Year - 1900;
    t_tm.tm_mon = iter->second->Time.Month - 1;
    t_tm.tm_mday = iter->second->Time.Day;
    t_tm.tm_hour = iter->second->Time.Hour;
    t_tm.tm_min = iter->second->Time.Minute;
    t_tm.tm_sec = iter->second->Time.Second;

    return (uint32)mktime( &t_tm );
}

