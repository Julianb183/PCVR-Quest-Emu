#include <android/log.h>
#include <jni.h>
#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>
#include <atomic>
#include <string>

#define LOG_TAG "PCVR-QEMU"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

namespace {
std::atomic<pid_t> child_pid{-1};
bool valid_ram(jint ram_mb) { return ram_mb >= 1024 && ram_mb <= 4096; }
void reap_finished_child() {
    pid_t pid = child_pid.load();
    if (pid <= 0) return;
    int status = 0;
    if (waitpid(pid, &status, WNOHANG) == pid) child_pid.store(-1);
}
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_julianb183_questterminal_EmulatorNative_nativeStart(
        JNIEnv* env, jclass, jstring imagePath, jint ramMb, jstring runtimeDir) {
    const char* image = env->GetStringUTFChars(imagePath, nullptr);
    const char* runtime = env->GetStringUTFChars(runtimeDir, nullptr);
    const std::string image_arg(image ? image : "");
    const std::string runtime_dir(runtime ? runtime : "");
    env->ReleaseStringUTFChars(imagePath, image);
    env->ReleaseStringUTFChars(runtimeDir, runtime);

    if (image_arg.empty()) return env->NewStringUTF("No guest image selected");
    if (!valid_ram(ramMb)) return env->NewStringUTF("RAM must be between 1024 and 4096 MB");
    if (access(image_arg.c_str(), R_OK) != 0) return env->NewStringUTF("Guest image is not readable");
    reap_finished_child();
    if (child_pid.load() > 0) return env->NewStringUTF("Emulator is already running");

    const std::string qemu = runtime_dir + "/qemu-system-aarch64";
    if (access(qemu.c_str(), X_OK) != 0)
        return env->NewStringUTF("QEMU backend missing: install qemu-system-aarch64 in the VM backend folder");

    pid_t pid = fork();
    if (pid < 0) return env->NewStringUTF("Could not create emulator process");
    if (pid == 0) {
        const std::string memory = std::to_string(static_cast<int>(ramMb)) + "M";
        const std::string drive = "file=" + image_arg + ",if=none,format=raw,id=drive0";
        execl(qemu.c_str(), qemu.c_str(),
              "-machine", "virt", "-cpu", "max",
              "-accel", "tcg,thread=multi", "-m", memory.c_str(), "-smp", "4",
              "-nodefaults", "-drive", drive.c_str(),
              "-device", "virtio-blk-device,drive=drive0",
              "-device", "virtio-gpu-pci", "-device", "virtio-keyboard-pci",
              "-device", "virtio-mouse-pci", "-display", "egl-headless",
              "-serial", "stdio", static_cast<char*>(nullptr));
        _exit(127);
    }
    child_pid.store(pid);
    LOGI("Started QEMU ARM64 VM pid %d", pid);
    return env->NewStringUTF("ARM64 QEMU VM started with software emulation");
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
