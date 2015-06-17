#include "packmgr.h"

namespace wd
{


CPackMgr::CPackMgr()
{
	m_handler	=	NULL;
}

CPackMgr::~CPackMgr(void)
{

}

void		CPackMgr::SetPackHandler(PackHandlerFunc_Ptr pfun)
{
	m_handler	=	pfun;
}

void		CPackMgr::LinkEstablish(uint32 linkid)
{
	std::map<uint32,std::vector<uint8>*>::iterator iter = m_streams.find(linkid);
	if(iter == m_streams.end())
	{
		std::vector<uint8>*p	=	new std::vector<uint8>();
		m_streams.insert(std::pair<uint32,std::vector<uint8>*>(linkid,p));
	}
}

void		CPackMgr::LinkRelease(uint32 linkid)
{
	std::map<uint32,std::vector<uint8>*>::iterator iter = m_streams.find(linkid);
	if(iter != m_streams.end())
	{
		std::vector<uint8>*p	=	iter->second;
		delete	p;
		m_streams.erase(iter);
	}
}

void		CPackMgr::PullData(uint32 linkid , uint8*pdata , uint32 datalen)
{
	std::map<uint32,std::vector<uint8>*>::iterator iter = m_streams.find(linkid);
	if(iter != m_streams.end())
	{
		std::vector<uint8>*p	=	iter->second;
		for (uint32 k = 0 ; k < datalen ; k ++)
			p->insert(p->end(),pdata, pdata + datalen );

		uint32 ll = sizeof(uint32);
		while ((uint32)p->size() > ll)
		{
			uint32 packlen = 0;
			uint8*	packdata	=	&p->operator [](0);
			uint32	packdatalen	=	(uint32)p->size();
			if( !UnPackLen(packdata,packdatalen,packlen) )
				break;
			if((uint32)p->size() - ll >= packlen)
			{
				if(m_handler)
					m_handler(linkid,&p->operator [](ll),packlen);
				std::vector<uint8>::iterator bit = p->begin();
				std::vector<uint8>::iterator eit = bit + ll + packlen;
				p->erase(bit,eit);
			}
		}
	}
}

bool	UnPackLen(uint8*&pdata,uint32& datalen,uint32& len)
{
	if(datalen < sizeof(len))
		return false;
	memcpy(&len,(void*)pdata,sizeof(len));
	pdata	+=	sizeof(len);
	datalen	-=	sizeof(len);
	return true;
}

bool	PackLen(uint8*&pdata,uint32& datalen,uint32 len)
{
	if(datalen < sizeof(len))
		return false;
	memcpy((void*)pdata,(void*)&len,sizeof(len));
	pdata	+=	sizeof(len);
	datalen	-=	sizeof(len);
	return true;
}


}