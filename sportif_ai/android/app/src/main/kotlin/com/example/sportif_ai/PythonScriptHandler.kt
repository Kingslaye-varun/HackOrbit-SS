package com.example.sportif_ai

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.io.OutputStreamWriter

class PythonScriptHandler(private val context: Context) {
    private val TAG = "PythonScriptHandler"
    
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "runPythonScript" -> {
                val scriptName = call.argument<String>("scriptName")
                val args = call.argument<String>("args")
                
                if (scriptName == null) {
                    result.error("MISSING_SCRIPT_NAME", "Script name is required", null)
                    return
                }
                
                GlobalScope.launch(Dispatchers.IO) {
                    try {
                        val scriptResult = runPythonScript(scriptName, args)
                        withContext(Dispatchers.Main) {
                            result.success(scriptResult)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error running Python script", e)
                        withContext(Dispatchers.Main) {
                            result.error("SCRIPT_ERROR", e.message, e.stackTraceToString())
                        }
                    }
                }
            }
            else -> result.notImplemented()
        }
    }
    
    private suspend fun runPythonScript(scriptName: String, args: String?): String = withContext(Dispatchers.IO) {
        // Check if Python is installed
        val pythonInstalled = isPythonInstalled()
        if (!pythonInstalled) {
            throw Exception("Python is not installed or not in PATH")
        }
        
        // Get the path to the Python script
        val scriptPath = getScriptPath(scriptName)
        if (!File(scriptPath).exists()) {
            throw Exception("Script not found: $scriptPath")
        }
        
        // Build the command
        val command = if (args != null) {
            arrayOf("python", scriptPath)
        } else {
            arrayOf("python", scriptPath)
        }
        
        // Run the command
        val process = ProcessBuilder(*command)
            .redirectErrorStream(true)
            .start()
        
        // If args are provided, write them to the process stdin
        if (args != null) {
            val writer = OutputStreamWriter(process.outputStream)
            writer.write(args)
            writer.flush()
            writer.close()
        }
        
        // Read the output
        val reader = BufferedReader(InputStreamReader(process.inputStream))
        val output = StringBuilder()
        var line: String?
        while (reader.readLine().also { line = it } != null) {
            output.append(line).append("\n")
        }
        
        // Wait for the process to complete
        val exitCode = process.waitFor()
        if (exitCode != 0) {
            throw Exception("Python script exited with code $exitCode: ${output.toString().trim()}")
        }
        
        return@withContext output.toString().trim()
    }
    
    private fun isPythonInstalled(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("python --version")
            process.waitFor() == 0
        } catch (e: Exception) {
            false
        }
    }
    
    private fun getScriptPath(scriptName: String): String {
        // In a real app, you might want to copy the scripts to the app's files directory
        // For this example, we assume the scripts are in the app's files directory
        val scriptsDir = File(context.filesDir, "python_scripts")
        if (!scriptsDir.exists()) {
            scriptsDir.mkdirs()
        }
        
        return File(scriptsDir, scriptName).absolutePath
    }
}