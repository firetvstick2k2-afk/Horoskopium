# ASTRALIUM – Handoff

**Stand:** 28.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Aktueller Stand:** TSL1-Verifier portiert; Ablaufstatus und Restzeitanzeige ergänzt; CI #115 Fehlerursache identifiziert, Korrektur eingereicht.

## TSL1-Lizenzintegration

- Der Nutzer-Screenshot aus Licence Studio bestätigt den öffentlichen EC-Prüfschlüssel. Er stimmt exakt mit dem bereits in Topf Secret eingebetteten Schlüssel überein:
  `MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEO_8xiWBZLIQw--gBpf1Touzg5jPDJLbLHbHiRUlakcvVTgdEcqSBf3-wsU9pzvsF9yCpKZfz4lWWB4bj2LGnQ`.
- Nur der öffentliche Schlüssel wird in ASTRALIUM verwendet. Privater Hauptschlüssel, Licence Studio, Topf Secret und dessen separate Admin-Aktivierung bleiben unverändert.
- Derselbe TSL1-Token soll beide Apps aktivieren. Der bestehende signierte Produkt-Claim `topf_secret` bleibt daher als gemeinsamer Lizenz-Namespace erhalten; der Generator wird nicht verändert.
- Das plattformunabhängige Offline-Prüfmodul in `lib/infrastructure/licensing/tsl1_license_verifier.dart` ist ein Dart-Port von `Topf_Secret/app/src/main/java/de/topfsecret/app/LicenseVerifier.kt`. Tokenformat, X.509-P-256-Schlüssel, SHA256withECDSA-Prüfung, Produkt-Claim, Lizenztypen, UUID, Ausstellungszeit und Ablauf-/Dauerfelder folgen derselben Payload- und Prüfsemantik.
- Der Verifier akzeptiert für Tests bereits einen injizierbaren öffentlichen Schlüssel. Der produktive öffentliche Schlüssel bleibt der unveränderte Standardwert.
- Der Lizenzdienst liegt in `lib/services/tsl1_license_service.dart`. TSL1-Token werden über `flutter_secure_storage` im plattformspezifischen sicheren Speicher abgelegt. Beim App-Start wird der gespeicherte Token erneut offline verifiziert.
- Die Aktivierungsseite liegt in `lib/screens/license_screen.dart`; erreichbar über Einstellungen. Aktivieren speichert nur nach erfolgreicher Signatur- und Ablaufprüfung. Der Ablauf wird zeitgenau überwacht; Restlaufzeit wird sekündlich aktualisiert. Abgelaufene, korrekt signierte Tokens bleiben zur Anzeige ihrer Ablaufdaten erkennbar, gelten aber nicht als aktiv. Deaktivieren entfernt den lokalen Token.
- **CI #115** auf `development`, Commit `d2f1113e10436adfdfc2ea3446108cacef91acc0`: Analyse auf Android und iOS fehlgeschlagen, weil `license_screen.dart` den Typ `AstraliumLicense` verwendete, ohne die Datei `tsl1_license_verifier.dart` zu importieren. Tests und Builds wurden deshalb übersprungen.
- **Korrektur:** Import des Typs `AstraliumLicense` in `license_screen.dart` ergänzt. CI nach diesem Commit muss Analyse, Tests und Builds auf beiden Plattformen bestätigen.
- **CI #111** auf `development`: vollständig erfolgreich. Android- und iOS-Analyse, Tests und Builds bestanden; Android-Debug-APK wurde hochgeladen.
- **CI #113** auf `development`: positiver TSL1-Test, Analyse und Builds vollständig erfolgreich auf Android und iOS. CI #112 wurde durch den unmittelbar folgenden Commit abgebrochen, bevor Flutter-Setup und Tests starteten.
- **CI #114** auf `development`, Commit `17772cb4ae189645722781eda30a34ffd0b56a03`: vollständig erfolgreich. TSL1-Verifier-Port und End-to-End-Tests sind auf Android und iOS grün.
- Positiver TSL1-Test: Ein temporäres P-256-Schlüsselpaar wird zur Laufzeit im Test erzeugt. Kein privater Produktionsschlüssel und keine Kundendaten werden verwendet oder committed. Geprüft werden Signaturvalidierung, Aktivierung, Speicherung, Wiederherstellung und Ablaufgrenze.
- Reale Android-/iOS-Geräteprüfung der nativen sicheren Speicher bleibt separat erforderlich.
- Eine gültige Signatur allein bedeutet noch keine Gerätebindung. Keine privaten Schlüssel oder Kundendaten in die App oder das Repository übernehmen.
- Die Lizenzverwaltung ist informativ und sperrt nicht global die App. Eine Produktzugriffs-/Sperrpolitik wurde nicht festgelegt.

## Verbindliche Regeln

1. Ausschließlich auf `development` arbeiten.
2. `main` nur nach der ausdrücklichen Formulierung „Bitte Main überschreiben“ verändern.
3. Vor Änderungen bestehender Dateien aktuellen GitHub-Inhalt und SHA abrufen.
4. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
5. Tests und Builds erst nach bestätigtem CI als erfolgreich bezeichnen.
6. Flutter-Paketkennung `horoskopium` und Application-ID nicht ohne ausdrückliche Entscheidung ändern.
7. Licence Studio, produktiven privaten Schlüssel, gemeinsamen TSL1-Produkt-Claim und Topf Secret Admin-Aktivierung nicht verändern.

## Nächste Schritte

1. Reale Android-/iOS-Geräteprüfung der nativen sicheren Speicherung.
2. Anschließend Geocoding und historische IANA-Zeitzonenauflösung.
3. DER-Signaturparser und Tokenformat bei Bedarf weiter gegen reale Licence-Studio-Testtokens abgleichen.
4. APK-/Gerätetest.
