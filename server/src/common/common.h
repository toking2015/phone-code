#ifndef _COMMON_H_
#define _COMMON_H_

#include <bitset>
#include <queue>
#include <list>
#include <vector>
#include <set>
#include <map>
#include <string>
#include <sstream>
#include <numeric>
#include <assert.h>
#include <algorithm>
#include <assert.h>

#include <weedong/core/os.h>
#include <weedong/core/bstream/bstream.h>
#include "macro.h"
#include "dthrow.h"

//通讯包头结构
struct tag_pack_head
{
    uint16  pack_flag;              //e1c7
    uint8   pack_status;            //扩展字段(未使用)
    uint8   pack_code;              //加密标志, 非0为加密key
    uint32  pack_length;
    uint32  pack_checksum;

    tag_pack_head()
    {
        pack_flag = 0;
        pack_status = 0;
        pack_code = 0;
        pack_length = 0;
        pack_checksum = 0;
    }
};

//协议包头结构
struct tag_msg_head
{
    uint32  msg_cmd;            //协议号
    uint32  role_id;            //角色id
    uint32  session;            //用户认证码
    uint32  order;              //协议包处理顺序
    uint32  action;             //行为号

    uint16  broad_cast;         //广播类型
    uint16  broad_type;         //广播二级标识
    uint32  broad_id;           //广播三级标识

    tag_msg_head()
    {
        msg_cmd = 0;
        role_id = 0;
        session = 0;
        order = 0;
        action = 0;

        broad_cast = 0;
        broad_type = 0;
        broad_id = 0;
    }
};

//序列同步协议
struct tag_msg_order : public tag_msg_head
{
    uint32  tag_msg_order_size;

    uint32  min;
    uint32  max;

    tag_msg_order()
    {
        msg_cmd = 1801311003;

        min = 0;
        max = 0;

        tag_msg_order_size = sizeof( min ) + sizeof( max );
    }
};

//错误协议
struct tag_msg_error : public tag_msg_head
{
    uint32  tag_msg_error_size;

    uint32  err_no;
    uint32  err_desc;

    tag_msg_error()
    {
        msg_cmd = 1465167678;

        err_no = 0;
        err_desc = 0;

        tag_msg_error_size = sizeof( err_no ) + sizeof( err_desc );
    }
};

//网关内部处理事件
struct tag_msg_access_event : public tag_msg_head
{
    uint32  tag_msg_access_event_size;

    int32   sock;
    uint32  code;

    tag_msg_access_event()
    {
        msg_cmd = 1001173331;

        sock = 0;
        code = 0;

        tag_msg_access_event_size = sizeof( sock ) + sizeof( code );
    }
};

struct tag_msg_auth_run_json : public tag_msg_head
{
    uint32  tag_msg_auth_run_json_size;

    int32   outside_sock;

    tag_msg_auth_run_json()
    {
        msg_cmd = 110123182;

        outside_sock = 0;

        tag_msg_auth_run_json_size = sizeof( outside_sock );
    }
};

//TSignleton
template<class T>
class TSignleton
{
public:
    static wd::CMutex mutex;
    static T* inst;

    static T* Inst(void)
    {
        if ( inst != NULL )
            return inst;

        wd::CGuard<wd::CMutex> Safe( &mutex );

        if ( inst == NULL )
            inst = new T();

        return inst;
    }

    static inline void Free(void)
    {
        if ( inst != NULL )
        {
            wd::CGuard<wd::CMutex> Safe( &mutex );

            if ( inst != NULL )
            {
                delete inst;
                inst = NULL;
            }
        }
    }

    static inline T* Ptr(void){ return Inst(); }
    static inline T& Ref(void){ return *Inst(); }
};
template<class T>
T* TSignleton<T>::inst = NULL;
template<class T>
wd::CMutex TSignleton<T>::mutex;

inline uint32* thread_rand_seed(void)
{
    static uint32 seed = 0;
    return &seed;
}

//生成的随机数区间为 [min, max)
template <typename T>
T TRand(T min, T max, uint32* seed = NULL)
{
    if ( seed == NULL )
        seed = thread_rand_seed();

    uint32 next = *seed;
    int32 result = 0;

    next *= 1103515245;
    next += 12345;
    result = (uint32) (next / 65536) % 2048;

    next *= 1103515245;
    next += 12345;
    result <<= 10;
    result ^= (uint32) (next / 65536) % 1024;

    next *= 1103515245;
    next += 12345;
    result <<= 10;
    result ^= (uint32) (next / 65536) % 1024;

    *seed = next;

    return min + (T)(result / (0x7FFFFFFF + 1.0) * (max - min));
}

//随机几率计算器
//判断是否满足10%的几率 即判断 RandRate(10, 100) == true
inline bool RandRate(uint32 numerator, uint32 denominator)
{
    return (numerator > TRand<uint32>(0, denominator));
}

//从数组中随机选择一个值
template<typename T>
inline T RandChoose(std::vector<T > &vec)
{
    return vec[ TRand<size_t>(0, vec.size()) ];
}

//从一组几率值中选取一个 比如命中几率列表[10, 20, 30, 40]中的其中一个
template <typename T>
uint32 RandRateChoose(T *array, uint32 len)
{
    T sum_value = std::accumulate(array, array+len, 0);
    T rand_value = TRand<T>(0, sum_value);

    sum_value = 0;
    for(uint32 i = 0; i < len; ++i)
    {
        sum_value += array[i];
        if (sum_value > rand_value)
            return i;
    }

    return 0;
}

#endif

