import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';
import { SplashView } from 'splash/src/main/ets/view/SplashView'
import { SettingsView } from 'setting/src/main/ets/view/SettingsView'
import { DashboardView } from 'dashboard/src/main/ets/view/DashboardView'



@Entry
@Component
struct Index {
  @Builder
  routeMap(name: string) {
    NavDestination() {
      if (name === 'splash') {
        SplashView()
      } else if (name === 'dashboard') {
        DashboardView()
      } else if (name === 'settings') {
        SettingsView()
      } else {
        SplashView()
      }
    }
    .hideBackButton(true)
  }

  build() {
    Navigation(NavigationManager.getInstance().pageInfos) {
      SplashView()
    }
    .navDestination(this.routeMap)
    .ignoreLayoutSafeArea()
    .hideTitleBar(true)
    .width('100%')
    .height('100%')

  }
}