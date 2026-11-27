# Horoskopium – Architekturleitlinien

## Zielbild

Eine gemeinsame Flutter-/Dart-Anwendung für Android und iOS. UI, Datenmodell, Lizenzvalidierung und astrologische Domänenlogik sollen möglichst plattformunabhängig bleiben.

## Verbindliche Schichten

- **Presentation (lib/screens, lib/widgets):** Flutter-Oberfläche, Navigation, Eingabeformulare und Chart-Visualisierung. Keine astronomischen Berechnungen in Widgets.
- **Application (lib/application):** Anwendungsfälle und Ports, z. B. Radix berechnen oder Transitbericht erstellen. Orchestriert Domain und Infrastruktur.
- **Domain (lib/domain):** fachliche, möglichst Flutter-freie Modelle und Regeln: Geburtsdaten, Himmelskörper, Winkel, Häuser, Aspekte und Berechnungsergebnisse.
- **Infrastructure (lib/infrastructure):** konkrete Adapter für Ephemeriden, Zeitzonen-/Ortsauflösung, lokale Speicherung, Lizenzprüfung und PDF-Ausgabe.

## Geplante Projektstruktur

```text
lib/
  main.dart
  application/
    ports/
    use_cases/
  domain/
    astrology/
    profiles/
    licensing/
  infrastructure/
    ephemeris/
    time/
    location/
    storage/
    licensing/
    pdf/
  models/
  screens/
  services/
  widgets/
test/
  domain/
  application/
  infrastructure/
```

Die Struktur wird schrittweise aufgebaut. Bestehende Profile und UI werden nicht in einem großen Umbau verschoben.

## Datenfluss für ein Radix

1. Geburtsprofil enthält Datum, lokale Uhrzeit und Geburtsort.
2. Ortsdienst löst den Ort in geografische Koordinaten auf.
3. Zeitdienst bestimmt anhand des Geburtsorts und des historischen Datums die korrekte Zeitzone einschließlich Sommerzeit und wandelt den lokalen Zeitpunkt in UTC um.
4. Die Application-Schicht übergibt UTC-Zeit, Koordinaten und gewähltes Häusersystem an den Ephemeriden-Port.
5. Ein geprüfter Infrastruktur-Adapter berechnet Planetenpositionen und weitere astronomische Werte.
6. Domain-Validierung prüft das Ergebnis; Berechnungs-Engine und Version werden mitgespeichert.
7. Interpretationslogik erstellt aus den berechneten Faktoren verständliche Texte.
8. Presentation zeigt Chart, Positionen, Aspekte und Deutungen. PDF nutzt dieselben Daten.

## Astrologische Berechnung

Berechnung und Interpretation strikt trennen:
- `ChartCalculationInput` verlangt einen bereits korrekt aufgelösten UTC-Zeitpunkt, valide Koordinaten und ein unterstütztes Häusersystem.
- `EphemerisEngine` ist der austauschbare Port.
- `ChartCalculationResult` enthält berechnete Positionen, ASC/MC, zwölf Hausspitzen sowie angefordertes und tatsächlich verwendetes Häusersystem.
- `CalculateRadix` validiert Eingabe und Ergebnis.
- `HouseCalculator` ist ein reines Dart-Domain-Modul und unabhängig von Hevelius und Flutter.

### Ausgewählte Engine: Hevelius Ephemeris

Die ausgewählte Abhängigkeit **hevelius_ephemeris 0.1.2** (Apache-2.0) ist in `pubspec.yaml` eingetragen. `HeveliusEphemerisEngine` implementiert den `EphemerisEngine`-Port.

- Reines Dart ohne native Bibliotheken; Paketmetadaten weisen Android/iOS aus.
- Berechnet Sonne, Mond, Planeten bis Pluto, Mondknoten und Lilith; Adapter liefert Rückläufigkeit sowie ASC/MC.
- Stellt ARMC und wahre Ekliptikschiefe für die Hausgeometrie bereit.
- JPL-SPK-Dateien sind nicht im Paket enthalten. DE440s ca. 32 MB (1849–2150), DE442 ca. 115 MB (1550–2650); Datenbereitstellung und Nutzungs-/Attributionsbedingungen sind noch zu klären.
- Paket 0.1.x ist jung. Tests, Performance und unabhängige Referenzvergleiche sind vor Produktivnutzung erforderlich.
- 22 mitgelieferte Fixstern-Daten enthalten Hipparcos-Werte unter ESA CC BY-NC 3.0 IGO; kommerzielle Nutzung ist ungeklärt. Bis zur Klärung nicht kommerziell ausliefern.

