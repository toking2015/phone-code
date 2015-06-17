#ifndef _PACKET_IMAGE_H_
#define _PACKET_IMAGE_H_

#include "common.h"

namespace image
{

struct SImage
{
    uint32      width;
    uint32      height;

    std::vector<char> data;
};

//加载 png 图片
bool load_png( std::string& file, SImage& image );

//保存 jpg 图片
bool save_jpg( std::string& file, SImage& image, uint32 quality );

} // namespace image

#endif
