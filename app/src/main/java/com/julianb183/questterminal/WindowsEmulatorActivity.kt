package com.julianb183.questterminal

import android.app.Activity
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast

class WindowsEmulatorActivity : Activity() {
    private lateinit var status: TextView
    private lateinit var memory: EditText

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_windows_emulator)
        status = findViewById(R.id.emulatorStatus)
        memory = findViewById(R.id.memoryInput)

        findViewById<Button>(R.id.startWindows).setOnClickListener { startPrototype() }
        findViewById<Button>(R.id.stopWindows).setOnClickListener {
            status.text = "Stopped. No guest process is running."
        }
    }

    private fun startPrototype() {
        val ram = memory.text.toString().trim().ifEmpty { "4096" }
        val ramMb = ram.toIntOrNull()
        if (ramMb == null || ramMb < 1024 || ramMb > 4096) {
            Toast.makeText(this, "RAM must be between 1024 and 4096 MB", Toast.LENGTH_SHORT).show()
            return
        }
        status.text = "PCVR Windows emulator configured\nWindows 11 ARM64 • ${ramMb} MB RAM • software/emulated GPU\n\nNo guest image or emulator backend is installed. Add a legally obtained ARM64 VHDX and a compatible emulator backend to boot Windows."
    }
}
