package com.hashira.logic.fitness_log_app.camera

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.view.View

/**
 * T7: 检测框叠加视图。
 *
 * 覆盖在 CameraX PreviewView 之上，绘制 YOLOv8 的实时检测结果：
 * - 绿色边框: 已确认的食物区域 (CONFIRMING / DONE)
 * - 黄色边框: 候选食物区域 (SCANNING 中)
 * - 角标动画: 吸引用户注意
 * - 置信度文字: 显示检测置信度
 */
class DetectionOverlayView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {
    
    /** 单个检测结果。 */
    data class DetectionBox(
        val box: FloatArray, // [x0, y0, x1, y1] 归一化坐标 [0,1]
        val confidence: Float = 0f,
        val label: String = "",
        val confirmed: Boolean = false,
    )
    
    private var detections: List<DetectionBox> = emptyList()
    
    // Paint 对象复用
    private val confirmedPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 6f
        color = Color.parseColor("#4CAF50") // 绿色
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }
    
    private val candidatePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 3f
        color = Color.parseColor("#FFC107") // 黄色/琥珀色
        alpha = 180
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }
    
    private val cornerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = Color.parseColor("#4CAF50")
    }
    
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        textSize = 36f
        color = Color.WHITE
        isFakeBoldText = true
    }
    
    private val textBgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = Color.parseColor("#CC000000") // 半透明黑色背景
    }
    
    // 动画相关
    private var animationPhase = 0f
    
    /** 更新检测结果（从主线程调用）。 */
    fun updateDetections(newDetections: List<DetectionBox>) {
        detections = newDetections
        invalidate()
    }
    
    /** 清除所有检测结果。 */
    fun clear() {
        detections = emptyList()
        invalidate()
    }
    
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        if (detections.isEmpty()) return
        
        animationPhase = (animationPhase + 0.05f) % 2f // 循环动画
        
        val viewWidth = width.toFloat()
        val viewHeight = height.toFloat()
        
        for (det in detections) {
            // 将归一化坐标转换为视图坐标
            val rect = RectF(
                det.box[0] * viewWidth,
                det.box[1] * viewHeight,
                det.box[2] * viewWidth,
                det.box[3] * viewHeight,
            )
            
            // 选择画笔
            val paint = if (det.confirmed) confirmedPaint else candidatePaint
            
            // 绘制主边框
            canvas.drawRect(rect, paint)
            
            // 绘制角标装饰 (L 型角标)
            drawCornerMarkers(canvas, rect, if (det.confirmed) cornerPaint else candidatePaint)
            
            // 绘制置信度文字
            if (det.confidence > 0) {
                drawConfidenceLabel(canvas, rect, det.confidence, det.label)
            }
            
            // 已确认时绘制呼吸动画效果
            if (det.confirmed) {
                drawBreathingEffect(canvas, rect)
            }
        }
    }
    
    /** 绘制 L 型角标。 */
    private fun drawCornerMarkers(canvas: Canvas, rect: RectF, paint: Paint) {
        val cornerLength = minOf(rect.width(), rect.height()) * 0.15f
        val thickness = if (paint == cornerPaint) 8f else 4f
        
        // 左上角
        canvas.drawRect(rect.left - thickness/2, rect.top - thickness/2,
                       rect.left + cornerLength, rect.top + thickness, paint)
        canvas.drawRect(rect.left - thickness/2, rect.top - thickness/2,
                       rect.left + thickness, rect.top + cornerLength, paint)
        
        // 右上角
        canvas.drawRect(rect.right - cornerLength, rect.top - thickness/2,
                       rect.right + thickness/2, rect.top + thickness, paint)
        canvas.drawRect(rect.right - thickness, rect.top - thickness/2,
                       rect.right + thickness/2, rect.top + cornerLength, paint)
        
        // 左下角
        canvas.drawRect(rect.left - thickness/2, rect.bottom - thickness,
                       rect.left + cornerLength, rect.bottom + thickness/2, paint)
        canvas.drawRect(rect.left - thickness/2, rect.bottom - cornerLength,
                       rect.left + thickness, rect.bottom + thickness/2, paint)
        
        // 右下角
        canvas.drawRect(rect.right - cornerLength, rect.bottom - thickness,
                       rect.right + thickness/2, rect.bottom + thickness/2, paint)
        canvas.drawRect(rect.right - thickness, rect.bottom - cornerLength,
                       rect.right + thickness/2, rect.bottom + thickness/2, paint)
    }
    
    /** 绘制置信度标签。 */
    private fun drawConfidenceLabel(canvas: Canvas, rect: RectF, confidence: Float, label: String) {
        val text = "${if (label.isNotEmpty()) "$label " else ""}${(confidence * 100).toInt()}%"
        val textWidth = textPaint.measureText(text)
        val textHeight = textPaint.fontMetrics.let { it.descent - it.ascent }
        val padding = 8f
        
        // 标签位置: 边框上方
        val labelLeft = rect.left
        val labelTop = rect.top - textHeight - padding * 2
        
        // 背景
        val bgRect = RectF(labelLeft - padding, labelTop - padding,
                          labelLeft + textWidth + padding * 2, labelTop + textHeight + padding)
        canvas.drawRoundRect(bgRect, 6f, 6f, textBgPaint)
        
        // 文字
        canvas.drawText(text, labelLeft + padding, labelTop + textHeight - textPaint.fontMetrics.descent, textPaint)
    }
    
    /** 绘制已确认时的呼吸效果（半透明填充）。 */
    private fun drawBreathingEffect(canvas: Canvas, rect: RectF) {
        val alpha = ((Math.sin(animationPhase.toDouble()) + 1) * 0.5 * 30).toInt()
        val breathPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.argb(alpha, 76, 175, 80) // 绿色半透明
        }
        canvas.drawRoundRect(rect, 12f, 12f, breathPaint)
    }

    companion object {
        const val TAG = "DetectionOverlay"
    }
}
