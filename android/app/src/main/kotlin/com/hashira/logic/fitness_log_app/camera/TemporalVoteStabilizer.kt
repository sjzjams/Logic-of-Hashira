package com.hashira.logic.fitness_log_app.camera

/**
 * INF5: 时间投票稳定器。
 *
 * 用于消除实时检测中的抖动和误报。
 * 连续 N 帧 (threshold) 检测到食物后，才触发 FoodConfirmed 事件。
 *
 * 算法:
 * - 每帧输入: 检测置信度 + 边界框
 * - 维护滑动窗口 (最近 windowSize 帧的结果)
 * - 当窗口中 positive 帧数 >= threshold 时，输出 confirmed
 * - 当窗口中 negative 帧数超过容限时，重置
 */
class TemporalVoteStabilizer(
    private val windowSize: Int = 10,      // 滑动窗口大小 (帧)
    private val threshold: Int = 6,         // 确认阈值 (窗口内至少 N 帧检测到)
    private val confidenceThreshold: Float = 0.35f, // 单帧置信度门槛
    private val resetThreshold: Int = 8,    // 重置阈值 (连续 N 帧无检测则重置)
) {
    
    /** 单帧检测结果。 */
    data class FrameResult(
        val hasFood: Boolean,
        val confidence: Float,
        val box: FloatArray? = null,  // [x0, y0, x1, y1]
        val timestampMs: Long = System.currentTimeMillis(),
    )
    
    private val frameWindow = ArrayDeque<FrameResult>(windowSize)
    
    // 连续负帧计数器
    private var consecutiveNegatives = 0
    
    // 上次确认时的平均置信度
    private var lastConfirmedConfidence = 0f
    
    // 统计信息
    private var totalFramesProcessed = 0L
    private var totalConfirmations = 0L
    
    /**
     * 处理新一帧的检测结果。
     * @return 确认结果 (null 表示未确认)
     */
    fun processFrame(confidence: Float, box: FloatArray? = null): StabilizerOutput? {
        totalFramesProcessed++
        
        val hasFood = confidence >= confidenceThreshold
        val result = FrameResult(hasFood, confidence, box)
        
        // 加入滑动窗口
        if (frameWindow.size >= windowSize) {
            frameWindow.removeFirst()
        }
        frameWindow.addLast(result)
        
        // 更新连续负帧计数
        if (hasFood) {
            consecutiveNegatives = 0
        } else {
            consecutiveNegatives++
            
            // 连续多帧未检测到，快速重置
            if (consecutiveNegatives >= resetThreshold) {
                reset()
                return null
            }
        }
        
        // 统计窗口内正帧数
        val positiveCount = frameWindow.count { it.hasFood }
        
        // 达到确认阈值
        if (positiveCount >= threshold && !isCurrentlyConfirmed()) {
            totalConfirmations++
            
            // 计算加权平均置信度和边界框
            val avgConfidence = computeWeightedConfidence()
            val smoothedBox = computeSmoothedBox()
            
            lastConfirmedConfidence = avgConfidence
            
            android.util.Log.d("TemporalVote", 
                "CONFIRMED! pos=$positiveCount/$windowSize, conf=%.2f".format(avgConfidence))
            
            return StabilizerOutput(
                confirmed = true,
                avgConfidence = avgConfidence,
                smoothedBox = smoothedBox,
                stabilityScore = positiveCount.toFloat() / windowSize,
            )
        }
        
        return null
    }
    
    /**
     * 计算加权平均置信度（最近帧权重更高）。
     */
    private fun computeWeightedConfidence(): Float {
        if (frameWindow.isEmpty()) return 0f
        
        var weightedSum = 0f
        var weightSum = 0f
        
        for ((i, frame) in frameWindow.withIndex()) {
            if (frame.hasFood) {
                val weight = (i + 1).toFloat() / frameWindow.size
                weightedSum += frame.confidence * weight
                weightSum += weight
            }
        }
        
        return if (weightSum > 0) weightedSum / weightSum else 0f
    }
    
    /**
     * 计算平滑后的边界框（对检测到的框取加权平均）。
     */
    private fun computeSmoothedBox(): FloatArray? {
        val detectedBoxes = frameWindow.filter { it.hasFood && it.box != null }
        if (detectedBoxes.isEmpty()) return null
        
        val n = detectedBoxes.size
        val box = FloatArray(4)
        
        for (fb in detectedBoxes) {
            for (j in 0 until 4) {
                box[j] += fb.box!![j]
            }
        }
        
        for (j in 0 until 4) {
            box[j] /= n
        }
        
        return box
    }
    
    /** 当前是否已确认状态。 */
    fun isCurrentlyConfirmed(): Boolean = lastConfirmedConfidence > 0
    
    /** 重置稳定器状态。 */
    fun reset() {
        frameWindow.clear()
        consecutiveNegatives = 0
        lastConfirmedConfidence = 0f
        android.util.Log.d("TemporalVote", "Stabilizer reset")
    }
    
    /**
     * 获取调试信息。
     */
    fun getDebugInfo(): Map<String, Any> = mapOf(
        "windowSize" to frameWindow.size,
        "maxWindowSize" to windowSize,
        "consecutiveNegatives" to consecutiveNegatives,
        "lastConfirmedConfidence" to lastConfirmedConfidence,
        "totalFrames" to totalFramesProcessed,
        "totalConfirmations" to totalConfirmations,
        "positiveInWindow" to frameWindow.count { it.hasFood },
    )
    
    /**
     * 稳定器输出。
     */
    data class StabilizerOutput(
        val confirmed: Boolean,
        val avgConfidence: Float,
        val smoothedBox: FloatArray?,
        val stabilityScore: Float, // 0.0 ~ 1.0
    )

    companion object {
        const val TAG = "TemporalVote"
    }
}
