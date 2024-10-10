package com.mysevenzip.hnguyen;
import android.os.Environment;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.apache.commons.compress.archivers.sevenz.SevenZFile;
import org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry;

import java.util.logging.Logger;
import java.util.ArrayList;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

import android.net.Uri;
import android.os.ParcelFileDescriptor;

import android.content.Context;
import android.content.ContentResolver;

@CapacitorPlugin(name = "Sevenzip")
public class SevenzipPlugin extends Plugin {
    Logger logger = Logger.getAnonymousLogger();
    private Context context;

    private Sevenzip implementation = new Sevenzip();
    ArrayList<String> callQueue = new ArrayList<String>();

    public void rmSrcFile(Uri fileUri) {
        if (fileUri != null && fileUri.toString().startsWith("content://")) {
            try {
                context.grantUriPermission(context.getPackageName(), fileUri, this.getActivity().getIntent().FLAG_GRANT_WRITE_URI_PERMISSION);
                ContentResolver contentResolver = context.getContentResolver();
                int rowsDeleted = contentResolver.delete(fileUri, null, null);
                if (rowsDeleted > 0) {
                    System.out.println("File deleted successfully.");
                } else {
                    System.out.println("No file found to delete.");
                }
            } catch (Exception e) {
                System.out.println("Error deleting file: " + e.getMessage());
            }
        } else {
            System.out.println("Invalid URI: " + fileUri);
        }
    }
    @Override
    public void load() {
    // Get the context
        this.context = this.getActivity().getApplicationContext();
    }
    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void unzip(PluginCall call) {

        call.setKeepAlive(true);
        callQueue.add(call.getCallbackId());
        String filePath = call.getString("fileURL") != null? call.getString("fileURL") : "";
        String outputDir = call.getString("outputDir") !=null? call.getString("outputDir") : "";
        String password = call.getString("password") !=null? call.getString("password") : "";
        Boolean removeSrcFile = call.getBoolean("rmSourceFile")!=null? call.getBoolean("rmSourceFile"): true;
        System.out.println("FileInput. ------------------------------" + filePath);

        String documentDir = String.valueOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS));
        //If using app-specific Dir, there will be no space left error --> must use external dir for large files
//        String documentDir = String.valueOf(context.getExternalFilesDir(null));
        System.out.println("Document Application directory: " + documentDir);
        if (outputDir != "" && documentDir != null) {
            outputDir = documentDir + outputDir;
        }
        else
            outputDir = documentDir;

        File testIn = new File(filePath);
        File testOut = new File(outputDir);

        if (testOut.canWrite()) {
            System.out.println("File/Directory is writable.");
        } else {
            System.out.println("File/Directory is not writable.");
        }
        Uri fileUri = Uri.parse(filePath);

        String finalOutputDir = outputDir;

        //Tam chap nhan
        new Thread(() -> {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                try (ParcelFileDescriptor pfd = getContext().getContentResolver().openFileDescriptor(fileUri, "r");
                     FileInputStream fis = new FileInputStream(pfd.getFileDescriptor());
                     BufferedInputStream bis = new BufferedInputStream(fis);
                     FileChannel fileChannel = fis.getChannel();
                     SevenZFile sevenZFile = new SevenZFile(fileChannel, password.toCharArray())) {
//                    logger.log(Level.INFO, sevenZFile.getEntries()); ;
                    SevenZArchiveEntry entry;
                    long totalSize = 0;
                    while ((entry = sevenZFile.getNextEntry()) != null) {
                        totalSize += entry.getSize();
                    }
                    sevenZFile.close();
                    pfd.close();
                    bis.close();
                    fis.close();
                    fileChannel.close();
                    try (ParcelFileDescriptor pfd2 = getContext().getContentResolver().openFileDescriptor(fileUri, "r");
                         FileInputStream fis2 = new FileInputStream(pfd2.getFileDescriptor());
                         BufferedInputStream bis2 = new BufferedInputStream(fis2);
                         FileChannel fileChannel2 = fis2.getChannel();
                         SevenZFile sevenZFile2 = new SevenZFile(fileChannel2, password.toCharArray())) {
                        long extractedSize = 0;
                        float lastProgress = 0;

                        while ((entry = sevenZFile2.getNextEntry()) != null) {
                            if (entry.isDirectory()) {
                                continue;
                            }
                            String itemName = entry.getName();
                            File outFile = new File(finalOutputDir, itemName);
                            outFile.getParentFile().mkdirs();

                            int bufferSize = 32 * 1024;
                            try (FileOutputStream out = new FileOutputStream(outFile);
                                 BufferedOutputStream bos = new BufferedOutputStream(out, bufferSize)) {
                                byte[] buffer = new byte[bufferSize]; // Use a larger buffer size
                                int len;
                                while ((len = sevenZFile2.read(buffer)) > 0) {
                                    bos.write(buffer, 0, len);
                                    extractedSize += len;
                                    float progress = (float) ((extractedSize * 100) / totalSize);
                                    if (progress - lastProgress >= 2) {
                                        lastProgress = progress;
                                        JSObject progressUpdate = new JSObject();
                                        progressUpdate.put("progress", progress/100);
                                        progressUpdate.put("fileName", outFile.getAbsolutePath());
                                        notifyListeners("progressEvent", progressUpdate);
                                        call.resolve(progressUpdate);
                                    }

                                }
                            }
                        }
                        sevenZFile2.close();
                        pfd2.close();
                        bis2.close();
                        fis2.close();
                        fileChannel2.close();
                        System.out.println("Co delete file goc hay ko " + removeSrcFile);

                        if(removeSrcFile)
                        {
                            System.out.println("Co delete file goc hay ko " + removeSrcFile);

                            rmSrcFile(fileUri);
                        }
                    }

                    JSObject ret = new JSObject();
                    callQueue.remove(call.getCallbackId());
                    call.release(bridge);
                } catch (IOException e) {
                    callQueue.remove(call.getCallbackId());
                    call.release(bridge);
                    call.reject(e.toString());
                }
            }
        }).start();



