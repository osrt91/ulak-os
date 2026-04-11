---
description: Ulak intake artefaktı üretir; superpowers:brainstorming yüklüyse onu da kullanır
---

# Ulak Intake (PoC Wrapper)

Bu komut Ulak OS'un intake artefakt zincirinin ilk halkasını üretir. Public superpowers marketplace'inden `brainstorming` skill'i yüklüyse, onu da çağırarak intake çıktısını zenginleştirir.

## Akış

1. **Kontrol et**: `superpowers:brainstorming` skill'i mevcut mu?
2. **Eğer mevcutsa**:
   - Brainstorming skill'ini çağır (kullanıcının talebi/niyeti üzerine)
   - Çıktısını proje bağlamı, başarı kriterleri, sınırlar olarak topla
3. **Eğer mevcut değilse**:
   - Native intake akışını uygula (proje state switch + intervention mode + kullanıcı niyeti)
4. **Yaz**: `reports/current/intake.md` dosyasını intake formatında oluştur:
   - Project state (GREENFIELD / BROWNFIELD / HYBRID)
   - Intervention mode (CREATE / REPAIR / EXTEND / REFACTOR / MIGRATE / RESCUE / REPACKAGE)
   - User intent
   - Success criteria
   - Constraints
   - Out-of-scope
5. **Önerin**: Bir sonraki artefakt zincirine geçiş için `/inventory` komutunu öner.

## Notlar

Bu komut Ulak OS'un mevcut superpowers wrapper'ıdır. Diğer wrapper'lar (`/ulak-roadmap`, `/ulak-validate`, `/ulak-evidence`, `/ulak-pack-gap`, `/ulak-final`) henüz shipped değil — ilgi duyuyorsan `reports/current/pack-gap-register.md` altında PG-* item'ı olarak tracked.

Eşleştirme detayları için: `docs/skills-integration/superpowers-mapping.md`

## Validation

Yazılan `reports/current/intake.md` dosyası şunları içermelidir:
- 6 başlığın hepsi dolu (project state, intervention mode, user intent, success criteria, constraints, out-of-scope)
- Boş veya placeholder cümle yok
- En az 5 cümle gerçek içerik
