# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** `firetvstick2k2-afk/Horoskopium`  
**Arbeitsbranch:** `development`  
**Status:** Projektgrundgerüst und erster UI-Prototyp

## 1. Verbindliche Arbeitsregeln

1. Ausschließlich auf `development arbeiten.
2. `main` niemals verändern, außer der Nutzer sagt ausdrücklich: **„Bitte Main überschreiben“**.
3. Vor jeder Änderung bestehender Dateien aktuellen Inhalt und SHA von GitHub abrufen.
4. Änderungen sauber und nachvollziehbar committen.
5. Diese Handoff-Datei bei jedem relevanten Projektfortschritt aktualisieren.
6. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.

## 2. Produktentscheidungen

- Projektname: **Horoskopium** (Arbeitstitel).
- Plattformen: Android und iOS von Anfang an.
- Technologie: Flutter / Dart, gemeinsame Codebasis.
- Gestaltung: klassisch, mit Pergament-, Nachtblau- und Goldtönen.
- Deutungen: maximal ausführlich und verständlich.
- Mehrere Geburtsprofile sollen möglich sein.
- Geplant sind Radix/Geburtshoroskop, Partnerschaft (Synastrie und Composit), Transite, Aspekte, Häuser, Planeten, Elemente, Modalitäten, Mondknoten, Chiron und Lilith.
- Umfangreiche Textdeutungen und exportierbarer PDF-Bericht.

## 3. Lizenzentscheidung – besonders wichtig

Der Nutzer hat ausdrücklich entschieden:

**Ein und derselbe Lizenzschlüssel soll sowohl Topf Secret als auch Horoskopium aktivieren.**

Daraus folgt:
- Vorhandener Licence-Studio-Generator bleibt unverändert.
- Vorhandener privater Hauptschlüssel bleibt unverändert.
- Vorhandenes TSL1-Tokenformat und ECDSA-P-256/SHA-256-Verfahren werden wiederverwendet.
- Horoskopium soll dieselben bestehenden Tokens akzeptieren, die Topf Secret akzeptiert.
- Derselbe Key soll auf Android und iOS funktionieren.
- In den Apps liegt ausschließlich der öffentliche Prüfschlüssel; niemals der private Hauptschlüssel.
- Kundenname/Bezeichnung kann frei sein (z. B. „Andre.Horoskopium“ oder „Andre Topf Secret“); sie ist nicht der kryptografische Produkttrenner.

**Wichtig für die Umsetzung:** Die bestehende Topf-Secret-Tokenprüfung muss aus dem aktuellen Quellcode übernommen werden. Keine neue Produktkennung verlangen, wenn dadurch alte Tokens nicht mehr funktionieren. Vor Implementierung die tatsächliche Payload-Prüfung und Signaturkodierung im Topf-Secret-Repository nachsehen und mit Testtokens prüfen. Keine Annahme als bereits umgesetzt darstellen.

## 4. Aktueller technischer Stand

- Flutter-Paketgrundlage angelegt.
- Erster Startbildschirm mit klassischer Farbwelt angelegt.
- Noch keine echte Geburtsdatenerfassung, Profile, Ephemeridenberechnung, Lizenzaktivierung oder PDF-Erzeugung.
- Android-/iOS-Plattformrunner müssen lokal einmalig erzeugt werden:
  `flutter create . --project-name horoskopium --platforms=android,ios`.
- Es wurde in diesem Schritt kein Flutter-Build ausgeführt; Buildfähigkeit ist daher noch nicht bestätigt.

## 5. Nächste Schritte

1. Flutter-Plattformrunner und CI-Build für Android/iOS einrichten.
2. Topf Secret Quellcode zur TSL1-Prüfung lesen und Horoskopium-kompatible Dart-Prüfung planen.
3. Lizenztest mit einem bestehenden, ausdrücklich bereitgestellten Testtoken; keine echten Kundentokens in GitHub einchecken.
4. Geburtsprofile lokal und datenschutzfreundlich implementieren.
5. Ephemeriden-Engine und deren Lizenzbedingungen prüfen (Swiss Ephemeris: AGPL bzw. kommerzielle Lizenz beachten).
6. Radix-Berechnung, Häuser, Aspekte und Chart-Wheel.
7. Deutungsinhalte und PDF-Berichte.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
