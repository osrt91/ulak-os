# Release Parity Policy

Claude Ulak için bundan sonra şu kural geçerli kabul edilir:

1. Kullanıcıya gösterilen sürüm ile GitHub repo sürümü aynıdır.
2. Her public sürüm aşağıdaki eşit yapıyla dağıtılır:
   - README.md
   - RELEASE_NOTES.md
   - MANIFEST.md
   - SOURCES.md
   - artifacts/
3. Erken dönem exact snapshot yoksa bu bilgi gizlenmez; sürüm `reconstructed` olarak işaretlenir.
4. İç kod adları (V7, V8, V9, V10.2, V10.3) changelog ve tarihçe için korunur ama public sürüm hattının yerine geçmez.
5. Yeni dağıtım değişiklikleri mümkün olduğunda patch sürüm olarak çıkarılır.
