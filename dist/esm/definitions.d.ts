export interface SevenzipPlugin {
    unzip(options: SevenzipOtions, callback: WatchProgressCallback): Promise<CallbackID>;
    clearProgressWatch(options: ClearWatchOptions): Promise<void>;
    getDefaultPath(): Promise<any>;
}
export interface ClearWatchOptions {
    id: CallbackID;
}
export declare type WatchProgressCallback = (progress: number | 0, fileName: string | '', err?: any) => void;
export interface SevenzipOtions {
    fileURL: string;
    password?: string;
    outputDir?: string;
    rmSourceFile?: boolean;
}
export declare type CallbackID = string;
