export interface SevenzipPlugin {
  unzip(options: SevenzipOtions): Promise<boolean>;
}
export interface SevenzipOtions {
  fileURL: string;
}
