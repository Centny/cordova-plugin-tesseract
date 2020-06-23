package com.github.centny.tess;

import android.content.Context;
import android.content.res.AssetManager;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class Tesseract {

    static {
        System.loadLibrary("tesseract");
    }

    public static native void bootstrap(String datapath, String language) throws Exception;

    public static native String recognize(int type, byte[] image) throws Exception;

    public static native String recognize(int type, byte[] image, int x, int y, int w, int h) throws Exception;

    public static void bootstrap(Context ctx) throws Exception {
        String datapath = checkTessdata(ctx);
        String language = listTrained(ctx);
        bootstrap(datapath, language);
    }

    public static String listTrained(Context ctx) {
        String langs = "";
        File tessdata = new File(ctx.getFilesDir(), "tessdata");
        for (File f : tessdata.listFiles()) {
            if (!f.getName().endsWith(".traineddata")) {
                continue;
            }
            if (!langs.isEmpty()) {
                langs += "+";
            }
            langs += f.getName().replace(".traineddata", "");
        }
        return langs;
    }

    public static boolean checkVersion(Context ctx) {
        try {
            AssetManager assetManager = ctx.getAssets();
            File tessdata = new File(ctx.getFilesDir(), "tessdata");
            String current = readString(new FileInputStream(new File(tessdata, "version.txt")));
            String having = readString(assetManager.open("tessdata/version.txt"));
            return current.trim().equals(having.trim());
        } catch (Exception e) {
            return false;
        }
    }

    public static String checkTessdata(Context ctx) throws IOException {
        AssetManager assetManager = ctx.getAssets();
        File tessdata = new File(ctx.getFilesDir(), "tessdata");
        if (tessdata.exists() && checkVersion(ctx)) {
            return tessdata.getAbsolutePath();
        }
        tessdata.mkdir();
        String[] files = assetManager.list("tessdata");
        if (files == null || files.length < 1) {
            return tessdata.getAbsolutePath();
        }
        for (String filename : files) {
            InputStream in = null;
            OutputStream out = null;
            try {
                in = assetManager.open("tessdata/" + filename);
                File outFile = new File(tessdata, filename);
                out = new FileOutputStream(outFile);
                copyFile(in, out);
            } finally {
                if (in != null) {
                    try {
                        in.close();
                    } catch (IOException e) {
                    }
                }
                if (out != null) {
                    try {
                        out.close();
                    } catch (IOException e) {
                    }
                }
            }
        }
        return tessdata.getAbsolutePath();
    }

    public static void copyFile(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[1024];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }
    }

    public static byte[] readBytes(InputStream in) throws IOException {
        try {
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            int nRead;
            byte[] buf = new byte[1024];
            while ((nRead = in.read(buf, 0, buf.length)) != -1) {
                buffer.write(buf, 0, nRead);
            }
            return buffer.toByteArray();
        } finally {
            in.close();
        }
    }

    public static String readString(InputStream in) throws IOException {
        byte[] data = readBytes(in);
        return new String(data, "UTF-8");
    }

}
