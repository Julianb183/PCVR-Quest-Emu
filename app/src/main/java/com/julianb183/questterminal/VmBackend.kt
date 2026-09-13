package com.julianb183.questterminal

import android.content.Context
import java.io.File

/** Files and configuration for the experimental ARM64 QEMU backend. */
class VmBackend(context: Context) {
    val directory: File = File(context.filesDir, "vm-backend")
    val qemuExecutable: File = File(directory, "qemu-system-aarch64")

    init { directory.mkdirs() }

    fun installHint(): String = if (qemuExecutable.canExecute()) {
        "QEMU backend ready: ${qemuExecutable.absolutePath}"
    } else {
        "QEMU backend missing. Put an Android ARM64 qemu-system-aarch64 binary in:\n${qemuExecutable.absolutePath}"
    }
}
