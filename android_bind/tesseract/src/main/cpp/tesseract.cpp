#include <jni.h>
#include <string>
#include <stdlib.h>
#include <tesseract/baseapi.h>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <android/log.h>

#define printf(...) __android_log_print(ANDROID_LOG_DEBUG,"Tess", __VA_ARGS__);

extern void tprintf(  // Trace printf
        const char *format, ...);

static tesseract::TessBaseAPI *tessShared;

extern "C" JNIEXPORT void JNICALL
Java_com_github_centny_tess_Tesseract_bootstrap(
        JNIEnv *env, jobject thiz, jstring datapath, jstring language) {
    const char *cdatapath = env->GetStringUTFChars(datapath, 0);
    const char *clanguage = env->GetStringUTFChars(language, 0);
    printf("Tesseract bootstrap by datapath:%s,language:%s\n", cdatapath, clanguage);
    if (tessShared) {
        tessShared->End();
        tessShared = 0;
    }
    tesseract::TessBaseAPI *tess = new tesseract::TessBaseAPI();
    if (tess->Init(cdatapath, clanguage)) {
        tess->End();
        env->ThrowNew(env->FindClass("java/lang/Exception"), "bootstrap fail");
    } else {
        tessShared = tess;
    }
    env->ReleaseStringUTFChars(datapath, cdatapath);
    env->ReleaseStringUTFChars(language, clanguage);
}

extern "C" jstring
Java_Tesseract_recognize(JNIEnv *env, jobject thiz, jint type, jbyteArray image, bool rect, jint x,
                         jint y, jint w, jint h) {
    jstring res = 0;
    if(!tessShared){
        env->ThrowNew(env->FindClass("java/lang/Exception"), "not bootstrap");
        return res;
    }
    const l_uint8 *cimage = (const l_uint8 *) env->GetByteArrayElements(image, 0);
    const size_t cimage_size = env->GetArrayLength(image);
    Pix *pix = 0;
    switch (type) {
        case 0:
            pix = pixReadMemPng(cimage, cimage_size);
            break;
        case 1:
            pix = pixReadMemJpeg(cimage, cimage_size, 0, 0, 0, 0);
            break;
    }
    if (pix) {
        tessShared->SetImage(pix);
        if (rect) {
            tessShared->SetRectangle(x, y, w, h);
        }
        char *outText = tessShared->GetUTF8Text();
        if (outText) {
            res = env->NewStringUTF(outText);
            delete[] outText;
        } else {
            env->ThrowNew(env->FindClass("java/lang/Exception"), "recognize fail");
        }
        pixDestroy(&pix);
    } else {
        env->ThrowNew(env->FindClass("java/lang/Exception"), "wrap image fail");
    }
    env->ReleaseByteArrayElements(image, (jbyte *) cimage, 0);
    return res;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_github_centny_tess_Tesseract_recognize__I_3B(JNIEnv *env, jobject thiz, jint type,
                                                      jbyteArray image) {
    return Java_Tesseract_recognize(env, thiz, type, image, false, 0, 0, 0, 0);
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_github_centny_tess_Tesseract_recognize__I_3BIIII(JNIEnv *env, jobject thiz, jint type,
                                                          jbyteArray image, jint x, jint y,
                                                          jint w, jint h) {
    return Java_Tesseract_recognize(env, thiz, type, image, true, x, y, w, h);
}