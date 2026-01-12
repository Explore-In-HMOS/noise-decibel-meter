import { ISettingsState } from './ISettingsState';

export class SettingsState {
  public isLoading: boolean;
  public readonly error?: string;
  public message?: string;
  public maxValue?: number;

  constructor(init: ISettingsState) {
    this.isLoading = init.isLoading ?? true;
    this.error = init.error === null ? undefined : init.error;
    this.message = init.message === null ? undefined : init.message;
    this.maxValue = init.maxValue ?? 1000
  }

  with(updates: ISettingsState): SettingsState {
    return new SettingsState({
      isLoading: updates.isLoading ?? this.isLoading,
      error: updates.error === null ? undefined : (updates.error ?? this.error),
      message: updates.message === null ? undefined : (updates.message ?? this.message),
      maxValue: updates.maxValue ?? this.maxValue
    });
  }

  static initial(): SettingsState {
    return new SettingsState({
      isLoading: false,
      error: null,
      message: '',
      maxValue: 1000
    });
  }
}
