# Flutter嵌入Ohos（add-to-app）示例 

### 环境配置
- https://gitee.com/openharmony-sig/flutter_engine
- https://gitee.com/openharmony-sig/flutter_flutter (dev分支)
- https://gitee.com/openharmony-sig/flutter_packages

### 学习资料
- https://www.arkui.club/chapter7/7_4_navigator.html (ArkUI实战)
- https://developer.huawei.com/consumer/cn/training/ (官方课程教程)
- https://gitee.com/openharmony-sig/flutter_samples/tree/master/ohos/docs (官方demo和文档)
- https://wolfx.cn/docs/frontend/ohos/007-flutter-plugin （Flutter插件开发）
- https://www.yuque.com/xuyisheng/ot9ge6/hg11fs9hnlcnauct (Flutter鸿蒙混编)
- https://www.cnblogs.com/shudaoshan/p/18084271 （核心知识点62实战）

### 三方仓库
- https://ohpm.openharmony.cn/#/cn/home

### 官方资料
- https://developer.huawei.com/consumer/cn/develop/
- https://developer.huawei.com/consumer/cn/samples/ (纯鸿蒙samples)

### 笔记
#### 1.1 管理组件拥有的状态
- @State 可以作为其子组件单向和双向同步的数据源，当其数值改变时，回引起相关组件的渲染刷新 ，@State父组件数据源+@Prop子组件数据源（单向同步）,与@Link,@ObjectLink装饰变量建立双向数据同步
  观察范围：
  1。装饰基础数据类型boolean,string,number类型时，可以观察到数值的变化
  2。装饰class或者Object时，可以观察到自身的赋值变化和其属性的赋值变化，即Object.keys(observedObject)返回的所有属性,嵌套属性观察不到
  3。装饰array时，可以观察到数组本身的赋值和添加，删除，更新，数组项中属性的赋值观察不到
  4。装饰Map/Set，可以观察到赋值，add,clear,delete
  5。支持联合类型

- @Prop 修饰的变量可以和父组件建立单向同步关系，修改不会同步回父组件，@State父组件数据源+@Link子组件数据源（双向同步）
  1。装饰变量会进行深拷贝，除了基本类型，Map,Set,Data,Array外都会丢失类型
  2。不能在@Entry装饰的自定义组件中使用
  3。装饰的数据更新依赖其所属自定义组件的重新渲染，所以在应用进入后台后，@Prop无法刷新，推荐使用@Link代替

- @Link 装饰的变量可以和父组件建立双向同步关系，子组件中@Link装饰的变量修改会同步给父组件中建立双向数据绑定的数据源，父组件的更新也会同步给@Link装饰的变量

- @Provide/@Consume 装饰的变量用于跨组件层级（多层组件）同步状态变量，@State+@Provide组合使用
  1。@Provide装饰的变量在祖先组件中，@Consume装饰的变量在后代组件中
  2。@Provide装饰的变量自动对其所有后代组件可用，后台通过使用@Consume去获取@Provide提供的变量，建立双向数据同步，与@State/@Link不同的是，前者可以在多层级的父子组件之间传递，不用显示传递参数

- @Observed 多层嵌套场景，需要和@ObjectLink、@Prop联用

- @ObjectLink 必须为被@Observed装饰的class实例，必须指定类型，不支持简单类型，装饰变量是只读的，不能被改变

- @Watch 关注某个状态变量值是否改变，在自定义方法中关注而不是build方法中，@Watch('XXXMethod') 修饰状态变量与@Prop或者@Link结合使用

- $$运算符 内置组件双向同步，提供TS变量的引用，使得TS变量和系统内置组件的内部状态保持同步

- @Track 应用于class对象的属性级更新，@Track装饰的属性变化时，只会触发该属性关联的UI更新，避免冗余刷新,装饰class对象的非静态成员属性

