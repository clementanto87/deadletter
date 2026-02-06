package com.example.deadletter

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class DeadletterApplication

fun main(args: Array<String>) {
    runApplication<DeadletterApplication>(*args)
}
