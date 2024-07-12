/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { FlutterEntry, FlutterPage, FlutterView, Log } from '@ohos/flutter_ohos';
import router from '@ohos.router';

@Entry
@Component
struct Page1 {
  private flutterEntry: FlutterEntry | null = null;
  private flutterView?: FlutterView

  aboutToAppear(): void {
    Log.d("Flutter", "Page1 aboutToAppear");
    this.flutterEntry = new FlutterEntry(getContext(this));
    this.flutterEntry.aboutToAppear();
    this.flutterView = this.flutterEntry.getFlutterView();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      FlutterPage({ viewId: this.flutterView?.getId() })
      Text('使用FlutterEntry和FlutterView').margin(30)
    }
  }

  onBackPress(): boolean {
    router.back()
    return true
  }
}
