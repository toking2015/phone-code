/*************************************************
  Description:      // 网络包的拆包，组包管理器
  Class:            // 研发五部
  Name:             // 闾训杰
  Date:             // 2011-12-28
*************************************************/

#ifndef _WEEDONG_CORE_PACKMGR_H_INCLUDED
#define _WEEDONG_CORE_PACKMGR_H_INCLUDED
#include "../os.h"
#include <map>
#include <vector>

namespace wd
{

//定义消息包处理函数类型
typedef void (*PackHandlerFunc_Ptr)(uint32 linkid,uint8* ppack , uint32 packlen);

//长度的打包，解包辅助函数
bool	UnPackLen(uint8*&pdata,uint32& datalen,uint32& len);
bool	PackLen(uint8*&pdata,uint32& datalen,uint32 len);

//打包，解包管理类
class CPackMgr
{
public:
	CPackMgr();
	~CPackMgr(void);

	void		LinkEstablish(uint32 linkid);
	void		LinkRelease(uint32 linkid);
	void		SetPackHandler(PackHandlerFunc_Ptr pfun);
	void		PullData(uint32 linkid , uint8*pdata , uint32 datalen);
protected:
	std::map<uint32,std::vector<uint8>*>		m_streams;
	PackHandlerFunc_Ptr							m_handler;
};

}

#endif	// _WEEDONG_CORE_PACKMGR_H_INCLUDED