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


### Interfaces


#### SevenzipOtions

| Prop            | Type                |
| --------------- | ------------------- |
| **`fileURL`**   | <code>string</code> |
| **`password`**  | <code>string</code> |
| **`outputDir`** | <code>string</code> |


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

(*) Method unzip nhận vào 3 input:
- password và outputDir là optional. Mặc định, file giải nén sẽ lưu ở thư mục Document của App (trên iOS) -- Đây là thư mục public của app và sẽ bị xoá khi uninstall app. Trên Android, thư mục mặc định là thư mục Document của ExternalStorage -- Đây là thư mục public của device và không bị xoá khi uninstall app.
- Nếu truyền outputDir thì sẽ là subpath của path mặc định, ví dụ '/subthumuc/thumuc1' (lưu ý cần có / ở đầu).
- Lưu ý là subDir này cần tạo trước và bảo đảm có tồn tại trước khi truyền vào unzip.

(*) Trên Android, cần cấp quyền READ_EXTERNAL_STORAGE va WRITE_EXTERNAL_STORAGE trong permission. Ngoài ra có thể request permission ở runtime,
bảo đảm đã có đủ quyền trước khi chạy unzip. Đồng thời trong tag <application> file Manifest, thêm vào 2 thuộc tính  android:largeHeap="true" (cho phép xử lý dung lượng lớn)
android:requestLegacyExternalStorage="true" (cấp quyền truy cập external trên Android 10)