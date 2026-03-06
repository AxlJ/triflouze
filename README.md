# Triflouze

**Dépenses partagées, synchronisées en temps réel pour tout le groupe.**

Application Flutter de gestion de dépenses en groupe — colocation, voyage, famille, association.

---

## Fonctionnalités

- **Groupes** — Créez ou rejoignez un groupe via un code à 6 caractères
- **Multi-groupes** — Appartenez à plusieurs groupes, définissez un groupe principal
- **Dépenses** — Titre, montant, devise (€, $, MAD…), catégorie, membres, commentaire, étiquettes
- **Synchronisation temps réel** — Les dépenses apparaissent instantanément sur tous les appareils du groupe
- **Notifications push** — Alerte automatique à chaque nouvelle dépense
- **Statistiques** — Graphiques interactifs par catégorie, filtres par période et par membre
- **Authentification** — Email/mot de passe ou Google Sign-In
- **Multilingue** — Français et anglais

---

## Stack technique

| Couche | Technologie |
|---|---|
| Framework | Flutter (Dart) |
| Auth | Firebase Authentication |
| Base de données | Cloud Firestore |
| Notifications | Firebase Cloud Messaging + OneSignal |
| Graphiques | fl_chart |
| Typographie | Google Fonts (Nunito) |

---

## Installation

### Prérequis

- Flutter SDK ≥ 3.x
- Compte Firebase avec un projet configuré

### Configuration

1. Cloner le repo
   ```bash
   git clone git@github.com:AxlJ/triflouze.git
   cd triflouze
   ```

2. Installer les dépendances
   ```bash
   flutter pub get
   ```

3. Ajouter les fichiers secrets (non versionnés) :
   - `android/app/google-services.json` — à télécharger depuis la console Firebase
   - `android/key.properties` — pour la signature release

4. Lancer l'app
   ```bash
   flutter run
   ```

### Build release

```bash
flutter build appbundle --release
# Sortie : build/app/outputs/bundle/release/app-release.aab
```

---

## Liens

- [Politique de confidentialité](https://axlj.github.io/triflouze/privacy.html)
- [Suppression de compte](https://axlj.github.io/triflouze/delete-account.html)
