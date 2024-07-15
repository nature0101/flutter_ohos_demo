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
    Scroll() {
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
          .fontColor($r('sys.color.ohos_id_color_progress')).onClick(() => {
          this.textArray[0] = "10"
        })
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
            return "keyGenerator_" + item;
          })
          MyComponent()
          MyComponent2()
          Parent()
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
      .padding(10)
      .margin(20)
    }.height('100%')
    .width('100%')
  }
}

class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: T[] = [];

  totalCount(): number {
    return 0;
  }

  getData(index: number): T {
    return this.originDataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  // 数据创建时回调，外部持有listener，来操作通知系统组件来更新状态
  registerDataChangeListener(listener: DataChangeListener): void {
    console.log('registerDataChangeListener---' + listener)
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用
  unregisterDataChangeListener(listener: DataChangeListener): void {
    console.log('unregisterDataChangeListener---' + listener)
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      // 重新加载所有子组件
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      // 在index处添加子组件
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      // 在index处数据变化，需要重建该组件
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      // 在index处删除组件
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      // 将from索引和to索引处子组件进行交换
      listener.onDataMove(from, to);
    })
  }

  notifyDatasetChange(operations: DataOperation[]): void {
    this.listeners.forEach((listener) => {
      // 一次性通知LazyForEach应该做哪些操作，若本次操作集合有reload操作，则其余操作全不生效
      listener.onDatasetChange(operations);
    })
  }
}

class MyDataSource<T> extends BasicDataSource<T> {
  private dataArray: T[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): T {
    return this.dataArray[index];
  }

  public addData(index: number, data: T): void {
    // index位置添加
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: T): void {
    // 最后位置添加
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public changeData(index: number, data: T): void {
    // 修改某一项
    this.dataArray.splice(index, 1, data);
    this.notifyDataChange(index);
  }
}

@Component
struct MyComponent {
  private data: MyDataSource<string> = new MyDataSource<string>();

  aboutToAppear(): void {
    for (let i = 0; i <= 20; i++) {
      this.data.pushData('Hello' + i)
    }
  }

  build() {
    List({ space: 3 }) {
      LazyForEach(this.data, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(25)
              .onAttach(() => {
                console.log("MyComponent---onAttach")
              })
              .onAppear(() => {
                console.log("MyComponent---onAppear")
              })
              .onDisAppear(() => {
                console.log("MyComponent---onDisAppear")
              })
              .onDetach(() => {
                console.log("MyComponent---onDetach")
              })
          }
        }.onClick(() => {
          // 末尾增加一项
          //this.data.pushData('Hello'+this.data.totalCount())
          // 修改某一项
          this.data.changeData(index, item + '00')
        })
      }, (item: string) => item)
    }.cachedCount(5)
  }
}

@Observed
class StringData {
  message: string;

  constructor(message: string) {
    this.message = message;
  }
}

@Component
struct MyComponent2 {
  @State data: MyDataSource<StringData> = new MyDataSource<StringData>();

  aboutToAppear(): void {
    for (let i = 0; i <= 20; i++) {
      this.data.pushData(new StringData('Hello' + i));
    }
  }

  build() {
    List({ space: 3 }) {
      LazyForEach(this.data, (item: StringData, index: number) => {
        ListItem() {
          Row() {
            // 不能更新
            Text(item.message)
              .fontSize(25)
            //能更新，子类必须是一个自定义组件
            ChildComponent({ data: item })
          }
        }.onClick(() => {
          // 修改某一项,局部刷新
          item.message += '0'
        })
      }, (item: StringData, index: number) => item.message)
    }.cachedCount(5)
  }
}

@Component
struct ChildComponent {
  // @ObjectLink装饰的成员变量仅能监听到其子属性的变化，再深入嵌套的属性便无法观测到了
  @ObjectLink data: StringData

  build() {
    Row() {
      Text(this.data.message).fontSize(50)
        .onAppear(() => {
          console.info("appear:" + this.data.message)
        })
    }.margin({ left: 10, right: 10 })
  }
}

@Component
struct Parent {
  @State simpleList: Array<string> = ['one', 'two', 'three'];

  build() {
    Row() {
      Column() {
        Repeat<string>(this.simpleList).each((obj: RepeatItem<string>) => {
          ChildItem({ item: obj.item })
        }).key((item: string) => item)
      }.width('100%').height('100%')
    }.height('100%')
  }
}

@Component
struct ChildItem {
  @Prop item: string;

  build() {
    Text(this.item).fontSize(25)
  }
}