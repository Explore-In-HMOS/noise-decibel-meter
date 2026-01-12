import { NavigationManager, NotificationManager, PermissionManager, PermissionResult, PermissionType } from 'core';
import { SplashState } from '../state/SplashState';
import { common } from '@kit.AbilityKit';
import { LogManager } from 'core/src/main/ets/logger/LogManager';


export class SplashViewModel {
  private _state: SplashState = SplashState.initial()
  private listeners: Array<(state: SplashState) => void> = []
  private readonly TAG: string = 'SplashViewModel';

  get state(): SplashState {
    return this._state
  }

  set state(newState: SplashState) {
    this._state = newState
    this.notifyListeners()
  }

  addListener(listener: (state: SplashState) => void) {
    this.listeners.push(listener)
  }

  private notifyListeners() {
    this.listeners.forEach(listener => listener(this._state))
  }


  async init(context: common.UIAbilityContext): Promise<void> {
    this.state = this.state.with({ isLoading: true });

    try {
      const result = await this.requestMicPermission(context);
      if (result === PermissionResult.Granted) {
        LogManager.info(this.TAG, 'Mic permission: GRANTED');
        this.state = this.state.with({isLoading: false})
        NavigationManager.getInstance().pageInfos.pushPath({name: 'dashboard'})
      } else {
        LogManager.info(this.TAG, 'Mic permission: DENIED');
      }
    } catch (e) {
      LogManager.error(this.TAG, `Mic permission error: ${JSON.stringify(e)}`);
      this.state = this.state.with({ error: 'Permission request failed' });
    } finally {
      this.state = this.state.with({ isLoading: false });
    }

    try {
      const isNotificationPermissionGranted = await this.requestNotificationPermission(context);
      if (isNotificationPermissionGranted) {
        LogManager.info(this.TAG, 'Notification is granted')
      } else {
        LogManager.info(this.TAG, 'Notification is rejected')
      }
    } catch (e) {
      LogManager.error(this.TAG, `Notification permission error: ${e}`)
    } finally {
      this.state = this.state.with({ isLoading: false });
    }
  }


  async requestMicPermission(context: common.UIAbilityContext) : Promise<PermissionResult> {
    const pm = PermissionManager.getInstance();
    const result = await pm.requestPermission(PermissionType.MIC, context) as PermissionResult
    return result
  }

  async requestNotificationPermission(context: common.UIAbilityContext) : Promise<boolean> {
    const nm = NotificationManager.getInstance()
    return await nm.requestPermission(context)
  }

}
