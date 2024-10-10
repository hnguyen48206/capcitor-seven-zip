import Foundation
import Capacitor
import PLzmaSDK
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
var globalCall: CAPPluginCall? = nil
var finalOutputDir = ""

@objc(SevenzipPlugin)
public class SevenzipPlugin: CAPPlugin, CAPBridgedPlugin, DecoderDelegate {
    func deleteFile(at path: String) {
    print("File to delete: \(path) -----------------------------")

    let fileManager = FileManager.default
    let fileURL = URL(fileURLWithPath: path)

    do {
    if fileManager.fileExists(atPath: path) {
    try fileManager.removeItem(at: fileURL)
    print("File deleted successfully.")
    } else {
    print("File does not exist at path: \(path)")
    }
    } catch let error as NSError {
    print("Error deleting file: \(error.localizedDescription)")
    }
    }

    public func decoder(decoder: PLzmaSDK.Decoder, path: String, progress: Double) {
        //        print("Reader progress: \(progress) %")
        let name = finalOutputDir + "/" + path;
        globalCall?.resolve(
          ["fileName":name, "progress":progress]
        )
        self.notifyListeners("progressEvent", data: ["fileName": name, "progress":progress])
    }
    
    public let identifier = "SevenzipPlugin"
    public let jsName = "Sevenzip"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "unzip", returnType: CAPPluginReturnCallback),
        CAPPluginMethod(name: "clearProgressWatch", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getDefaultPath", returnType: CAPPluginReturnPromise)

    ]

    private let implementation = Sevenzip()
    private var callQueue = [String]()
    @objc func unzip(_ call: CAPPluginCall) {
        call.keepAlive = true
        callQueue.append(call.callbackId)
        globalCall = call
        let rmSourceFile = call.getBool("rmSourceFile") ?? false
        var filePath = call.getString("fileURL") ?? ""
        var outputDir = call.getString("outputDir") ?? ""
        var password = call.getString("password") ?? ""
        filePath = filePath.replacingOccurrences(of: "file://", with: "")
        
        do {
            let outputURL = (URL(fileURLWithPath: filePath)).deletingLastPathComponent().absoluteString
            var documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            print("Document Application directory: \(documentDir)")
          
            if(outputDir != "" && documentDir != nil)
            {
                outputDir = documentDir + outputDir
            }
            else
            {
                outputDir = documentDir
            }
            finalOutputDir = outputDir
            
            let archivePath = try Path(filePath)
            let archivePathInStream = try InStream(path: archivePath)
            let decoder = try Decoder(stream: archivePathInStream, fileType: .sevenZ, delegate: self)
            if(password != "")
            {
                try decoder.setPassword(password)
            }
           
            let opened = try decoder.open()
            print("Input: \(filePath)  Output:\(finalOutputDir)")
            print("Root Application directory: \(NSHomeDirectory())")
            let extracted = try decoder.extract(to: Path(((outputDir != "") ? outputDir : documentDir) ?? NSHomeDirectory()))
            
            // call.keepAlive = false

            if let saved_call = bridge?.savedCall(withID: call.callbackId) {
                           bridge?.releaseCall(call)
           }
            callQueue.removeAll(where: { $0 == call.callbackId})
            if(rmSourceFile)
            {
                deleteFile(at: filePath)
            }
        } catch {
            let description = "\(error)"
            print("Exception: \(description)")
            call.reject(description)

            if let saved_call = bridge?.savedCall(withID: call.callbackId) {
                           bridge?.releaseCall(call)
           }
            callQueue.removeAll(where: { $0 == call.callbackId})
        }
    }
    
    
    @objc func clearProgressWatch(_ call: CAPPluginCall) {
        guard let callbackId = call.getString("id") else {
            call.reject("Watch call id must be provided")
            return
        }

        if let savedCall = bridge?.savedCall(withID: callbackId) {
            bridge?.releaseCall(savedCall)
        }

        callQueue.removeAll(where: { $0 == callbackId})
        call.resolve()
    }

    @objc func getDefaultPath(_ call: CAPPluginCall) {
        call.resolve(["path":NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSHomeDirectory()])
    }
}

