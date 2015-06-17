#ifndef _ACCESS_MASTER_H_
#define _ACCESS_MASTER_H_

#include "common.h"

//门面模式:封装众多的细小接口
class CMaster
{
public:
    CMaster();
    ~CMaster();

    void Start(void);
    void LoadData(void);
    void ReLoadData(void);
};
#define theMaster TSignleton<CMaster >::Ref()

#endif  //IMMORTAL_GAMESVR_MASTER_H_

