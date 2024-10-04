import { WebPlugin } from '@capacitor/core';
import type { SevenzipPlugin, SevenzipOtions, WatchProgressCallback, CallbackID, ClearWatchOptions } from './definitions';
export declare class SevenzipWeb extends WebPlugin implements SevenzipPlugin {
    clearProgressWatch(_options: ClearWatchOptions): Promise<void>;
    unzip(_options: SevenzipOtions, _callback: WatchProgressCallback): Promise<CallbackID>;
}
