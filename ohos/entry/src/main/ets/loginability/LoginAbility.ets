import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

export default class LoginAbility extends UIAbility {
  para: Record<string, number> = {
    'PropA': 47
  };
  storage: LocalStorage = new LocalStorage(this.para);

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {

    let window = windowStage.getMainWindow()
    window.then(window => {
      let uiContext = window.getUIContext()
      uiContext.runScopedTask(() => {
        //Environment和UIContext相关联，需要在UIContext明确的时候才可以调用
        Environment.envProp('languageCode', 'zh_TW')
      })
    })

    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    //将LocalStorage实例从UIAbility共享到一个或多个视图
    //在UI页面通过getShared接口获取通过loadContent共享的LocalStorage实例
    windowStage.loadContent('pages/Login', this.storage, (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      // 最早和UI关联的时机，早于该时机调用会导致持久化失败
      // 如有本地有aProp，不会设置47，会取上一次存储的值，否则会设置47
      // 1.先在PersistentStorage中查询是否存在aProp，如果不存，则在AppStorage中查询是否存在aProp,如果不存在，则在AppStorage中创建aProp属性，并初始化默认值47，
      // 2.然后PersistentStorage将aProp和47写入磁盘，AppStorage中aProp对应的值和其后续的更改将被持久化
      // 3.在Index组件中创建的状态变量@StorageLink('aProp) aProp和AppStorage中的'aProp'双向绑定，在创建过程中会在AppStorage中查找aProp
      PersistentStorage.persistProp('aProp', 47);
      let aProp = AppStorage.get<number>('aProp');

      // 反例获取到的值是47不是48
      // let aProp1 = AppStorage.setOrCreate('aProp', 47);
      // PersistentStorage.persistProp('aProp', 48);

      PersistentStorage.persistProp('aProp', 48);
      if (AppStorage.get<number>('aProp') as number > 50) {
        // 如果PersistentStorage存储的值超过50，设置为47
        AppStorage.setOrCreate('aProp', 47);
      }

      // null vs undefined
      //1.null表示对象为空，undefined表示缺少值
      //2.声明变量但未赋值时，变量值为undefined，表示空值时，是null
      //3.在比较时，null和undefined的值相等，但数据类型不同

      // 支持联合类型，null表示对象为空，undefined表示缺少值，
      PersistentStorage.persistProp("P", undefined);
      PersistentStorage.persistProp("P1", null);

      // 设备语言code存入
      // 更新链：Environment --> AppStorage -->Component
      Environment.envProp('languageCode', 'en')

      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
