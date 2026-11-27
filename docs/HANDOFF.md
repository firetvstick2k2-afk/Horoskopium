# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Letzter Code-Commit:** `f398976` (Angle-Normalisierung)  
**Letzter Test-Commit:** `d3f9c25` (Whole-Sign-Grenz- und Invarianztests)  
**Letzter Dokumentations-Commit:** wird mit dieser Aktualisierung gesetzt.  
**Status:** Flutter-Grundgerüst, UI-Prototyp, Domain-/Application-Schnittstellen, Hevelius-Adapter sowie Placidus-/Whole-Sign-Berechnung integriert. CI-Lauf **45949515533** auf Commit `04a5a16` ist vollständig erfolgreich: Android und iOS haben Analyze, Tests und Plattform-Builds bestanden; Android-Artefakt wurde hochgeladen. Damit sind Whole-Sign-Grenz- und Invarianztests sowie die vorherigen erweiterten Placidus-Referenztests CI-seitig bestätigt. JPL-SPK-Datei und vollständige fachliche Freigabe von Placidus bleiben offen.

## 1. Verbindliche Arbeitsregeln

1. Ausschließlich auf development arbeiten.
2. main niemals verändern, außer der Nutzer sagt ausdrücklich: „Bitte Main überschreiben“.
3. Vor jeder Änderung bestehender Dateien aktuellen Inhalt und SHA von GitHub abrufen.
4. Änderungen sauber und nachvollziehbar committen.
5. Diese Handoff-Datei bei jedem relevanten Projektfortschritt aktualisieren.
6. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
7. Keine erfolgreichen Tests, Builds oder Hardwareprüfungen behaupten, wenn sie nicht tatsächlich erfolgreich abgeschlossen wurden.
8. Mathematische/astronomische Berechnungen mit unabhängigen Referenzwerten validieren.
9. Funktionierende Komponenten nicht unnötig umbauen; Unsicherheiten prüfen und dokumentieren.

## 2. Produktentscheidungen

- Projektname: **Horoskopium**.
- Plattformen: Android und iOS; gemeinsame Flutter-/Dart-Codebasis.
- Gestaltung: Pergament, Nachtblau und Gold; klassisch und gut lesbar.
- Geplant: Radix, Synastrie/Composite, Transite, Aspekte, Häuser, Planeten, Elemente, Modalitäten, Mondknoten, Chiron, Lilith und PDF-Bericht.
- Berechnung und astrologische Interpretation bleiben strikt getrennt.
- Langfristiges Produktziel: Horoskopium soll nicht nur Horoskope berechnen, sondern daraus individuell zusammengestellte astrologische Analysen und professionell gestaltete PDF-Berichte erzeugen können. Dazu gehören später auswählbare Analyse-Module (z. B. Radix, Liebe/Beziehung, Business/Beruf, Geld, Transite, Solar-Return, Rückkehr-Analysen, Synastrie, Kinderhoroskop und weitere Spezialthemen) sowie ein konfigurierbarer Angebots-/Preiskatalog mit eigenen Beschreibungen, Preisen und Zeitumfängen samt PDF-Preisliste.
- Zusätzlich ausdrücklich gewünscht: **Tierhoroskope für Haustiere** als eigener Analysebereich. Dafür ist ein eigenes Tier-Profil (Tierart, Name und – soweit bekannt – Geburtsdatum, Geburtszeit und Geburtsort) vorzusehen. Unbekannte oder ungenaue Geburtszeiten müssen transparent behandelt werden; keine scheinpräzisen Häuser/AC-Angaben ohne belastbare Zeit. Die astrologische Deutung bleibt als symbolisches Angebot gekennzeichnet.
- Die vom Nutzer bereitgestellte fremde Preisliste (45-seitige PDF) dient ausschließlich als Funktions-/Umfangsinspiration. Keine Übernahme fremder Texte, Preise, Marken- oder Gestaltungselemente.

## 2a. Radix-/Chart-Design

