import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

AppStorage.setOrCreate('PropB', 111);
// 通过getShared接口获取stage共享的LocalStorage实例
let storage = LocalStorage.getShared()

@Entry(storage)
@Component
struct Login {
  @State message: string = '登录页面';
  private context = getContext(this) as common.UIAbilityContext
  @LocalStorageLink('PropA') propA: number = 1;
  @StorageProp('PropB') propB: number = 0;
  @StorageLink('aProp') aProp: number = 0;
  @StorageProp('languageCode') lang: string = 'zh';
  langProp: SubscribedAbstractProperty<string> = AppStorage.prop('languageCode');

  build() {
    Column() {
      Text(`${this.aProp}${this.langProp.get()}`)
        .fontSize(50)
        .fontWeight(FontWeight.Bold).onClick(() => {
        this.aProp++;
        this.langProp.set('zh');
      })
      Text(`${this.propB}`)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
      Text(`${this.propA}`)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
      Text(this.message)
        .id('LoginHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      CountModifier()
      TextInputExample()
      AddLog()
      Button('点击跳转到选择页面').onClick(() => {
        let want: Want = {
          bundleName: 'com.example.flutter_demo',
          abilityName: 'EntryAbility'
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
      }).alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
    }
    .height('100%')
    .width('100%')
  }
}

@Component
struct TotalView {
  @Prop @Watch('onCountUpdated') count: number = 0;
  @State total: number = 0;
  // @Watch 回调更新this.total
  onCountUpdated(propName: string): void {
    console.log('onCountUpdated----'+propName);// count
    this.total += this.count;
  }

  build() {
    Text(`Total: ${this.total}`)
  }
}

@Component
struct CountModifier {
  @State count: number = 0;

  build() {
    Column() {
      Button('add to basket')
        .onClick(() => {
          this.count++
        })
      TotalView({ count: this.count })
    }
  }
}

@Component
struct TextInputExample {
  @State text: string = ''
  controller: TextInputController = new TextInputController()

  build() {
    Column({ space: 20 }) {
      Text(this.text)
      TextInput({ text: $$this.text, placeholder: 'input your word...', controller: this.controller })
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 14, weight: 400 })
        .caretColor(Color.Blue)
        // .onChange((value:string)=>{
        //   this.text =value+"11111"
        // })
        .width(300)
    }.justifyContent(FlexAlign.Center)
  }
}

class LogTrack {
  @Track str1: string;
  @Track str2: string;

  constructor(str1: string) {
    this.str1 = str1;
    this.str2 = 'World';
  }
}

class LogNotTrack {
  str1: string;
  str2: string;

  constructor(str1: string) {
    this.str1 = str1;
    this.str2 = '世界';
  }
}

@Component
struct AddLog {
  @State logTrack: LogTrack = new LogTrack('Hello');
  @State logNotTrack: LogNotTrack = new LogNotTrack('你好');

  isRender(index: number) {
    console.log(`Text ${index} is rendered`);
    return 50;
  }

  build() {
    Row() {
      Column() {
        Text(this.logTrack.str1) // UINode1
          .fontSize(this.isRender(1))
          .fontWeight(FontWeight.Bold)
        Text(this.logTrack.str2) // UINode2
          .fontSize(this.isRender(2))
          .fontWeight(FontWeight.Bold)
        Button('change logTrack.str1')
          .onClick(() => {
            // this.logTrack= new LogTrack('Hello11112222');
            this.logTrack.str1 = 'Bye';
          })
        Text(this.logNotTrack.str1) // UINode3
          .fontSize(this.isRender(3))
          .fontWeight(FontWeight.Bold)
        Text(this.logNotTrack.str2) // UINode4
          .fontSize(this.isRender(4))
          .fontWeight(FontWeight.Bold)
        Button('change logNotTrack.str1')
          .onClick(() => {
            this.logNotTrack.str1 = '再见';
          })
      }
    }
  }
}