import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager'
import { SettingsState } from '../state/SettingsState'
import { SettingsViewModel } from '../viewmodel/SettingsViewModel'

@Entry
@Component
export struct SettingsView {

  private viewModel: SettingsViewModel = new SettingsViewModel()
  @State state: SettingsState = SettingsState.initial()

  aboutToAppear(): void {
    this.viewModel.addListener((newState: SettingsState) => {
      this.state = newState
    })
    this.viewModel.init()
  }

  build() {
    Column() {
      if (this.state.isLoading) {
        LoadingProgress()
      }

      if (this.state.error) {
        Text(this.state.error)
          .fontColor(Color.Red)
      }

      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .fillColor(Color.White)
            .height(32)
            .width(32)
        }
        .onClick(() => {
          NavigationManager.getInstance().pageInfos.pushPath({ name: 'dashboard' })
        })
        .backgroundColor(Color.Transparent)

        Text('Max Decibel Value')
          .fontSize(19)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)



      TextInput({
        'placeholder': `${this.viewModel.getValue} db`,
        controller: this.viewModel.controller
      })
        .onChange((val) => {
          this.viewModel.setValue(Number.parseInt(val))
        })


      Button('save')
        .onClick(() => {
          this.viewModel.saveSettings()
        })
    }
    .align(Alignment.Center)
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 20, right: 20 , top: 24, bottom:20})
    .width('100%')
    .height('100%')
  }
}
