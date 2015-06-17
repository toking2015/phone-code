#include "proto/transfrom/transfrom_common.h"

#include "proto/common/SMsgHead.h"
#include "proto/common/SCompressData.h"
#include "proto/common/SInteger.h"
#include "proto/common/S2UInt16.h"
#include "proto/common/S2Int16.h"
#include "proto/common/S2UInt32.h"
#include "proto/common/S2Int32.h"
#include "proto/common/S2Float.h"
#include "proto/common/S3UInt32.h"
#include "proto/common/S4Int32.h"
#include "proto/common/SMapVal.h"
#include "proto/common/SKeyValue.h"
#include "proto/common/S2String.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_common::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;


    return handles;
}

