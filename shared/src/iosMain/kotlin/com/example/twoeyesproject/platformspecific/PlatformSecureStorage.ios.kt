package com.example.twoeyesproject.platformspecific

import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.COpaquePointerVar
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.alloc
import kotlinx.cinterop.interpretObjCPointer
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.pin
import kotlinx.cinterop.ptr
import kotlinx.cinterop.value
import platform.CoreFoundation.CFDictionaryAddValue
import platform.CoreFoundation.CFDictionaryCreateMutable
import platform.CoreFoundation.CFDictionaryRef
import platform.CoreFoundation.CFRelease
import platform.Foundation.CFBridgingRetain
import platform.Foundation.NSData
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.create
import platform.Security.SecItemAdd
import platform.Security.SecItemCopyMatching
import platform.Security.SecItemDelete
import platform.Security.errSecSuccess
import platform.Security.kSecAttrAccount
import platform.Security.kSecAttrService
import platform.Security.kSecClass
import platform.Security.kSecClassGenericPassword
import platform.Security.kSecMatchLimit
import platform.Security.kSecMatchLimitOne
import platform.Security.kSecReturnData
import platform.Security.kSecValueData

@OptIn(ExperimentalForeignApi::class)
actual class PlatformSecureStorage {

    actual fun putString(key: String, value: String) {
        val data = value.encodeToByteArray().toNSData()

        // getString / remove 와 동일하게 kSecAttrService 포함 — 세 함수가 같은 keychain 항목을 참조
        val query = CFDictionaryCreateMutable(null, 5, null, null)!!
        CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword)
        CFDictionaryAddValue(query, kSecAttrService, CFBridgingRetain("com.example.twoeyesproject.TwoEyesProject"))
        CFDictionaryAddValue(query, kSecAttrAccount, CFBridgingRetain(key))
        CFDictionaryAddValue(query, kSecValueData, CFBridgingRetain(data))

        SecItemDelete(query)
        SecItemAdd(query, null)

        CFRelease(query)
    }

    @OptIn(BetaInteropApi::class)
    actual fun getString(key: String): String? {
        val query = CFDictionaryCreateMutable(null, 6, null, null)
        CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword)
        CFDictionaryAddValue(query, kSecAttrService, CFBridgingRetain("com.example.twoeyesproject.TwoEyesProject"))
        CFDictionaryAddValue(query, kSecAttrAccount, CFBridgingRetain(key))
        CFDictionaryAddValue(query, kSecReturnData, CFBridgingRetain(true))
        CFDictionaryAddValue(query, kSecMatchLimit, kSecMatchLimitOne)

        // memScoped: 블록 종료 시 alloc 메모리 자동 해제
        return memScoped {
            val result = alloc<COpaquePointerVar>()
            val status = SecItemCopyMatching(query, result.ptr)
            if (status != errSecSuccess) return@memScoped null

            // COpaquePointer → NSData: as? 캐스팅 대신 interpretObjCPointer 사용
            val nsData = result.value?.let { interpretObjCPointer<NSData>(it.rawValue) }
                ?: return@memScoped null

            // NSData → String: NSString.create 로 변환
            NSString.create(data = nsData, encoding = NSUTF8StringEncoding).toString()
        }
    }

    actual fun remove(key: String) {
        val query = CFDictionaryCreateMutable(null, 4, null, null)
        CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword)
        CFDictionaryAddValue(query, kSecAttrService, CFBridgingRetain("com.example.twoeyesproject.TwoEyesProject"))
        CFDictionaryAddValue(query, kSecAttrAccount, CFBridgingRetain(key))
        SecItemDelete(query as CFDictionaryRef)
    }
}

@OptIn(ExperimentalForeignApi::class)
fun ByteArray.toNSData(): NSData = memScoped {
    if (isEmpty()) return NSData()
    val pinned = this@toNSData.pin()
    val nsData = NSData.create(
        bytes = pinned.addressOf(0),
        length = this@toNSData.size.toULong()
    )
    pinned.unpin()
    nsData
}