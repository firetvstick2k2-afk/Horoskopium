# ASTRALIUM – Handoff

**Stand:** 28.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Aktueller HEAD vor dieser Dokumentationsänderung:** `a193b313dbe7f62c8048037b65e43f11d8792e0c`
**Aktueller Stand:** Geburtsortsuche mit Ergebnisauswahl und Speicherung von Koordinaten/IANA-Zeitzone ist in der Profilmaske integriert. Profile werden über Resolver und aktive Ephemeriden-Engine zur Radix-Berechnung geführt; Ergebnisansicht zeigt berechnete Positionen, Winkel und Häuser. CI für den aktuellen Integrationsstand ist noch ausstehend.

## Funktionsplanung

- Neu: `docs/FUNKTIONEN.md` als lebender fachlicher Funktionskatalog.
- Enthält getrennte Bereiche für klassische, traditionelle und moderne Astrologie.
- Fest eingeplant als fachliche Anforderungen: Partnerhoroskop, Familienhoroskop, Kinderhoroskop und Tierhoroskop.
- Weitere Bereiche: Radix, Synastrie, Composite, Davison, Prognosemethoden, Solar/Lunar Return, Drakonisch, Persona, Harmonische, Fixsterne, Asteroiden, Astrogeografie, Relokation, Local Space, Horary, Electional und Mundanastrologie.
- Der Katalog unterscheidet Planung von Implementierung und enthält Priorisierung, Daten-/Qualitätsanforderungen, Grenzen und offene Entscheidungen.
- Astrodienst (astro.com) und die vom Nutzer bereitgestellte Beispiel-Preisliste dienen als Recherche-/Ideenquellen. Keine Texte, Preise oder geschützten Inhalte werden übernommen.
- Keine App-Funktionalität wurde durch diese Dokumentationsarbeit implementiert.

## TSL1-Lizenzintegration

- Der Nutzer-Screenshot aus Licence Studio bestätigt den öffentlichen EC-Prüfschlüssel. Er stimmt exakt mit dem bereits in Topf Secret eingebetteten Schlüssel überein:
  `MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEO_8xiWBZLIQw--gBpf1Touzg5jPDJLbLHbHiRUlakcvVTgdEcqSBf3-wsU9pzvsF9yCpKZfz4lWWB4bj2LGnQ`.
- Nur der öffentliche Schlüssel wird in ASTRALIUM verwendet. Privater Hauptschlüssel, Licence Studio, Topf Secret und dessen separate Admin-Aktivierung bleiben unverändert.
- Derselbe TSL1-Token soll beide Apps aktivieren. Der bestehende signierte Produkt-Claim `topf_secret` bleibt daher als gemeinsamer Lizenz-Namespace erhalten; der Generator wird nicht verändert.
- Der plattformunabhängige Offline-Prüfer liegt in `lib/infrastructure/licensing/tsl1_license_verifier.dart`; der Lizenzdienst in `lib/services/tsl1_license_service.dart`.
- TSL1-Token werden über `flutter_secure_storage` abgelegt und beim App-Start erneut offline verifiziert.
- Die Aktivierungsseite liegt in `lib/screens/license_screen.dart`. Ablaufstatus und Restlaufzeit werden angezeigt; Deaktivieren entfernt den lokalen Token.
- **CI #115** auf Commit `d2f1113e10436adfdfc2ea3446108cacef91acc0`: Analyse fehlgeschlagen, weil `AstraliumLicense` ohne Import verwendet wurde.
- **Korrektur:** Import in `license_screen.dart` ergänzt.
- **CI #116**, Run `46163201959`, Commit `8b135d96ab2d877a29388e793cf10eb6d2226061`: vollständig erfolgreich (verified status: success).
- CI #114 war ebenfalls erfolgreich; CI #112 wurde vor Tests abgebrochen.
- Reale Android-/iOS-Geräteprüfung der nativen sicheren Speicherung bleibt separat erforderlich.
- Die Lizenzverwaltung sperrt die App nicht global; eine Produktzugriffs-/Sperrpolitik wurde nicht festgelegt.

## Verbindliche Regeln

1. Ausschließlich auf `development` arbeiten.
2. `main` nur nach der ausdrücklichen Formulierung „Bitte Main überschreiben“ verändern.
3. Vor Änderungen bestehender Dateien aktuellen GitHub-Inhalt und SHA abrufen.
4. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
5. Tests und Builds erst nach bestätigtem CI als erfolgreich bezeichnen.
6. Flutter-Paketkennung `horoskopium` und Application-ID nicht ohne ausdrückliche Entscheidung ändern.
7. Licence Studio, produktiven privaten Schlüssel, gemeinsamen TSL1-Produkt-Claim und Topf Secret Admin-Aktivierung nicht verändern.

## Nächste Schritte

1. Funktionskatalog gemeinsam priorisieren und fachliche offene Fragen klären.
2. Reale Android-/iOS-Geräteprüfung der nativen sicheren Speicherung.
3. Geburtsort-Geocoding, Ergebnisauswahl und Speicherung der Ortsmetadaten sind in der Profilmaske integriert.
4. Profile nutzen bei Antippen den Resolver und die aktive Ephemeriden-Engine; Geburtszeit ist für die genaue Radix-Berechnung Pflicht. DST-Lücken/-Dopplungen werden abgewiesen.
5. Radix-Ergebnisansicht zeigt reale Engine-Positionen, Aszendent/MC und Häuserspitzen. Die Radix-Zeichnung ist weiterhin ein Prototyp und noch nicht mit den Ergebnisdaten verbunden; Aspektberechnung/Visualisierung fehlt.
6. CI für die Integrationsänderungen vollständig abwarten, Analyzer-/Testfehler beheben und Hand-off danach mit dem bestätigten Status aktualisieren.
7. Unabhängige Referenztests für Ephemeriden und Häusersysteme; anschließend APK-/Gerätetest.
