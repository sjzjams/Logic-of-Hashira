package com.hashira.logic.fitness_log_app.segmentation

import android.graphics.Bitmap
import android.util.LruCache
import java.io.File
import java.security.MessageDigest

/**
 * INF3: 掩码缓存管理器。
 *
 * 双级缓存策略:
 * - L1: 内存 LRU (最近 N 个 mask 的 Bitmap)
 * - L2: 磁盘文件 (.mag bit plane, 已有 WriteMaskBitplane 支持)
 *
 * 缓存键: 图像内容 pHash (perceptual hash) 的 MD5 摘要。
 *
 * 命中路径: computeKey → getMemory → getDisk → miss → segment → putMemory + putDisk
 */
class MaskCache(private val cacheDir: File) {

    // L1 内存缓存: 最多保留 5 个解码后的 mask Bitmap (每张 ~300KB@640x640)
    private val memoryCache = object : LruCache<String, Bitmap>(5) {
        override fun sizeOf(key: String, value: Bitmap): Int {
            return value.byteCount / 1024 // KB
        }
    }

    private val diskCacheDir by lazy {
        File(cacheDir, "mask-cache").apply { mkdirs() }
    }

    /**
     * 计算图像的缓存键 (MD5 of downscaled average hash)。
     * 对 8x8 灰度图取均值 hash，再对 hash 做 MD5。
     */
    fun computeKey(bitmap: Bitmap): String {
        // 缩放到 16x16 计算均值 hash
        val small = Bitmap.createScaledBitmap(bitmap, 16, 16, true)
        val pixels = IntArray(256)
        small.getPixels(pixels, 0, 16, 0, 0, 16, 16)
        small.recycle()

        // 转灰度 + 计算均值
        var sum = 0L
        val gray = ByteArray(256)
        for (i in pixels.indices) {
            val r = (pixels[i] shr 16) and 0xff
            val g = (pixels[i] shr 8) and 0xff
            val b = pixels[i] and 0xff
            gray[i] = ((0.299 * r + 0.587 * g + 0.114 * b).toInt() and 0xFF).toByte()
            sum += gray[i].toInt() and 0xff
        }
        val avg = (sum / 256).toFloat()

        // 生成 256-bit hash (每个像素 1 bit, 16×16=256 bits, 需 4 个 64-bit long)
        val hash = LongArray(4)
        for (i in 0 until 256) {
            if ((gray[i].toInt() and 0xff) > avg) {
                hash[i / 64] = hash[i / 64] or (1L shl (63 - (i % 64)))
            }
        }

        // MD5 摘要作为最终 key
        val md = MessageDigest.getInstance("MD5")
        for (h in hash) {
            md.update(
                byteArrayOf(
                    (h shr 56).toByte(),
                    (h shr 48).toByte(),
                    (h shr 40).toByte(),
                    (h shr 32).toByte(),
                    (h shr 24).toByte(),
                    (h shr 16).toByte(),
                    (h shr 8).toByte(),
                    h.toByte()
                )
            )
        }
        val digest = md.digest()
        return digest.joinToString("") { "%02x".format(it) }
    }

    /** 从内存缓存获取 mask Bitmap (可能为 null)。 */
    fun getMemory(key: String): Bitmap? = memoryCache.get(key)

    /** 从磁盘缓存获取 .mag 文件路径 (可能为 null)。 */
    fun getDisk(key: String): File? {
        val file = File(diskCacheDir, "$key.mag")
        return if (file.exists() && file.length() > 0) file else null
    }

    /** 放入内存缓存。 */
    fun putMemory(key: String, maskBitmap: Bitmap) {
        memoryCache.put(key, maskBitmap)
    }

    /**
     * 将 .mag 文件复制到磁盘缓存。
     * @param sourceMaskPath 原始 mask 文件路径 (来自 nativeSegment 输出)
     * @return 缓存中的文件引用
     */
    fun putDisk(key: String, sourceMaskPath: String): File? {
        val source = File(sourceMaskPath)
        if (!source.exists()) return null
        val dest = File(diskCacheDir, "$key.mag")
        return try {
            source.copyTo(dest, overwrite = true)
            dest
        } catch (_: Exception) {
            null
        }
    }

    /** 清除所有缓存。 */
    fun clear() {
        memoryCache.evictAll()
        diskCacheDir.deleteRecursively()
        diskCacheDir.mkdirs()
    }

    /** 获取缓存统计信息。 */
    fun stats(): Map<String, Any> = mapOf(
        "memorySize" to memoryCache.size(),
        "memoryMaxSize" to memoryCache.maxSize(),
        "diskCount" to (diskCacheDir.listFiles()?.size ?: 0),
        "diskDir" to diskCacheDir.absolutePath,
    )

    companion object {
        const val TAG = "MaskCache"
    }
}
