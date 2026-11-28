# ASTRALIUM – Chat-Handover

**Stand:** 28.11.2026  
**Repository:** https://github.com/firetvstick2k2-afk/Horoskopium  
**Branch:** `development`  
**Aktueller HEAD vor diesem Handover-Update:** `3765c52188320ff532837625905312ba8eff9136`  
**Main:** unverändert lassen.

## Aktueller Stand
- CI #118 (Run `46165457738`) für Commit `e007078...` erfolgreich.
- CI #125 (Run `46166046070`) schlug wegen eines unbenutzten Imports fehl; der Import wurde entfernt. CI #129 (Run `46167117430`) für die Workflow-Änderung `cancel-in-progress: false` war erfolgreich.
- Geburtsortsuche mit auswählbaren Treffern speichert Koordinaten, Land und IANA-Zeitzone im Geburtsprofil.
- Antippen eines Profils führt über `CalculateProfileRadix`, historische IANA-Auflösung und aktive Ephemeriden-Engine zur Berechnung. Fehlende Geburtszeit wird in der Profilmaske verhindert; DST-Lücken/-Dopplungen werden nicht geraten.
- Radix-Ansicht zeigt die berechneten Planetenpositionen, Aszendent, MC und Häuserspitzen. Die grafische Radix-Zeichnung ist noch nicht datenverbunden; Aspekte fehlen.
- CI-Läufe #130–#137 sind noch nicht als erfolgreich bestätigt; mehrere Push-Runs wurden abgebrochen/queued. Aktuelle Run-Liste vor weiterer Arbeit prüfen.
- Neue Adapter: `BirthPlaceGeocoder`, Open-Meteo-Geocoder, `IanaBirthChartInputResolver`; IANA-Zeitzonen-Datenbank via `timezone`.
- TSL1-Verifier-Importfehler aus CI #115 behoben.
- `docs/FUNKTIONEN.md` neu angelegt: fachlicher Funktionskatalog und Ausbauplanung.
- `docs/HANDOFF.md` enthält technischen Status und Projektregeln.
- Funktionskatalog ist Planung, keine Behauptung bereits implementierter Features.

## Wichtige fachliche Anforderungen
- Klassische, traditionelle und moderne Astrologie getrennt führen.
- Partnerhoroskop, Familienhoroskop, Kinderhoroskop und Tierhoroskop sind ausdrücklich gewünschte Kernbereiche.
- Zusätzlich geplant: Radix, Synastrie, Composite, Davison, Transite, Progressionen, Solar/Lunar Return, Drakonisch, Persona, Harmonische, Fixsterne, Asteroiden, Astrogeografie, Relokation, Local Space, Horary, Electional und Mundanastrologie.
- Astrodienst (astro.com) und die Nutzer-PDF „PREISE Astrologie.pdf“ sind Referenzen für Ideen; keine Übernahme geschützter Texte oder Preise.
- Vor Implementierung gemeinsam priorisieren und fachliche Berechnungsregeln festlegen.

## Technische Regeln
- Nur `development`; `main` ausschließlich nach „Bitte Main überschreiben“.
- Vor Änderungen vorhandene Datei und Blob-SHA abrufen.
- Package name `horoskopium` und Application-ID nicht eigenmächtig ändern.
- Keine privaten Signierschlüssel oder Kundendaten committen.
- Licence Studio, TSL1-Generator, gemeinsamer Produkt-Claim und Topf Secret Admin-Aktivierung unverändert lassen.
- Keine CI-/Geräteerfolge behaupten, bevor sie verifiziert sind.

## Nächste Schritte
1. Neue Funktionsliste gemeinsam prüfen und priorisieren.
2. Native sichere Speicherung auf Android/iOS testen.
3. CI nach Analyzer-Korrektur erneut prüfen und Fehler beheben.
4. CI für die Profil-/Radix-Integration vollständig abwarten und eventuelle Analyzer-/Testfehler beheben.
5. Grafische Radix mit berechneten Positionen verbinden und Aspektberechnung ergänzen.
6. Ephemeriden- und Häusersystem-Referenztests vervollständigen.
