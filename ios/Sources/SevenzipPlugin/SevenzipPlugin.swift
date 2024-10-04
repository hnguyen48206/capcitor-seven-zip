import Foundation
import Capacitor
import PLzmaSDK
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
var globalCall: CAPPluginCall? = nil

@objc(SevenzipPlugin)
public class SevenzipPlugin: CAPPlugin, CAPBridgedPlugin, DecoderDelegate {
    public func decoder(decoder: PLzmaSDK.Decoder, path: String, progress: Double) {
        //        print("Reader progress: \(progress) %")
        // globalCall?.resolve([
        //     "value": progress
        // ])
        self.notifyListeners("progressEvent", data: ["fileName":path, "progress":progress])
    }
    
    public let identifier = "SevenzipPlugin"
    public let jsName = "Sevenzip"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "unzip", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = Sevenzip()
    
    @objc func unzip(_ call: CAPPluginCall) {
        // call.keepAlive = true
        globalCall = call
        var filePath = call.getString("fileURL") ?? ""
        var outputDir = call.getString("outputDir") ?? ""
        var password = call.getString("password") ?? ""
        filePath = filePath.replacingOccurrences(of: "file://", with: "")
        
        do {
            let outputURL = (URL(fileURLWithPath: filePath)).deletingLastPathComponent().absoluteString
            print("Input: \(filePath)  Output:\(outputURL)")
            print("Root Application directory: \(NSHomeDirectory())")
            var documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            print("Document Application directory: \(documentDir)")
            
            let archivePath = try Path(filePath)
            let archivePathInStream = try InStream(path: archivePath)
            let decoder = try Decoder(stream: archivePathInStream, fileType: .sevenZ, delegate: self)
            
            if(password != "")
            {
                try decoder.setPassword(password)
            }
            if(outputDir != "" && documentDir != nil)
            {
                documentDir = documentDir! + outputDir
            }
            let opened = try decoder.open()
            let extracted = try decoder.extract(to: Path(((outputDir != "") ? outputDir : documentDir) ?? NSHomeDirectory()))
            
            // call.keepAlive = false
            
            call.resolve([
                "value": true
            ])
        } catch {
            print("Exception: \(error)")
            call.reject("Failed to Unzip")
        }
    }
}

