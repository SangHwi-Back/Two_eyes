package com.example.twoeyesproject.image

expect class URIByteEncoder(uriString: String) {
    fun uriToByteArray(): ByteArray?
}