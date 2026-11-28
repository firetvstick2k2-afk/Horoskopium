# ASTRALIUM – Handoff

**Stand:** 28.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Aktueller Teststand:** `28c78347d1b7a2d4fd9604d8f8ecf47ac61a0984` (Test und Handoff gemeinsam committed; CI-Lauf steht aus).

## TSL1-Lizenzintegration

- Der Nutzer-Screenshot aus Licence Studio bestätigt den öffentlichen EC-Prüfschlüssel. Er stimmt exakt mit dem bereits in Topf Secret eingebetteten Schlüssel überein:
  `MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEO_8xiWBZLIQw--gBpf1Touzg5jPDJLbLHbHiRUlakcvVTgdEcqSBf3-wsU9pzvsF9yCpKZfz4lWWB4bj2LGnQ`.
- Nur der öffentliche Schlüssel wird in ASTRALIUM verwendet. Privater Hauptschlüssel, Licence Studio, Topf Secret und dessen separate Admin-Aktivierung bleiben unverändert.
- Derselbe TSL1-Token soll beide Apps aktivieren. Der bestehende signierte Produkt-Claim `topf_secret` bleibt daher als gemeinsamer Lizenz-Namespace erhalten; der Generator wird nicht verändert.
- Das plattformunabhängige Offline-Prüfmodul liegt in `lib/infrastructure/licensing/tsl1_license_verifier.dart`. Es prüft Tokenstruktur, ECDSA-P-256/SHA-256-Signatur, Version, Produkt-Claim, Lizenztyp, UUID, Ausstellungszeit, Kundenname sowie Ablauf-/Dauerfelder.
- Der Verifier akzeptiert für Tests bereits einen injizierbaren öffentlichen Schlüssel. Der produktive öffentliche Schlüssel bleibt der unveränderte Standardwert.
- Der Lizenzdienst liegt in `lib/services/tsl1_license_service.dart`. TSL1-Token werden über `flutter_secure_storage` im plattformspezifischen sicheren Speicher abgelegt. Beim App-Start wird der gespeicherte Token erneut offline verifiziert.
- Die Aktivierungsseite liegt in `lib/screens/license_screen.dart`; erreichbar über Einstellungen. Aktivieren speichert nur nach erfolgreicher Signatur- und Ablaufprüfung. Deaktivieren entfernt den lokalen Token.
- Die Lizenzverwaltung ist informativ und sperrt nicht global die App. Eine Produktzugriffs-/Sperrpolitik wurde nicht festgelegt.
- **CI #111** auf `development`, Commit `6fb043c82f1ced192e0f2bfdcb1c708444b4aa36`: vollständig erfolgreich. Android- und iOS-Analyse, Tests und Builds bestanden; Android-Debug-APK wurde hochgeladen.
- Positiver TSL1-Test (Commit `28c78347d1b7a2d4fd9604d8f8ecf47ac61a0984`): Ein temporäres P-256-Schlüsselpaar wird zur Laufzeit im Test erzeugt. Kein privater Produktionsschlüssel und keine Kundendaten werden verwendet oder committed. Geprüft werden Signaturvalidierung, Aktivierung, Speicherung, Wiederherstellung und Ablaufgrenze.
- Reale Android-/iOS-Geräteprüfung der nativen sicheren Speicher bleibt separat erforderlich.
- Eine gültige Signatur allein bedeutet noch keine Gerätebindung. Keine privaten Schlüssel oder Kundendaten in die App oder das Repository übernehmen.

## Verbindliche Regeln

1. Ausschließlich auf `development` arbeiten.
2. `main` nur nach der ausdrücklichen Formulierung „Bitte Main überschreiben“ verändern.
3. Vor Änderungen bestehender Dateien aktuellen GitHub-Inhalt und SHA abrufen.
4. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
5. Tests und Builds erst nach bestätigtem CI als erfolgreich bezeichnen.
6. Flutter-Paketkennung `horoskopium` und Application-ID nicht ohne ausdrückliche Entscheidung ändern.
7. Licence Studio, produktiven privaten Schlüssel, gemeinsamen TSL1-Produkt-Claim und Topf Secret Admin-Aktivierung nicht verändern.

## Nächste Schritte

1. CI des positiven TSL1-End-to-End-Tests abwarten und eventuelle Fehler korrigieren.
2. Danach reale Android-/iOS-Secure-Storage-Prüfung.
3. Anschließend Geocoding und historische IANA-Zeitzonenauflösung.
4. DER-Signaturparser auf strikte ASN.1-Validierung härten.
5. APK-/Gerätetest.
