import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

// 页面：只有被@Entry装饰的组件才可以调用页面的生命周期，生命周期方法：onPageShow,onPageHide,onBackPress
// 自定义组件：@Component修饰，生命周期方法：aboutToAppear,build,onDidBuild,aboutToDisappear,后两个方法中不能更改状态变量，使用animateTo等功能
// 整体生命周期方法：aboutToAppear-> build-> onDidBuild-> onPageShow-> onPageHide-> aboutToDisappear
@Entry
@Component
struct Page {
  @State message: string = 'SplashPage';
  // 获取上下文
  private context = getContext(this) as common.UIAbilityContext
  showImage: boolean = false
  private textArray: string[] = ["1", "2", "3", "4"]

  build() {
    Column() {
      Text($r('app.string.SplashAbility_label'))
        .size({ width: 100, height: 120 })
        .fontColor($r('app.color.big_red'))
        .backgroundImage($r('app.media.background'))// .backgroundColor($r('app.color.big_red'))
        .padding(10)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
      Text($r('sys.string.ohos_set_network'))
        .fontSize($r('sys.float.titlebar_subheader_size'))
        .fontColor($r('sys.color.ohos_id_color_progress'))
      if (this.showImage) {
        Image($r('sys.media.ohos_ic_public_play'))
          .border({
            color: $r('sys.color.ohos_id_color_palette_aux1'),
            radius: $r('sys.float.ohos_id_corner_radius_button')
          }).width(50).height(50).margin(10)
      } else {
        Text(this.message)
          .id('PageHelloWorld')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
        ForEach(this.textArray, (item: string, index?: number) => {
          Text(item).fontSize(20).backgroundColor(Color.Blue).margin({ top: 10 })
        }, (item: string, index?: number) => {
          return "keyGenerator" + index;
        })
      }
      Button('跳转登录页面').onClick(() => {
        let want: Want = {
          bundleName: 'com.example.flutter_demo',
          abilityName: 'LoginAbility',
          uri: 'page/Login' // 跳转到Ability不同的page

        };
        // 注意区分Stage模型和FA模型的startAbility
        // 一个UiAbility至少对应一个@entry修饰的page，page类似Android中的fragment
        try {
          this.context.startAbility(want, (err, data) => {
            if (err.code) {
              // 处理业务逻辑错误
              console.error(`startAbility failed, code is ${err.code}, message is ${err.message}`);
              return;
            }
            // 关闭当前页面
            this.context.terminateSelf((err) => {
              console.log('terminateSelf result:' + JSON.stringify(err));
            });
          })
        } catch (err) {
          let code = (err as BusinessError).code;
          let message = (err as BusinessError).message;
          console.error(`startAbility failed, code is ${code}, message is ${message}`);
        }

      })
    }
    .height('100%')
    .width('100%')
    .padding(10)
    .margin(20)
  }
}