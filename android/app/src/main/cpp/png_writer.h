// Sprint 2.2-C Phase C 辅助头:最小可用的 8-bit RGBA PNG 写出器。
//
// 仅实现 8 bit / 颜色类型 6 (RGBA) / 无交错 / filter 0,
// 不实现压缩级别以外的可选项,目的是在 NDK 工程内无第三方依赖地
// 把合成后的前景图写盘,被 Kotlin 端用 BitmapFactory 直接读回。
//
// 不依赖 stb_image_write,只用 NDK 自带的 zlib。
#pragma once

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <zlib.h>

namespace foodseg {

namespace png_detail {

// 初始化一次 CRC32 表 (PNG 用的多项式 0xedb88320,initial 0xffffffff)。
class CrcTable {
public:
    static uint32_t table[256];
    static bool inited;
    static void ensure() {
        if (inited) return;
        for (uint32_t n = 0; n < 256; n++) {
            uint32_t c = n;
            for (int k = 0; k < 8; k++) {
                c = (c & 1u) ? (0xedb88320u ^ (c >> 1)) : (c >> 1);
            }
            table[n] = c;
        }
        inited = true;
    }
};

inline uint32_t CrcTable::table[256] = {0};
inline bool CrcTable::inited = false;

// 计算 type+data 的 CRC32(初值 0xffffffff,最终按位取反)。
inline uint32_t compute_crc(const uint8_t* type, const uint8_t* data, uint32_t len) {
    CrcTable::ensure();
    uint32_t c = 0xffffffffu;
    for (int i = 0; i < 4; i++) c = CrcTable::table[(c ^ type[i]) & 0xff] ^ (c >> 8);
    for (uint32_t i = 0; i < len; i++) c = CrcTable::table[(c ^ data[i]) & 0xff] ^ (c >> 8);
    return c ^ 0xffffffffu;
}

// 以大端序写入 32 位无符号整数。
inline void write_be32(uint8_t* p, uint32_t v) {
    p[0] = static_cast<uint8_t>((v >> 24) & 0xff);
    p[1] = static_cast<uint8_t>((v >> 16) & 0xff);
    p[2] = static_cast<uint8_t>((v >> 8) & 0xff);
    p[3] = static_cast<uint8_t>(v & 0xff);
}

// 写一个 PNG chunk: length(4 BE) + type(4) + data(len) + crc(4)。
// type 必须传 4 字节字符串字面量,例如 "IHDR"。
inline void write_chunk(FILE* fp, const char type[4], const uint8_t* data, uint32_t len) {
    uint8_t header[4];
    write_be32(header, len);
    fwrite(header, 1, 4, fp);
    fwrite(type, 1, 4, fp);
    if (len > 0) fwrite(data, 1, len, fp);
    uint32_t crc = compute_crc(reinterpret_cast<const uint8_t*>(type), data, len);
    write_be32(header, crc);
    fwrite(header, 1, 4, fp);
}

}  // namespace png_detail

// 把 RGBA8888 像素写出为 PNG 文件。失败返回 false。
//
// 参数:
///   path    - 输出文件路径,会覆盖已有文件。
///   width   - 像素宽度,必须 > 0。
///   height  - 像素高度,必须 > 0。
///   rgba    - 行优先的 RGBA 像素,长度 = width*height*4。
inline bool write_png_rgba(const char* path, int width, int height, const uint8_t* rgba) {
    if (path == nullptr || rgba == nullptr || width <= 0 || height <= 0) {
        return false;
    }

    FILE* fp = fopen(path, "wb");
    if (fp == nullptr) {
        return false;
    }

    // PNG 文件签名
    static const uint8_t kSignature[8] = {
        0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
    };
    fwrite(kSignature, 1, 8, fp);

    // IHDR: 13 字节 payload
    uint8_t ihdr[13];
    png_detail::write_be32(ihdr, static_cast<uint32_t>(width));
    png_detail::write_be32(ihdr + 4, static_cast<uint32_t>(height));
    ihdr[8] = 8;   // bit depth
    ihdr[9] = 6;   // color type: 6 = truecolor + alpha
    ihdr[10] = 0;  // compression method
    ihdr[11] = 0;  // filter method
    ihdr[12] = 0;  // interlace method
    png_detail::write_chunk(fp, "IHDR", ihdr, 13);

    // 构造 raw: 每行前加 1 字节 filter byte 0 (None)
    const int rowbytes = width * 4;
    const int total = (rowbytes + 1) * height;
    std::vector<uint8_t> raw(static_cast<size_t>(total));
    for (int y = 0; y < height; y++) {
        raw[static_cast<size_t>(y * (rowbytes + 1))] = 0;
        std::memcpy(raw.data() + y * (rowbytes + 1) + 1,
                    rgba + y * rowbytes,
                    static_cast<size_t>(rowbytes));
    }

    // deflate 压缩 (raw deflate,不带 zlib 头尾)
    z_stream strm = {};
    if (deflateInit(&strm, Z_DEFAULT_COMPRESSION) != Z_OK) {
        fclose(fp);
        return false;
    }
    const uLong bound = deflateBound(&strm, static_cast<uLong>(total));
    std::vector<uint8_t> compressed(static_cast<size_t>(bound));
    strm.next_in = raw.data();
    strm.avail_in = static_cast<uInt>(total);
    strm.next_out = compressed.data();
    strm.avail_out = static_cast<uInt>(bound);
    int ret = deflate(&strm, Z_FINISH);
    deflateEnd(&strm);
    if (ret != Z_STREAM_END) {
        fclose(fp);
        return false;
    }
    const uLong compressed_size = bound - strm.avail_out;
    png_detail::write_chunk(fp, "IDAT", compressed.data(),
                            static_cast<uint32_t>(compressed_size));

    // IEND
    png_detail::write_chunk(fp, "IEND", nullptr, 0);

    fclose(fp);
    return true;
}

}  // namespace foodseg
