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

    private var hasLocalDBInit = false
    private var databaseLocation = "Documents"
    
    private let implementation = Sevenzip()
    private var callQueue = [String]()
    
    func getAssetFile(fileName: String) -> String? {
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil) else {
    print("File not found")
    return nil
    }
    print(filePath)
    return filePath
    }
    
    func setPathSuffix(sDb: String ) -> String {
        if(sDb != "")
        {
            var toDb: String = sDb
            let ext: String = ".db"
            if sDb.hasSuffix(ext) {
                if !sDb.contains("SQLite.db") {
                    toDb = sDb.prefix(sDb.count - ext.count) + "SQLite.db"
                }
            }
            return toDb
        }
        return ""
            
        }
    
    func cleanTmpFolder()
    {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory.appendingPathComponent("tmpdb", isDirectory: true)
        try? fileManager
            .contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            .forEach { file in
                try? fileManager.removeItem(atPath: file.path)
            }
    }
    func copyFromAssetToDatabase(uAsset: URL, uDb: URL) throws {
            do {

                let bRet: Bool = try copyFile(pathName: uAsset.path,
                                              toPathName: uDb.path,
                                              overwrite: true)
                print("Target Path " + uDb.absoluteString)
                if bRet {
                    return
                } else {
                    let msg = "Error: copyFile return false"
                    print("\(msg)")
                    throw UtilsFileError.copyFromAssetToDatabaseFailed(message: msg)
                }
            } catch UtilsFileError.getAssetsDatabasesPathFailed {
                let msg = "Error: getAssetsDatabasesPath Failed"
                print("\(msg)")
                throw UtilsFileError.copyFromAssetToDatabaseFailed(message: msg)
            } catch UtilsFileError.getFolderURLFailed(let message) {
                print("Error: getFolderUrl Failed \(message)")
                throw UtilsFileError.copyFromAssetToDatabaseFailed(message: message)
            } catch UtilsFileError.copyFileFailed {
                let msg = "Error: copyFile Failed"
                print("\(msg)")

                throw UtilsFileError.copyFromAssetToDatabaseFailed(message: msg)
            } catch let error {
                let msg = "Error: \(error)"
                print("\(msg)")
                throw UtilsFileError.copyFromAssetToDatabaseFailed(message: msg)
            }

        }
    @objc func unzip(_ call: CAPPluginCall) {
        call.keepAlive = true
        callQueue.append(call.callbackId)
        globalCall = call
        let isLocalAsset = call.getBool("isLocalAsset") ?? false
        let rmSourceFile = call.getBool("rmSourceFile") ?? false
        var filePath = call.getString("fileURL") ?? ""
        var outputDir = call.getString("outputDir") ?? ""
        var password = call.getString("password") ?? ""
        var sqlLiteDBLocationConfig = call.getString("sqlLiteDBLocationConfig") ?? "Documents"
        
        if(isLocalAsset)
        {
            //Init SQLLite DB Location if not
            if(!hasLocalDBInit)
            {
                databaseLocation = sqlLiteDBLocationConfig
                hasLocalDBInit = true
            }
            //Get 7z file from Asset
            if let assetPath = getAssetFile(fileName: "public/assets/" + filePath) {
            // Process the data
                print("GET ASSET FILE OK")
                print(assetPath)
                
                var url = URL.init(string: assetPath)
                let newName = setPathSuffix(sDb: url?.lastPathComponent ?? "")
                if(newName != "")
                {
                    print(newName)
                }
                //output Dir will be in tmp Directory
                var finalOutputDir = FileManager.default.temporaryDirectory.appendingPathComponent("tmpdb", isDirectory: true)
                print("Tmp Application directory: \(finalOutputDir)")

                do {
                    try FileManager.default.createDirectory(at: finalOutputDir, withIntermediateDirectories: true, attributes: nil)
                    
                    let archivePath = try Path(assetPath)
                    let archivePathInStream = try InStream(path: archivePath)
                    let decoder = try Decoder(stream: archivePathInStream, fileType: .sevenZ, delegate: self)
                    if(password != "")
                    {
                        try decoder.setPassword(password)
                    }
                    
                    let opened = try decoder.open()
                    print("Input: \(filePath)  Output:\(finalOutputDir)")
                    let extracted = try decoder.extract(to: Path(finalOutputDir.relativePath))
                    
                    // call.keepAlive = false
                    
                    if let saved_call = bridge?.savedCall(withID: call.callbackId) {
                        bridge?.releaseCall(call)
                    }
                    callQueue.removeAll(where: { $0 == call.callbackId})
                    
                    //Loop through extracted DBs and move to SQLLite Location
                    let enumerator = FileManager.default.enumerator(atPath: finalOutputDir.relativePath)
                       while let element = enumerator?.nextObject() as? String {
                           print(element)
                           if(element.hasSuffix(".db"))
                           {
                               let newName = setPathSuffix(sDb: element)
                               var uAsset = finalOutputDir
                               uAsset.appendPathComponent(element)
                               var uDb = try getFolderURL(folderPath: databaseLocation)
                                   .appendingPathComponent(newName)
                               print(uDb.absoluteString)
                               try copyFromAssetToDatabase(uAsset: uAsset, uDb: uDb)
                           }
                           
//                           if let fType = enumerator?.fileAttributes?[FileAttributeKey.type] as? FileAttributeType{
//
//                               switch fType{
//                               case .typeRegular:
//                                   print("a file")
//                               case .typeDirectory:
//                                   print("a dir")
//                               default:
//                                   print("")
//                               }
//                           }

                       }
                    //check If target Folder has the DB
                    let finalTarget = FileManager.default.enumerator(atPath: try getFolderURL(folderPath: databaseLocation).absoluteString)
                       while let element = enumerator?.nextObject() as? String {
                           print("DB. SQL Lite " + element)
                       }
                    cleanTmpFolder()
                }
                catch {
                    let description = "\(error)"
                    print("Exception: \(description)")
                    call.reject(description)

                    if let saved_call = bridge?.savedCall(withID: call.callbackId) {
                                   bridge?.releaseCall(call)
                   }
                    callQueue.removeAll(where: { $0 == call.callbackId})
                }
            } else {
            print("FAIL TO GET ASSET FILE")
            call.reject("FAIL TO GET ASSET FILE")

            if let saved_call = bridge?.savedCall(withID: call.callbackId) {
             bridge?.releaseCall(call)
            }
                callQueue.removeAll(where: { $0 == call.callbackId})
            }

            
        }
        else
        {
            do {
                filePath = filePath.replacingOccurrences(of: "file://", with: "")

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
    
    func getAssetsDatabasesPath() -> URL? {
        if let appFolder = Bundle.main.resourceURL {
            return appFolder.appendingPathComponent("public/assets/databases")
        } else {
            let errmsg = "Error: getAssetsDatabasePath did not find app folder"
            print(errmsg)
            return nil
        }
    }
    
    
    func isDirExist(dirPath: String) -> Bool {
        var isDir: ObjCBool = true
        let fileManager = FileManager.default
        let exists = fileManager.fileExists(atPath: dirPath, isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    
    func getFolderURL(folderPath: String) throws -> URL {
            do {
                let databaseURL = try getDatabasesUrl().absoluteURL
                var dbPathURL: URL
                let first = folderPath.split(separator: "/", maxSplits: 1)
                if first[0] == "Applications" {
                    dbPathURL = try getApplicationURL().absoluteURL
                } else if first[0] == "Library" {
                    dbPathURL = try getLibraryURL().absoluteURL
                } else if first[0] == "tmp" {
                    dbPathURL = getTmpURL().absoluteURL
                } else if first[0].caseInsensitiveCompare("cache") == .orderedSame {
                    dbPathURL = try getCacheURL().absoluteURL
                } else if first[0] == "Documents" || first[0] == "default" {
                    dbPathURL = databaseURL
                } else {
                    var msg: String = "getFolderURL command failed :"
                    msg.append(" Folder '\(first[0])' not allowed")
                    throw UtilsFileError.getFolderURLFailed(message: msg)
                }
                if first.count > 1 {
                    dbPathURL = dbPathURL
                        .appendingPathComponent(String(first[1])).absoluteURL
                }
                return dbPathURL
            } catch UtilsFileError.getDatabasesURLFailed {
                throw UtilsFileError.getFolderURLFailed(message: "getDatabasesURLFailed")
            } catch UtilsFileError.getApplicationURLFailed {
                throw UtilsFileError
                .getFolderURLFailed(message: "getApplicationURLFailed")
            } catch let error {
                var msg: String = "getFolderURL command failed :"
                msg.append(" \(error.localizedDescription)")
                throw UtilsFileError.getFolderURLFailed(message: msg)
            }
        }
    
    func getDatabasesUrl() throws -> URL {
            if let path: String = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first {
                return NSURL(fileURLWithPath: path) as URL
            } else {
                print("Error: getDatabasesURL did not find the document folder")
                throw UtilsFileError.getDatabasesURLFailed
            }
        }



   func getDatabaseLocationURL(databaseLocation: String) throws -> URL {
            do {
                let url: URL = try getFolderURL(folderPath: databaseLocation)

                return url
            } catch UtilsFileError.getFolderURLFailed(let message) {
                throw UtilsFileError.getDatabaseLocationURLFailed(message: message)
            }
        }

        // MARK: - getApplicationURL

func getApplicationURL() throws -> URL {
            if let path: String = NSSearchPathForDirectoriesInDomains(
                .applicationDirectory, .userDomainMask, true
            ).first {
                return NSURL(fileURLWithPath: path) as URL
            } else {
                print("Error: getApplicationURL did not find the application folder")
                throw UtilsFileError.getApplicationURLFailed
            }
        }



        // MARK: - getCacheURL

func getCacheURL() throws -> URL {
            if let path: String = NSSearchPathForDirectoriesInDomains(
                .cachesDirectory, .userDomainMask, true
            ).first {
                return NSURL(fileURLWithPath: path) as URL
            } else {
                print("Error: getCacheURL did not find the cache folder")
                throw UtilsFileError.getCacheURLFailed
            }
        }

        // MARK: - getTmpURL

        func getTmpURL() -> URL {
            return FileManager.default.temporaryDirectory
        }

        // MARK: - getLibraryURL

      func getLibraryURL() throws -> URL {
            if let path: String = NSSearchPathForDirectoriesInDomains(
                .libraryDirectory, .userDomainMask, true
            ).first {
                return NSURL(fileURLWithPath: path) as URL
            } else {
                print("Error: getApplicationURL did not find the library folder")
                throw UtilsFileError.getLibraryURLFailed
            }
        }

     func getFilePath(databaseLocation: String,
                              fileName: String) throws -> String {
           do {
               let url: URL = try getFolderURL(folderPath: databaseLocation)
               let dbPath: String = url
                   .appendingPathComponent("\(fileName)").path
               return dbPath
           } catch UtilsFileError.getFolderURLFailed(let message) {
               print("Error: getFilePath Failed \(message)")
               throw UtilsFileError.getFilePathFailed
           }
       }
    // MARK: - IsFileExist

        func isFileExist(filePath: String) -> Bool {
            var ret: Bool = false
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                ret = true
            }
            return ret
        }
        func isFileExist(databaseLocation: String, fileName: String) -> Bool {
            var ret: Bool = false
            do {
                let filePath: String =
                    try getFilePath(
                        databaseLocation: databaseLocation,
                        fileName: fileName)
                ret = isFileExist(filePath: filePath)
                return ret
            } catch UtilsFileError.getFilePathFailed {
                return false
            } catch _ {
                return false
            }
        }
    
    // MARK: - DeleteFile

    func deleteFile(filePath: String) throws -> Bool {
           var ret: Bool = false
           do {
               if isFileExist(filePath: filePath) {
                   let fileManager = FileManager.default
                   do {
                       try fileManager.removeItem(atPath: filePath)
                       ret = true
                   } catch let error {
                       print("Error: \(error)")
                       throw UtilsFileError.deleteFileFailed
                   }
               }
           } catch let error {
               print("Error: \(error)")
               throw UtilsFileError.deleteFileFailed
           }
           return ret
       }
    // MARK: - DeleteFile

         func deleteFile(fileName: String,
                              databaseLocation: String) throws -> Bool {
            var ret: Bool = false
            do {
                let filePath: String = try
                    getFilePath(databaseLocation: databaseLocation,
                                fileName: fileName)
                ret = try deleteFile(filePath: filePath)
            } catch let error {
                print("Error: \(error)")
                throw UtilsFileError.deleteFileFailed
            }
            return ret
        }

        // MARK: - DeleteFile

         func deleteFile(dbPathURL: URL, fileName: String) throws -> Bool {
            var ret: Bool = false
            do {
                let uURL: URL = dbPathURL.appendingPathComponent(fileName)
                let filePath: String = uURL.path
                ret = try deleteFile(filePath: filePath)
            } catch UtilsFileError.deleteFileFailed {
                throw UtilsFileError.deleteFileFailed
            } catch let error {
                print("Error: \(error)")
                throw UtilsFileError.deleteFileFailed
            }
            return ret
        }
    func copyFile(pathName: String, toPathName: String, overwrite: Bool) throws -> Bool {
            if pathName.count > 0 && toPathName.count > 0 {
                let isPath = isFileExist(filePath: pathName)
                if isPath {
                    do {
                        let isExist: Bool = isFileExist(filePath: toPathName)
                        if !isExist || overwrite {
                            if overwrite && isExist {
                                _ = try deleteFile(filePath: toPathName)
                            }
                            let fileManager = FileManager.default
                            try fileManager.copyItem(atPath: pathName,
                                                     toPath: toPathName)
                        }
                        return true
                    } catch let error {
                        print("Error: \(error)")
                        throw UtilsFileError.copyFileFailed
                    }
                } else {
                    print("Error: CopyFilePath Failed pathName does not exist")
                    throw UtilsFileError.copyFileFailed
                }
            } else {
                print("Error: CopyFilePath Failed paths count = 0")
                throw UtilsFileError.copyFileFailed
            }
        }

}

enum UtilsFileError: Error {
    case getFilePathFailed
    case copyFileFailed
    case moveFileFailed
    case renameFileFailed
    case deleteFileFailed
    case getAssetsDatabasesPathFailed
    case getDatabasesPathFailed
    case getDatabasesURLFailed
    case getApplicationPathFailed
    case getApplicationURLFailed
    case getCacheURLFailed
    case getLibraryPathFailed
    case getLibraryURLFailed
    case getFileListFailed
    case copyFromAssetToDatabaseFailed(message: String)
    case unzipToDatabaseFailed(message: String)
    case copyFromNamesFailed
    case getFolderURLFailed(message: String)
    case createDirFailed(message: String)
    case moveAllDBSQLiteFailed(message: String)
    case createDatabaseLocationFailed(message: String)
    case getDatabaseLocationURLFailed(message: String)
}
