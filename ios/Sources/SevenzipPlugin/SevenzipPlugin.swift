import Foundation
import Capacitor
import PLzmaSDK
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SevenzipPlugin)
public class SevenzipPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SevenzipPlugin"
    public let jsName = "Sevenzip"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "unzip", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = Sevenzip()

    @objc func unzip(_ call: CAPPluginCall) {
    let filePath = call.getString("fileURL") ?? ""
    // return

//        let fileURL = NSURL(fileURLWithPath: filePath)
//    let archive = LzmaSDKObjCReader(fileURL: fileURL, andType: LzmaSDKObjCFileType7z)

//    do {
//        try archive.open()
//        for item in archive.iterate() {
//        if item.isDirectory {
//         continue
//        } 
//        let outputURL = fileURL.deletingLastPathComponent().appendingPathComponent(item.fileName)
//        try archive.extract(item, to: outputURL)
//        }
//        call.resolve(true)
//        } catch {
//     //    call.reject("Failed to unzip file: \(error.localizedDescription)")
//        call.reject(false)
//        }


do {
    let outputURL = (URL(fileURLWithPath: filePath)).deletingLastPathComponent().absoluteString

    let archivePath = try Path(filePath)
    let archivePathInStream = try InStream(path: archivePath)
    let decoder = try Decoder(stream: archivePathInStream /* archivePathInStream */, fileType: .sevenZ) 
    let opened = try decoder.open()
    let extracted = try decoder.extract(to: Path(outputURL))
    call.resolve([
            "value": true
        ])
} catch {
    print("Exception: \(error)")
    call.reject("Failed to Unzip")
}

   }






}

