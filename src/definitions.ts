export interface SevenzipPlugin {
  unzip(options: SevenzipOtions): Promise<boolean>;
}
export interface SevenzipOtions {
  fileURL: string;
  password?: string;
  outputDir?: string;
}


// export type CallbackID = string;

// export interface MyData {
//   data: string;
// }

// export type MyPluginCallback = (message: MyData | null, err?: any) => void;

// export interface SevenzipPlugin {
//   unzip(options: SevenzipOtions, callback: MyPluginCallback): Promise<CallbackID>;
// }