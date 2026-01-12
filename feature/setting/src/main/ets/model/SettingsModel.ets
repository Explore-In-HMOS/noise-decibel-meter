import { BaseModel } from 'core/src/main/ets/base/BaseModel';

export interface SettingsJson {
  maxvalue: number;
}

export class SettingsModel implements BaseModel {
  maxValue: number = 1000;

  constructor(maxValue: number) {
    this.maxValue = maxValue;
  }

  toJson(): SettingsJson {
    return {
      maxvalue: this.maxValue
    };
  }

  static fromJson(json: SettingsJson): SettingsModel {
    return new SettingsModel(json.maxvalue);
  }
}