# ASTRALIUM – Handoff

**Stand:** 28.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** `development`  
**Aktueller HEAD:** `175cec2c018dfb694abb1c0b14744a42ce9c3aba`  
**Letzter bestätigter CI-Lauf:** CI #158, Run `46175669817`, vollständig erfolgreich auf dem aktuellen HEAD (Android: Analyse, Tests, Debug-APK; iOS: Analyse, Tests, unsigned Build).

## Aktueller technischer Stand

### Geburtsprofile und Radix
- Geburtsortsuche mit auswählbaren Treffern speichert Koordinaten, Land und IANA-Zeitzone im Geburtsprofil.
- `CalculateProfileRadix` führt Profile über `IanaBirthChartInputResolver` und die aktive Ephemeriden-Engine zur Berechnung.
- Historische IANA-Zeitzonen werden für die Umrechnung lokaler Geburtszeit nach UTC verwendet. Fehlende Geburtszeit sowie nicht eindeutige/nicht existente DST-Zeiten werden nicht geraten.
- Radix-Ergebnis enthält reale Engine-Positionen, Aszendent, MC und Häuserspitzen, soweit von der Berechnung geliefert.
- `RadixPreview` zeichnet echte Positionen, Tierkreisring, vorhandene Häuserspitzen, ASC/MC-Achsen und jetzt auch berechnete Hauptaspekt-Verbindungen.
- `RadixScreen` listet zusätzlich erkannte Hauptaspekte mit Orbis.

### Hauptaspekte – neu integriert
- `lib/domain/astrology/aspect_calculator.dart`: Konjunktion, Sextil, Quadrat, Trigon und Opposition.
- Standard-Orben: 8° / 6° / 7° / 7° / 8°. Das sind konfigurierbare Anwendungs-Defaults, keine universellen astrologischen Regeln.
- `CalculateRadix` berechnet Aspekte an der Anwendungsgrenze aus den vom Engine-Ergebnis gelieferten ekliptischen Längenpositionen.
- `ChartCalculationResult` enthält eine unveränderliche Aspektliste und `withAspects` zur Anreicherung.
- `CalculateProfileRadix` verwendet bereits `CalculateRadix`; damit durchläuft auch der Profil-Workflow die Aspektberechnung.
- Die Ephemeriden-Engine und ihr Port/Vertrag wurden für diese Funktion nicht geändert.
- Applying/separating wird nicht behauptet, da die aktuelle Positionsstruktur keine Längengeschwindigkeit bereitstellt.
- Aspekte werden nur aus real gelieferten Positionen berechnet; es gibt keine geschätzten Aspektlinien.

## Letzter CI-Stand
- CI #152, Run `46174397878`, Commit `2c9f006145fe0bd357821021a3456ad94a22c569`: success.
- CI #153, Run `46175622835`: success auf einem Zwischenstand.
- CI #158, Run `46175669817`, HEAD `175cec2c018dfb694abb1c0b14744a42ce9c3aba`: success; dies ist der aktuelle maßgebliche grüne Stand.
- Mehrere Zwischenläufe #154–#157 wurden durch nachfolgende Pushes abgebrochen/ersetzt; sie sind nicht der maßgebliche Endlauf.

## Funktionsplanung
- `docs/FUNKTIONEN.md` ist der lebende fachliche Funktionskatalog.
- Getrennte Bereiche für klassische, traditionelle und moderne Astrologie.
- Gewünschte Bereiche: Partnerhoroskop, Familienhoroskop, Kinderhoroskop, Tierhoroskop; außerdem Synastrie, Composite, Davison, Prognosemethoden, Solar/Lunar Return, Drakonisch, Persona, Harmonische, Fixsterne, Asteroiden, Astrogeografie, Relokation, Local Space, Horary, Electional und Mundanastrologie.
- Planung ist klar von bereits implementierten Funktionen zu unterscheiden.
- Astrodienst (astro.com) und die vom Nutzer bereitgestellte Beispiel-Preisliste dienen als Ideen-/Recherchequellen. Keine Texte, Preise oder geschützten Inhalte übernehmen.

## TSL1-Lizenzintegration
- Nur der öffentliche EC-Prüfschlüssel wird in ASTRALIUM verwendet. Privater Hauptschlüssel, Licence Studio, Topf Secret und dessen separate Admin-Aktivierung bleiben unverändert.
- Gemeinsamer signierter Produkt-Claim `topf_secret` bleibt unverändert; Generator wird nicht verändert.
- Offline-Prüfer: `lib/infrastructure/licensing/tsl1_license_verifier.dart`; Dienst: `lib/services/tsl1_license_service.dart`.
- Token werden über `flutter_secure_storage` abgelegt und beim Start offline verifiziert.
- Reale Android-/iOS-Geräteprüfung der nativen sicheren Speicherung bleibt offen.
- Keine globale App-Sperrpolitik beschlossen.

## Verbindliche Regeln
1. Ausschließlich auf `development` arbeiten.
2. `main` nur nach der ausdrücklichen Formulierung „Bitte Main überschreiben“ verändern.
3. Vor Änderungen bestehender Dateien aktuellen GitHub-Inhalt und Blob-SHA abrufen.
4. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
5. Tests und Builds erst nach bestätigtem CI als erfolgreich bezeichnen.
6. Flutter-Paketkennung `horoskopium` und Application-ID nicht ohne ausdrückliche Entscheidung ändern.
7. Licence Studio, produktiven privaten Schlüssel, gemeinsamen TSL1-Produkt-Claim und Topf Secret Admin-Aktivierung nicht verändern.

## Nächste Schritte
1. Radix-Darstellung fachlich und visuell prüfen: Zeichenring-Orientierung, Hausachsen, Glyphen-Kollisionen und Aspektlinien.
2. Zusätzliche Tests für Aspektdarstellung/Geometrie und Ergebnisdaten ergänzen.
3. Unabhängige Referenztests für Ephemeriden und Häusersysteme vervollständigen.
4. Native sichere Speicherung auf echten Android-/iOS-Geräten prüfen.
5. Open-Meteo-Nutzungsbedingungen/Attribution für kommerzielle Nutzung klären; ebenso Rechte an Fixstern-Daten vor kommerziellem Einsatz.
6. Funktionskatalog gemeinsam priorisieren.
