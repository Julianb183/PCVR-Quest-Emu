#include <android/log.h>
#include <jni.h>
#include <sys/wait.h>
#include <unistd.h>

#include <atomic>
#include <string>
#include <thread>

#define LOG_TAG "PCVR-QEMU"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace {
std::atomic<pid_t> child_pid{-1};
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_julianb183_questterminal_EmulatorNative_nativeStart(
        JNIEnv* env, jclass, jstring imagePath, jint ramMb, jstring runtimeDir) {
    const char* image = env->GetStringUTFChars(imagePath, nullptr);
    const char* runtime = env->GetStringUTFChars(runtimeDir, nullptr);
    std::string image_arg(image ? image : "");
    std::string runtime_dir(runtime ? runtime : "");
    env->ReleaseStringUTFChars(imagePath, image);
    env->ReleaseStringUTFChars(runtimeDir, runtime);

    if (image_arg.empty()) {
        return env->NewStringUTF("No guest image selected");
    }
    if (access(image_arg.c_str(), R_OK) != 0) {
        return env->NewStringUTF("Guest image is not readable");
    }
    if (child_pid.load() > 0) {
        return env->NewStringUTF("Emulator is already running");
    }

    // The APK expects a companion QEMU executable named qemu-system-aarch64
    // in its private native library directory. It is intentionally not bundled
    // until QEMU and its Android dependencies have been cross-compiled.
    const std::string qemu = runtime_dir + "/qemu-system-aarch64";
    if (access(qemu.c_str(), X_OK) != 0) {
        return env->NewStringUTF("QEMU backend is not installed in the app runtime directory");
    }

    pid_t pid = fork();
    if (pid < 0) {
        return env->NewStringUTF("Could not create emulator process");
    }
    if (pid == 0) {
        std::string memory = std::to_string(static_cast<int>(ramMb)) + "M";
        execl(qemu.c_str(), qemu.c_str(),
              "-machine", "virt",
              "-cpu", "cortex-a72",
              "-m", memory.c_str(),
              "-nographic",
              "-drive", (std::string("file=") + image_arg + ",if=none,format=raw,id=drive0").c_str(),
              "-device", "virtio-blk-device,drive=drive0",
              static_cast<char*>(nullptr));
        _exit(127);
    }

    child_pid.store(pid);
    LOGI("Started QEMU pid %d", pid);
    return env->NewStringUTF("QEMU process started; display and input integration are still pending");
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_julianb183_questterminal_EmulatorNative_nativeStop(JNIEnv* env, jclass) {
    pid_t pid = child_pid.exchange(-1);
    if (pid <= 0) return env->NewStringUTF("No emulator process is running");
    kill(pid, SIGTERM);
    int status = 0;
    waitpid(pid, &status, 0);
    return env->NewStringUTF("Emulator stopped");
}
