package com.aditya.downtube

import android.media.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.nio.ByteBuffer

class MainActivity : FlutterActivity() {
    private val CHANNEL = "downtube/merge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "mergeVideoAndAudio") {
                val videoPath = call.argument<String>("videoPath") ?: return@setMethodCallHandler result.error("ARG", "Missing videoPath", null)
                val audioPath = call.argument<String>("audioPath") ?: return@setMethodCallHandler result.error("ARG", "Missing audioPath", null)
                val outputPath = call.argument<String>("outputPath") ?: return@setMethodCallHandler result.error("ARG", "Missing outputPath", null)

                try {
                    mergeWithMediaMuxer(videoPath, audioPath, outputPath)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("MERGE_ERROR", "Merging failed: ${e.message}", null )
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun mergeWithMediaMuxer(videoPath: String, audioPath: String, outputPath: String) {
        val videoExtractor = MediaExtractor()
        val audioExtractor = MediaExtractor()
        val muxer: MediaMuxer

        try {
            videoExtractor.setDataSource(videoPath)
            audioExtractor.setDataSource(audioPath)

            muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)

            // Track selection (safe)
            val videoTrackIndex = muxer.addTrack(videoExtractor.getTrackFormat(0))
            val audioTrackIndex = muxer.addTrack(audioExtractor.getTrackFormat(0))

            muxer.start()

            val bufferSize = 1 * 1024 * 1024
            val buffer = ByteBuffer.allocate(bufferSize)
            val bufferInfo = MediaCodec.BufferInfo()

            // 🔹 Copy video samples
            videoExtractor.selectTrack(0)
            while (true) {
                bufferInfo.offset = 0
                bufferInfo.size = videoExtractor.readSampleData(buffer, 0)
                if (bufferInfo.size < 0) break

                bufferInfo.presentationTimeUs = videoExtractor.sampleTime
                bufferInfo.flags = videoExtractor.sampleFlags
                muxer.writeSampleData(videoTrackIndex, buffer, bufferInfo)
                videoExtractor.advance()
            }

            // 🔸 Copy audio samples
            audioExtractor.selectTrack(0)
            while (true) {
                bufferInfo.offset = 0
                bufferInfo.size = audioExtractor.readSampleData(buffer, 0)
                if (bufferInfo.size < 0) break

                bufferInfo.presentationTimeUs = audioExtractor.sampleTime
                bufferInfo.flags = audioExtractor.sampleFlags
                muxer.writeSampleData(audioTrackIndex, buffer, bufferInfo)
                audioExtractor.advance()
            }

            muxer.stop()
            muxer.release()
        } finally {
            videoExtractor.release()
            audioExtractor.release()
        }
    }
}
