# Horoskopium – Ephemeris Runtime Lifecycle

**Status:** Architekturentscheidung / Implementierungsgrundlage  
**Branch:** development  
**Stand:** 27.11.2026

## Ziel

Die JPL-SPK-Datei wird genau einmal pro App-Prozess geöffnet und von einer app-weiten Runtime verwaltet. Der Hevelius-Adapter bleibt Implementierung des bestehenden `EphemerisEngine`-Ports. UI und Radix-Use-Case erhalten keine eigenen Datei-Handles und öffnen keine SPK-Dateien selbst.

## Verifizierte technische Randbedingung

Die dokumentierte Hevelius-API beschreibt `openSpkFile(path)` als dateibasiertes On-Demand-Lesen. Die Datei bleibt bis zum Programmende geöffnet; ein öffentlicher Close-Pfad ist in der geprüften API nicht dokumentiert. Daraus folgt: Eine geöffnete SPK-Datei darf während dieses App-Prozesses nicht gelöscht, umbenannt, ersetzt oder überschrieben werden.

## Verantwortlichkeiten

1. **EphemerisDownloadService**
   - Lädt, prüft SHA-256, installiert und löscht ausschließlich nicht aktive Kernel.
   - Kennt keine Engine-Instanz und öffnet keine SPK-Datei.
   - Bleibt zuständig für Dateisystem-Recovery (.part/.bak).

2. **EphemerisRuntime (app-weiter Owner)**
   - Ein Prozess-Owner, einmal am App-Root erzeugt und an Services/Use-Cases weitergereicht.
   - Besitzt die einzige aktive `HeveliusEphemerisEngine`-Instanz.
   - Öffnet einen Kernel lazy nach expliziter Auswahl bzw. beim Wiederherstellen der gespeicherten Auswahl.
   - Gibt denselben Engine-Verweis für alle Radix-Berechnungen zurück.
   - Verhindert einen Wechsel auf einen anderen Kernel während der Laufzeit.
   - Bietet `isActive(kernelId)`, `activeKernelId`, `activeEngine` und eine kontrollierte Löschoperation.
   - Persistiert nur die Kernel-ID, niemals den Dateipfad als Wahrheit oder einen offenen Handle.

3. **Settings UI**
   - Unterscheidet klar zwischen „Lokal gespeichert“ und „Aktiv für Berechnungen“.
   - Bietet „Als Berechnungs-Ephemeride verwenden“ nur für vollständig vorhandene und SHA-256-validierte Dateien.
   - Zeigt beim aktiven Kernel „Aktiv bis zum nächsten App-Neustart“.
   - Deaktiviert Löschen für den aktiven Kernel.
   - Verhindert Download/Ersetzen des aktiven Kernels.
   - Ein anderer Kernel kann erst nach App-Neustart aktiviert werden; keine vorgetäuschte Live-Umschaltung.

## Zustandsmodell

- **notSelected:** Es wurde kein Kernel als Berechnungsquelle gewählt. Radix-Berechnung meldet verständlich, dass eine Ephemeride fehlt.
- **stored:** Eine Datei liegt lokal und hat die erwartete SHA-256-Prüfung bestanden, ist aber nicht geöffnet.
- **active:** Die Runtime hat die Datei erfolgreich geöffnet und hält die Engine bis zum Prozessende.
- **error:** Öffnen oder Validieren schlug fehl. Keine Engine wird als aktiv ausgegeben; Fehlerursache wird sichtbar.

„Gespeichert“ bedeutet nicht automatisch „aktiv“. Eine Datei wird bei jeder Aktivierung erneut gegen den fest hinterlegten Hash geprüft.

## Aktivierungsablauf

1. Gewünschte Kernel-ID gegen den festen Katalog auflösen; unbekannte IDs ablehnen.
2. Prüfen, ob bereits eine Engine aktiv ist:
   - gleiche Kernel-ID: vorhandene Engine zurückgeben (idempotent).
   - andere Kernel-ID: Wechsel ablehnen und Neustart verlangen.
