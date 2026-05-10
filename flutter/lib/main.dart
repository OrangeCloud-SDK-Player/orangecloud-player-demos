import 'package:flutter/material.dart';
import 'package:orangecloud_player_client/orangecloud_player_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OrangeCloudPlayerClient.initialize(
    appId: 'demo_app_id',
    licenseUrl: 'https://license.example.com/demo',
  );
  runApp(const OrangeCloudPlayerDemoApp());
}

class OrangeCloudPlayerDemoApp extends StatelessWidget {
  const OrangeCloudPlayerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrangeCloud Player Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// =============================================================================
// 首页 - 功能入口列表
// =============================================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      _Entry('基础播放', '输入URL播放，支持倍速/音量/截图', Icons.play_circle_outline, const BasicPlayerPage()),
      _Entry('短视频', '短视频列表滑动播放', Icons.video_library_outlined, const ShortVideoPage()),
      _Entry('离线下载', '视频下载与离线播放', Icons.download_outlined, const DownloadPage()),
      _Entry('画中画', '小窗悬浮播放', Icons.picture_in_picture_alt_outlined, const PIPPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('OrangeCloud Player Demo')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = entries[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(e.icon, size: 32),
              title: Text(e.title),
              subtitle: Text(e.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => e.page)),
            ),
          );
        },
      ),
    );
  }
}

class _Entry {
  final String title, subtitle;
  final IconData icon;
  final Widget page;
  const _Entry(this.title, this.subtitle, this.icon, this.page);
}

// =============================================================================
// 基础播放页
// =============================================================================

class BasicPlayerPage extends StatefulWidget {
  const BasicPlayerPage({super.key});

  @override
  State<BasicPlayerPage> createState() => _BasicPlayerPageState();
}

class _BasicPlayerPageState extends State<BasicPlayerPage> implements PlayerObserver {
  final _urlController = TextEditingController(
    text: 'https://demo-videos.orangecloud.com/sample.mp4',
  );
  late final OrangeCloudPlayerClient _player;

  bool _isPlaying = false;
  bool _isLooping = false;
  bool _isMuted = false;
  double _rate = 1.0;
  double _volume = 1.0;
  double _progress = 0;
  double _duration = 1;

  @override
  void initState() {
    super.initState();
    _player = OrangeCloudPlayerClient();
    _player.addObserver(this);
  }

