import { OrangeCloudPlayerClient } from '../../web/orangecloud-player-client/src';

// --- DOM Elements ---
const $ = <T extends HTMLElement>(id: string) => document.getElementById(id) as T;
const urlInput = $<HTMLInputElement>('urlInput');
const btnLoad = $('btnLoad');
const btnPlay = $('btnPlay');
const btnPause = $('btnPause');
const btnStop = $('btnStop');
const btnLoop = $('btnLoop');
const btnMute = $('btnMute');
const volumeSlider = $<HTMLInputElement>('volumeSlider');
const rateSelect = $<HTMLSelectElement>('rateSelect');
const progressBar = $('progressBar');
const progressFill = $('progressFill');
const timeLabel = $('timeLabel');
const logArea = $('logArea');

// --- Logger ---
function log(msg: string, isError = false) {
  const t = new Date().toLocaleTimeString();
  const div = document.createElement('div');
  div.className = `log-item${isError ? ' error' : ''}`;
  div.innerHTML = `<span class="time">[${t}]</span> ${msg}`;
  logArea.appendChild(div);
  logArea.scrollTop = logArea.scrollHeight;
}

// --- Format time ---
function fmt(s: number): string {
  const m = Math.floor(s / 60);
  const sec = Math.floor(s % 60);
  return `${String(m).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
}

// --- Init Player ---
const player = new OrangeCloudPlayerClient({
  containerId: 'playerContainer',
  appId: 'demo-app',
  licenseKey: 'demo-license-key',
});

let loopEnabled = false;
let muted = false;

log('播放器初始化完成');

// --- Events ---
player.on('play', () => log('▶ 开始播放'));
player.on('pause', () => log('⏸ 已暂停'));
player.on('ended', () => log('⏹ 播放结束'));
player.on('error', (err: unknown) => log(`错误: ${err}`, true));
player.on('timeupdate', () => {
  const cur = player.currentTime ?? 0;
  const dur = player.duration ?? 0;
  timeLabel.textContent = `${fmt(cur)} / ${fmt(dur)}`;
  progressFill.style.width = dur > 0 ? `${(cur / dur) * 100}%` : '0%';
});

// --- Controls ---
btnLoad.addEventListener('click', () => {
  const url = urlInput.value.trim();
  if (!url) return;
  log(`加载: ${url}`);
  player.play(url);
});

btnPlay.addEventListener('click', () => player.resume());
btnPause.addEventListener('click', () => player.pause());
btnStop.addEventListener('click', () => { player.stop(); log('已停止'); });

btnLoop.addEventListener('click', () => {
  loopEnabled = !loopEnabled;
  player.setLoop(loopEnabled);
  btnLoop.textContent = `🔁 循环: ${loopEnabled ? '开' : '关'}`;
  log(`循环: ${loopEnabled ? '开启' : '关闭'}`);
});

btnMute.addEventListener('click', () => {
  muted = !muted;
  player.setMute(muted);
  btnMute.textContent = muted ? '🔇' : '🔊';
});

volumeSlider.addEventListener('input', () => {
  const vol = Number(volumeSlider.value) / 100;
  player.setVolume(vol);
});

rateSelect.addEventListener('change', () => {
  const rate = Number(rateSelect.value);
  player.setRate(rate);
  log(`倍速: ${rate}x`);
});

// --- Progress bar seek ---
progressBar.addEventListener('click', (e) => {
  const rect = progressBar.getBoundingClientRect();
  const ratio = (e.clientX - rect.left) / rect.width;
  const dur = player.duration ?? 0;
  if (dur > 0) {
    player.seek(ratio * dur);
    log(`跳转: ${fmt(ratio * dur)}`);
  }
});

// --- Set initial volume ---
player.setVolume(0.8);
