import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

// 页面：只有被@Entry装饰的组件才可以调用页面的生命周期，生命周期方法：onPageShow,onPageHide,onBackPress
// 自定义组件：@Component修饰，生命周期方法：aboutToAppear,build,onDidBuild,aboutToDisappear,后两个方法中不能更改状态变量，使用animateTo等功能
// 整体生命周期方法：aboutToAppear-> build-> onDidBuild-> onPageShow-> onPageHide-> aboutToDisappear
// 组件MyComponent包含一个Child组件其生命周期流程：aboutToAppear --> MyComponent build --> MyComponent onDidBuild--> Child aboutToAppear --> Child build --> Child onDidBuild --> Index onPageShow
// 组件删除：先调用父组件aboutToDisappear,再调用子组件aboutToDisappear
// 退出应用：执行Index onPageHide --> MyComponent aboutToDisappear --> Child aboutToDisappear
@Entry({ routeName: '路由名字' })
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
          Parent1()
          AnimatablePropertyExample()
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
      }.width('100%')
    }
  }
}

@Component
struct ChildItem {
  @Prop item: string;

  build() {
    Text(this.item).fontSize(25)
  }
}

@Component
struct HelloComponent {
  @State message: string = 'Hello,World';

  build() {
    Row() {
      Text(this.message)
    }
  }
}

class HelloComponentParam {
  message: string = ""
}

// 自定义组件不能有继承关系，可以省略new
// @Component仅能装饰struct,有一个可选参数，是否开启组件冻结
@Reusable
  // 组件树上被移除时，会被放入复用缓存中，下次新建节点会复用
@Component({ freezeWhenInactive: true })
  // 冻结功能，自定义组件处于非激活状态时，状态变量将不响应更新，即@Watch不会调用，使用场景支持页面路由，退到后台运行时无法被冻结，不可见页面A状态更新，不会触发页面A刷新
struct ParentComponent {
  param: HelloComponentParam = { message: 'Hello,World' }

  aboutToReuse(params: Record<string, ESObject>) {
    // 当自定义组件从复用缓存中重新加入节点树时，触发aboutToReuse生命周期回调，并将组件的构造参数传递给aboutToReuse
    // reuseId划分组件的复用组，只有一个复用组件可以不用设置reuseId,
  }

  @Builder
  ddd() {

  }

  textValue(): string {
    return 'ddd';
  }

  // @Entry装饰的自定义组件，build函数下的根结点唯一且必要，且必须为容器组件，其中ForEach禁止作为根节点
  // @Component装饰的自定义组件，build函数下的根节点唯一且必要，可以为非容器组件，其中ForEach禁止作为根节点
  build() {
    // 不允许声明本地变量
    // 不允许使用console.info
    // 不允许调用没有用@Builder装饰的方法，允许系统组件的参数是TS方法的返回值
    // 不允许使用switch
    // 不允许使用表达式
    // 不允许直接改变状态变量Text(this.count++)，可能会导致循环渲染，sort().filter()和filter().sort()区别是前者会返回一个新数组
    Column() {
      // 调用要加this
      this.ddd()
      // 参数可以为调用TS方法的返回值
      Text(this.textValue())
      HelloComponent(this.param).reuseId('child');
    }
  }

  runPromise() {
    // 异步并发promise 方式
    let promise: Promise<number> = new Promise((resolve: Function, reject: Function) => {
      setTimeout(() => {
        const randomNumber: number = Math.random();
        if (randomNumber > 0.5) {
          resolve(randomNumber);
        } else {
          reject(new Error('Random number is too small'));
        }
      }, 1000)
    })

    promise.then((result: number) => {
      console.info('Random number is' + result);
    }).catch((error: BusinessError) => {
      console.error(error.message);
    })
  }

  // 异步并发async/await
  // async函数返回一个Promise对象
  async myAsyncFunction(): Promise<String> {
    const result: string = await new Promise((resolve: Function, reject: Function) => {
      setTimeout(() => {
        resolve("Hello,world");
      }, 3000)
    });
    console.info(result);
    return result;
    // return 'dd';
  }
}

@Component
struct CustomLayout {
  result: SizeResult = {
    width: 0,
    height: 0
  };

  @Builder
  doNothingBuilder() {
  };

  @BuilderParam builder: () => void = this.doNothingBuilder

  build() {
    this.builder()
  }

  // 第一步：计算各子组件的大小
  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Measurable[], constraint: ConstraintSizeOptions): SizeResult {
    let size = 100;
    children.forEach((child) => {
      let result: MeasureResult = child.measure({
        minHeight: size,
        minWidth: size,
        maxWidth: size,
        maxHeight: size
      })
      size += result.width / 2;
    })
    this.result.width = 100;
    this.result.height = 400;
    return this.result;
  }

  // 第二步：放置各子组件的位置
  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Array<Layoutable>, constraint: ConstraintSizeOptions) {
    let startPos = 300;
    children.forEach((child) => {
      let pos = startPos - child.measureResult.height;
      child.layout({ x: pos, y: pos })
    })
  }

  @Builder
  overBuilder() {

  }
}