  @override
  void dispose() {
    _player.removeObserver(this);
    _player.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  void onPlayEvent(PlayerEvent event, Map<String, dynamic> params) {
    if (!mounted) return;
    setState(() {
      switch (event) {
        case PlayerEvent.onPlayBegin:
          _isPlaying = true;
          _duration = (params['duration'] as num?)?.toDouble() ?? _duration;
        case PlayerEvent.onPlayPause:
          _isPlaying = false;
        case PlayerEvent.onPlayResume:
          _isPlaying = true;
        case PlayerEvent.onPlayEnd:
          _isPlaying = false;
          _progress = 0;
        case PlayerEvent.onPlayProgress:
          _progress = (params['progress'] as num?)?.toDouble() ?? _progress;
          _duration = (params['duration'] as num?)?.toDouble() ?? _duration;
        default:
          break;
      }
    });
  }

  @override
  void onNetStatus(Map<String, dynamic> netStatus) {}

  Future<void> _startPlay() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    await _player.startVodPlay(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础播放')),
      body: Column(
        children: [
          // 视频区域
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _player.videoWidget,
            ),
          ),
          // 进度条
          Slider(
            value: _progress.clamp(0, _duration),
            max: _duration > 0 ? _duration : 1,
            onChanged: (v) => _player.seek(v),
          ),
          // URL 输入
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: '视频 URL',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 播放控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: _startPlay,
                icon: const Icon(Icons.play_arrow),
                tooltip: '播放',
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _isPlaying ? _player.pause() : _player.resume(),
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow_outlined),
                tooltip: _isPlaying ? '暂停' : '继续',
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () async {
                  await _player.stopPlay();
                  setState(() {
                    _isPlaying = false;
                    _progress = 0;
                  });
                },
                icon: const Icon(Icons.stop),
                tooltip: '停止',
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () async {
                  final data = await _player.snapshot();
                  if (mounted && data != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('截图成功 (${data.length} bytes)')),
                    );
                  }
                },
                icon: const Icon(Icons.camera_alt),
                tooltip: '截图',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 倍速
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('倍速'),
                Expanded(
                  child: Slider(
                    value: _rate,
                    min: 0.5,
                    max: 3.0,
                    divisions: 10,
                    label: '${_rate.toStringAsFixed(1)}x',
                    onChanged: (v) {
                      setState(() => _rate = v);
                      _player.setRate(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          // 音量
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('音量'),
                Expanded(
                  child: Slider(
                    value: _volume,
                    onChanged: (v) {
                      setState(() => _volume = v);
                      _player.setAudioPlayoutVolume(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          // 循环 & 静音
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('循环'),
                  selected: _isLooping,
                  onSelected: (v) {
                    setState(() => _isLooping = v);
                    _player.setLoop(v);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('静音'),
                  selected: _isMuted,
                  onSelected: (v) {
                    setState(() => _isMuted = v);
                    _player.setMute(v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 短视频页
// =============================================================================

class ShortVideoPage extends StatefulWidget {
  const ShortVideoPage({super.key});

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  late final ShortVideoController _controller;
  final _videos = [
    'https://demo-videos.orangecloud.com/short1.mp4',
    'https://demo-videos.orangecloud.com/short2.mp4',
    'https://demo-videos.orangecloud.com/short3.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _controller = ShortVideoController(
      config: ShortVideoConfig(preloadConcurrency: 2),
    );
    _controller.setDataSource(_videos.map((url) => VideoItem(url: url)).toList());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('短视频')),
      body: _controller.buildListView(
        itemBuilder: (context, i) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Text(
                '视频 ${i + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 离线下载页
// =============================================================================

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final _manager = DownloadManager();
  final _taskIds = <String>[];

  Future<void> _addTask() async {
    final taskId = await _manager.startDownload(
      url: 'https://demo-videos.orangecloud.com/sample.mp4',
    );
    setState(() => _taskIds.add(taskId));
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('离线下载')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      body: _taskIds.isEmpty
          ? const Center(child: Text('点击 + 添加下载任务'))
          : ListView.builder(
              itemCount: _taskIds.length,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: const Icon(Icons.video_file),
                  title: Text('任务 ${i + 1}'),
                  subtitle: Text('ID: ${_taskIds[i]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => _manager.pauseDownload(_taskIds[i]),
                  ),
                );
              },
            ),
    );
  }
}

// =============================================================================
// 画中画页
// =============================================================================

class PIPPage extends StatefulWidget {
  const PIPPage({super.key});

  @override
  State<PIPPage> createState() => _PIPPageState();
}

class _PIPPageState extends State<PIPPage> {
  late final OrangeCloudPlayerClient _player;
  late final PIPController _pip;
  bool _inPIP = false;

  @override
  void initState() {
    super.initState();
    _player = OrangeCloudPlayerClient();
    _pip = PIPController();
    _player.startVodPlay('https://demo-videos.orangecloud.com/sample.mp4');
  }

  @override
  void dispose() {
    _pip.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('画中画')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _player.videoWidget,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              if (_inPIP) {
                await _pip.exitPictureInPicture();
              } else {
                await _pip.enterPictureInPictureMode();
              }
              setState(() => _inPIP = !_inPIP);
            },
            icon: Icon(_inPIP ? Icons.fullscreen : Icons.picture_in_picture),
            label: Text(_inPIP ? '退出画中画' : '进入画中画'),
          ),
        ],
      ),
    );
  }
}
