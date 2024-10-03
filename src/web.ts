import { WebPlugin } from '@capacitor/core';

import type { SevenzipPlugin, SevenzipOtions } from './definitions';

export class SevenzipWeb extends WebPlugin implements SevenzipPlugin {
  async unzip(option: SevenzipOtions): Promise<boolean> {
    console.log(option);
    return true;
   }
}
