# ASTRALIUM – Chat-Handover

**Stand:** 28.11.2026  
**Repository:** https://github.com/firetvstick2k2-afk/Horoskopium  
**Branch:** `development`  
**Letzter verifizierter HEAD vor der aktuellen Dokumentationsänderung:** `8b135d96ab2d877a29388e793cf10eb6d2226061`  
**Main:** unverändert lassen.

## Aktueller Stand
- CI #116 (Run `46163201959`) für Commit `8b135d96...` erfolgreich.
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
3. Geocoding und historische Zeitzonen integrieren.
4. Ephemeriden- und Häusersystem-Referenztests vervollständigen.