- Großer zentraler Radix-Kreis mit zwölf Tierkreiszeichen und zwölf Häusern.
- Planetensymbole und Positionen; ergänzende Positionsliste.
- Farbige, klar unterscheidbare Aspektlinien.
- Nachtblauer Hintergrund mit dezenten Sternen und goldenen Akzenten.
- Zoom, Verschieben, Touch-Bedienung, responsive Darstellung und antippbare Detailinformationen.
- Technische Präferenz: skalierbare Flutter-CustomPaint-Darstellung.

## 3. Lizenzentscheidung

**Ein und derselbe Lizenzschlüssel soll sowohl Topf Secret als auch Horoskopium aktivieren.**
- Licence-Studio-Generator und vorhandener privater Hauptschlüssel bleiben unverändert.
- Bestehendes TSL1-Tokenformat und ECDSA-P-256/SHA-256 werden wiederverwendet.
- In Apps liegt nur der öffentliche Prüfschlüssel.
- TSL1-Portierung aus Topf Secret ist noch nicht implementiert.

## 4. Aktueller technischer Stand

- Flutter-Grundlage, Startbildschirm, Profile und Radix-Visual-Prototyp vorhanden.
- Profile werden lokal mit SharedPreferences gespeichert; keine verschlüsselte Datenbank bisher.
- Domain-Modelle:
  - `angle.dart`, `celestial_position.dart`
  - `chart_calculation_input.dart`: UTC-Zeit, Koordinaten, Häusersystem
  - `chart_calculation_result.dart`: Positionen, Engine-Version, ASC/MC, zwölf Hausspitzen und System-/Fallback-Metadaten
  - `house_calculator.dart`: eigenständige Placidus-/Whole-Sign-Berechnung
- Application: `EphemerisEngine` Port und `CalculateRadix` Use Case.
- Hevelius `hevelius_ephemeris: ^0.1.2`; Dart SDK-Untergrenze `>=3.13.7`.
- Adapter `lib/infrastructure/ephemeris/hevelius_ephemeris_engine.dart` berechnet Sonne, Mond, Planeten bis Pluto, Mondknoten, Lilith, Rückläufigkeit, ASC/MC und übergibt ARMC/wahre Ekliptikschiefe an die Hausberechnung.
- **JPL-SPK-Datei fehlt:** Sie ist weder im Repository noch im App-Bundle und wird nicht automatisch bereitgestellt. Ohne lokale SPK-Datei gibt es keine echten Planetenpositionen.
- **Datenstrategie (Recherche 27.11.2026):** Als erste mobile Standarddatei ist `de440s.bsp` vorgesehen (ca. 31–32 MB, Abdeckung 1849–2150). JPL/NAIF führt sie im offiziellen SPK-Verzeichnis. Hevelius 0.1.2 nennt DE440s als Standard-Download; die Paket-Dokumentation beschreibt SHA-256-Prüfung und dateibasiertes Öffnen ohne komplettes Einlesen in den RAM. DE442 (ca. 114–115 MB, 1550–2650) bleibt eine spätere Option für erweiterte historische Abdeckung; DE441 (ca. 3,3 GB) ist für die mobile Standardinstallation ausdrücklich ungeeignet.
- **Bereitstellungsprinzip:** SPK nicht ins Git-Repository oder direkt ins APK/IPA committen/bundlen. Download nur nach ausdrücklicher Nutzeraktion bzw. beim erstmaligen Setup mit klarer Anzeige von Dateigröße, Abdeckung, WLAN/Mobilfunk und Speicherbedarf; Download in temporäre Datei, Integritätsprüfung anhand eines vertrauenswürdig eingebetteten SHA-256-Werts, erst danach atomar in den finalen App-Datenpfad übernehmen. Vorhandene gültige Datei weiterverwenden; bei Abbruch/Fehler keine beschädigte Datei als verfügbar markieren. Offline-Nutzung nach erfolgreichem Download.
- **Noch nicht implementiert/abgesichert:** Android-/iOS-Dateipfad und Berechtigungen, HTTP-Download mit Resume/Retry, SHA-256-Validierung im App-Code, Dateiversions-/Schema-Metadaten, Speicherplatzprüfung, Update-/Löschverhalten und UI-Setup. Erst nach Klärung dieser Punkte den Downloader bauen.
- **Lizenz-/Attribution:** JPL/NAIF stellt das SPK-Verzeichnis öffentlich bereit und bittet um angemessene Quellenangabe/Referenzierung. Das ist keine pauschale Lizenzfreigabe für sämtliche Daten, Bibliotheken oder Drittinhalte. Hevelius-Code hat Apache-2.0; Paket- und Dritt-Datenhinweise/NOTICE müssen mitgeliefert werden. Fixsternwerte mit ESA-NC-Klausel bleiben ausgeschlossen. Als geplante App-Attribution: „Planetary ephemeris: JPL DE440s (NASA/JPL NAIF); calculations by Hevelius.“ Vor kommerzieller Veröffentlichung die konkreten JPL-Datenbedingungen und alle Notices nochmals rechtlich prüfen.
- Chiron und Asteroiden sind noch nicht im Adapter eingebunden.
- Hevelius-Fixsternwerte mit ESA CC BY-NC 3.0 IGO bis zur Klärung kommerzieller Rechte nicht verwenden.

