#ifndef IMMORTAL_REALDBSVR_MASTER_H_
#define IMMORTAL_REALDBSVR_MASTER_H_

#include "common.h"

//门面模式:封装众多的细小接口

class CMaster
{
public:
    CMaster();
    ~CMaster();

    void Start(void);
    void LoadData(void);
public:
};
#define theMaster TSignleton<CMaster >::Ref()

#endif  //IMMORTAL_GAMESVR_MASTER_H_

