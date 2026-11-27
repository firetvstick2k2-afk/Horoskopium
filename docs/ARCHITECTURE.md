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
    ports/                 # Schnittstellen zu technischen Diensten
    use_cases/             # fachliche Anwendungsabläufe
  domain/
    astrology/             # Winkel, Positionen, Häuser, Aspekte, Radix
    profiles/              # Geburtsprofil-Fachmodell
    licensing/             # Lizenzstatus und Regeln (ohne private Schlüssel)
  infrastructure/
    ephemeris/             # Adapter der ausgewählten Ephemeriden-Engine
    time/                  # Zeitzonen und historische DST-Auflösung
    location/              # Geocoding und Koordinaten
    storage/               # lokale Persistenz und Migrationen
    licensing/             # TSL1-Prüfung mit öffentlichem Schlüssel
    pdf/                   # Berichtserzeugung
  models/                  # bestehende UI-nahe Modelle; schrittweise migrieren
  screens/
  services/                # bestehende Services; schrittweise migrieren
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

Berechnung und Interpretation strikt trennen. Die aktuelle Implementierung legt nur die Schnittstelle fest:
- ChartCalculationInput verlangt einen bereits korrekt aufgelösten UTC-Zeitpunkt und valide Koordinaten.
- EphemerisEngine ist der austauschbare Port.
- ChartCalculationResult enthält berechnete Positionen sowie Engine-ID und Version.
- CalculateRadix validiert Eingabe und Ergebnis.

Die Hevelius-Engine ist als Infrastruktur-Adapter integriert. Die JPL-SPK-Datei muss zur Laufzeit als lokale Datei bereitgestellt werden; ohne passende Datendatei ist keine Positionsberechnung möglich. Keine Dummy-Positionen oder erfundenen Aspekte in echte Charts übernehmen.

### Ausgewählte Engine: Hevelius Ephemeris

Die ausgewählte Abhängigkeit **hevelius_ephemeris 0.1.2** (Apache-2.0) ist in `pubspec.yaml` eingetragen. `HeveliusEphemerisEngine` in `lib/infrastructure/ephemeris/hevelius_ephemeris_engine.dart` implementiert den `EphemerisEngine`-Port. Die bestehende Application-/Domain-Schnittstelle bleibt die Grenze zur Bibliothek.

Begründung:
- Reines Dart ohne native Bibliotheken und ohne Flutter-Abhängigkeit; laut Paketmetadaten für Android und iOS ausgewiesen.
- Berechnet geozentrische ekliptikale Positionen für Sonne, Mond, Planeten und Pluto sowie Chiron und mehrere Asteroiden.
- Enthält mittleren/wahren Mondknoten, mittlere/osculierende Lilith und Längengeschwindigkeiten für Rückläufigkeit.
- Stellt Aszendent und MC bereit.
- Paketcode steht unter Apache-2.0; Lizenz- und NOTICE-Hinweise müssen in der ausgelieferten App erhalten bleiben.

Wichtige Einschränkungen und offene Prüfungen:
- Paketversion 0.1.2 verlangt Dart SDK `^3.13.7`; die App-SDK-Untergrenze wurde auf `>=3.13.7` angehoben. CI muss die tatsächliche Flutter-/Dart-Kompatibilität noch bestätigen.
- Die dokumentierte freie API stellt Aszendent und MC bereit, aber keine vollständigen Häuserspitzen bzw. Häusersysteme; die Hevelius-Website führt astrologische Häusersysteme als Pro-Funktion. Hausberechnung muss daher separat und lizenzkompatibel ergänzt werden. Keine Häuser aus unbestätigten Annahmen ableiten.
- Die mitgelieferten 22 Fixstern-Daten enthalten Hipparcos-Werte mit ESA CC BY-NC 3.0 IGO; eine kommerzielle Nutzungserlaubnis ist laut NOTICE noch offen. Diese Fixstern-Daten dürfen wir bis zur Klärung nicht in einer kommerziellen Horoskopium-Ausgabe verwenden. Die Kernberechnung der Planetenpositionen ist davon getrennt.
- Die JPL-Ephemeridendateien sind nicht im Paket enthalten. DE440s umfasst etwa 32 MB und den Zeitraum 1849–2150; DE442 etwa 115 MB und 1550–2650. Datenbereitstellung, Speicherbedarf, Offline-Installation und die jeweiligen NOTICE-/Quellenhinweise müssen vor der endgültigen Auswahl des Datenpakets geprüft werden.
- Das Paket ist jung (0.1.x). Vor produktiver Nutzung sind API, Tests, Performance auf Android/iOS und Vergleichsrechnungen mit unabhängigen Referenzen zu prüfen.

