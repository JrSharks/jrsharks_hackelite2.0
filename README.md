
# AccessAble – Inclusive Places Platform

AccessAble helps people with disabilities discover, add, and review accessibility-friendly places in Sri Lanka.


## Monorepo Layout


````
├─ accessable-app/        # Flutter app for end users (mobile & web)
├─ accessable-web/        # React admin website (Vite + Mantine + Tailwind)
├─ accessable-backend/    # NestJS backend (TypeScript + Firebase)

````

---

## Prerequisites

- Node.js 18+ and npm 9+
- Flutter SDK (latest stable)
- Firebase project (Auth, Firestore, Storage enabled)
- Firebase CLI (optional, for emulators and deploy)

---

## Quick Start

### Backend (NestJS)

```bash
cd accessable-backend
npm install
npx ts-node -r tsconfig-paths/register src/main.ts
````

Runs on [http://localhost:3000](http://localhost:3000).

### Admin Website (React + Vite)

```bash
cd accessable-web
npm install
npm run dev
```

Runs on [http://localhost:5173](http://localhost:5173).

### User App (Flutter)

```bash
cd accessable-app
flutter pub get
flutter run -d chrome   # run in web mode
# or: flutter run       # run on device/emulator
```

---

## Roles & Approvals

* **Roles**: `pwd`, `caregiver`, `admin`
* Users/places/reviews are **pending** until approved by admin
* Non-approved users are redirected to `/pending`

---


## License

This project is part of the AccessAble platform for improving accessibility in Sri Lanka.
