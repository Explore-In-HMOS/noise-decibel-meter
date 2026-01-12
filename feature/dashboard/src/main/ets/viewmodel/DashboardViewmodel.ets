import { DashboardState } from '../state/DashboardState';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { NotificationManager } from 'core/src/main/ets/notification/NotificationManager';
import { StorageManager } from 'core/src/main/ets/storage/StorageManager'
import { SettingsModel } from '../model/SettingsModel';

export class DashboardViewModel {
  private _state: DashboardState = DashboardState.initial()
  private listeners: Array<(state: DashboardState) => void> = []
  private readonly TAG: string = 'DashboardViewModel';

  currentDecibel: number = 0;
  gaugeColors: [LinearGradient, number][] = []
  audioRecorder: audio.AudioCapturer | undefined = undefined;

  get state(): DashboardState {
    return this._state
  }

  set state(newState: DashboardState) {
    this._state = newState
    this.notifyListeners()
  }

  addListener(listener: (state: DashboardState) => void) {
    this.listeners.push(listener)
  }

  private notifyListeners() {
    this.listeners.forEach(listener => listener(this._state))
  }

  async init(): Promise<void> {
    this.initialize()
  }

  async initialize() {
    const store = StorageManager.getInstance()
    const settings = await store.getModelWithExpiry('settings', SettingsModel.fromJson)
    const maxValue = settings?.maxValue ?? 1000
    const streamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
      channels: audio.AudioChannel.CHANNEL_1,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    };
    const recorderInfo: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    };
    const recorderOptions: audio.AudioCapturerOptions = {
      streamInfo: streamInfo,
      capturerInfo: recorderInfo
    };
    audio.createAudioCapturer(recorderOptions, (err, recorder) => {
      if (err) {
        console.error(`创建音频记录器失败, 错误码: ${err.code}, 错误信息: ${err.message}`);
        return;
      }

      console.info(`${this.TAG}: 音频记录器创建成功`);
      this.audioRecorder = recorder;

      if (!this.audioRecorder) {
        return;
      }

      this.audioRecorder.on('audioInterrupt', (interruptEvent: audio.InterruptEvent) => {
        if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
          switch (interruptEvent.hintType) {
            case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            case audio.InterruptHint.INTERRUPT_HINT_STOP:
              this.stopRecording();
              break;
            default:
              break;
          }
        } else if (
          interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE &&
            interruptEvent.hintType === audio.InterruptHint.INTERRUPT_HINT_RESUME
        ) {
          this.startRecording();
        }
      });

      let lastUpdate = 0;
      this.audioRecorder.on('readData', (buffer: ArrayBuffer) => {
        this.currentDecibel = this.calculateDecibel(buffer);
        const now = Date.now();
        if (now - lastUpdate > 500) {
          lastUpdate = now;
          this.state = this.state.with({ decibel: this.currentDecibel });
        }
      });

      this.startRecording();
    });

  }

  startRecording() {
    if (this.audioRecorder !== undefined) {
      this.audioRecorder.start((err: BusinessError) => {
        if (err) {
          console.error('Failed to start recording.');
        } else {
          console.info('Recording started successfully.');
        }
      });
    }
  }

  stopRecording() {
    if (this.audioRecorder !== undefined) {
      this.audioRecorder.stop((err: BusinessError) => {
        if (err) {
          console.error('Failed to stop recording.');
        } else {
          console.info('Recording stopped successfully.');
        }
      });
    }
  }

  calculateDecibel(pcm: ArrayBuffer): number {
    let sum = 0;
    const pcmView = new DataView(pcm);
    const numSamples = pcm.byteLength / 2;

    for (let i = 0; i < pcm.byteLength; i += 2) {
      const sample = pcmView.getInt16(i, true) / 32768.0;
      sum += sample * sample;
    }

    const meanSquare = sum / numSamples;
    const rms = Math.sqrt(meanSquare);
    const decibels = 20 * Math.log10(rms);

    if (isNaN(decibels) || decibels === -Infinity) {
      return -100;
    }

    const mappedValue = ((decibels + 100) / 100) * 100;
    return Math.max(0, Math.min(100, mappedValue));
  }

}
