# ASTRALIUM – Handoff

**Stand:** 28.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Ausgangs-HEAD:** `cc0c61c49d4c178be9b3d172b012994801c5439d`

## TSL1-Lizenzintegration – erster Schritt

- Der Nutzer-Screenshot aus Licence Studio bestätigt den öffentlichen EC-Prüfschlüssel. Er stimmt exakt mit dem bereits in Topf Secret eingebetteten Schlüssel überein:
  `MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEO_8xiWBZLIQw--gBpf1Touzg5jPDJLbLHbHiRUlakcvVTgdEcqSBf3-wsU9pzvsF9yCpKZfz4lWWB4bj2LGnQ`.
- Nur der öffentliche Schlüssel wird in ASTRALIUM verwendet. Privater Hauptschlüssel, Licence Studio, Topf Secret und dessen separate Admin-Aktivierung bleiben unverändert.
- Derselbe TSL1-Token soll beide Apps aktivieren. Der bestehende signierte Produkt-Claim `topf_secret` bleibt daher als gemeinsamer Lizenz-Namespace erhalten; der Generator wird nicht verändert.
- Neues plattformunabhängiges Offline-Prüfmodul: `lib/infrastructure/licensing/tsl1_license_verifier.dart`. Es prüft Tokenstruktur, ECDSA-P-256/SHA-256-Signatur, Version, Produkt-Claim, Lizenztyp, UUID, Ausstellungszeit, Kundenname sowie Ablauf-/Dauerfelder.
- PointyCastle wird für die ECDSA-Prüfung verwendet. Negativtests für fehlerhafte Tokenformate und ungültige Signaturen wurden ergänzt.
- CI #109 zeigte einen Wiring-Fehler: `HomeScreen` reichte den Lizenzdienst beim Öffnen der Einstellungen nicht weiter. Die Übergabe wurde korrigiert; der Fehler trat identisch in Android- und iOS-Analyse auf.
- Lizenzdienst ergänzt: `lib/services/tsl1_license_service.dart`. TSL1-Token werden über `flutter_secure_storage` verschlüsselt im plattformspezifischen sicheren Speicher abgelegt (Android Keystore-basierte Verschlüsselung / iOS Keychain).
- Beim App-Start wird der gespeicherte Token erneut offline verifiziert. Status: nicht aktiviert, aktiv, ungültig/abgelaufen oder Speicherfehler.
- Aktivierungsseite ergänzt: `lib/screens/license_screen.dart`; erreichbar über Einstellungen. Aktivieren speichert nur nach erfolgreicher Signatur- und Ablaufprüfung. Deaktivieren entfernt den lokalen Token.
- Die Lizenzverwaltung ist zunächst informativ und sperrt nicht global die App. Eine Produktzugriffs-/Sperrpolitik wurde noch nicht festgelegt.
- Noch offen: positiver Ende-zu-Ende-Test mit einem gültigen temporären TSL1-Token aus Licence Studio, reale Geräteprüfung und Entscheidung über eine mögliche Gerätebindung.
- Eine gültige Signatur allein bedeutet noch keine Gerätebindung. Keine privaten Schlüssel oder Kundendaten in die App oder das Repository übernehmen.

## Verbindliche Regeln

1. Ausschließlich auf `development` arbeiten.
2. `main` nur nach der ausdrücklichen Formulierung „Bitte Main überschreiben“ verändern.
3. Vor Änderungen bestehender Dateien aktuellen GitHub-Inhalt und SHA abrufen.
4. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
5. Tests und Builds erst nach bestätigtem CI als erfolgreich bezeichnen.
6. Flutter-Paketkennung `horoskopium` und Application-ID nicht ohne ausdrückliche Entscheidung ändern.

## Nächste Schritte

1. CI für sichere Speicherung und Aktivierungsoberfläche prüfen; Fehler bei Bedarf korrigieren.
2. Positiven Ende-zu-Ende-Test mit einem temporären gültigen TSL1-Token aus Licence Studio ermöglichen, ohne den produktiven privaten Schlüssel zu exportieren.
3. Danach Geocoding und historische IANA-Zeitzonenauflösung.
