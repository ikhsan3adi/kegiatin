---
trigger: always_on
glob: "*.dart"
description: aturan tambahan
---

Aturan tambahan:
- Dalam kode (termasuk komentar, nama variabel, nama fungsi, dan dokumentasi inline) hindari menyebut hal yang tidak terkait langsung dengan implementasi teknis atau logika program. Contoh yang tidak boleh disebut: nama orang (mis. Fairuz, Pak Lukman), nama sprint atau milestone (mis. Sprint 1), istilah non-teknis yang tidak relevan (mis. Flowchart), atau referensi organisasi/proses.
- Komentar harus fokus menjelaskan maksud kode, asumsi, kompleksitas algoritma, dan hal yang membantu pemeliharaan kode. Jangan gunakan komentar untuk catatan pribadi, tugas non-teknis, atau komunikasi antar-person.
- Jika perlu mencantumkan konteks non-teknis (mis. penanggung jawab atau keputusan manajerial), tempatkan informasi tersebut di sistem manajemen proyek atau dokumentasi terpisah, bukan langsung di repository kode.
- Untuk pengecualian yang memang diperlukan (mis. pemberitahuan kepatuhan atau lisensi), pastikan ditulis singkat, relevan, dan telah disetujui tim.
- Proses penegakan: bila reviewer menemukan pelanggaran, ajukan perbaikan melalui PR yang menjelaskan alasan perubahan dan referensi aturan ini.

Contoh frasa yang dilarang (tidak eksklusif): "Sprint 1", "Fairuz", "Flowchart", "Pak Lukman".

Catatan: aturan ini terutama diterapkan pada komentar kode dan nama entitas di repository, dengan tujuan menjaga fokus teknis dan keterbacaan kode.
