package com.example.deadletter.controller

import com.example.deadletter.model.DeadLetter
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping("/api")
class DeadletterController {

    private val store: MutableMap<String, DeadLetter> = Collections.synchronizedMap(mutableMapOf())

    @GetMapping("/health")
    fun health() = mapOf("status" to "UP")

    @GetMapping("/deadletters")
    fun list(): List<DeadLetter> = store.values.toList()

    @GetMapping("/deadletters/{id}")
    fun get(@PathVariable id: String): ResponseEntity<DeadLetter> =
        store[id]?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()

    @PostMapping("/deadletters")
    fun create(@RequestBody body: DeadLetter): DeadLetter {
        val id = UUID.randomUUID().toString()
        val dl = body.copy(id = id)
        store[id] = dl
        return dl
    }
}
