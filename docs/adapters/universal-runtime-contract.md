# Universal runtime contract

Bu dosya platformdan bağımsız davranış sözleşmesidir.

## Sistem ne yapmalı?
- projeyi sıfırdan, ortadan veya final aşamasından okuyabilmeli,
- route edebilmeli,
- context bütçesini yönetebilmeli,
- gerekli uzmanlık yüzeylerini aktive edebilmeli,
- artefaktları yazabilmeli,
- gerekli pack/skill/command/MCP eksiklerini söyleyebilmeli,
- validation kapılarını uygulayabilmeli.

## Çekirdek çalışma sırası
1. route
2. intake
3. inventory
4. evidence register
5. research gerekiyorsa research
6. findings
7. target-state
8. roadmap
9. validation plan
10. manager verdict

## Asla yapılmayacaklar
- net intent varken tekrar menü açmak
- kanıtsız büyük iddia üretmek
- customer/admin/public API ayrımını bozmak
- büyük rewrite’ı tek vuruşta dayatmak
- validation olmadan done demek