Der Adapter benötigt eine lokal bereitgestellte JPL-SPK-Datei. Er berechnet derzeit Sonne, Mond, Merkur bis Pluto, mittleren/wahren Mondknoten, mittlere/osculierende Lilith und Rückläufigkeit. Chiron und Asteroiden sind noch nicht angebunden. `fromSpkFilePath` öffnet eine lokale SPK-Datei on demand. Ohne diese Datendatei ist keine echte Planetenberechnung möglich.

### Häusersysteme

Implementiert in `lib/domain/astrology/house_calculator.dart`, ohne zusätzliche Paketabhängigkeit:

- **Placidus** ist das voreingestellte Quadranten-Häusersystem. Die vier Zwischenhäuserspitzen werden iterativ anhand der Teilung der tag-/nachtseitigen Halbkreisbögen in Rektaszension bestimmt.
- **Whole Sign** ist die Alternative. Haus 1 beginnt am Anfang des Tierkreiszeichens, in dem der Aszendent steht; jedes folgende Haus umfasst genau ein Zeichen.
- ASC/DSC und MC/IC werden als gegenüberliegende Achsen übernommen; die übrigen gegenüberliegenden Spitzen werden exakt um 180° gespiegelt.
- Die Umrechnung von Rektaszension in ekliptikale Länge verwendet die Schiefe der Ekliptik.
- Wenn Placidus an der mathematischen Polarkreisgrenze liegt oder eine Zwischenhausspitze circumpolar/nicht lösbar ist, wird ausdrücklich Whole Sign verwendet. Das Ergebnis markiert `usedPolarHouseFallback` und speichert angefordertes und effektives System.
- Unbekannte Systemnamen führen zu einem Fehler.

Prüfstatus:
- Flutter-Analyse deckte zunächst einen doppelten Feld-Initializer und einen fehlenden App-Widgettest auf. Beides wurde korrigiert.
- Ein numerischer Äquator-Test für die Placidus-Semi-Arc-Geometrie wurde ergänzt.
- Die Koordinatentransformation von Rektaszension in ekliptikale Länge wurde bei der Prüfung korrigiert.
- **Noch keine Produktivfreigabe:** unabhängige vollständige Referenzvektoren (z. B. Swiss Ephemeris house tables / `swe_houses_armc`) und reale Radix-Vergleiche müssen noch bestanden werden. Swiss Ephemeris dient dabei nur als Vergleichsreferenz; es wird nicht als Laufzeitbibliothek eingebunden.
- CI muss nach den letzten Korrekturen erneut erfolgreich Analyze, Tests und Android-/iOS-Builds durchlaufen.

## Zeitzonen und Orte

Geburtsort und lokale Geburtszeit sind nicht ausreichend, um UTC ohne Orts-/Zeitzonenauflösung sicher zu bestimmen. Historische Zeitzonenregeln und Sommerzeit müssen für das Geburtsdatum gelten. Bei fehlender oder mehrdeutiger Uhrzeit darf kein scheinbar exakter Aszendent bzw. keine scheinbar exakte Häuserstellung behauptet werden.

## Lizenz

Ein Lizenzschlüssel für Topf Secret und Horoskopium, auf Android und iOS. Bestehendes TSL1-Format, vorhandener Hauptschlüssel und Generator sollen wiederverwendet werden. Private Signierschlüssel gehören ausschließlich in Licence Studio; in Apps liegt nur der öffentliche Prüfschlüssel.

## Datenschutz

Geburtsdatum, Uhrzeit und Ort sind persönliche Daten. Als Ausgangspunkt lokale Speicherung, Datensparsamkeit und keine Übertragung an Server ohne klaren Zweck und ausdrückliche Nutzerinformation. Export und Löschmöglichkeit vorsehen. Die aktuelle Speicherung via SharedPreferences ist noch keine verschlüsselte Datenbank.

## Radix-Visualisierung

- Chartdarstellung als Flutter-CustomPainter, nicht als Rasterbild.
- InteractiveViewer stellt Zoom und Verschieben bereit.
- Die aktuelle Radix-Ansicht ist ein visueller Prototyp ohne berechnete Planetenpositionen oder Aspekte.
- Planetensymbole, Achsen, Aspekte und Positionsliste werden datengetrieben ergänzt, sobald echte Berechnungsergebnisse vorliegen.

## Status

Placidus/Whole Sign sind im Domain-Modul implementiert und in den Hevelius-Adapter integriert. Noch offen sind erfolgreiche CI-Verifikation, vollständige unabhängige Haus-Referenztests, JPL-Datenbereitstellung, historische Zeitzonen-/Geocoding-Adapter, Lizenzintegration, Chart-Anbindung und PDF-Ausgabe.
