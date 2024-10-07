package com.mysevenzip.hnguyen;
import android.os.Environment;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import org.apache.commons.compress.archivers.ArchiveEntry;
import org.apache.commons.compress.archivers.sevenz.SevenZFile;
import org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry;

import java.util.logging.Level;
import java.util.logging.Logger;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.nio.channels.SeekableByteChannel;
import android.content.ContentResolver;
import android.net.Uri;
import android.os.ParcelFileDescriptor;


@CapacitorPlugin(name = "Sevenzip")
public class SevenzipPlugin extends Plugin {
    Logger logger = Logger.getAnonymousLogger();

    private Sevenzip implementation = new Sevenzip();

    @PluginMethod
    public void unzip(PluginCall call) {
        String filePath = call.getString("fileURL") != null? call.getString("fileURL") : "";
        String outputDir = call.getString("outputDir") !=null? call.getString("outputDir") : "";
        String password = call.getString("password") !=null? call.getString("password") : "";
        System.out.println("FileInput. ------------------------------" + filePath);

        String documentDir = String.valueOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS));
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
                     SevenZFile sevenZFile = new SevenZFile(fileChannel)) {

                    SevenZArchiveEntry entry;
                    long totalSize = 0;
                    while ((entry = sevenZFile.getNextEntry()) != null) {
                        totalSize += entry.getSize();
                    }

                    sevenZFile.close();

                    try (ParcelFileDescriptor pfd2 = getContext().getContentResolver().openFileDescriptor(fileUri, "r");
                         FileInputStream fis2 = new FileInputStream(pfd2.getFileDescriptor());
                         BufferedInputStream bis2 = new BufferedInputStream(fis2);
                         FileChannel fileChannel2 = fis2.getChannel();
                         SevenZFile sevenZFile2 = new SevenZFile(fileChannel2)) {
                        long extractedSize = 0;
                        int lastProgress = 0;

                        while ((entry = sevenZFile2.getNextEntry()) != null) {
                            if (entry.isDirectory()) {
                                continue;
                            }
                            String itemName = entry.getName();
                            File outFile = new File(finalOutputDir, itemName);
                            outFile.getParentFile().mkdirs();

                            try (FileOutputStream out = new FileOutputStream(outFile);
                                 BufferedOutputStream bos = new BufferedOutputStream(out, 32768)) {
                                byte[] buffer = new byte[32768]; // Use a larger buffer size
                                int len;
                                while ((len = sevenZFile2.read(buffer)) > 0) {
                                    bos.write(buffer, 0, len);
                                    extractedSize += len;
                                    int progress = (int) ((extractedSize * 100) / totalSize);
                                    if (progress - lastProgress >= 5) {
                                        lastProgress = progress;
                                        JSObject progressUpdate = new JSObject();
                                        progressUpdate.put("progress", progress);
                                        progressUpdate.put("fileName", itemName);
                                        notifyListeners("progressEvent", progressUpdate);
                                    }

                                }
                            }
                        }
                    }

                    JSObject ret = new JSObject();
                    ret.put("status", "success");
                    call.resolve(ret);
                } catch (IOException e) {
                    call.reject("Unzipping failed", e);
                }
            }
        }).start();

//        new Thread(() -> {
//            try (SevenZFile sevenZFile = new SevenZFile(new File(filePath))) {
//                SevenZArchiveEntry entry;
//                long totalSize = 0;
//                while ((entry = sevenZFile.getNextEntry()) != null) {
//                    totalSize += entry.getSize();
//                }
//
//                sevenZFile.close();
//
//                try (SevenZFile sevenZFile2 = new SevenZFile(new File(filePath))) {
//                    long extractedSize = 0;
//                    while ((entry = sevenZFile2.getNextEntry()) != null) {
//                        if (entry.isDirectory()) {
//                            continue;
//                        }
//
//                        File outFile = new File(finalOutputDir, entry.getName());
//                        outFile.getParentFile().mkdirs();
//
//                        try (FileOutputStream out = new FileOutputStream(outFile)) {
//                            byte[] buffer = new byte[1024];
//                            int len;
//                            while ((len = sevenZFile2.read(buffer)) > 0) {
//                                out.write(buffer, 0, len);
//                                extractedSize += len;
//                                int progress = (int) ((extractedSize * 100) / totalSize);
//                                JSObject progressUpdate = new JSObject();
//                                progressUpdate.put("progress", progress);
//                                progressUpdate.put("fileName", "");
//                                notifyListeners("progressEvent", progressUpdate);
//                            }
//                        }
//                    }
//                }
//
//                JSObject ret = new JSObject();
//                ret.put("status", "success");
//                call.resolve(ret);
//            } catch (IOException e) {
//                logger.log(Level.SEVERE, "an exception was thrown", e);
//                call.reject("Unzipping failed", e);
//            }
//        }).start();



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
}
