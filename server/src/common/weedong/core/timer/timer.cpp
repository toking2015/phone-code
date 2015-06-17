#include <weedong/core/timer/timer.h>

namespace wd
{

//Misc
bool tm_compare_less ( tm &_l, tm &_r )
{
    if ( _l.tm_year	!= _r.tm_year )		return _l.tm_year		< _r.tm_year;
    if ( _l.tm_mon	!= _r.tm_mon )		return _l.tm_mon		< _r.tm_mon;
    if ( _l.tm_mday	!= _r.tm_mday )		return _l.tm_mday		< _r.tm_mday;
    if ( _l.tm_hour	!= _r.tm_hour )		return _l.tm_hour		< _r.tm_hour;
    if ( _l.tm_min	!= _r.tm_min )		return _l.tm_min    	< _r.tm_min;
	return _l.tm_sec < _r.tm_sec;
}

bool isLeapYear( uint32 year )
{
	return year % 400 == 0 || ( year % 4 == 0 && year % 100 != 0 );
}

bool isLeapYear( const tm *pTm )
{
	uint32 year = pTm->tm_year + 1900;
	return isLeapYear( year );
}

int32 getMaxYearDay( const tm *pTm )
{
	return isLeapYear( pTm ) ? 366 : 365;
}

int32 getMaxMonthDay( uint32 year, uint32 month )
{
	switch ( month )
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

	return isLeapYear( year ) ? 29 : 28;
}

int32 getMaxMonthDay( const tm *pTm )
{
	uint32 year = pTm->tm_year + 1900;
	uint32 month = pTm->tm_mon + 1;
	return getMaxMonthDay( year, month );
}

int32 getMaxMonthDay( CTimer::CLoopData &LoopData )
{
	return getMaxMonthDay( LoopData.NextTime.tm_year, LoopData.NextTime.tm_mon );
}

//CLoopData
CTimer::CLoopData::CLoopData()
{
	memset( this, 0, sizeof(*this) );
}

CTimer::CLoopData::~CLoopData()
{

}

bool CTimer::CLoopData::CheckOvertime(void)
{
    if ( EndTime.tm_year == 0 )
		return false;

	return tm_compare_less( EndTime, NextTime );
}

//CTimer
CTimer::CTimer()
{
    mutex_create( &mutex );
}

CTimer::~CTimer()
{
	mutex_lock( &mutex );

	for ( std::vector< CLoopData* >::iterator iter = LoopList.begin();
			iter != LoopList.end();
			++iter )
	{
		delete (*iter);
	}
	LoopList.clear();
	LoopById.clear();

    mutex_unlock( &mutex );
    mutex_destroy( &mutex );
}

void CTimer::UpdateLoopDataDay( CTimer::CLoopData &LoopData )
{
	while ( LoopData.NextTime.tm_mday > getMaxMonthDay( LoopData ) )
	{
		LoopData.NextTime.tm_mday -= getMaxMonthDay( LoopData );
		if ( ++LoopData.NextTime.tm_mon > 12 )
		{
			LoopData.NextTime.tm_mon -= 12;
			LoopData.NextTime.tm_year++;
		}
	}
}
void CTimer::UpdateLoopNextTime( CTimer::CLoopData &LoopData )
{
	switch ( LoopData.Type )
	{
	case CTimer::eYear:
		LoopData.NextTime.tm_year += LoopData.Delay;
		break;
	case CTimer::eMonth:
		LoopData.NextTime.tm_mon += LoopData.Delay;
		break;
	case CTimer::eDay:
		LoopData.NextTime.tm_mday += LoopData.Delay;
		break;
	case CTimer::eHour:
		LoopData.NextTime.tm_hour += LoopData.Delay;
		break;
	case CTimer::eMinute:
		LoopData.NextTime.tm_min += LoopData.Delay;
		break;
	case CTimer::eSecond:
		LoopData.NextTime.tm_sec += LoopData.Delay;
		break;
	}

	if ( LoopData.NextTime.tm_sec >= 60 )
	{
        LoopData.NextTime.tm_min += LoopData.NextTime.tm_sec / 60;
		LoopData.NextTime.tm_sec %= 60;
	}

    if ( LoopData.NextTime.tm_min >= 60 )
	{
        LoopData.NextTime.tm_hour += LoopData.NextTime.tm_min / 60;
        LoopData.NextTime.tm_min %= 60;
	}

    if ( LoopData.NextTime.tm_hour >= 24 )
	{
        LoopData.NextTime.tm_mday += LoopData.NextTime.tm_hour / 24;
		LoopData.NextTime.tm_hour %= 24;
	}

	UpdateLoopDataDay( LoopData );
}

void CTimer::RemoveLoop( uint32 LoopId )
{
	mutex_lock( &mutex );

	CLoopData *pLoopData = GetLoop( LoopId );
	if ( pLoopData != NULL )
        pLoopData->Type = CTimer::eRemove;

    mutex_unlock( &mutex );
}

void CTimer::SetEndTime( uint32 LoopId, const char *Timeset )
{
	mutex_lock( &mutex );

	CLoopData *pLoopData = GetLoop( LoopId );
	if ( pLoopData == NULL )
    {
        mutex_unlock( &mutex );
		return;
    }

	if ( Timeset == NULL || Timeset[0] == '\0' )
	{
		memset( &pLoopData->EndTime, 0, sizeof( pLoopData->EndTime ) );

        mutex_unlock( &mutex );
		return;
	}

	pLoopData->EndTime = formation( Timeset, localtime() );

    mutex_unlock( &mutex );
}

bool CTimer::CheckLoop( uint32 LoopId )
{
    mutex_lock( &mutex );

    CLoopData *pLoopData = GetLoop( LoopId );

    bool isLive = ( pLoopData != NULL && pLoopData->Type != CTimer::eRemove );

    mutex_unlock( &mutex );
     
    return isLive;
}

//Update
void CTimer::Update(void)
{
	if ( LoopList.empty() )
		return;

    struct tm timenow = localtime();

	std::list< CLoopData* > RunList;
	{
		mutex_lock( &mutex );

		std::vector< CLoopData* >::iterator iter = LoopList.begin();
		for ( ; iter != LoopList.end(); ++iter )
		{
			CLoopData *pLoopData = (*iter);

            if ( pLoopData->Type == CTimer::eRemove )
			{
                //删除循环
				DelLoop( pLoopData->LoopId );
				continue;
			}

			if ( tm_compare_less( timenow, pLoopData->NextTime ) )
				break;

            //压入到运行列表
			RunList.push_back( pLoopData );
		}

        //删除当前循环
		LoopList.erase( LoopList.begin(), iter );

        mutex_unlock( &mutex );
	}

	for ( std::list< CLoopData* >::iterator iter = RunList.begin();
			iter != RunList.end();
			++iter )
	{
		CLoopData *pLoopData = (*iter);

		//检查循环体是否已超过最后结束时间
		if ( pLoopData->CheckOvertime() )
		{
			DelLoop( pLoopData->LoopId );
			continue;
		}

		//调用循环体执行时间
		pLoopData->OnTimeout();

		//累加循环执行次数
		if ( ++(pLoopData->LoopCount) >= pLoopData->LoopMax && pLoopData->LoopMax != 0 )
		{
			DelLoop( pLoopData->LoopId );
			continue;
		}

		//更新下次执行时间
		UpdateLoopNextTime( *pLoopData );

		//插入执行列表
		InsertToLoopList( pLoopData );
	}
}

bool time_compare_less( CTimer::CLoopData *l, CTimer::CLoopData *r )
{
    return tm_compare_less( l->NextTime, r->NextTime );
}
void CTimer::InsertToLoopList( CTimer::CLoopData *pLoopData )
{
	mutex_lock( &mutex );

	std::vector< CLoopData* >::iterator lower = std::lower_bound( 
			LoopList.begin(), 
			LoopList.end(), 
			pLoopData,  
			time_compare_less );

	LoopList.insert( lower, pLoopData );

    mutex_unlock( &mutex );
}

uint32 CTimer::AllocLoopId(void)
{
	static uint32 LoopId = 0;

	//循环获取一个不重复的LoopId
	for (;;)
	{
		++LoopId;

		std::map< uint32, CLoopData* >::iterator iter = LoopById.find( LoopId );
		if ( iter == LoopById.end() )
			break;
	}

	return LoopId;
}

void CTimer::AddLoop( CLoopData *pLoopData )
{
	mutex_lock( &mutex );

	LoopById[ pLoopData->LoopId ] = pLoopData;

    mutex_unlock( &mutex );
}

void CTimer::DelLoop( uint32 LoopId )
{
	mutex_lock( &mutex );

	std::map< uint32, CLoopData* >::iterator iter = LoopById.find( LoopId );
	if ( iter != LoopById.end() )
	{
		delete iter->second;
		LoopById.erase( iter );
	}

    mutex_unlock( &mutex );
}

CTimer::CLoopData* CTimer::GetLoop( uint32 LoopId )
{
	mutex_lock( &mutex );

    CLoopData *pLoopData = NULL;
	std::map< uint32, CLoopData* >::iterator iter = LoopById.find( LoopId );
	if ( iter != LoopById.end() )
        pLoopData = iter->second;

    mutex_unlock( &mutex );

	return pLoopData;
}

struct tm CTimer::formation( const char *format, struct tm &_tm )
{
	struct tm ret = _tm;

	if ( format != NULL && format[0] != '\0' )
	{
		if ( sscanf( format, "%d/%d/%d %d:%d:%d",
            &ret.tm_yday, &ret.tm_mon, &ret.tm_mday, &ret.tm_hour, &ret.tm_min, &ret.tm_sec ) != 6 )
		{
			ret = _tm;
			if ( sscanf( format, "%d/%d/%d", &ret.tm_yday, &ret.tm_mon, &ret.tm_mday ) != 3 )
			{
				ret = _tm;
				if ( sscanf( format, "%d:%d:%d", &ret.tm_hour, &ret.tm_min, &ret.tm_sec ) != 3 )
					ret = _tm;
			}
		}
	}

	return ret;
}

}

