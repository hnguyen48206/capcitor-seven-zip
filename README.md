# sevenzip

capcitor plugin to unzip 7z format

## Install

```bash
npm i sevenzip
npx cap sync
```

## API

<docgen-index>

* [`unzip(...)`](#unzip)
* [`clearProgressWatch(...)`](#clearprogresswatch)
* [`getDefaultPath()`](#getdefaultpath)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### unzip(...)

```typescript
unzip(options: SevenzipOtions, callback: WatchProgressCallback) => Promise<CallbackID>
```

| Param          | Type                                                                    |
| -------------- | ----------------------------------------------------------------------- |
| **`options`**  | <code><a href="#sevenzipotions">SevenzipOtions</a></code>               |
| **`callback`** | <code><a href="#watchprogresscallback">WatchProgressCallback</a></code> |

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### clearProgressWatch(...)

```typescript
clearProgressWatch(options: ClearWatchOptions) => Promise<void>
```

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#clearwatchoptions">ClearWatchOptions</a></code> |

--------------------


### getDefaultPath()

```typescript
getDefaultPath() => Promise<any>
```

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### Interfaces


#### SevenzipOtions

| Prop                          | Type                 |
| ----------------------------- | -------------------- |
| **`fileURL`**                 | <code>string</code>  |
| **`password`**                | <code>string</code>  |
| **`outputDir`**               | <code>string</code>  |
| **`rmSourceFile`**            | <code>boolean</code> |
| **`isLocalAsset`**            | <code>boolean</code> |
| **`sqlLiteDBLocationConfig`** | <code>string</code>  |


#### ClearWatchOptions

| Prop     | Type                                              |
| -------- | ------------------------------------------------- |
| **`id`** | <code><a href="#callbackid">CallbackID</a></code> |


### Type Aliases


#### WatchProgressCallback

<code>(progress: number, fileName: string, err?: any): void</code>


#### CallbackID

<code>string</code>

</docgen-api>


# NOTE:

(*) Trường hợp sử dụng lib như một thư viện giải nén 7z generic (sử dụng file trong FileSystem)

- fileURL là field bắt buộc, ở dạng absolute path.  
- password, outputDir, rmSourceFile là optional. Mặc định, file giải nén sẽ lưu ở thư mục Document của App (trên iOS) -- Đây là thư mục public của app và sẽ bị xoá khi uninstall app. Trên Android, thư mục mặc định là thư mục Document của ExternalStorage -- Đây là thư mục public của device và không bị xoá khi uninstall app. (khi nhận info từ callback hoặc progressEvent thì fileName sẽ thể hiện absolute path nơi file giải nén ra được lưu)
- Nếu truyền outputDir thì sẽ là subpath của path mặc định, ví dụ '/subthumuc/thumuc1' (lưu ý cần có / ở đầu).
- Lưu ý là subDir này cần tạo trước và bảo đảm có tồn tại trước khi truyền vào unzip.
- Nếu truyền rmSourceFile là True thì sẽ xoá file archive gốc sau khi bung nén. Tuy nhiên, chỉ hoạt động trên iOS do thư mục giải nén trên Android là public, app ko có quyền xoá file trừ khi dev thành file manager (rắc rối với app store)
- isLocalAsset và sqlLiteDBLocationConfig không sử dụng.

(*) Trường hợp sử dụng nội bộ (cần truyền biến ***isLocalAsset*** là TRUE)

- Lúc này fileURL sẽ là relative path của file archive trong asset folder. Ví dụ, ở project ionic đang lưu là assets/data/test.7z (trong đó assests là root path) thì truyền vào gía trị là 'data/test.7z'
- rmSourceFile không hoạt động vì lúc này file gốc là asset binary của app (read-only)
- outputDir không hoạt động vì không custom thư mục này (trên Android).
- Đối với iOS, tham số ***sqlLiteDBLocationConfig*** cần truyền vào giá trị như giá trị đã cấu hình cho ***iosDatabaseLocation*** của plugin SQLLite. Lưu ý là thư mục cấu hình này ***iosDatabaseLocation*** cần bảo đảm đã tồn tại trước khi gọi unzip. 
- Thư mục giải nén ra trên Android là thư mục ko thể truy cập bằng FileSystem. Là thư mục DB dành riêng của app. Chỉ có thể truy cập bằng DB apis (hoặc thư viện như sql lite viết sẵn)

(*) Trên Android, cần cấp quyền READ_EXTERNAL_STORAGE va WRITE_EXTERNAL_STORAGE trong permission. Ngoài ra có thể request permission ở runtime,
bảo đảm đã có đủ quyền trước khi chạy unzip. Đồng thời trong tag "application" file Manifest, thêm vào 2 thuộc tính  android:largeHeap="true" (cho phép xử lý dung lượng lớn)
android:requestLegacyExternalStorage="true" (cấp quyền truy cập external trên Android 10)

(*) Hỗ trợ iOS 13+ và Android 7+