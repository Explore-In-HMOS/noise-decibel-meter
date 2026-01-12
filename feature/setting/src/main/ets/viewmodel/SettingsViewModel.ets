import { SettingsModel } from '../model/SettingsModel';
import { SettingsState } from '../state/SettingsState';
import { StorageManager } from 'core/src/main/ets/storage/StorageManager'
import { Duration } from 'core/src/main/ets/base/DurationModel';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';


export class SettingsViewModel {
  private _state: SettingsState = SettingsState.initial()
  private listeners: Array<(state: SettingsState) => void> = []
  private readonly TAG: string = 'SettingsViewModel';
  public controller = new TextInputController()

  get state(): SettingsState {
    return this._state
  }

  set state(newState: SettingsState) {
    this._state = newState
    this.notifyListeners()
  }

  addListener(listener: (state: SettingsState) => void) {
    this.listeners.push(listener)
  }

  private notifyListeners() {
    this.listeners.forEach(listener => listener(this._state))
  }


  async init(): Promise<void> {
    this.state = this.state.with({isLoading: true})
    const store = StorageManager.getInstance()
    const val = await store.getModelWithExpiry('settings', SettingsModel.fromJson)
    this.state = this.state.with({isLoading: false,maxValue: val?.maxValue})

  }

  async saveSettings() : Promise<void> {
    this.state = this.state.with({isLoading: true})
    const maxValue = this.getValue
    const settingsModel = new SettingsModel(maxValue);
    const store = StorageManager.getInstance()
    await store.saveModelWithExpiry('settings', settingsModel, Duration.days(365))
    this.state = this.state.with({isLoading: false,maxValue: maxValue})
    NavigationManager.getInstance().pageInfos.pushPath({name: 'dashboard'})

  }

  setValue(value: number) {
    this.state = this.state.with({maxValue: value})
  }

  get getValue() : number {
    return this.state.maxValue ?? 0
  }

  async save() : Promise<void> {
    this.state = this.state.with({isLoading: true})
    await this.saveSettings()
    this.state = this.state.with({isLoading: false})
  }

}
