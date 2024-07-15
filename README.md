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
#### 1。渲染控制
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