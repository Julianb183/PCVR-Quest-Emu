package com.julianb183.questterminal

import android.app.Activity
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.ScrollView
import android.widget.TextView

class MainActivity : Activity() {
    private lateinit var output: TextView
    private lateinit var input: EditText
    private lateinit var scroll: ScrollView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        output = findViewById(R.id.output)
        input = findViewById(R.id.input)
        scroll = findViewById(R.id.outputScroll)
        append("Quest Terminal 0.1.0\nCommands run inside the app sandbox.\nType 'help' for commands.\n\n$ ")
        findViewById<Button>(R.id.run).setOnClickListener { runCommand() }
        input.setOnEditorActionListener { _, _, _ -> runCommand(); true }
    }

    private fun runCommand(): Boolean {
        val command = input.text.toString().trim()
        if (command.isEmpty()) return true
        append(command + "\n")
        input.text.clear()
        when (command) {
            "help" -> append("help       show commands\npwd        show app directory\nls         list app files\nclear      clear screen\necho TEXT   print text\n")
            "pwd" -> append(filesDir.absolutePath + "\n")
            "ls" -> append(filesDir.list()?.joinToString("\n")?.plus("\n") ?: "(empty)\n")
            "clear" -> output.text = ""
            else -> if (command.startsWith("echo ")) append(command.removePrefix("echo ") + "\n") else append("command not found: $command\n")
        }
        append("\n$ ")
        scroll.post { scroll.fullScroll(ScrollView.FOCUS_DOWN) }
        return true
    }

    private fun append(text: String) { output.append(text) }
}