常用组件间数据同步组合：@State和@Provide装饰的变量以及LocalStorage和AppStorage都是顶层数据源，其余装饰器都是与数据源做同步的数据
1。@State（父) + @Prop（子）单向同步,子改变不同步父, 组件级别的共享，通过命名参数机制传递，表示传递层级是父子之间的传递，
2。@State（父）+ @Link（子) 双向同步，
3。@State（父数据源）+ @ObjectLink（子变量) +@Observed(修饰class) 双向同步
4。@Provide (父) + @Consume（子）跨组件不传递参数，后代组件双向数据同步，组件级别共享可以通过key@Consume绑定，因为不用传递参数，实现多层级的数据共享，共享范围大于@State，

#### 1.2 管理应用拥有的状态

- LocalStorage:页面级UI状态存储，用于UIAbility内，页面间的状态共享，可以通过@Entry在当前组件树上共享实例
  1.@LocalStorageProp：@LocalStorageProp装饰的变量与LocalStorage中给定属性建立单向同步关系
  2.@LocalStorageLink：@LocalStorageLink装饰的变量与LocalStorage中给定属性建立双向同步关系

- AppStorage:特殊的单例LocalStorage对象，由UI框架在应用程序启动时创建，为应用程序UI状态属性提供中央存储
  1.持久化数据PersistentStorage和环境变量Environment都是通过AppStorage中转，才可以和UI交互
  2.主线程内多个UIAbility实例间的状态共享
  3.UI中使用需要配合@StorageProp和@StorageLink使用

- PersistentStorage：持久化存储UI状态，通常和AppStorage配合使用,UI和业务逻辑不直接访问PersistentStorage中的属性，所有属性访问都是对AppStorage的访问，
  1.AppStorage中的更改会自动同步到PersistentStorage,PersistentStorage和AppStorage中的属性建立双向同步
  2.不支持嵌套对象，对象数组，对象属性
  3.存储小于2kb数据，写入操作是同步的，在UI线程执行影响UI渲染性能，大量数据存储建议使用数据库

- Environment：应用程序运行的设备的环境参数，环境参数会同步到AppStorage中,使用场景：多语言，暗黑模式

#### 2 渲染控制
- if/else：条件渲染

- ForEach：循环渲染，使用场景：
1。数据源不变，
2。数据源数组项发生变化，
3。数据源数组项子属性变化，建议：避免最终键值生成规则包含index（可能导致重新渲染），建议使用唯一id作为键值，不推荐第三个参数KeyGenerator函数处于缺省状态，

- LazyForEach：数据懒加载，必须在容器组件内使用，仅有List,Grid,Swiper和WaterFlow支持懒加载（可配置cachedCount属性）其他组件仍然是一次性加载所有的数据，
必须使用DataChangeListener对象进行更新，第一个参数dataSource使用状态变量时，状态变量改变不会触发LazyForEach的UI刷新，
状态管理：@Observed（装饰类）和@ObjectLink（装饰变量，变量对象类是用前者进行装饰的）装饰器用于在涉及嵌套对象或者数组的场景中进行双向数据同步

- Repeat：循环渲染（推荐）基于数组类型数据进行循环渲染，需要与容器组件配合使用，且接口返回的组件应当是允许包含在Repeat父容器组件中的子组件，
与ForEach相比优点：一是优化了部分更新场景下的渲染性能，二是组件生成函数的索引index由框架侧维护
若上次的键值有不重复的且本次有新的键值生成需要新建子组件时，Repeat会复用上次多余的子组件并更新item和index索引，（复用UI组件）
数据源数组项子属性变化，数组数据为对象类型，修改对象的某个属性，无法触发Repeat重新渲染，需要结合@ObservedV2和@Trace装饰器使用进行深度观测，
- ContentSlot：混合开发，渲染并管理Native层使用C-API创建的组件，支持混合模式开发，当容器是ArkTS组件，子组件在Native侧创建时，推荐使用ContentSlot占位组件