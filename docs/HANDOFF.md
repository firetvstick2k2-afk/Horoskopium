# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Letzter Code-/Test-Commit:** `ffb869f4` (app-weite EphemerisRuntime und Lifecycle-Regressionstests); CI für diesen neuen Runtime-Code steht noch aus. Architekturentscheidung: `docs/EPHEMERIS_RUNTIME_DESIGN.md` (Commit `0744b81f`).  
**Letzter vollständig erfolgreicher CI-Lauf:** **46062638336** (Run #84) auf Commit `b4d634ae`; Android und iOS haben Analyze, sämtliche Tests und ihre Plattform-Builds bestanden. Android-Debug-APK wurde erfolgreich gebaut und als Artifact hochgeladen. Der Code-Test-Commit `0061e799` ist in diesem Nachfolge-Commit enthalten und damit CI-validiert. Der separate Lauf #83 (`46062622219`) wurde durch den unmittelbar folgenden Push abgebrochen, hatte keine Jobs und ist kein Testfehler.  
**Vorheriger Runner-Abbruch:** Lauf `46035145817` auf `d6adb361` hatte einen erfolgreichen Android-Job; der iOS-Job wurde nach längerer macOS-Runner-Wartezeit ohne Start abgebrochen (`cancelled`, keine Steps). Der iOS-Job wurde nicht wegen eines Code-/Testfehlers abgebrochen. Der nächste Code-Lauf `46040817288` lief anschließend auf beiden Plattformen vollständig erfolgreich.  
**Status:** Flutter-Grundgerüst, UI-Prototyp, Domain-/Application-Schnittstellen, Hevelius-Adapter, Placidus-/Whole-Sign-Berechnung und erster JPL-Downloadmanager sind integriert. DE440s/DE442 können heruntergeladen und lokal per SHA-256 geprüft werden. Die SPK-Datei ist noch nicht mit dem Radix-Use-Case verbunden und wurde noch nicht auf realen Geräten validiert. Placidus bleibt trotz umfangreicher mathematischer Referenztests bis zur End-to-End-Prüfung fachlich nicht freigegeben.

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
- **JPL-SPK-Datei fehlt weiterhin lokal auf dem Gerät:** Sie ist weder im Repository noch im App-Bundle enthalten. Die Downloadverwaltung kann sie nun auf das Gerät laden; solange keine gültige Datei geladen und an die Engine angebunden ist, gibt es keine echten Planetenpositionen im Radix-Use-Case.
- **Datenstrategie (Recherche 27.11.2026):** Für die App werden zwei direkt ladbare Pakete angeboten: `de440s.bsp` (ca. 32 MB, 1849–2150) als kompakte Option und `de442.bsp` (ca. 115 MB, 1550–2650) als empfohlene Standardoption. Die aktuelle Hevelius-API-Dokumentation empfiehlt DE442 für allgemeine Nutzung und bestätigt die größere Abdeckung; der Paket-Downloader enthält feste SHA-256-Prüfsummen für beide Dateien. DE441 (ca. 3,3 GB, −13.200 bis +17.191) bleibt eine spätere Spezialoption und wird nicht im ersten mobilen Downloadmanager angeboten.
- **Bereitstellungsprinzip:** SPK nicht ins Git-Repository oder direkt ins APK/IPA committen/bundlen. Download nur nach ausdrücklicher Nutzeraktion bzw. beim erstmaligen Setup mit klarer Anzeige von Dateigröße, Abdeckung, WLAN/Mobilfunk und Speicherbedarf; Download in temporäre Datei, Integritätsprüfung anhand eines vertrauenswürdig eingebetteten SHA-256-Werts, erst danach atomar in den finalen App-Datenpfad übernehmen. Vorhandene gültige Datei weiterverwenden; bei Abbruch/Fehler keine beschädigte Datei als verfügbar markieren. Offline-Nutzung nach erfolgreichem Download.
- **Erster Implementierungsschritt (27.11.2026):** `lib/services/ephemeris_download_service.dart` enthält einen nativen HTTPS-Download für DE440s/DE442 in den App-Support-Pfad (`path_provider`), eine temporäre `.part`-Datei, Content-Length-Prüfung, SHA-256-Prüfung mit fest im App-Code verankerten Prüfsummen und Übernahme erst nach erfolgreicher Prüfung. Bereits vorhandene Dateien werden bei jedem Statuscheck erneut gehasht; ungültige Dateien werden entfernt. `lib/screens/settings_screen.dart` bietet unter Einstellungen beide Pakete, Abdeckungszeitraum, ungefähre Größe, Installationsstatus, Fortschrittsanzeige und Löschen. Der Startbildschirm hat einen Einstellungen-Button. Dependencies `crypto` und `path_provider` wurden ergänzt. Ein Metadaten-Test wurde angelegt.
- **Noch offen:** Resume/Fortsetzen, expliziter Abbruch, Retry-UX, Speicherplatzprüfung, Versions-/Manifestmodell, atomarer Austausch einer bereits installierten Version mit Rollback, Hintergrunddownload, tatsächliche Installation und Hevelius-Laufzeitintegration mit der heruntergeladenen Datei. Die UI markiert Dateien derzeit als lokal gespeichert; sie werden noch nicht automatisch vom Radix-Use-Case geöffnet. Keine reale Android-/iOS-Geräteprüfung bisher. CI-Lauf **45951090740** für den aktuellen Stand `295ce6e` war beim letzten Statusabruf noch `pending` (GitHub hatte noch keine Jobs bereitgestellt); neue Downloadfunktion ist daher noch nicht als CI-bestanden bestätigt.
- **Lizenz-/Attribution:** JPL/NAIF stellt das SPK-Verzeichnis öffentlich bereit und bittet um angemessene Quellenangabe/Referenzierung. Das ist keine pauschale Lizenzfreigabe für sämtliche Daten, Bibliotheken oder Drittinhalte. Hevelius-Code hat Apache-2.0; Paket- und Dritt-Datenhinweise/NOTICE müssen mitgeliefert werden. Fixsternwerte mit ESA-NC-Klausel bleiben ausgeschlossen. Als geplante App-Attribution: „Planetary ephemeris: JPL DE442 (NASA/JPL NAIF); calculations by Hevelius.“ Vor kommerzieller Veröffentlichung die konkreten JPL-Datenbedingungen und alle Notices nochmals rechtlich prüfen.
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
- Testergänzung in Commit `d3f9c25`; im vollständig erfolgreichen CI-Lauf **45949515533** (HEAD `04a5a16`) liefen Android-/iOS-Analyse, Tests und Builds erfolgreich. Diese Prüfungen bestätigen die Umsetzung der Whole-Sign-Geometrie, ersetzen aber keine End-to-End-Radixprüfung mit verifizierter Ephemeride.

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
- Drei zusätzliche vollständige Zwölf-Häuser-Regressionstests mit unabhängigen Swiss-Referenzvektoren wurden in Commit `3fe0f97` ergänzt: 37° N / ε=23°, 42° S / ε=24.5° sowie 12° N / ε=22°. Die Tests prüfen zusätzlich positive Hausbögen und Gegenüberliegend-Beziehungen. Diese Tests waren im späteren vollständig erfolgreichen CI-Lauf **45949515533** enthalten.
- CI-Lauf **45947700544** (Commit `640af1b`, Handoff-Dokumentation nach dem Angle-Fix) ist vollständig erfolgreich: Android Analyze, Tests, Debug-APK und Artifact-Upload sowie iOS Analyze, Tests und unsigned Build.
- **Placidus ist ausdrücklich NICHT fachlich freigegeben:** unabhängige vollständige Referenzvektoren (z. B. Swiss-Ephemeris-`swe_houses_armc`) und reale Radix-Stichproben fehlen. Swiss Ephemeris ist nur Vergleichsreferenz, keine Runtime-Abhängigkeit.
- Vor Freigabe mehrere Breitengrade (Äquator, mittlere und hohe Breiten, beide Hemisphären), mehrere ARMC-Werte, alle zwölf Spitzen, Achsen, Reihenfolge, Gegenüberliegende und Polargrenzfälle unabhängig vergleichen.

## 4b. Hevelius und JPL-Daten

- Hevelius `hevelius_ephemeris: ^0.1.2` ist reines Dart und unterstützt Android/iOS. Die Bibliothek liest JPL-SPK-Dateien bei Bedarf von der Festplatte; sie lädt die Dateien nicht selbst herunter.
- Die aktuelle Auswahl im Downloadmanager: DE440s (ca. 32 MB, 1849–2150) als kompakte Option und DE442 (ca. 115 MB, 1550–2650) als empfohlene Option. Hevelius-Dokumentation empfiehlt DE442 für allgemeine Nutzung. DE441 (ca. 3,3 GB) wird in der mobilen App vorerst nicht angeboten.
- `EphemerisDownloadService` lädt die offizielle JPL-Datei in den App-Support-Pfad, schreibt zunächst eine `.part`-Datei, prüft Content-Length soweit vom Server geliefert und validiert anschließend die fest hinterlegte SHA-256-Prüfsumme. Erst danach wird die Datei übernommen.
- **Dateiaustausch (Commit `de20325`):** Eine bereits vorhandene gültige Datei wird vor dem Austausch in eine `.bak`-Datei umbenannt. Scheitert die Übernahme der geprüften neuen Datei, wird die vorherige Version zurückbenannt. Beim nächsten Statuscheck wird ein unterbrochener Austausch anhand der Prüfsumme wiederhergestellt; eine gültige Backup-Datei wird bevorzugt erhalten. Das ist eine Recovery-Absicherung, noch kein vollständiges transaktionales Dateisystemprotokoll.
- **Wichtige Hevelius-Lebensdauer-Einschränkung:** `openSpkFile(path)` öffnet intern eine `RandomAccessFile` synchron und hält sie laut Paketdokumentation bis zum Programmende offen. Es gibt in der geprüften API keinen Close-Pfad. Deshalb darf eine einmal von der Engine geöffnete SPK-Datei während der Engine-Laufzeit nicht gelöscht, ersetzt oder verschoben werden. Die spätere Integration braucht einen klaren App-weiten Engine-/Datei-Lebenszyklus; Einstellungen dürfen aktive Kernel nicht entfernen. Ein Neustart der App kann als sicherer Zeitpunkt für Kernelwechsel/Löschung dienen.
- Die Einstellungsseite zeigt derzeit „Lokal gespeichert“ und ermöglicht Download/Löschen. Es gibt noch keine Auswahl eines aktiven Kernels, keine Engine-Factory/Provider-Integration und keine Verbindung von `CalculateRadix` mit einer geladenen SPK-Datei.
- **CI:** Lauf **45952385504** auf Commit `06c12cdc` ist vollständig erfolgreich: Android Analyze, Tests, Debug-APK und Artifact-Upload sowie iOS Analyze, Tests und unsigned Build. Dieser Commit enthält auch den Code aus `de20325`; der separate Lauf `45952337375` für `de20325` wurde durch den nachfolgenden Push abgebrochen. Damit ist `de20325` über den erfolgreichen Nachfolge-Commit CI-abgedeckt. Die Testability-/Recovery-Änderungen `48de9a7`, `be3d176` und `b9f25d96` sind durch `46023467331` abgedeckt. Die zusätzlichen HTTP-Tests aus `80440079` sind durch den vollständig erfolgreichen Lauf `46040817288` auf Android und iOS abgedeckt.
- **Testbarkeit (27.11.2026):** `EphemerisDownloadService` akzeptiert jetzt optional einen Support-Directory-Provider und eine `HttpClient`-Factory. Die Standardwerte bleiben `getApplicationSupportDirectory` und `HttpClient.new`; damit ändert sich das normale App-Verhalten nicht. Vier isolierte Dateisystemtests prüfen: Wiederherstellung einer gültigen `.bak` bei fehlendem Ziel, Wiederherstellung über einer beschädigten Zieldatei, Beibehaltung einer gültigen Zieldatei mit Entfernen eines veralteten Backups sowie Entfernen ungültiger Dateien, wenn kein gültiges Backup existiert. Fünf HTTP-Tests in `test/infrastructure/ephemeris_download_http_test.dart` prüfen einen vollständigen Download mit SHA-256-Validierung und Fortschritt, einen chunked Download ohne `Content-Length` mit erfolgreicher SHA-256-Validierung, die Ablehnung einer HTTP-503-Antwort samt Entfernen der `.part`-Datei, eine Prüfsummenabweichung bei Erhalt einer zuvor gültigen Zieldatei sowie einen abrupten Netzwerkabbruch während des Antwort-Streams. Der Abbruchtest sendet absichtlich nur einen Teil der angekündigten Bytes und zerstört anschließend den Socket. Er prüft, dass der Download fehlschlägt, die `.part`-Datei entfernt wird und eine zuvor gültige Zieldatei unverändert erhalten bleibt. Der vollständige CI-Lauf `46055579030` (Run #81, Commit `d0275092`) bestätigte auf Android und iOS erfolgreich Analyze, sämtliche Tests und Plattform-Builds; Android-Debug-APK samt Artifact-Upload ebenfalls erfolgreich. Der zusätzliche chunked-Test ohne `Content-Length` aus Commit `0061e799` ist durch den erfolgreichen Nachfolge-CI-Lauf `46062638336` (Run #84, Commit `b4d634ae`) ebenfalls auf Android und iOS bestätigt. Lauf #83 (`46062622219`) wurde vor dem Start der Jobs durch den Dokumentations-Push abgebrochen; Run #84 hat den Code-Commit vollständig mitgetestet. Neu ergänzt: injizierbare Datei-Umbenennung im Downloadservice und Regressionstest, der einen Fehler beim Promotion-Schritt simuliert und die Wiederherstellung der vorherigen Datei prüft; Commit `09dbd1b8`. Der direkte Lauf #87 (`46068748614`) wurde beim Push des Handoff-Commits abgebrochen, bevor Analyze oder Tests starteten. Der erfolgreiche Nachfolge-Lauf #88 (`46068763061`, Commit `a1169099`) hat den Rollback-Test auf Android und iOS vollständig ausgeführt; Android-Debug-APK und Artifact-Upload sowie iOS-Unsigned-Build ebenfalls erfolgreich.
- Keine reale Android-/iOS-Geräteprüfung und kein tatsächlicher JPL-SPK-Download auf einem Gerät bisher. Keine Planetenberechnung als produktionsbereit bezeichnen, bevor Download, Öffnen, Abdeckung und astronomische Referenzfälle auf beiden Plattformen validiert wurden.
- JPL/NAIF-Datenbedingungen und alle Drittanbieter-Notices vor kommerzieller Veröffentlichung erneut prüfen. Hevelius-Code ist Apache-2.0. Fixsternwerte mit ESA CC BY-NC 3.0 IGO bleiben bis zur Klärung kommerzieller Rechte ausgeschlossen.
- Chiron und Asteroiden sind im Horoskopium-Adapter noch nicht eingebunden.
### EphemerisRuntime – erster Implementierungsschritt

- Neue Klasse `lib/infrastructure/ephemeris/ephemeris_runtime.dart` (Commit `e02aba02`, danach Katalog-Injektion `b86655a4`): zentraler Runtime-Owner, der eine Engine-Instanz besitzt, gespeicherte Kernel-ID über SharedPreferences wiederherstellen kann und parallele Restore-/Activate-Aufrufe dedupliziert.
- Aktivierung prüft Kernel-ID gegen den injizierbaren Katalog und validiert die lokale Datei erneut über `EphemerisDownloadService.installedPath()` (inkl. SHA-256/Recovery), bevor `HeveliusEphemerisEngine.fromSpkFilePath()` einmalig aufgerufen wird.
- Nach Aktivierung wird derselbe Engine-Verweis wiederverwendet. Wechsel auf einen anderen Kernel wird abgelehnt; Löschung des aktiven Kernels wird unterhalb der UI blockiert. Inaktive Kernel können über die Runtime gelöscht werden.
- Fehler beim Persistieren der Auswahl nach erfolgreichem Open lassen die Engine bewusst aktiv; eine erneute Öffnung im selben Prozess wird verhindert. Ein Restore mit unbekannter Kernel-ID öffnet keine Datei.
- Tests in `test/infrastructure/ephemeris_runtime_test.dart` decken derzeit keine Auswahl, einmalige Aktivierung/Identität, Kernelwechsel-Sperre, Löschschutz, parallelen Restore, ungültige Datei und unbekannte gespeicherte ID ab.
- Commit `ffb869f4` enthält die Tests; CI noch ausstehend. Runtime ist noch nicht am App-Root oder in der Settings-UI verdrahtet. Vorher müssen CI und die Runtime-Tests grün sein; anschließend Settings-Status/Schutz integrieren.

### Engine-/SPK-Lebenszyklus (Architekturentscheidung 27.11.2026)

- Architekturentwurf in `docs/EPHEMERIS_RUNTIME_DESIGN.md` (Commit `0744b81f`): ein app-weiter Runtime-Owner besitzt die einzige Hevelius-Engine pro App-Prozess; lazy Öffnung und Restore der gespeicherten Kernel-ID; idempotente Aktivierung; kein Live-Wechsel; aktiver Kernel darf nicht gelöscht oder ersetzt werden.
- Die Runtime ist die einzige Instanz, die Engine-Öffnung und Kernel-Löschschutz kontrolliert. Screens erhalten keine eigenen Hevelius-Engines. Download-Service bleibt zuständig für Download/Hash/Datei-Recovery, kennt aber nicht die aktive Engine.
- Einstellungen sollen „Lokal gespeichert“ klar von „Aktiv für Berechnungen“ unterscheiden. Kernelwechsel erst nach App-Neustart.
- Verifizierte API-Randbedingung: `openSpkFile(path)` liest SPK-Daten bei Bedarf von Disk; der Datei-Handle bleibt laut Hevelius-Dokumentation bis zum Programmende geöffnet. Daher keine aktive Datei verschieben/löschen/ersetzen. Noch keine Runtime-Implementierung und keine Geräteintegration; dies ist zunächst die verbindliche Designgrundlage.

## 5. Nächste Schritte

1. Die vier Recovery-Tests und fünf HTTP-/Integritätstests sind vorhanden. Der erste Runtime-Owner samt sieben Lifecycle-Tests ist in `ffb869f4` ergänzt; CI steht noch aus. Der letzte vollständig erfolgreiche CI-Lauf ist `46062638336` (Run #84) auf `b4d634ae`; er enthält und validiert auch den chunked-Test aus `0061e799` auf Android und iOS. Lauf #83 wurde ohne gestartete Jobs durch den Folge-Push abgebrochen. Der neue Rollback-Test für einen simulierten Fehler beim Umbenennen der geprüften `.part`-Datei wurde in `09dbd1b8` ergänzt und durch CI-Lauf #88 (`46068763061`, Commit `a1169099`) auf Android und iOS erfolgreich bestätigt. Lauf #87 (`46068748614`) wurde während des Folge-Pushs vor Analyze/Tests abgebrochen; #88 enthält den Testcommit vollständig. Der Abbruchtest bestätigt, dass `.part` entfernt und die vorherige gültige Datei erhalten bleibt. Als Nächstes Dateiaustausch-Fehler und Rollback gezielt testbar machen.
2. App-weiten Engine-/SPK-Lebenszyklus entwerfen (SPK-Datei bleibt nach `openSpkFile` bis Programmende geöffnet); erst danach Kernel-Auswahl und Radix-Use-Case sicher anbinden.
4. Echte SPK-Dateien auf Android und iOS herunterladen/öffnen und Hevelius gegen dokumentierte JPL-Horizons-Referenzfälle testen.
4. Placidus weiterhin fachlich prüfen und reale Radix-Stichproben gegen unabhängige Referenzen validieren; nicht vorzeitig freigeben.
5. Historische Zeitzonen-/Sommerzeit-Auflösung und Geocoding/Koordinatenstrategie.
6. TSL1-Verifikation aus Topf Secret portieren; Generator nicht ändern.
7. Profile-Datenschutz, Export/Import und Migration verbessern.
8. Radix-Chart, Aspekte, Interpretationen und PDF datengetrieben vervollständigen.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.


### Runtime-Race-Absicherung (27.11.2026)

- Nach dem vollständig grünen CI-Lauf #95 (`46070186954`, Commit `b34fc9a5`) wurde ein zusätzlicher Lifecycle-Randfall identifiziert: `restore()` konnte nach einer bereits erfolgten Aktivierung versuchen, die gespeicherte Kerneldatei ein zweites Mal zu öffnen.
- `EphemerisRuntime` verwendet jetzt eine bereits aktive Engine direkt und wartet bei einem parallel laufenden Aktivierungsvorgang auf genau dieselbe Future. Dadurch gewinnt immer die bereits geöffnete Engine; es wird keine zweite SPK-Instanz erzeugt.
- Zwei Regressionstests ergänzen die sieben bisherigen Runtime-Tests: Restore nach Aktivierung und Restore während einer laufenden Aktivierung. CI für diesen Folgecommit steht noch aus.
- Nächster Schritt nach grüner CI: Runtime am App-Root als einzige Instanz bereitstellen und anschließend die Einstellungsseite auf Runtime-gesteuerte Aktivierung/Löschsperre umstellen. Keine Radix-Berechnung ohne erfolgreich aktivierte und validierte Ephemeride.
