//
// Created by kiototeko on 7/10/20.
//

#include <iostream>
#include <jni.h>
#include "getPeaks.h"
#include "getPeaks_initialize.h"
#include "getPeaks_terminate.h"

#define SIZE 20

extern "C" JNIEXPORT jdoubleArray JNICALL getPeaksA(
        JNIEnv* env,
        jobject thiz,
        jdoubleArray a)
{
    int sz = SIZE;
    jdouble temp[SIZE];

    jdouble* ac = env->GetDoubleArrayElements(a, NULL);
    jdoubleArray result = env->NewDoubleArray(SIZE);

    if(result != NULL){
        getPeaks_initialize();
        getPeaks(ac, temp, &sz);
        env->SetDoubleArrayRegion(result, 0, SIZE, temp);
    }
    env->ReleaseDoubleArrayElements(a,ac,0);
    getPeaks_terminate();

    return result;
}

/*
JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    // Find your class. JNI_OnLoad is called from the correct class loader context for this to work.
    jclass c = env->FindClass("com/ucla/printerleaks/MainActivity");
    if (c == nullptr) return JNI_ERR;

    // Register your class' native methods.
    static const JNINativeMethod methods[] = {
            {"nativeFoo", "()V", reinterpret_cast<void*>(getPeaksA)}
    };
    int rc = env->RegisterNatives(c, methods, sizeof(methods)/sizeof(JNINativeMethod));
    if (rc != JNI_OK) return rc;

    return JNI_VERSION_1_6;
}
 */