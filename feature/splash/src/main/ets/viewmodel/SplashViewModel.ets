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


  async init(): Promise<void> {
    this.state = this.state.with({ isLoading: true });

    //await new Promise<void>((resolve) => setTimeout(resolve, 5000));

    try {
      const result = await this.requestMicPermission();
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
      const isNotificationPermissionGranted = await this.requestNotificationPermission();
      if (isNotificationPermissionGranted){
        LogManager.info(this.TAG,'Notification is granted')
      } else {
        LogManager.info(this.TAG,'Notification is rejected')
      }
    } catch (e){
      LogManager.error(this.TAG,`Notification permission error: ${e}}`)
    } finally {
      this.state = this.state.with({ isLoading: false });
    }
  }


  async requestMicPermission () : Promise<PermissionResult> {
    const pm = PermissionManager.getInstance();
    const context = getContext(this) as common.UIAbilityContext;
    const result = await pm.requestPermission(PermissionType.MIC,context) as PermissionResult
    return result
  }

  async requestNotificationPermission () : Promise<boolean> {
    const nm = NotificationManager.getInstance()
    const context = getContext(this) as common.UIAbilityContext;
    return await nm.requestPermission(context)
  }

}