Der Adapter berechnet Sonne, Mond, Merkur bis Pluto, mittleren/wahren Mondknoten sowie mittlere/osculierende Lilith und liefert ASC/MC. Rückläufigkeit wird aus der Längengeschwindigkeit abgeleitet. Die Engine erhält ein bereits geöffnetes `Ephemeris`-Objekt; `fromSpkFilePath` öffnet eine lokale SPK-Datei on demand. Die JPL-Datei wird derzeit weder mitgeliefert noch automatisch heruntergeladen/kopiert. Die Bibliothek wird nicht direkt aus Widgets oder UI-Code aufgerufen. Version und Datenbestand werden festgehalten, damit Ergebnisse reproduzierbar bleiben. Ephemera bleibt Rückfalloption.

## Zeitzonen und Orte

Geburtsort und lokale Geburtszeit sind nicht ausreichend, um UTC ohne Orts-/Zeitzonenauflösung sicher zu bestimmen. Historische Zeitzonenregeln und Sommerzeit müssen für das Geburtsdatum gelten. Bei fehlender oder mehrdeutiger Uhrzeit darf kein scheinbar exakter Aszendent bzw. keine scheinbar exakte Häuserstellung behauptet werden.

## Lizenz

Ein Lizenzschlüssel für Topf Secret und Horoskopium, auf Android und iOS. Bestehendes TSL1-Format, vorhandener Hauptschlüssel und Generator sollen wiederverwendet werden. Die Tokenprüfung wird anhand des Topf-Secret-Quellcodes portiert. Private Signierschlüssel gehören ausschließlich in Licence Studio; in Apps liegt nur der öffentliche Prüfschlüssel.

## Datenschutz

Geburtsdatum, Uhrzeit und Ort sind persönliche Daten. Als Ausgangspunkt lokale Speicherung, Datensparsamkeit und keine Übertragung an Server ohne klaren Zweck und ausdrückliche Nutzerinformation. Export und Löschmöglichkeit vorsehen. Die aktuelle Speicherung via SharedPreferences ist noch keine verschlüsselte Datenbank.

## Radix-Visualisierung

- Chartdarstellung als Flutter-CustomPainter, nicht als Rasterbild.
- InteractiveViewer stellt Zoom und Verschieben bereit.
- Zeichenring, Häuser-Segmente, Gradeinteilung und Sternenhintergrund sind reine Darstellungselemente.
- Die aktuelle Radix-Ansicht ist ausdrücklich ein visueller Prototyp ohne berechnete Planetenpositionen oder Aspekte.
- Planetensymbole, Achsen (AC/DC/MC/IC), Aspekte und Positionsliste werden datengetrieben aus dem späteren Berechnungsergebnis ergänzt.

## Status

Domain-/Application-Bausteine sowie Hevelius-Abhängigkeit und Adapter sind angelegt. Der Adapter benötigt eine lokal bereitgestellte JPL-SPK-Datei. Noch offen sind JPL-Datenbereitstellung/-Lizenzprüfung, Häuserspitzen, historische Zeitzonen-/Geocoding-Adapter, Lizenzintegration, Chart-Anbindung und PDF-Bibliothek.
