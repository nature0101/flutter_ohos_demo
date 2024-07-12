import {
  AbilityAware,
  AbilityPluginBinding,
  Any,
  BasicMessageChannel,
  EventChannel,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import { common, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import router from '@ohos.router'

export default class NativePlugin implements FlutterPlugin, AbilityAware {
  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.ability = binding.getAbility();

  }

  onDetachedFromAbility(): void {
    this.ability = null;
  }

  private channel?: MethodChannel;
  private basicChannel?: BasicMessageChannel<Any>;
  private eventChannel?: EventChannel;
  private eventSink?: EventSink;
  private ability: UIAbility | null = null;

  getUniqueClassName(): string {
    return "NativePlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter.demo.dev/native");
    this.channel.setMethodCallHandler({
      onMethodCall(call: MethodCall, result: MethodResult) {
        switch (call.method) {
          case "openNative":
          // 方式一 打开page
          // router.pushUrl({url:'pages/Login'})
          // return;

          // 方式二 打开ability
          // 怎么给ability传递参数
          // 打开native page
            let want: Want = {
              bundleName: 'com.example.flutter_demo',
              abilityName: 'LoginAbility',
              uri: 'page/Login', // 跳转到Ability不同的page
            };
            let context = getContext(this.ability) as common.UIAbilityContext;
            try {
              context.startAbility(want, (err, data) => {
                if (err.code) {
                  // 处理业务逻辑错误
                  console.error(`startAbility failed, code is ${err.code}, message is ${err.message}`);
                  return;
                }
              })
            } catch (err) {
              let code = (err as BusinessError).code;
              let message = (err as BusinessError).message;
              console.error(`startAbility failed, code is ${code}, message is ${message}`);
            }
            break;
          case "getDataFromNative":
            let map = (call.args as Map<String, Object>)
            let key = map.get('key');
            result.success(key + "+ohos");
            break;
          default:
            result.notImplemented;
            break;
        }
      }
    });
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
  }
}