//        new Thread(() -> {
//            try (RandomAccessFile randomAccessFile = new RandomAccessFile(filePath, "r");
//                 IInArchive inArchive = SevenZip.openInArchive(null, new RandomAccessFileInStream(randomAccessFile))) {
//
//                ISimpleInArchive simpleInArchive = inArchive.getSimpleInterface();
//                long totalSize = 0;
//                for (ISimpleInArchiveItem item : simpleInArchive.getArchiveItems()) {
//                    totalSize += item.getSize();
//                }
//
//                for (ISimpleInArchiveItem item : simpleInArchive.getArchiveItems()) {
//                    final long itemSize = item.getSize();
//                    long finalTotalSize = totalSize;
//                    item.extractSlow(new ISequentialOutStream() {
//                        long extractedSize = 0;
//
//                        @Override
//                        public int write(byte[] data) throws SevenZipException {
//                            try (FileOutputStream fos = new FileOutputStream(new File(finalOutputDir, item.getPath()), true)) {
//                                fos.write(data);
//                            } catch (IOException e) {
//                                throw new SevenZipException("Error writing file", e);
//                            }
//                            extractedSize += data.length;
//                            int progress = (int) ((extractedSize * 100) / finalTotalSize);
//                            JSObject progressUpdate = new JSObject();
//                            progressUpdate.put("progress", progress);
//                            progressUpdate.put("fileName", "");
//                            notifyListeners("progressEvent", progressUpdate);
//                            return data.length;
//                        }
//                    });
//                }
//
//                JSObject ret = new JSObject();
//                ret.put("status", "success");
//                call.resolve(ret);
//            } catch (Exception e) {
//                call.reject("Unzipping failed", e);
//            }
//        }).start();

    }

    @PluginMethod
    public void clearProgressWatch(PluginCall call) {
        String callbackId = call.getString("id");

        if (callbackId != null) {
//            PluginCall removed = watchingCalls.remove(callbackId);
//            if (removed != null) {
//                removed.release(bridge);
//            }
//
//            if (watchingCalls.size() == 0) {
//                implementation.clearLocationUpdates();
//            }

            call.resolve();
        } else {
            call.reject("Watch call id must be provided");
        }
    }

    @PluginMethod
    public void getDefaultPath(PluginCall call) {
        JSObject res = new JSObject();
        res.put("path",String.valueOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)));
        call.resolve(res);
    }
}
