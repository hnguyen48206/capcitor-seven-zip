export interface SevenzipPlugin {
  unzip(options: SevenzipOtions): Promise<boolean>;
}
//password và outputDir là optional. Mặc định, file giải nén sẽ lưu ở thư mục Document của App (trên iOS))
//nếu truyền outputDir thì sẽ là subpath của Document, ví dụ '/subthumuc/thumuc1'
//lưu ý là subDir này cần tạo trước và bảo đảm có tồn tại trước khi truyền vào unzip
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