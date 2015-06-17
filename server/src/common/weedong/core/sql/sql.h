/*************************************************
  Model:            // mysql数据库操作封装
  Class:            // 研发三部
  Name:             // 黄少卿
  Date:             // 2011-11-15
  Descript:
    提供对数据库的基本操作封装
*************************************************/
#ifndef _GAME_COMMON_SQL_H_
#define _GAME_COMMON_SQL_H_

#include <weedong/core/os.h>
#include <mysql.h>
#include <stdarg.h>

#include <string>
#include <vector>

namespace wd
{

class CSql
{
private:
	MYSQL *m_hSql;
	MYSQL_RES *m_hResult;
	MYSQL_ROW m_hRow;
	unsigned long* m_fieldLengthArray;
	bool m_bConnected;

    std::vector<char> m_lastString;

public:
	CSql();

    /*************************************************
      Description:    // 初始化连接数据库
    *************************************************/
	CSql( const char *host, uint16 port, const char *db, const char *usr, const char *pwd );
	~CSql();

	/*************************************************
      Description:    // 返回mysql的当前错误码
    *************************************************/
	uint32 lastErrorCode(void);

	/*************************************************
      Description:    // 返回mysql的当前错误描述
    *************************************************/
	const char * lastErrorMsg(void);

	/*************************************************
      Description:    // 返回mysql最后一次执行语句
    *************************************************/
	const char * lastSqlString(void);

	/*************************************************
      Description:    // 连接指定数据库
	  Input:          // host : 目标主机域名或ip
	                  // port : 目标主机端口
					  // db   : 目标主机数据库名
					  // usr  : 目标主机用户名
					  // pwd  : 目标主机密码
      Return:         // 同步返回连接是否成功
    *************************************************/
	bool connect( const char *host, uint16 port, const char *db, const char *usr, const char *pwd );

	/*************************************************
      Description:    // 判断sql连接是否存在
      Return:         // 返回连接是否成功
    *************************************************/
	bool connected(void);

	/*************************************************
      Description:    // 关闭当前连接并释放内存
    *************************************************/
	void disconnect(void);

	/*************************************************
      Description:    // 测试当前连接是否可用, 长时间连接空闲建议使用test进行事先测试连接
      Return:         // 返回sql通讯是否成功
    *************************************************/
	bool test(void);

	/*************************************************
      Description:    // 数据请求, 建议 select 或带数据返回的存储过程使用
      Return:         // 返回请求结果行数, 如果返回0为空请求或执行错误
      Oter:           // 如果返回为 0, 建议使用 lastErrorCode 判断执行失败结果分析
    *************************************************/
	int32 query( const char *format, ... );
    int32 query( const std::string string );

	/*************************************************
      Description:    // 执行请求, 建议 insert, update, delete 或不带数据返回的存储过程使用
      Return:         // 返回执行结果行数, 如果返回0为空执行错误
      Oter:           // 如果返回为 0, 建议使用 lastErrorCode 判断执行失败结果分析
    *************************************************/
	int32 execute( const char *format, ... );

	/*************************************************
      Description:    // 返回带有自增键值 insert 成功后的当前自增值
      Oter:           // 应在 execute 执行成功后调用, 例如 insert 一个自增Guid, 会返回当前执行成功的 Guid值
    *************************************************/
	int64 insertId(void);

	/*************************************************
      Description:    // 将结果指针偏移到起始行
      Oter:           // 应在 query 执行成功后调用
    *************************************************/
	void first(void);

	/*************************************************
      Description:    // 将结果指针向下偏移一行
      Other:          // 应在 query、first 执行成功后调用
    *************************************************/
	void next(void);

	/*************************************************
      Description:    // 判断当前指针行是否可用
    *************************************************/
	bool empty(void);

	/*************************************************
      Description:    // 在当前偏移行中返回指定列的整形数据
      Input:          // Index 为 返回结果的列索引
    *************************************************/
	int32 getInteger( int32 Index );
    int64 getLong( int32 Index );

	/*************************************************
      Description:    // 在当前偏移行中返回指定列的字符串数据
      Input:          // Index 为 返回结果的列索引
    *************************************************/
	std::string getString( int32 Index );

	/*************************************************
      Description:    // 在当前偏移行中返回指定列的二进制数据
      Input:          // Index : 返回结果的列索引
	                  // data : 返回的出参缓存指针
					  // size : 返回的出参缓存大小
					  // offset : 返回的二进制数据偏移量
	  Return:         // 返回数据获取是否成功
    *************************************************/
	bool getData( int32 Index, void* data, int32 size, int32 offset = 0 );

	/*************************************************
      Description:    // 返回当前偏移行中的有效数据长度
	  Input:          // Index : 返回长度的列索引
    *************************************************/
	int32 getSize( int32 Index );

    /*************************************************
      Description:    // 返回当前偏移行中的有效数据指针
	  Input:          // Index : 返回长度的列索引
    *************************************************/
    int8* getBuff( int32 Index );

	/*************************************************
      Description:    // 将数据转换成 mysql 编码字符串
      Input:          // str 需要转换编码的字符串指针
    *************************************************/
	std::string escape( const char *str );

	/*************************************************
      Description:    // 将数据转换成 mysql 编码字符串
      Input:          // ptr 需要转换编码的二进制指针
	                  // size 需要转换编码的二进制数据长度
    *************************************************/
	std::string escape( const void *ptr, const int32 size );

	/*************************************************
      Description:    // 将数据转换成 mysql 编码字符串
      Input:          // ptr 需要转换编码的二进制指针
	                  // size 需要转换编码的二进制数据长度
    *************************************************/
	std::string escape( std::string str );

private:
	/*************************************************
      Description:    // 释放 sql 执行后的数据结果内存
    *************************************************/
	void freeResult(void);
};

}

#endif


