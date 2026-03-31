package com.example.twoeyesproject.image

import android.content.Context
import android.graphics.BitmapFactory
import org.koin.android.ext.koin.androidContext
import org.koin.compose.koinInject
import org.koin.dsl.module

interface ContextStore {
    var context: Context
}

actual class ImageDecoder {
    val contextStore = module {
        single<ContextStore> { AndroidContextStore(androidContext()) }
    }

    actual suspend fun decode(source: ImageSource): PlatformImage {
        val contextStore = koinInject<AndroidContextStore>()
        val context = contextStore.context
        val image = BitmapFactory.decodeStream(
            context.contentResolver.openInputStream(source.build()))
        return image
    }
}

class AndroidContextStore(private val _context: Context): ContextStore {
    override var context: Context = _context
}
