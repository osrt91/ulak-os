---
description: Public bir markanın tasarım referansını (awesome-design-md) indirip frontend ajanlara sağlar
---

# Ulak Design Reference

Bu komut, `VoltAgent/awesome-design-md` reposundan belirtilen markanın **DESIGN.md** dosyasını (renk paleti, tipografi, bileşen stilleri, layout ilkeleri) indirir ve frontend ajanların kullanabileceği şekilde `reports/current/design-references/<brand>/` altına yazar.

## Kullanım

```
/ulak-design-ref <brand>
```

Örnekler:
- `/ulak-design-ref stripe`
- `/ulak-design-ref linear`
- `/ulak-design-ref vercel`
- `/ulak-design-ref notion`

Mevcut markaları görmek için: https://github.com/VoltAgent/awesome-design-md

## Akış

1. `scripts/fetch-design-references.sh <brand>` çağır (Windows: `.ps1`)
2. İndirilen `reports/current/design-references/<brand>/DESIGN.md` dosyasını oku
3. Mevcut frontend görevine entegre et:
   - `/frontend-war-room` ile birlikte kullanılırsa, savaş odası bu referansı bağlama dahil eder
   - `design-system-architect` subagent'ı bu dosyayı tasarım kararı için input olarak alır
4. İçeriği kullanıcıya özetle: "Stripe'ın renk paleti şu, tipografisi şu, ana bileşenleri şu" gibi
5. Kullanıcıya öner: "Şu component'i Stripe stiline uyarlayayım mı?"

## Lisans

awesome-design-md MIT lisanslıdır. İndirdiğin DESIGN.md dosyasının kaynağı her zaman belirtilmeli (dosyanın içinde upstream URL var).

## Bağımlılıklar

- `curl` (sh) veya `Invoke-WebRequest` (ps1)
- İnternet bağlantısı (offline modda kullanılamaz)

## Validation

`reports/current/design-references/<brand>/DESIGN.md` dosyası yazılmış olmalıdır. Yazılmamışsa fetch script hatası bastır ve kullanıcıya alternatif (manuel browse) öner.
