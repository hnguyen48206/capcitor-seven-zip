import { WebPlugin } from '@capacitor/core';

import type { SevenzipPlugin, SevenzipOtions, WatchProgressCallback, CallbackID, ClearWatchOptions} from './definitions';

export class SevenzipWeb extends WebPlugin implements SevenzipPlugin {
   // eslint-disable-next-line @typescript-eslint/no-unused-vars
   clearProgressWatch(_options: ClearWatchOptions): Promise<void> {
     throw new Error('Method not implemented.');
   }

   async unzip(
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    _options: SevenzipOtions,
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    _callback: WatchProgressCallback,
  ): Promise<CallbackID> {
   
    return ``;
  }
}