## 4a. Häusersysteme

Implementierung in `lib/domain/astrology/house_calculator.dart`, keine zusätzliche Abhängigkeit:
- **Placidus** ist Standard. Vier Zwischenhäuserspitzen werden iterativ anhand der Teilung der tag-/nachtseitigen Halbkreisbögen in Rektaszension bestimmt.
- **Whole Sign** ist Alternative; Haus 1 beginnt am Zeichenanfang des Aszendentenzeichens.
- ASC/DSC, MC/IC und gegenüberliegende Spitzen werden als Achsen behandelt; Koordinatentransformation berücksichtigt die Ekliptikschiefe. Die Umrechnung der Zwischenhaus-Rektaszensionen in ekliptikale Länge verwendet die inverse Beziehung `lambda = atan2(sin(RA), cos(RA) * cos(epsilon))`. Die Deklination aus RA wird korrekt über `delta = atan2(sin(epsilon) * sin(RA), cos(epsilon))` berechnet.
- Bei mathematischer Polarkreisgrenze oder nicht lösbarer/circumpolarer Zwischenhausspitze wird transparent auf Whole Sign zurückgefallen.
- Ergebnis speichert gewünschtes und effektives System plus `usedPolarHouseFallback`.
- Unbekannte Häusersysteme werden abgewiesen.

### Whole-Sign-Prüfung (27.11.2026)

- Regel unabhängig anhand der Definition geprüft: Haus 1 beginnt am Anfang des tropischen 30°-Zeichens, in dem die ekliptikale Länge des Aszendenten liegt; die folgenden Häuser beginnen jeweils 30° später.
- Die Implementierung verwendet dafür `floor(ASC / 30) * 30` und normalisiert jede Spitze in den Bereich [0°, 360°). MC, ARMC, geografische Breite und Obliquität bestimmen bei Whole Sign nicht die Hausspitzen; sie bleiben Eingabeparameter der gemeinsamen Calculator-Schnittstelle und werden weiterhin auf gültige Werte geprüft.
- Neue Regressionstests decken ASC genau auf 0°/30°/90°, knapp unter und über Zeichenwechseln sowie knapp unter 360° ab.
- Zusätzlich werden alle zwölf möglichen aufsteigenden Zeichen durchlaufen und jeweils zwölf lückenlose 30°-Hausintervalle geprüft.
- Invarianztest: identischer ASC mit unterschiedlichen MC-/ARMC-/Breiten-/Obliquitätswerten ergibt identische Whole-Sign-Spitzen. Tests prüfen außerdem System-Aliase und Ablehnung nicht normalisierter ASC-Werte.
- Testergänzung in Commit `d3f9c25`; CI-Ergebnis ist nach dem Push noch abzuwarten. Diese Prüfungen bestätigen die Umsetzung der Whole-Sign-Geometrie, ersetzen aber keine End-to-End-Radixprüfung mit verifizierter Ephemeride.

