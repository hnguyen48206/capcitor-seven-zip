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
