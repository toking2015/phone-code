#include "image.h"

#include "png.h"
#include "jpeglib.h"
#include "file.h"

namespace image
{

struct SImageSource
{
    std::vector<char>&  data;
    uint32              offset;
};

void pngReadCallback( png_structp png_ptr, png_bytep data, png_size_t length )
{
    SImageSource* source = (SImageSource*)png_get_io_ptr(png_ptr);

    if ( (int32)( source->offset + length ) <= (int32)source->data.size() )
    {
        memcpy( data, &source->data[0] + source->offset, length );
        source->offset += length;
    }
    else
    {
        png_error( png_ptr, "pngReaderCallback failed" );
    }
}

bool load_png( std::string& file, SImage& image )
{
    std::vector<char> buff;

    if ( !file::read( file, buff ) )
        return false;

    png_byte        header[8] = {0};
    png_structp     png_ptr = NULL;
    png_infop       info_ptr = NULL;

    bool ret = false;
    do
    {
        if ( buff.size() < sizeof( header ) )
        {
            printf( "image: png file size < %u\n", (uint32)sizeof( header ) );
            break;
        }


        memcpy( header, &buff[0], sizeof( header ) );
        if ( png_sig_cmp( header, 0, sizeof( header ) ) )
        {
            printf( "image: png header sig error!\n" );
            break;
        }

        png_ptr = png_create_read_struct( PNG_LIBPNG_VER_STRING, 0, 0, 0 );
        if ( png_ptr == NULL )
        {
            printf( "image: png create struct error!\n" );
            break;
        }

        info_ptr = png_create_info_struct(png_ptr);
        if ( info_ptr == NULL )
        {
            printf( "image: png create info error!\n" );
            break;
        }

        //设置读取头回调
        SImageSource source = { buff, 0 };
        png_set_read_fn( png_ptr, &source, pngReadCallback );

        //读取结构头
        png_read_info(png_ptr, info_ptr);

        //RGBA8888 强制容错
        if ( png_get_color_type(png_ptr, info_ptr) != PNG_COLOR_TYPE_RGB_ALPHA )
        {
            printf( "image: png color is not a RGBA-8888\n" );
            break;
        }

        if ( png_get_bit_depth(png_ptr, info_ptr) != 8 )
        {
            printf( "image: png color is not a RGBA-8888\n" );
            break;
        }

        // expand any tRNS chunk data into a full alpha channel
        if ( png_get_valid( png_ptr, info_ptr, PNG_INFO_tRNS ) )
            png_set_tRNS_to_alpha( png_ptr );

        image.width     = png_get_image_width(png_ptr, info_ptr);
        image.height    = png_get_image_height(png_ptr, info_ptr);

        png_read_update_info( png_ptr, info_ptr );

        //读取 png 数据
        png_size_t rowbytes;
        png_bytep* row_pointers = ( png_bytep* )malloc( sizeof(png_bytep) * image.height );

        rowbytes = png_get_rowbytes( png_ptr, info_ptr );

        uint32 _dataLen = rowbytes * image.height;
        image.data.resize( _dataLen );

        for ( uint16 i = 0; i < image.height; ++i )
            row_pointers[i] = (png_byte*)( &image.data[0] ) + i * rowbytes;

        png_read_image( png_ptr, row_pointers );
        png_read_end( png_ptr, NULL );

        if ( row_pointers != NULL )
            free( row_pointers );

        ret = true;
    }
    while(0);

    if ( png_ptr )
        png_destroy_read_struct( &png_ptr, (info_ptr) ? &info_ptr : 0, 0 );

    return ret;
}

bool save_jpg( std::string& file, SImage& image, uint32 quality )
{
    if ( quality < 50 ) quality = 50;
    if ( quality > 100 ) quality = 100;

    bool ret = false;
    do
    {
        struct jpeg_compress_struct cinfo;
        struct jpeg_error_mgr jerr;
        JSAMPROW row_pointer[1];        /* pointer to JSAMPLE row[s] */
        int     row_stride;          /* physical row width in image buffer */

        cinfo.err = jpeg_std_error(&jerr);
        /* Now we can initialize the JPEG compression object. */
        jpeg_create_compress(&cinfo);

        FILE * outfile = fopen( file.c_str(), "wb" );
        if ( outfile == NULL )
        {
            printf( "image: can't open file to write\n" );
            break;
        }

        jpeg_stdio_dest(&cinfo, outfile);

        cinfo.image_width = image.width;    /* image width and height, in pixels */
        cinfo.image_height = image.height;
        cinfo.input_components = 3;       /* # of color components per pixel */
        cinfo.in_color_space = JCS_RGB;       /* colorspace of input image */

        jpeg_set_defaults(&cinfo);

        //设置压缩质量
        jpeg_set_quality( &cinfo, quality, true );

        jpeg_start_compress(&cinfo, TRUE);

        row_stride = image.width * 3; /* JSAMPLEs per row in image_buffer */

        char *pTempData = (char*)malloc( image.width * image.height * 3 );
        {
            for (int32 i = 0; i < (int32)image.height; ++i)
            {
                int32 _i = i * image.width;
                for (int32 j = 0; j < (int32)image.width; ++j)
                {
                    int32 _j = _i + j;

                    pTempData[ _j * 3 ] = image.data[ _j * 4 ];
                    pTempData[ _j * 3 + 1 ] = image.data[ _j * 4 + 1 ];
                    pTempData[ _j * 3 + 2 ] = image.data[ _j * 4 + 2 ];
                }
            }

            while ( cinfo.next_scanline < cinfo.image_height )
            {
                row_pointer[0] = (unsigned char*)( pTempData + cinfo.next_scanline * row_stride );
                jpeg_write_scanlines( &cinfo, row_pointer, 1 );
            }

            free(pTempData);
        }

        jpeg_finish_compress(&cinfo);
        fclose(outfile);
        jpeg_destroy_compress(&cinfo);

        ret = true;
    } while (0);

    return ret;
}

} // namespace image
