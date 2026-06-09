package com.hashira.logic.fitness_log_app.camera

/**
 * INF4: AI 检测状态机。
 *
 * 状态转换流程:
 * IDLE → (用户进入相机) → SCANNING
 * SCANNING → (检测到食物) → CONFIRMING
 * CONFIRMING → (稳定器确认) → ANALYZING
 * CONFIRMING → (超时/无食物) → SCANNING
 * ANALYZING → (完成) → DONE
 * DONE → (用户继续/重拍) → SCANNING
 */
enum class AiState {
    /** 初始/空闲状态。 */
    IDLE,
    
    /** 正在逐帧扫描检测食物。 */
    SCANNING,
    
    /** 检测到候选食物，等待时间投票确认。 */
    CONFIRMING,
    
    /** 已确认食物存在，正在执行完整 YOLOv8-seg 推理。 */
    ANALYZING,
    
    /** 分割完成，等待用户操作。 */
    DONE,
}

/**
 * 状态机事件。
 */
sealed class AiEvent {
    /** 用户打开相机预览。 */
    data object CameraStarted : AiEvent()
    
    /** 用户关闭相机/离开页面。 */
    data object CameraStopped : AiEvent()
    
    /** 当前帧检测到食物候选。 */
    data class FoodDetected(val confidence: Float, val box: FloatArray = floatArrayOf()) : AiEvent()
    
    /** 当前帧未检测到食物。 */
    data object NoFood : AiEvent()
    
    /** 时间投票稳定器确认食物存在（连续 N 帧检测到）。 */
    data class FoodConfirmed(val avgConfidence: Float) : AiEvent()
    
    /** 确认超时（食物消失或不够稳定）。 */
    data object ConfirmTimeout : AiEvent()
    
    /** 分割推理完成。 */
    data class SegmentComplete(val foregroundPath: String, val maskPath: String?) : AiEvent()
    
    /** 分割推理失败。 */
    data class SegmentFailed(val error: String) : AiEvent()
    
    /** 用户请求重新开始扫描。 */
    data object Reset : AiEvent()
}

/**
 * 状态转换监听器。
 */
interface AiStateListener {
    fun onStateChanged(from: AiState, to: AiState, event: AiEvent)
    fun onAnalysisProgress(progress: Float) {} // 0.0 ~ 1.0
}

/**
 * INF4: AI 状态机实现。
 *
 * 线程安全：所有状态变更通过主线程 Handler 执行。
 */
class AiStateMachine(private val listener: AiStateListener? = null) {
    
    @Volatile
    var currentState: AiState = AiState.IDLE
        private set
    
    private val stateHistory = mutableListOf<Pair<AiState, Long>>()
    
    /**
     * 处理事件并尝试状态转换。
     * @return 是否成功转换
     */
    fun processEvent(event: AiEvent): Boolean {
        val oldState = currentState
        val newState = transition(oldState, event) ?: return false
        
        currentState = newState
        stateHistory.add(Pair(newState, System.currentTimeMillis()))
        
        // 保留最近 50 条历史
        if (stateHistory.size > 50) {
            stateHistory.removeAt(0)
        }
        
        listener?.onStateChanged(oldState, newState, event)
        
        android.util.Log.d("AiStateMachine", "State: $oldState -> $newState (event: ${event::class.simpleName})")
        
        return true
    }
    
    /**
     * 核心状态转移表。
     */
    private fun transition(current: AiState, event: AiEvent): AiState? {
        return when (current) {
            AiState.IDLE -> when (event) {
                is AiEvent.CameraStarted -> AiState.SCANNING
                else -> null
            }
            
            AiState.SCANNING -> when (event) {
                is AiEvent.FoodDetected -> AiState.CONFIRMING
                is AiEvent.CameraStopped -> AiState.IDLE
                is AiEvent.Reset -> AiState.SCANNING // 重新扫描
                else -> current // NoFood 忽略，保持 SCANNING
            }
            
            AiState.CONFIRMING -> when (event) {
                is AiEvent.FoodConfirmed -> AiState.ANALYZING
                is AiEvent.ConfirmTimeout -> AiState.SCANNING
                is AiEvent.CameraStopped -> AiState.IDLE
                is AiEvent.Reset -> AiState.SCANNING
                else -> null
            }
            
            AiState.ANALYZING -> when (event) {
                is AiEvent.SegmentComplete -> AiState.DONE
                is AiEvent.SegmentFailed -> AiState.SCANNING // 失败回退到扫描
                is AiEvent.CameraStopped -> AiState.IDLE
                else -> null
            }
            
            AiState.DONE -> when (event) {
                is AiEvent.Reset -> AiState.SCANNING
                is AiEvent.CameraStopped -> AiState.IDLE
                else -> null
            }
        }
    }
    
    /** 是否可以拍照（仅在 SCANNING 或 DONE 状态允许）。 */
    fun canCapture(): Boolean = currentState in listOf(AiState.SCANNING, AiState.DONE)
    
    /** 是否正在分析中（不允许重复触发）。 */
    fun isAnalyzing(): Boolean = currentState == AiState.ANALYZING
    
    /** 重置到初始状态。 */
    fun reset() {
        processEvent(AiEvent.Reset)
    }
    
    /** 获取状态历史（用于调试）。 */
    fun getStateHistory(): List<Pair<AiState, Long>> = stateHistory.toList()

    companion object {
        const val TAG = "AiStateMachine"
    }
}
