package com.example.deadletter.model

data class DeadLetter(
    val id: String? = null,
    val payload: String = "",
    val reason: String? = null
)
