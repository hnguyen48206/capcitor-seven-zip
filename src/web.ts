import { WebPlugin } from '@capacitor/core';

import type { SevenzipPlugin, SevenzipOtions} from './definitions';

export class SevenzipWeb extends WebPlugin implements SevenzipPlugin {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars, @typescript-eslint/ban-types
  // unzip(option: SevenzipOtions, progress?: MyPluginCallback): void {
  //   console.log(option);
  // }
  async unzip(option: SevenzipOtions): Promise<boolean> {
    console.log(option);
    return true;
   }
}
