import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

@Entry
@Component
struct Page {
  @State message: string = 'SplashPage';
  private context = getContext(this) as common.UIAbilityContext

  build() {
    Column() {
      Text(this.message)
        .id('PageHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      Button('跳转登录页面').onClick(() => {
        let want: Want = {
          bundleName: 'com.example.flutter_demo',
          abilityName: 'LoginAbility',
          uri: 'page/Login' // 跳转到Ability不同的page

        };
        // 注意区分Stage模型和FA模型的startAbility
        // 一个UiAbility至少对应一个@entry修饰的page，page类似Android中的fragment
        try{
          this.context.startAbility(want, (err, data) => {
            if (err.code) {
              // 处理业务逻辑错误
              console.error(`startAbility failed, code is ${err.code}, message is ${err.message}`);
              return;
            }
            // 关闭当前页面
            this.context.terminateSelf((err)=>{
              console.log('terminateSelf result:'+JSON.stringify(err));
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
  }
}