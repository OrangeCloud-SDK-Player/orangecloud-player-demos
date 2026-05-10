package com.orangecloud.player.demo

import com.orangecloud.player.*

/**
 * OrangeCloud Player SDK - Android Activity Demo (伪代码)
 *
 * 演示如何在 Android Activity 中集成 OrangeCloudPlayerClient。
 * 此文件为参考代码，展示 Activity 中的集成模式。
 * 实际使用时需要配合 Android 项目的 layout XML。
 *
 * 关键集成点：
 * 1. 在 onCreate 中初始化 SDK 并创建播放器实例
 * 2. 设置 PlayerListener 监听播放状态
 * 3. 在 onDestroy 中调用 stopPlay() 释放资源
 * 4. 使用 runOnUiThread 更新 UI
 */

/*
// ============================================================
// 以下为 Activity 集成示例代码（需要 Android 项目环境）
// ============================================================

class MainActivity : AppCompatActivity() {

    private lateinit var client: OrangeCloudPlayerClient

    // 配置参数
    private val appId = "demo_app"
    private val licenseUrl = "https://license.example.com/player"

    // 播放状态
    private var isPlaying = false
    private var currentRate = 1.0f
    private var currentVolume = 100
    private var isLoop = false
    private var isMuted = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // 1. 初始化 SDK
        OrangeCloudPlayerClient.initialize(this, appId, licenseUrl)
        client = OrangeCloudPlayerClient(this)

        // 2. 设置播放器回调
        client.listener = object : PlayerListener {
            override fun onPlayStateChanged(state: Int) {
                runOnUiThread {
                    when (state) {
                        0 -> updateStatus("已停止")
                        1 -> { updateStatus("播放中"); isPlaying = true }
                        2 -> { updateStatus("已暂停"); isPlaying = false }
                        3 -> updateStatus("缓冲中...")
                    }
                }
            }

            override fun onProgress(current: Long, duration: Long) {
                runOnUiThread {
                    findViewById<SeekBar>(R.id.seekBar).max = duration.toInt()
                    findViewById<SeekBar>(R.id.seekBar).progress = current.toInt()
                    findViewById<TextView>(R.id.tvProgress).text =
                        "${formatTime(current)} / ${formatTime(duration)}"
                }
            }

            override fun onError(code: Int, message: String) {
                runOnUiThread { updateStatus("❌ 错误[$code]: $message") }
            }

            override fun onPlayEnd() {
                runOnUiThread {
                    isPlaying = false
                    updateStatus("播放结束")
                }
            }

            override fun onResolutionChanged(index: Int, name: String) {
                runOnUiThread { updateStatus("清晰度切换: $name") }
            }

            override fun onSnapshotComplete(bitmap: android.graphics.Bitmap?) {
                runOnUiThread {
                    updateStatus(if (bitmap != null) "截图成功" else "截图失败")
                }
            }
        }

        // 3. 绑定 UI 事件
        findViewById<Button>(R.id.btnPlay).setOnClickListener { doPlay() }
        findViewById<Button>(R.id.btnPause).setOnClickListener { doPauseResume() }
        findViewById<Button>(R.id.btnStop).setOnClickListener { doStop() }
        findViewById<Button>(R.id.btnRate).setOnClickListener { doSwitchRate() }
        findViewById<Button>(R.id.btnMute).setOnClickListener { doToggleMute() }
        findViewById<Button>(R.id.btnLoop).setOnClickListener { doToggleLoop() }
        findViewById<Button>(R.id.btnSnapshot).setOnClickListener { doSnapshot() }

        // 进度条拖动
        findViewById<SeekBar>(R.id.seekBar).setOnSeekBarChangeListener(
            object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {}
                override fun onStartTrackingTouch(sb: SeekBar?) {}
                override fun onStopTrackingTouch(sb: SeekBar?) {
                    sb?.let { client.seek(it.progress.toLong()) }
                }
            }
        )

        // 音量控制
        findViewById<SeekBar>(R.id.seekVolume).setOnSeekBarChangeListener(
            object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {
                    if (fromUser) {
                        currentVolume = progress
                        client.setAudioPlayoutVolume(progress)
                    }
                }
                override fun onStartTrackingTouch(sb: SeekBar?) {}
                override fun onStopTrackingTouch(sb: SeekBar?) {}
            }
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        client.stopPlay()
    }

    // ============================================================
    // 操作方法
    // ============================================================

    private fun doPlay() {
        val url = findViewById<EditText>(R.id.etUrl).text.toString().trim()
        if (url.isEmpty()) {
            updateStatus("请输入播放地址")
            return
        }
        client.startVodPlay(url)
    }

    private fun doPauseResume() {
        if (isPlaying) {
            client.pause()
        } else {
            client.resume()
        }
    }

    private fun doStop() {
        client.stopPlay()
        isPlaying = false
        updateStatus("已停止")
    }

    private fun doSwitchRate() {
        val rates = floatArrayOf(0.5f, 1.0f, 1.5f, 2.0f)
        val idx = (rates.indexOf(currentRate) + 1) % rates.size
        currentRate = rates[idx]
        client.setRate(currentRate)
        updateStatus("倍速: ${currentRate}x")
    }

    private fun doToggleMute() {
        isMuted = !isMuted
        client.setMute(isMuted)
        updateStatus(if (isMuted) "已静音" else "已取消静音")
    }

    private fun doToggleLoop() {
        isLoop = !isLoop
        client.setLoop(isLoop)
        updateStatus(if (isLoop) "循环播放: 开" else "循环播放: 关")
    }

    private fun doSnapshot() {
        val bitmap = client.snapshot()
        updateStatus(if (bitmap != null) "截图成功" else "截图失败")
    }

    // ============================================================
    // UI 辅助
    // ============================================================

    private fun updateStatus(text: String) {
        findViewById<TextView>(R.id.tvStatus).text = text
    }

    private fun formatTime(ms: Long): String {
        val sec = ms / 1000
        return "%02d:%02d".format(sec / 60, sec % 60)
    }
}
*/