class Tmp {
  paramA1: string = ''
}

@Builder
function overBuilder(params: Tmp) {
  Row() {
    // 按引用传递参数，参数是状态变量，且状态变量改变会引起@Builder方法内部UI刷新
    Text(`1-UseStateVarByReference: ${params.paramA1} `)
    HelloComponent({ message: params.paramA1 })
  }
}

// 多层@Builder嵌套使用$$
@Builder
function overBuilder2($$: Tmp) {
  Row() {
    Text(`2-UseStateVarByReference: ${$$.paramA1} `)
    // 按引用传递参数，如果在@Builder方法内部调用自定义组件，ArkUI提供$$作为按引用传递参数的范式
    HelloComponent({ message: $$.paramA1 })
  }
}

@Builder
// 按值传递，状态变化不会引起@Builder方法内UI刷新
function overBuilder3(message: string) {
  Row() {
    Text(`3-UseStateVarByReference: ${message} `)
    HelloComponent({ message: message })
  }
}


// 调用@Builder装饰的函数默认按值传递，当传递的参数为状态变量时，状态变量的改变不会引起@Builder方法内UI刷新，当使用状态变量时，推荐使用按引用传递
@Component
struct Parent1 {
  @State label: string = 'Hello';

  build() {
    Column() {
      overBuilder({ paramA1: this.label })
      overBuilder2({ paramA1: this.label })
      overBuilder3(this.label)
      Button('Click me' + this.label).onClick(() => {
        this.label = 'ArkUI';
      })
    }
  }
}

@Builder
function overBuilder4() {
}

@Component
struct Child1 {
  @Builder
  doNothingBuilder() {
  };

  // 使用自定义组件的自定义构建函数初始化@BuilderParam
  @BuilderParam customBuilderParam: () => void = this.doNothingBuilder;
  // 使用全局自定义构建函数初始化@BuilderParam
  @BuilderParam customOverBuilderParam: () => void = overBuilder4;

  build() {

  }
}

@Component
struct Child {
  @Builder
  customBuilder() {
  }

  // 使用父组件@Builder装饰的方法初始化子组件@BuilderParam
  @BuilderParam customBuilderParam: () => void = this.customBuilder;

  build() {
    Column() {
      this.customBuilderParam()
    }
  }
}

@Component
struct Parent2 {
  @Builder
  componentBuilder() {
    Text(`Parent builder `)
  }

  build() {
    Column() {
      Child({ customBuilderParam: this.componentBuilder })
    }
  }
}

@Component
struct Child3 {
  label: string = `Child`

  @Builder
  customBuilder() {
  }

  @Builder
  customChangeThisBuilder() {
  }

  @BuilderParam customBuilderParam: () => void = this.customBuilder;
  @BuilderParam customChangeThisBuilderParam: () => void = this.customChangeThisBuilder;

  build() {
    Column() {
      this.customBuilderParam()
      this.customChangeThisBuilderParam()
    }
  }
}

@Component
struct Parent3 {
  label: string = `Parent`

  @Builder
  componentBuilder() {
    Text(`${this.label}`).globalFancy()
  }

  build() {
    Column() {
      // stateStyles 多态样式
      Button('Button1').stateStyles({
        focused:{
          .backgroundColor(Color.Pink)
        },
        pressed:{

        },
        normal:{

        },
        disabled:{

        },
        selected:{

        }
      })
      this.componentBuilder()
      Child3({
        customBuilderParam: this.componentBuilder, customChangeThisBuilderParam: (): void => {
          this.componentBuilder()
        }
      })
    }
  }
}

//wrapBuilder:封装全局@Builder

//@Styles提炼公共样式，支持通用属性和通用事件，不支持参数，全局定义需要加function关键字，组件内定义不需要添加,只能在文件内使用，不支持export
//组件内优先级高于全局
@Styles
function globalFancy() {
  .width('100%')
}

//@Extend 定义扩展组件样式，仅支持在全局定义，支持参数，不支持在组件内部定义,支持封装指定组件的私有属性，私有事件，和自身定义的全局方法
@Extend(Text)
function fancy(fontSize: number, onClick: () => void) {
  .fontColor(Color.Red)
  .fontSize(fontSize)
  .onClick(onClick)
}

// 实现动画效果
//@AnimatableExtend 定义可动画属性，常见height,width,backgroundColor,translate属性
@AnimatableExtend(Text) function animatableFontSize(size: number) {
  .fontSize(size)
}

@Component
struct AnimatablePropertyExample {
  @State fontSize: number = 20
  build() {
    Column() {
      Text("AnimatableProperty")
        .animatableFontSize(this.fontSize)
        .animation({duration: 1000, curve: "ease"})
      Button("Play")
        .onClick(() => {
          this.fontSize = this.fontSize == 20 ? 36 : 20
        })
    }.width("100%")
    .padding(10)
  }
}

//@Require 校验构造参数，使用@Require修饰变量时，必须构造时传参
//@Require装饰器仅用于装饰struct内的@Prop、@State、@Provide、@BuilderParam和普通变量(无状态装饰器修饰的变量)
