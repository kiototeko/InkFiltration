#include <jni.h>
#include <string>
#include <iostream>
#include "getPeaksA.h"
#include "getPeaksPre.h"
#include "getPeaksGlobal_initialize.h"
#include "getPeaksGlobal_terminate.h"

#define SIZE 20
#define SIZE2 100

/*
extern "C" JNIEXPORT jdoubleArray JNICALL Java_com_ucla_printerleaks_MainActivity_getPeaksA(
        JNIEnv* env,
        jobject thiz,
        jdoubleArray a, jdouble minH)
{
    int sz = SIZE;
    jdouble temp[SIZE];

    jdouble* ac = env->GetDoubleArrayElements(a, NULL);
    jdoubleArray result = env->NewDoubleArray(SIZE);
    memset(temp, 0, SIZE);


    if(result != NULL){
        getPeaks_initialize();
        getPeaks(ac, minH, temp, &sz);
        env->SetDoubleArrayRegion(result, 0, SIZE, temp);
    }
    env->ReleaseDoubleArrayElements(a,ac,0);
    getPeaks_terminate();

    return result;
}
*/
extern "C" JNIEXPORT jdoubleArray JNICALL Java_com_ucla_printerleaks_processSignal_getPeaksB(
        JNIEnv* env,
        jobject thiz,
        jdoubleArray a, jdouble minH, jint window, jint printer, jint peakdis)
{
    int sz = SIZE;
    jdouble temp[SIZE] = {0};

    jdouble* ac = env->GetDoubleArrayElements(a, NULL);
    jdoubleArray result = env->NewDoubleArray(SIZE);
    //memset(temp, 0, SIZE*sizeof(*temp));


    if(result != NULL){
        getPeaksGlobal_initialize();
        getPeaksA(ac, minH, window, printer, peakdis, temp, &sz);
        env->SetDoubleArrayRegion(result, 0, SIZE, temp);
    }
    env->ReleaseDoubleArrayElements(a,ac,0);
    getPeaksGlobal_terminate();

    return result;
}

extern "C" JNIEXPORT jdoubleArray JNICALL Java_com_ucla_printerleaks_processSignal_getPeaksPre(
        JNIEnv* env,
        jobject thiz,
        jdoubleArray a, jdoubleArray sample, jint window, jint minH)
{
    int sz[2] = {0};
    jdouble temp[SIZE2];

    jdouble* ac = env->GetDoubleArrayElements(a, NULL);
    jdouble* samplec = env->GetDoubleArrayElements(sample, NULL);
    jdoubleArray result = env->NewDoubleArray(SIZE2);
    memset(temp, 0, SIZE2);


    if(result != NULL){
        getPeaksGlobal_initialize();
        getPeaksPre(ac, samplec, window, minH, temp, sz);
        env->SetDoubleArrayRegion(result, 0, SIZE2, temp);
    }
    env->ReleaseDoubleArrayElements(a,ac,0);
    env->ReleaseDoubleArrayElements(sample,samplec,0);
    getPeaksGlobal_terminate();

    return result;
}