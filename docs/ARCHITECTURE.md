# Horoskopium – Architekturleitlinien

## Zielbild

Eine gemeinsame Flutter-/Dart-Anwendung für Android und iOS. UI, Datenmodell, Lizenzvalidierung und astrologische Domänenlogik sollen möglichst plattformunabhängig bleiben.

## Vorgeschlagene Schichten

- **Presentation:** Flutter-Oberfläche, Navigation, Eingabeformulare, Chart-Visualisierung.
- **Application:** Anwendungsfälle wie Profil anlegen, Radix berechnen, Transitbericht erstellen.
- **Domain:** Geburtsdaten, Himmelskörper, Häuser, Aspekte, Berechnungsergebnisse und Deutungsmodelle.
- **Infrastructure:** lokale Datenbank, Ephemeridenbibliothek, PDF-Ausgabe und Plattformadapter.

## Astrologische Berechnung

Berechnung und Interpretation strikt trennen:
1. Geburtsdatum, exakte lokale Uhrzeit und Geburtsort erfassen.
2. Zeitzone und historische Sommerzeit zuverlässig auflösen.
3. Geografische Koordinaten bestimmen.
4. Planetenpositionen, Häuserachsen und Aspekte mit einer geprüften Ephemeriden-Engine berechnen.
5. Berechnungsergebnis versioniert speichern.
6. Erst danach Deutungstexte darauf anwenden.

Die Auswahl der Ephemeriden-Engine ist offen. Vor Einbindung sind Genauigkeit, Offline-Fähigkeit, Plattformunterstützung und Lizenzbedingungen zu prüfen. Swiss Ephemeris hat unterschiedliche Lizenzmodelle (u. a. AGPL oder kommerzielle Lizenz); Lizenzpflichten vor Veröffentlichung klären.

## Lizenz

Ein Lizenzschlüssel für Topf Secret und Horoskopium, auf Android und iOS. Bestehendes TSL1-Format, vorhandener Hauptschlüssel und Generator sollen wiederverwendet werden. Die Tokenprüfung wird anhand des Topf-Secret-Quellcodes portiert. Private Signierschlüssel gehören ausschließlich in Licence Studio.

## Datenschutz

Geburtsdatum, Uhrzeit und Ort sind persönliche Daten. Als Ausgangspunkt lokale Speicherung, Datensparsamkeit und keine Übertragung an Server ohne klaren Zweck und ausdrückliche Nutzerinformation. Export und Löschmöglichkeit vorsehen.

## Radix-Visualisierung

- Chartdarstellung als Flutter-CustomPainter, nicht als Rasterbild.
- `InteractiveViewer` stellt Zoom und Verschieben bereit.
- Zeichenring, Häuser-Segmente, Gradeinteilung und Sternenhintergrund sind reine Darstellungselemente.
- Die aktuelle Radix-Ansicht ist ausdrücklich ein visueller Prototyp ohne berechnete Planetenpositionen oder Aspekte. Diese dürfen erst nach Auswahl und Integration einer geprüften Ephemeriden-Engine angezeigt werden.
- Planetensymbole, Achsen (AC/DC/MC/IC), Aspekte und Positionsliste werden datengetrieben aus dem späteren Berechnungsergebnis ergänzt.

## Status

Dies ist eine Leitlinie, keine bereits vollständig implementierte Architektur. Entscheidungen zu Datenbank, Ephemeriden-Engine, PDF-Bibliothek und Backup folgen nach Prototyp und Lizenzprüfung.
