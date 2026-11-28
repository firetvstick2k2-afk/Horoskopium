# ASTRALIUM – Handoff

**Stand:** 28.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Ausgangs-HEAD:** `ed599e1bea260e60335dd8285845ca3bb5c59991`

## TSL1-Lizenzintegration – erster Schritt

- Der Nutzer-Screenshot aus Licence Studio bestätigt den öffentlichen EC-Prüfschlüssel. Er stimmt exakt mit dem bereits in Topf Secret eingebetteten Schlüssel überein:
  `MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEO_8xiWBZLIQw--gBpf1Touzg5jPDJLbLHbHiRUlakcvVTgdEcqSBf3-wsU9pzvsF9yCpKZfz4lWWB4bj2LGnQ`.
- Nur der öffentliche Schlüssel wird in ASTRALIUM verwendet. Privater Hauptschlüssel, Licence Studio, Topf Secret und dessen separate Admin-Aktivierung bleiben unverändert.
- Derselbe TSL1-Token soll beide Apps aktivieren. Der bestehende signierte Produkt-Claim `topf_secret` bleibt daher als gemeinsamer Lizenz-Namespace erhalten; der Generator wird nicht verändert.
- Neues plattformunabhängiges Offline-Prüfmodul: `lib/infrastructure/licensing/tsl1_license_verifier.dart`. Es prüft Tokenstruktur, ECDSA-P-256/SHA-256-Signatur, Version, Produkt-Claim, Lizenztyp, UUID, Ausstellungszeit, Kundenname sowie Ablauf-/Dauerfelder.
- PointyCastle wird für die ECDSA-Prüfung verwendet. Negativtests für fehlerhafte Tokenformate und ungültige Signaturen wurden ergänzt.
- Noch nicht umgesetzt: Aktivierungsoberfläche, sichere lokale Speicherung, Reaktivierung nach Neustart, Gerätebindung und Prüfung eines echten Licence-Studio-Testtokens.
- Eine gültige Signatur allein bedeutet noch keine Gerätebindung. Keine privaten Schlüssel oder Kundendaten in die App oder das Repository übernehmen.

## Verbindliche Regeln

1. Ausschließlich auf `development` arbeiten.
2. `main` nur nach der ausdrücklichen Formulierung „Bitte Main überschreiben“ verändern.
3. Vor Änderungen bestehender Dateien aktuellen GitHub-Inhalt und SHA abrufen.
4. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
5. Tests und Builds erst nach bestätigtem CI als erfolgreich bezeichnen.
6. Flutter-Paketkennung `horoskopium` und Application-ID nicht ohne ausdrückliche Entscheidung ändern.

## Nächste Schritte

1. CI für den TSL1-Prüfer abwarten und Fehler korrigieren.
2. Einen Test mit einem temporären gültigen TSL1-Token aus Licence Studio ermöglichen, ohne den produktiven privaten Schlüssel zu exportieren.
3. Lizenzstatus lokal speichern und Aktivierungs-/Deaktivierungsoberfläche ergänzen.
4. Danach Geocoding und historische IANA-Zeitzonenauflösung.
