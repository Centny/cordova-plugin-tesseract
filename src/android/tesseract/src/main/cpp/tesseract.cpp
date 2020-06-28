#include <jni.h>
#include <string>
#include <stdlib.h>
#include <tesseract/baseapi.h>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <android/log.h>

static tesseract::TessBaseAPI *tessShared;

extern "C" JNIEXPORT void JNICALL
Java_com_github_centny_tess_Tesseract_bootstrap(JNIEnv *env, jobject thiz, jstring datapath, jstring language)
{
    const char *cdatapath = env->GetStringUTFChars(datapath, 0);
    const char *clanguage = env->GetStringUTFChars(language, 0);
    printf("Tesseract bootstrap by datapath:%s,language:%s\n", cdatapath, clanguage);
    if (tessShared)
    {
        tessShared->End();
        tessShared = 0;
    }
    tesseract::TessBaseAPI *tess = new tesseract::TessBaseAPI();
    if (tess->Init(cdatapath, clanguage))
    {
        tess->End();
        env->ThrowNew(env->FindClass("java/lang/Exception"), "bootstrap fail");
    }
    else
    {
        tessShared = tess;
    }
    env->ReleaseStringUTFChars(datapath, cdatapath);
    env->ReleaseStringUTFChars(language, clanguage);
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_github_centny_tess_Tesseract_recognize(JNIEnv *env, jobject thiz, jbyteArray image, jint x, jint y, jint w, jint h)
{
    jstring res = 0;
    if (!tessShared)
    {
        env->ThrowNew(env->FindClass("java/lang/Exception"), "not bootstrap");
        return res;
    }
    const l_uint8 *cimage = (const l_uint8 *)env->GetByteArrayElements(image, 0);
    const size_t cimage_size = env->GetArrayLength(image);
    Pix *pix = pixReadMem(cimage, cimage_size);
    if (pix)
    {
        tessShared->SetImage(pix);
        bool isok = true;
        if (x > 0 || y > 0 || w > 0 || h > 0)
        {
            int width = pixGetWidth(pix);
            int height = pixGetHeight(pix);
            if (x < 0 || y < 0 || w < 1 || h < 1 || x > width || y > height || x + w > width || y + h > height)
            {
                env->ThrowNew(env->FindClass("java/lang/Exception"), "error rectangle");
                isok = false;
            }
            else
            {
                tessShared->SetRectangle(x, y, w, h);
                isok = true;
            }
        }
        if (isok)
        {
            char *outText = tessShared->GetUTF8Text();
            if (outText)
            {
                res = env->NewStringUTF(outText);
                delete[] outText;
            }
            else
            {
                env->ThrowNew(env->FindClass("java/lang/Exception"), "recognize fail");
            }
        }
        pixDestroy(&pix);
    }
    else
    {
        env->ThrowNew(env->FindClass("java/lang/Exception"), "wrap image fail");
    }
    env->ReleaseByteArrayElements(image, (jbyte *)cimage, 0);
    return res;
}