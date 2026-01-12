import { ProgressComponent } from '../component/ProgressComponent'
import { SplashState } from '../state/SplashState'
import { SplashViewModel } from '../viewmodel/SplashViewModel'
import { common } from '@kit.AbilityKit'


@Entry
@Component
export struct SplashView {

  private viewModel : SplashViewModel = new SplashViewModel()
  @State state : SplashState = SplashState.initial()

  aboutToAppear(): void {
    this.viewModel.addListener((newState : SplashState) => {
      this.state = newState
    })
    const uiContext = globalThis.getUIContext?.() as common.UIAbilityContext;
    this.viewModel.init(uiContext)

    this.viewModel.init(uiContext)
  }

  build() {
    Column() {
      if (this.state.isLoading) {
          LoadingProgress()
      }

      if (this.state.error) {
        Text(this.state.error)
          .fontColor(Color.Red)
          .margin({top: 20})
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)

  }
}