# ASTRALIUM – Chat-Handover

**Stand:** 28.11.2026  
**Repository:** https://github.com/firetvstick2k2-afk/Horoskopium  
**Branch:** `development`  
**Aktueller HEAD:** `175cec2c018dfb694abb1c0b14744a42ce9c3aba`  
**Letzter CI-Lauf:** #158 (Run `46175669817`) – vollständig erfolgreich für Android und iOS.  
**Main:** unverändert lassen.

## Aktueller Stand
- Geburtsortsuche mit auswählbaren Treffern speichert Koordinaten, Land und IANA-Zeitzone im Geburtsprofil.
- Profil-Tap führt über `CalculateProfileRadix`, historische IANA-Zeitauflösung und aktive Ephemeriden-Engine zur Radix-Berechnung.
- Fehlende Geburtszeit sowie DST-Lücken/-Dopplungen werden nicht geraten.
- Radix-Ergebnis enthält echte Engine-Positionen, ASC, MC und Häuserdaten, soweit geliefert.
- Hauptaspekte sind integriert: Konjunktion, Sextil, Quadrat, Trigon und Opposition.
- Aspektberechnung erfolgt in `CalculateRadix` an der Anwendungsgrenze, nicht in der Ephemeriden-Engine.
- `ChartCalculationResult` speichert die unveränderliche Aspektliste; Profilberechnungen verwenden denselben Use Case.
- Radix-Grafik zeichnet die gelieferten Planetenpositionen und berechneten Aspektverbindungen. Die Ergebnisansicht listet Aspekte und Orben.
- Standard-Orben (Konjunktion 8°, Sextil 6°, Quadrat 7°, Trigon 7°, Opposition 8°) sind Anwendungs-Defaults und keine universellen Regeln.
- Keine applying/separating-Aussage, da Geschwindigkeitsdaten im Positionsmodell fehlen.
- CI #158 auf HEAD `175cec2c018dfb694abb1c0b14744a42ce9c3aba` vollständig grün: Android-Analyse, Tests, Debug-APK sowie iOS-Analyse, Tests, unsigned Build.
- `docs/FUNKTIONEN.md` enthält den fachlichen Funktionskatalog; Planung und implementierter Stand sind getrennt.
- `docs/HANDOFF.md` ist die ausführlichere technische Übergabe.

## Nächste Schritte
1. Radix-Kreis fachlich/visuell prüfen: Orientierung, Häuser, Glyphen-Kollisionen und Aspektlinien.
2. Gezielte Tests für Aspektdarstellung und Geometrie ergänzen.
3. Ephemeriden- und Häusersystem-Referenztests vervollständigen.
4. Native `flutter_secure_storage`-Funktion auf echten Android-/iOS-Geräten prüfen.
5. Open-Meteo-Bedingungen/Attribution und Fixstern-Datenrechte vor kommerziellem Einsatz klären.
6. Funktionskatalog gemeinsam priorisieren.

## Wichtige fachliche Anforderungen
- Klassische, traditionelle und moderne Astrologie getrennt führen.
- Partnerhoroskop, Familienhoroskop, Kinderhoroskop und Tierhoroskop sind gewünschte Kernbereiche.
- Weitere geplante Themen: Synastrie, Composite, Davison, Transite, Progressionen, Solar/Lunar Return, Drakonisch, Persona, Harmonische, Fixsterne, Asteroiden, Astrogeografie, Relokation, Local Space, Horary, Electional und Mundanastrologie.
- Astrodienst (astro.com) und die Nutzer-PDF „PREISE Astrologie.pdf“ sind Ideen-/Recherchequellen; keine geschützten Texte oder Preise übernehmen.
- Astrologie nicht als Naturwissenschaft oder deterministische Vorhersage darstellen.

## Technische Regeln
- Nur `development`; `main` ausschließlich nach „Bitte Main überschreiben“.
- Vor Änderungen bestehende Datei und Blob-SHA abrufen.
- Package name `horoskopium` und Application-ID nicht eigenmächtig ändern.
- Keine privaten Signierschlüssel oder Kundendaten committen.
- Licence Studio, TSL1-Generator, gemeinsamer Produkt-Claim `topf_secret` und Topf Secret Admin-Aktivierung unverändert lassen.
- Keine CI-/Geräteerfolge behaupten, bevor sie verifiziert sind.
