#include "sql.h"

namespace wd
{

CSql::CSql()
{
	m_hSql = NULL;
	m_hResult = NULL;

	m_hRow = NULL;
	m_fieldLengthArray = NULL;

	m_bConnected = false;

    m_lastString.resize( 64 * 1024 );
    m_lastString[0] = '\0';
}

CSql::CSql( const char *host, uint16 port, const char *db, const char *usr, const char *pwd )
{
	m_hSql = NULL;
	m_hResult = NULL;

	m_hRow = NULL;
	m_fieldLengthArray = NULL;

	connect( host, port, db, usr, pwd );

    m_lastString.resize( 64 * 1024 );
    m_lastString[0] = '\0';
}

CSql::~CSql()
{
	disconnect();
}

uint32 CSql::lastErrorCode(void)
{
	if ( m_hSql == NULL )
		return -1;

	return mysql_errno( m_hSql );
}

const char* CSql::lastErrorMsg(void)
{
	if ( m_hSql == NULL )
		return NULL;

	return mysql_error( m_hSql );
}

const char* CSql::lastSqlString(void)
{
    return &m_lastString[0];
}

void CSql::freeResult(void)
{
	if ( m_hSql == NULL )
		return;

	if ( m_hResult == NULL )
		m_hResult = mysql_store_result( m_hSql );

	if ( m_hResult != NULL )
		mysql_free_result( m_hResult );

	while ( mysql_next_result( m_hSql ) == 0 )
	{
		m_hResult = mysql_store_result( m_hSql );
		if ( m_hResult != NULL )
			mysql_free_result( m_hResult );
	}

	m_hResult = NULL;
}

bool CSql::connected(void)
{
	return m_bConnected;
}

bool CSql::connect( const char *host, uint16 port, const char *db, const char *usr, const char *pwd )
{
	//printf( "Mysql->Connect Host[%s] Port[%d] DataBase[%s] User[%s] Password[%s]\r\n", host, port, db, usr, pwd );

	disconnect();

	m_bConnected = false;

	if ( (m_hSql = mysql_init(NULL)) != NULL )
	{
		if ( m_hSql == mysql_real_connect( m_hSql, host, usr, pwd, db, port, NULL, CLIENT_FOUND_ROWS | CLIENT_MULTI_RESULTS ) )
        {
            mysql_set_character_set( m_hSql, "utf8" );
			m_bConnected = true;
        }
	}

	return m_bConnected;
}

void CSql::disconnect(void)
{
	freeResult();

	if ( m_hSql != NULL)
	{
		mysql_close( m_hSql );
		m_hSql = NULL;
	}
}

bool CSql::test(void)
{
	if ( !connected() )
		return false;

	return ( mysql_ping( m_hSql ) == 0 );
}

#ifdef WIN32
int asprintf(char **strp, const char *fmt, ...)
{
    va_list va;
    va_start(va, fmt);
    const int required = vsnprintf(NULL, 0, fmt, va);
    char *const buffer = (char *) malloc(required + 1);
    const int ret = vsnprintf(buffer, required + 1, fmt, va);
    *strp = buffer;
    va_end(va);
    return ret;
}

int vasprintf(char **strp, const char *fmt, va_list va)
{
    const int required = vsnprintf(NULL, 0, fmt, va);
    char *const buffer = (char *) malloc(required + 1);
    const int ret = vsnprintf(buffer, required + 1, fmt, va);
    *strp = buffer;
    return ret;
}
#endif
int32 CSql::query( const char *format, ... )
{
	freeResult();

	char *mysql_string = NULL;

	va_list args;
	va_start(args, format);
	int32 mysql_string_length = vasprintf( &mysql_string, format, args );
	va_end(args);

	if ( mysql_string == NULL )
		return 0;

    if ( (int32)m_lastString.size() < mysql_string_length + 1 )
        m_lastString.resize( mysql_string_length + 1 );
    memcpy( &m_lastString[0], mysql_string, mysql_string_length );
    m_lastString[ mysql_string_length ] = '\0';
	//printf( "Query[%s]\r\n", mysql_string );

	if ( mysql_real_query( m_hSql, mysql_string, mysql_string_length ) != 0 )
	{
		free( mysql_string );
		return 0;
	}

	free( mysql_string );

	m_hResult = mysql_store_result( m_hSql );
	if ( m_hResult == NULL )
		return 0;

	first();
	return (int32)mysql_num_rows( m_hResult );
}
int32 CSql::query( const std::string string )
{
    return query( string.c_str() );
}

int32 CSql::execute( const char *format, ... )
{
	freeResult();

	char *mysql_string = NULL;

	va_list args;
	va_start(args, format);
	int32 mysql_string_length = vasprintf( &mysql_string, format, args );
	va_end(args);

	if ( mysql_string == NULL )
		return 0;

    if ( (int32)m_lastString.size() < mysql_string_length + 1 )
        m_lastString.resize( mysql_string_length + 1 );
    memcpy( &m_lastString[0], mysql_string, mysql_string_length );
    m_lastString[ mysql_string_length ] = '\0';
	//printf( "Query[%s]\r\n", mysql_string );

	if ( mysql_real_query( m_hSql, mysql_string, mysql_string_length ) != 0 )
	{
		free( mysql_string );
		return 0;
	}

	free( mysql_string );
	return (int32)mysql_affected_rows( m_hSql );
}

int64 CSql::insertId(void)
{
	if ( m_hSql == NULL )
		return 0;

	return mysql_insert_id( m_hSql );
}

void CSql::first(void)
{
	if ( m_hResult != NULL )
	{
		mysql_data_seek( m_hResult, 0 );
		mysql_field_seek( m_hResult, 0 );
		next();
	}
}

void CSql::next(void)
{
	if ( m_hResult != NULL )
	{
		m_hRow = mysql_fetch_row( m_hResult );
		m_fieldLengthArray = mysql_fetch_lengths( m_hResult );
	}
}

bool CSql::empty(void)
{
	return ( m_hResult == NULL || m_hRow == NULL || !(*m_hRow) || m_fieldLengthArray == NULL );
}

int32 CSql::getInteger( int32 Index )
{
	if ( m_hResult == NULL )
		return 0;

	if ( Index < 0 || Index >= (int32)m_hResult->field_count )
		return 0;

	if ( m_fieldLengthArray[ Index ] <= 0 )
		return 0;

	char __buffer[16] = {0};
	memcpy( __buffer,
			m_hRow[ Index ],
			m_fieldLengthArray[ Index ] > sizeof( __buffer ) - 1 ? sizeof( __buffer ) - 1 : m_fieldLengthArray[ Index ] );

	char *begin = __buffer;
	char *end = begin + sizeof(__buffer) - 1;

	if ( *begin == '\0' )
		return 0;

	for ( begin = begin + 1; *begin != '\0' && begin < end; ++begin )
	{
		if ( *begin < '0' || *begin > '9' )
			return 0;
	}

	return atoi( __buffer );
}

int64 CSql::getLong( int32 Index )
{
    if ( m_hResult == NULL )
        return 0;

    if ( Index < 0 || Index >= (int32)m_hResult->field_count )
        return 0;

    if ( m_fieldLengthArray[ Index ] <= 0 )
        return 0;

    char __buffer[32] = {0};
    memcpy( __buffer,
        m_hRow[ Index ],
        m_fieldLengthArray[ Index ] > sizeof( __buffer ) - 1 ? sizeof( __buffer ) - 1 : m_fieldLengthArray[ Index ] );

    char *begin = __buffer;
    char *end = begin + sizeof(__buffer) - 1;

    if ( *begin == '\0' )
        return 0;

    for ( begin = begin + 1; *begin != '\0' && begin < end; ++begin )
    {
        if ( *begin < '0' || *begin > '9' )
            return 0;
    }

    return atoll( __buffer );
}

std::string CSql::getString( int32 Index )
{
	if ( m_hResult == NULL )
		return std::string();

	if ( Index < 0 || Index >= (int32)m_hResult->field_count )
		return std::string();

	if ( m_fieldLengthArray[ Index ] <= 0 )
		return std::string();

	return std::string( (char*)m_hRow[ Index ], m_fieldLengthArray[ Index ] );
}

bool CSql::getData( int32 Index, void* data, int32 size, int32 offset )
{
	if ( data == NULL || size <= 0 || offset < 0 )
		return false;

	if ( m_hResult == NULL )
		return false;

	if ( Index < 0 || Index >= (int32)m_hResult->field_count )
		return false;

	if ( (int32)m_fieldLengthArray[ Index ] < offset + size )
		return false;

	memcpy( data, m_hRow[ Index ] + offset, size );

	return true;
}

int32 CSql::getSize( int32 Index )
{
	if ( m_hResult == NULL )
		return 0;

	if ( Index < 0 || Index >= (int32)m_hResult->field_count )
		return 0;

	return m_fieldLengthArray[ Index ];
}

int8* CSql::getBuff( int32 Index )
{
    if ( m_hResult == NULL )
		return false;

	if ( Index < 0 || Index >= (int32)m_hResult->field_count )
		return false;

	return m_hRow[ Index ];
}

std::string CSql::escape( const char *str )
{
	return escape( str, (int32)strlen( str ) );
}

std::string CSql::escape( const void *ptr, const int32 size )
{
	if ( m_hSql == NULL || ptr == NULL || size <= 0 )
		return std::string();

	std::string buff( size * 4 + 1, '\0' );

	mysql_real_escape_string( m_hSql, &buff[0], (char*)ptr, size );

	return buff;
}

std::string CSql::escape( std::string str )
{
    return escape( str.c_str(), str.size() );
}

}

