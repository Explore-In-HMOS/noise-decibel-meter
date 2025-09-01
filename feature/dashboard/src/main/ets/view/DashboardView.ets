import { NavigationManager } from 'core'
import { AnimatedProgressButton } from '../component/AnimatedProgressButton'
import { DashboardState } from '../state/DashboardState'
import { DashboardViewModel } from '../viewmodel/DashboardViewmodel'


@Entry
@Component
export struct DashboardView {

  private viewModel = new DashboardViewModel()

  @State state: DashboardState = DashboardState.initial()

  async aboutToAppear(): Promise<void> {
    this.viewModel.addListener((newState: DashboardState) => {
      this.state = newState
    })
    this.viewModel.init();
  }

  onPageShow(): void {
    this.viewModel.startRecording()
  }

  build() {
    Column() {
      Stack() {
        AnimatedProgressButton({
          value: parseInt((this.state.decibel ?? 0).toFixed(0)),
          type: ProgressType.Ring,
        })

        Text(`${this.state.decibel?.toFixed(2)} db`)
          .fontSize('24fp')
          .fontWeight(FontWeight.Bold)
          .padding({bottom:50})
          .align(Alignment.Center)

        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_right')) // sistemden gelen ikon
            .fillColor(Color.White)
            .width(24)
            .height(24)
        }
        .onClick(() => {
          NavigationManager.getInstance().pageInfos.pushPath({name: 'settings'})
        })
        .align(Alignment.Center)
        .margin({ top: '10%' })
        .backgroundColor(Color.Transparent)
      }
      .alignContent(Alignment.Center)
      .width('100%')
      .height('100%')




    }
    .width('100%')
    .height('100%')

  }
}