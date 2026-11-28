# ASTRALIUM

**Professionelle Astrologie – klassisch gestaltet, ausführlich interpretiert.**

ASTRALIUM ist eine plattformübergreifende Astrologie-App für Android und iOS auf Basis von Flutter und Dart.

## Projektstatus

Das Projekt befindet sich im aktiven Grundaufbau. Der aktuelle Stand ist ein erster UI-Prototyp mit klassischer Gestaltung. Berechnungs-Engine, Lizenzprüfung, Profile, Horoskop-Auswertungen und PDF-Berichte werden schrittweise ergänzt.

## Technische Kennungen

Der Flutter-Paketname und die daraus erzeugte Android-Application-ID bleiben vorerst `horoskopium`, damit bestehende Installationen und technische Verknüpfungen stabil bleiben. Der sichtbare App-Name lautet **ASTRALIUM**.

## Entwicklungsumgebung

- Flutter / Dart
- Gemeinsame Codebasis für Android und iOS
- Material 3 mit klassischer Pergament-, Nachtblau- und Gold-Farbwelt

Plattformverzeichnisse einmalig erzeugen:

```bash
flutter create . --project-name horoskopium --platforms=android,ios
flutter pub get
flutter run
```

## Verbindliche Projektregeln

- Ausschließlich auf dem Branch `development` arbeiten.
- `main` bleibt unangetastet, außer der ausdrücklichen Anweisung: **„Bitte Main überschreiben“**.
- Vor jeder Änderung an bestehenden Dateien zuerst den aktuellen Inhalt und SHA von GitHub abrufen.
- Handoff-Dokumentation bei relevanten Änderungen aktuell halten.
- Keine privaten Schlüssel, Passwörter oder Signatur-Secrets in das Repository einchecken.

## Lizenzkonzept

ASTRALIUM soll denselben vorhandenen Lizenzschlüssel wie Topf Secret akzeptieren. Ziel ist: ein Key aktiviert beide Apps, auf Android und iOS. Der vorhandene Licence-Studio-Generator und der bestehende Hauptschlüssel sollen dafür unverändert bleiben. Die technische Übernahme des TSL1-Prüfverfahrens wird separat umgesetzt und gegen echte Testtokens geprüft. Der private Hauptschlüssel gehört niemals in die App.

Weitere Details: [docs/HANDOFF.md](docs/HANDOFF.md) und [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
