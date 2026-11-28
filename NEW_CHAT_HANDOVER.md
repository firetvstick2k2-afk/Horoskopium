# ASTRALIUM – Chat-Handover

**Stand:** 28.11.2026  
**Repository:** https://github.com/firetvstick2k2-afk/Horoskopium  
**Branch:** `development`  
**Aktueller HEAD:** `ca0b9705070d24a002d1370052d79a9de677f0e2`  
**Main:** unverändert lassen.

## Aktueller Stand
- CI #118 (Run `46165457738`) für Commit `e007078...` erfolgreich.
- CI #125 (Run `46166046070`) auf Commit `043c6b2...` schlug bei `flutter analyze` fehl: genau ein neuer Warning wegen unbenutztem Import im IANA-Resolver. Dieser Import ist in `ca0b970...` entfernt; erneute CI-Prüfung steht aus.
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
4. Geocoding-Auswahl und Resolver-Integration in Profil-/Radix-UI ergänzen.
5. Ephemeriden- und Häusersystem-Referenztests vervollständigen.