### Test- und Prüfstatus

- Die zuvor in diesem Dokument als behoben bezeichnete doppelte Initialisierung in `chart_calculation_result.dart` war im tatsächlichen HEAD `7943fae` weiterhin vorhanden. Die Dokumentation war an dieser Stelle falsch.
- Lauf **45940062310** (Commit `7943fae`) ist fehlgeschlagen:
  - Android-Job `140313137736`: `flutter analyze` meldete `field_initialized_in_parameter_and_initializer` in `chart_calculation_result.dart:16`.
  - iOS-Job `140313137946`: derselbe Fehler.
  - Zusätzlich unbenutzter Material-Import in `test/widget_test.dart`.
  - Tests und Plattform-Builds wurden wegen des Analyze-Fehlers übersprungen.
- Korrekturen auf development:
  - Commit `232cae814c2413ba3f181de2493f7d3502d53702`: Konstruktorparameter von `required this.positions` auf `required List<CelestialPosition> positions` geändert; unveränderliche Kopie wird genau einmal im Initializer angelegt.
  - Commit `f56ddc785e878a75c0bc840ddb14a7e6719d040c`: unbenutzten `material.dart`-Import aus `test/widget_test.dart` entfernt.
- Nach den Codekorrekturen liefen `45943315071` (Commit `232cae8`) und `45943318974` (Commit `f56ddc7`); beide wurden durch neuere Pushes abgebrochen. Lauf `45943344345` (Commit `7d1e016`) wurde abgeschlossen mit Failure: beide Plattformen scheiterten erneut bei `flutter analyze`; die sieben Meldungen waren ausschließlich Info-Diagnosen (vier deprecated_member_use für `package:flutter/material.dart`, drei prefer_const_constructors). Keine Errors oder Warnings wurden ausgegeben. Tests und Plattform-Builds wurden daher übersprungen.
- Verifizierte Ursache: Das aktuelle Flutter-Stable-`flutter analyze` behandelt Info-Level-Diagnosen standardmäßig als fatal. CI-Datei `.github/workflows/flutter-ci.yml` wurde in Commit `ad28a75bbba4ac3fc5aaf053608d90249c8844ee` geändert: beide Analyze-Schritte verwenden nun `flutter analyze --no-fatal-infos`. Fehler und Warnings bleiben fatal; Info-Hinweise bleiben sichtbar, blockieren aber nicht den Build.
- Lauf **45943723699** (Commit `040b336`) bestätigt: Android- und iOS-Analyze erfolgreich. Beide Jobs scheiterten im Schritt `flutter test` am selben Widget-Fehler: `A RenderFlex overflowed by 25 pixels on the bottom`, verursacht durch die Text-/Icon-Column in `RadixPreview` bei Constraints von 96 × 96 px (`lib/widgets/radix_preview.dart:20`). Sieben andere Tests bestanden, darunter vier Angle-/HouseCalculator-Tests. Android-APK und iOS-Build wurden wegen des Testfehlers übersprungen.
- Korrektur in Commit `b2fa38410f64f60198b4bb34209e5128dfb90e42`: Die Beschriftungs-Column in `RadixPreview` wird nur bei `size >= 150` gerendert. Bei der 96-px-Kachel auf dem Startbildschirm bleibt die Radix-Grafik ohne zu kleine Mittelbeschriftung erhalten.
- CI-Lauf **45944214217** (HEAD `c41f875` mit obiger RadixPreview-Korrektur) vollständig erfolgreich: Android Analyze, Tests, Debug-APK und Upload erfolgreich; iOS Analyze, Tests und unsigned Build erfolgreich.
- Unabhängige mathematische Prüfung fand zwei Fehler im bisherigen Placidus-Solver. Erstens war `_rightAscensionToLongitude` in die falsche Richtung transformiert: Korrekt ist `atan2(sin(RA), cos(RA) * cos(epsilon))`, abgeleitet aus `RA = atan2(sin(lambda) * cos(epsilon), cos(lambda))`. Zweitens war die Deklination aus RA fälschlich als `asin(sin(RA) * sin(epsilon))` berechnet. Korrekt ist `atan2(sin(epsilon) * sin(RA), cos(epsilon))`, entsprechend `tan(delta) = tan(epsilon) * sin(RA)`.
- Referenzabgleich mit Swiss Ephemeris 2.10.03 (`swe.houses_armc`, Placidus) und dem unabhängigen Quellcode `swehouse.c` (`Asc1`/`Asc2`): https://github.com/astrotools/SwissEphemeris/blob/master/swisseph/swehouse.c. Swiss Ephemeris wird ausschließlich als Referenz, nicht als Runtime-Abhängigkeit verwendet.
- Die vier Zwischenhausspitzen stimmen nach beiden Korrekturen in den geprüften Fällen auf < 1e-6° mit den unabhängigen Referenzwerten überein: ARMC 0°/Breite 0°/ε 23.4391667°; ARMC 340°/48.4° N; ARMC 150°/33.9° S; ARMC 20°/60° N. Für den Äquatorfall lauten die vier Werte 32.1812349°, 62.0894279°, 117.9105721° und 147.8187651°.
- Codekorrekturen: `3fbe837` (RA→Länge), `0249d1a` und `da1095d` (RA→Deklination und Zentralisierung). Regressionstests für Äquator, mittlere nördliche Breite, südliche Hemisphäre und 60° N in Commit `7512083`. **CI-Prüfung dieser letzten Änderungen steht noch aus.**
- Ältere Placidus-Korrektur-Commits: `4a212a7f3ce6d950b78a84ff986ba06d29b49caf` (Projektion/Polar-Fallback) und `3fd0b2f9806deb24c79f724b283dc6da29c889c5` (numerischer Äquator-Test).
- CI-Lauf **45946804855** (Commit `9abd9c6`) ist fehlgeschlagen. Analyze war auf Android und iOS erfolgreich; in beiden Jobs bestanden 14 Tests und dieselben zwei Placidus-Tests scheiterten beim Erzeugen von `HouseCalculation`, weil eine numerisch knapp negative RA→Länge-Rundung nach Addition von 360° exakt `360.0` statt `0.0` ergab. Ursache: `Angle.normalize` konnte durch Floating-Point-Rundung den dokumentierten halboffenen Bereich [0, 360) verletzen.
- Korrektur in Commit `f398976`: Nach dem Wrap wird ein auf `>= 360` gerundeter Wert auf 0 gesetzt. Regressionstest für `Angle.normalize(-1e-14)` in Commit `45dfcb1`. CI-Lauf **45947220605** (HEAD `dc98e57`) ist vollständig erfolgreich: Android Analyze, alle Tests, Debug-APK und Artifact-Upload sowie iOS Analyze, alle Tests und unsigned Build bestanden. Damit sind auch die Placidus-Fälle aus 50° S und 55° N nach der Normalisierungskorrektur bestätigt.
- Erweiterte unabhängige Referenzprüfung mit Swiss Ephemeris 2.10.03 (swe.houses_armc, System Placidus): zusätzliche ARMC-/Breitenfälle 45°/20° N, 210°/50° S und 300°/55° N. In allen Fällen stimmen alle zwölf Hausspitzen einschließlich der Wrap-around-Werte 0°/360° bis auf numerische Rundung mit dem Referenzsystem überein.
- Polargrenzprüfung: Bei ε = 23.44° ist die Grenze 90° − ε = 66.56°. Der Fall 66.559° N (ARMC 45°) liefert noch gültige Placidus-Häuser und stimmt für alle zwölf Spitzen mit Swiss Ephemeris überein. Genau bei 66.56° greift der explizite Whole-Sign-Fallback.
- Diese zusätzlichen Regressionstests wurden in Commit `51e86a9` ergänzt. Der zugehörige CI-Lauf ist nach dem Push noch zu prüfen.
- Erweiterte unabhängige Rasterprüfung am 27.11.2026: 1.584 Kombinationen aus ARMC (15°-Schritten über 360°), Breiten in Nord- und Südhalbkugel sowie sechs Obliquitätswerten (22°, 23°, 23.4391667°, 23.44°, 24° und 24.5°) wurden mit Swiss Ephemeris 2.10.03 (swe.houses_armc, Placidus) verglichen. In allen 1.584 Fällen stimmten alle zwölf Spitzen mit maximaler Abweichung < 0.000001° überein; alle Hausbögen waren positiv und die Gegenüberliegend-Beziehungen korrekt. Dies ist ein unabhängiger numerischer Vergleich des Dart-Algorithmus-Portes, noch kein automatisierter Lauf des Dart-Codes über alle 1.584 Fälle.
- Drei zusätzliche vollständige Zwölf-Häuser-Regressionstests mit unabhängigen Swiss-Referenzvektoren wurden in Commit `3fe0f97` ergänzt: 37° N / ε=23°, 42° S / ε=24.5° sowie 12° N / ε=22°. Die Tests prüfen zusätzlich positive Hausbögen und Gegenüberliegend-Beziehungen. CI-Lauf **45948518404** für diesen Test-Commit war beim letzten Statusabruf pending.
- CI-Lauf **45947700544** (Commit `640af1b`, Handoff-Dokumentation nach dem Angle-Fix) ist vollständig erfolgreich: Android Analyze, Tests, Debug-APK und Artifact-Upload sowie iOS Analyze, Tests und unsigned Build.
- **Placidus ist ausdrücklich NICHT fachlich freigegeben:** unabhängige vollständige Referenzvektoren (z. B. Swiss-Ephemeris-`swe_houses_armc`) und reale Radix-Stichproben fehlen. Swiss Ephemeris ist nur Vergleichsreferenz, keine Runtime-Abhängigkeit.
- Vor Freigabe mehrere Breitengrade (Äquator, mittlere und hohe Breiten, beide Hemisphären), mehrere ARMC-Werte, alle zwölf Spitzen, Achsen, Reihenfolge, Gegenüberliegende und Polargrenzfälle unabhängig vergleichen.

