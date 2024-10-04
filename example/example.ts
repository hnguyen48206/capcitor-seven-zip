import { Component, NgZone } from '@angular/core';
import { FilePicker, PickedFile } from '@capawesome/capacitor-file-picker';
import { Sevenzip } from 'sevenzip';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {
  currentProgress: number = 0;
  currentSrc = '';
  currentOut = '';
  callbackID = '';
  constructor(private _ngZone: NgZone) {
  }
  async pickFiles() {
    let result = await FilePicker.pickFiles({
      limit: 1,
    });
    // file:///Users/ezecar/Library/Developer/CoreSimulator/Devices/205B1CA6-1241-4946-8B56-61C02DC919AE/data/Containers/Data/Application/0F09CF4F-7B06-41AD-A646-F294E0A3A574/Library/Caches/BC1C170C-E5B6-465B-8FF0-397675CF376E/sample1.7z
    console.log(result);
    if (result) {
      let path: PickedFile = result.files[0];
      console.log('Picked File', path.path);
      this.currentSrc = path.path || '';
    }
  }
  async startUnzip() {
    this.currentProgress = 0;
    let eventListener = null;

    // ------------------------------------ Event Listener ---------------------------------------

    // try {
    //   eventListener = await (Sevenzip as any).addListener(
    //     'progressEvent',
    //     (eventData: any) => {
    //       // console.log(eventData.fileName + ' / ' + eventData.progress);

    //       this._ngZone.run(() => {
    //         this.currentProgress = Math.floor(eventData.progress.toFixed(2) * 100)
    //         console.log(this.currentProgress)
    //     });

    //     }
    //   );

    //   let res = await Sevenzip.unzip({
    //     fileURL: this.currentSrc || '',
    //   });

    //   console.log('Unzip Result: ', res)
    //   eventListener.remove();

    // } catch (error) {
    //   console.log(error);
    //   eventListener.remove();
    // }

    // ------------------------------------ Callback ---------------------------------------

    try {
      //password và outputDir là optional. Mặc định, file giải nén sẽ lưu ở thư mục Document của App (trên iOS))
      //nếu truyền outputDir thì sẽ là subpath của Document, ví dụ '/subthumuc/thumuc1'
      //lưu ý là subDir này cần tạo trước và bảo đảm có tồn tại trước khi truyền vào unzip
      let cID = await Sevenzip.unzip(
        {
          fileURL: this.currentSrc || '',
          outputDir: '/abc',
        },
        (data: any) => {
          //data là object { progress: number, fileName: string} progress là số double tiến độ, fileName là tên của file trong archive đang được giải nén
          // console.log('callback data', data);
          if (data?.progress) {
            this._ngZone.run(() => {
              this.currentProgress = Math.floor(data.progress.toFixed(2) * 100);
              //Kiểm tra nếu progress là 100 thì chủ động cancel callback
              if (this.currentProgress == 100)
                Sevenzip.clearProgressWatch({
                  id: this.callbackID,
                });
            });
          }
        },
      );

      //Lưu lại callbackID để cancel
      this.callbackID = cID;
      console.log('callbackID', this.callbackID);
    } catch (error) {
      console.log(error);
    }
  }
}