3. Datei über `EphemerisDownloadService.installedPath()` wiederherstellen/prüfen.
4. `HeveliusEphemerisEngine.fromSpkFilePath(path)` genau einmal aufrufen.
5. Erst nach erfolgreichem Öffnen Engine und Kernel-ID im Runtime-Owner festhalten.
6. Kernel-ID in SharedPreferences speichern.
7. Wenn Speichern der Präferenz fehlschlägt, die bereits geöffnete Engine nicht schließen oder als nicht existent behandeln; Fehler protokollieren/anzeigen. Der Prozess bleibt auf dem aktiven Kernel fixiert.

## Wiederherstellung beim App-Start

1. Runtime wird am App-Root genau einmal erstellt.
2. Gespeicherte Kernel-ID lesen.
3. Ist keine ID vorhanden: keine SPK-Datei öffnen; Berechnungsstatus bleibt „nicht ausgewählt“.
4. Ist eine ID vorhanden: ID gegen Katalog prüfen, Datei hashen/recovern und Engine öffnen.
5. Fehlt die Datei oder ist sie ungültig: Auswahl verwerfen bzw. als Fehler markieren; keine Ersatzdatei stillschweigend auswählen.
6. Ein erfolgreicher Restore setzt denselben Kernel als aktiv für den gesamten Prozess.

Die Runtime muss einen einmal gestarteten Restore über ein gemeinsames Future deduplizieren, damit parallele Aufrufer nicht mehrfach `openSpkFile` auslösen.

## Lösch- und Austauschregeln

- Runtime ist die einzige Stelle, die beurteilen kann, ob ein Kernel aktiv ist.
- Löschen muss über Runtime-Guard laufen; die UI allein reicht als Schutz nicht.
- Aktiver Kernel: Lösch- und Austauschoperationen hart ablehnen.
- Inaktiver Kernel: Löschen über Download-Service erlaubt.
- Ein Wechsel von DE440s zu DE442 erfolgt nach Neustart. Erst der neue Prozess kann den anderen Kernel öffnen.
- Keine temporären Rename-/Backup-Recovery-Aktionen auf einem aktiven Kernel durchführen.

## Fehler- und Teststrategie

Vor Integration müssen Tests mindestens abdecken:
- keine Auswahl → kein Engine-Aufruf;
- gültige Auswahl → genau ein Engine-Aufruf;
- parallele Restore-/Activate-Aufrufe → ein gemeinsamer Öffnungsvorgang;
- erneute Aktivierung desselben Kernels → dieselbe Engine-Instanz;
- Wechsel auf anderen Kernel → Ablehnung ohne zweiten Open-Aufruf;
- ungültige/unbekannte gespeicherte ID → keine Öffnung;
- fehlende oder SHA-inkorrekte Datei → keine aktive Engine;
- aktiver Kernel kann nicht gelöscht werden;
- inaktiver Kernel kann gelöscht werden;
- Fehler beim Engine-Open → kein aktiver Zustand und keine persistierte Auswahl;
- Fehler beim Persistieren nach erfolgreichem Open → Engine bleibt im Prozess aktiv und ist nicht erneut zu öffnen.

## Integrationsreihenfolge

1. Runtime-Owner und testbare Abhängigkeiten implementieren.
2. Unit-Tests mit Fake-Engine-Factory und temporärem Dateisystem.
3. Settings-UI an Runtime anbinden; Status „gespeichert/aktiv“ und Schutzaktionen darstellen.
4. Runtime am App-Root initialisieren und gespeicherte Auswahl wiederherstellen.
5. `CalculateRadix` erhält ausschließlich die Runtime-Engine; keine direkte Engine-Erzeugung in Screens.
6. Erst danach echte JPL-Dateien auf Android und iOS öffnen und astronomische Referenzfälle gegen JPL Horizons validieren.

## Nicht-Ziele / bewusste Grenzen

- Keine Live-Umschaltung zwischen geöffneten SPK-Dateien.
- Keine Löschung/Ersetzung eines aktiven Kernels.
- Keine stillschweigende Auswahl eines anderen Kernels bei Fehlern.
- Keine Behauptung, dass eine gespeicherte Datei bereits für Berechnungen aktiv ist.
- Keine echte Radix-Freigabe allein aufgrund grüner CI; Geräte- und Referenztests bleiben erforderlich.
