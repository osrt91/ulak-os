# Contributing

## Katkı ilkeleri
- Önce çekirdek sözleşmeyi bozup bozmadığını kontrol et.
- Yeni dosya eklemeden önce mevcut agent/command/skill yapısına sığıp sığmadığını değerlendir.
- Vendor adaptörleri (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`) arasında anlamsal drift oluşturma.
- İç kod adı değişikliği yaparsan public release numarasını da güncelle.
- Büyük davranış değişiklikleri için `docs/adr/` altına yeni ADR ekle.

## PR checklist
- [ ] README ve CHANGELOG güncellendi
- [ ] VERSIONING etkisi değerlendirildi
- [ ] `docs/adapters/` dosyaları drift açısından kontrol edildi
- [ ] `reports/current/` artefakt zinciri bozulmadı
- [ ] En az bir golden eval düşünülerek değişiklik gözden geçirildi