## 4b. Hevelius und JPL-Daten

- Hevelius 0.1.2 ist laut Paketmetadaten reines Dart und Apache-2.0; Android/iOS werden unterstützt.
- DE440s ist als erste mobile Standarddatei festgelegt (ca. 31–32 MB; 1849–2150); DE442 bleibt optionale spätere Erweiterung (ca. 114–115 MB; 1550–2650). Offizieller Download-Index: https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/.
- Hevelius-Paketdokumentation: Download-Script mit SHA-256-Prüfung; Datei wird aus lokalem Pfad mit `openSpkFile` verwendet. Der bestehende Adapter öffnet bereits einen lokalen Pfad.
- Noch keine mobile Download-/Installationslogik, keine SHA-Verifikation in Horoskopium und keine tatsächliche SPK-Datei im App-Sandbox-Pfad. Keine Planetenberechnung als produktionsbereit ausgeben, bis dies integriert und auf beiden Plattformen getestet ist.
- Paket ist jung (0.1.x); Plattformtests und unabhängige Vergleiche bleiben Pflicht.

## 5. Nächste Schritte

1. SPK-Downloader/Installer für DE440s entwerfen und implementieren: Plattformpfade, HTTPS-Download, SHA-256-Integrität, temporäre Datei/atomarer Abschluss, Abbruch/Retry und Offline-Status.
2. Echte DE440s-Datei auf Android und iOS installieren und Hevelius gegen dokumentierte JPL-Horizons-Referenzfälle testen.
3. Placidus weiterhin fachlich prüfen und reale Radix-Stichproben gegen unabhängige Referenzen validieren; nicht vorzeitig freigeben.
5. Historische Zeitzonen-/Sommerzeit-Auflösung und Geocoding/Koordinatenstrategie.
6. TSL1-Verifikation aus Topf Secret portieren; Generator nicht ändern.
7. Profile-Datenschutz, Export/Import und Migration verbessern.
8. Radix-Chart, Aspekte, Interpretationen und PDF datengetrieben vervollständigen.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
