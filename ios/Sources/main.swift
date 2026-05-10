import Foundation
import OrangeCloudPlayerClient

#if canImport(SwiftUI)
import SwiftUI

// ============================================================
// OrangeCloud Player SDK - iOS SwiftUI Demo
//
// 在 SwiftUI App 中集成 OrangeCloudPlayerClient 的完整示例。
// 可直接复制到 Xcode 项目中使用。
// ============================================================

/// ViewModel：封装 OCPlayerClient 的所有交互逻辑
@MainActor
class PlayerViewModel: ObservableObject {
    private let client = OCPlayerClient()
    private var delegateHandler: PlayerDelegateHandler?

    @Published var playState: PlayState = .idle
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var rate: Float = 1.0
    @Published var isMuted: Bool = false
    @Published var isLooping: Bool = false
    @Published var logs: [String] = []

    // 配置
    @Published var videoUrl = "https://example.com/demo.mp4"
    @Published var appId = "demo_app"
    @Published var licenseUrl = "https://license.example.com/v1"

    var isPlaying: Bool { playState == .playing }
    var progress: Double { duration > 0 ? currentTime / duration : 0 }

    init() {
        delegateHandler = PlayerDelegateHandler(vm: self)
        client.delegate = delegateHandler
        OCPlayerClient.initialize(appId: appId, licenseUrl: licenseUrl)
        addLog("SDK 已初始化")
    }

    func startPlay() {
        guard !videoUrl.isEmpty else { return }
        let success = client.startVodPlay(videoUrl)
        addLog(success ? "开始播放: \(videoUrl)" : "播放失败")
    }

    func stopPlay() {
        client.stopPlay()
        currentTime = 0
        duration = 0
        addLog("停止播放")
    }

    func togglePause() {
        if isPlaying {
            client.pause()
            addLog("已暂停")
        } else {
            client.resume()
            addLog("已恢复")
        }
    }

    func seek(to progress: Double) {
        let time = progress * duration
        client.seek(time)
        addLog("跳转到 \(formatTime(time))")
    }

    func setRate(_ newRate: Float) {
        rate = newRate
        client.setRate(newRate)
        addLog("倍速: \(newRate)x")
    }

    func toggleMute() {
        isMuted.toggle()
        client.setMute(isMuted)
        addLog(isMuted ? "已静音" : "已取消静音")
    }

    func toggleLoop() {
        isLooping.toggle()
        client.setLoop(isLooping)
        addLog(isLooping ? "循环播放开启" : "循环播放关闭")
    }

    func takeSnapshot() {
        if let _ = client.snapshot() {
            addLog("截图成功")
        } else {
            addLog("截图失败")
        }
    }

    func addLog(_ text: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        logs.append("[\(formatter.string(from: Date()))] \(text)")
        if logs.count > 200 { logs.removeFirst() }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

/// 播放状态
enum PlayState { case idle, playing, paused, buffering, ended }

/// Delegate 处理器（桥接到 ViewModel）
class PlayerDelegateHandler: OCPlayerClientDelegate {
    weak var vm: PlayerViewModel?
    init(vm: PlayerViewModel) { self.vm = vm }

    func onPlayStateChanged(_ client: OCPlayerClient, state: Int) {
        Task { @MainActor in
            switch state {
            case 0: vm?.playState = .idle
            case 1: vm?.playState = .playing
            case 2: vm?.playState = .paused
            case 3: vm?.playState = .buffering
            case 4: vm?.playState = .ended
            default: break
            }
            vm?.addLog("播放状态: \(vm?.playState ?? .idle)")
        }
    }

    func onPlayProgress(_ client: OCPlayerClient, current: TimeInterval, duration: TimeInterval) {
        Task { @MainActor in
            vm?.currentTime = current
            vm?.duration = duration
        }
    }

    func onPlayError(_ client: OCPlayerClient, code: Int, message: String) {
        Task { @MainActor in
            vm?.playState = .idle
            vm?.addLog("❌ 错误(\(code)): \(message)")
        }
    }
}

// ============================================================
// SwiftUI 视图
// ============================================================

/// 播放器主视图
struct PlayerDemoView: View {
    @StateObject private var vm = PlayerViewModel()
    @State private var seekProgress: Double = 0
    @State private var isSeeking = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 播放器区域占位
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(16/9, contentMode: .fit)
                    if vm.playState == .idle {
                        Text("输入 URL 开始播放")
                            .foregroundColor(.gray)
                    } else if vm.playState == .buffering {
                        ProgressView()
                            .tint(.white)
                    }
                }

                // 进度条
                VStack(spacing: 4) {
                    Slider(
                        value: isSeeking ? $seekProgress : Binding(get: { vm.progress }, set: { seekProgress = $0 }),
                        in: 0...1,
                        onEditingChanged: { editing in
                            isSeeking = editing
                            if !editing { vm.seek(to: seekProgress) }
                        }
                    )
                    HStack {
                        Text(vm.formatTime(vm.currentTime))
                        Spacer()
                        Text(vm.formatTime(vm.duration))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                // 播放控制
                HStack(spacing: 20) {
                    Button(action: vm.stopPlay) {
                        Image(systemName: "stop.fill")
                    }
                    Button(action: vm.togglePause) {
                        Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                    }
                    Button(action: vm.toggleMute) {
                        Image(systemName: vm.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    }
                    Button(action: vm.toggleLoop) {
                        Image(systemName: "repeat")
                            .foregroundColor(vm.isLooping ? .blue : .primary)
                    }
                    Button(action: vm.takeSnapshot) {
                        Image(systemName: "camera.fill")
                    }
                }
                .padding(.vertical, 12)

                // 倍速选择
                HStack(spacing: 8) {
                    Text("倍速:")
                        .font(.caption)
                    ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { r in
                        Button("\(r, specifier: "%.1f")x") {
                            vm.setRate(Float(r))
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(vm.rate == Float(r) ? .blue : .gray)
                    }
                }
                .padding(.bottom, 8)

                Divider()

                // 日志
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(vm.logs.enumerated()), id: \.offset) { idx, log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .id(idx)
                            }
                        }
                        .padding(8)
                    }
                    .onChange(of: vm.logs.count) { _ in
                        proxy.scrollTo(vm.logs.count - 1, anchor: .bottom)
                    }
                }

                Divider()

                // URL 输入
                HStack {
                    TextField("输入视频 URL...", text: $vm.videoUrl)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit { vm.startPlay() }
                    Button("播放") { vm.startPlay() }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.videoUrl.isEmpty)
                }
                .padding(8)
            }
            .navigationTitle("OrangeCloud Player Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(vm.isPlaying ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(stateText)
                            .font(.caption)
                    }
                }
            }
        }
    }

    private var stateText: String {
        switch vm.playState {
        case .idle: return "空闲"
        case .playing: return "播放中"
        case .paused: return "已暂停"
        case .buffering: return "缓冲中"
        case .ended: return "已结束"
        }
    }
}

@main
struct OrangeCloudPlayerDemoApp: App {
    var body: some Scene {
        WindowGroup {
            PlayerDemoView()
        }
    }
}
#else
print("OrangeCloudPlayerDemo requires SwiftUI (iOS 16+ / macOS 13+)")
#endif
