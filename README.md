# Dear Stranger

> **A human-powered creative platform where strangers give artists reasons to create.**

Dear Stranger is a full-stack web application that bridges the gap between people who want to share heartfelt messages and artists who need meaningful inspiration. Senders write letters to unknown artists; artists claim a letter, create artwork in response, and deliver it back — turning words into art.

---

## ✨ Features

### For Senders
- **Write Letters** — Compose a message with a title and personal prompt for any artist to discover.
- **Anonymous Option** — Post anonymously if preferred.
- **Track Your Letters** — Follow the journey of your letter from available → claimed → delivered.
- **Receive Artwork** — Get notified and view the artwork an artist created in response to your words.
- **Reply** — Continue the conversation with the artist after delivery.

### For Artists
- **Browse the Feed** — Discover available letters waiting to inspire.
- **Claim a Letter** — Pick a letter that speaks to you and commit to creating artwork for it.
- **Upload Artwork** — Upload your artwork via a secure pre-signed upload flow (Backblaze B2).
- **Publish & Deliver** — Publish your finished piece directly to the sender.
- **Artist Profile** — Showcase your medium, bio, and what you're currently working on.

### For Everyone
- **User Profiles** — Customizable profiles with avatar, bio, location, and favorite medium.
- **Guestbook** — Leave messages on other users' profiles.
- **Real-Time Notifications** — WebSocket-powered live notifications for letter claims, artwork deliveries, replies, and guestbook entries.
- **User Search** — Find and connect with other members of the community.

---

## 🏗️ Architecture

```
dear-stranger/
├── backend/          # Node.js + Express + TypeScript API server
└── frontend/         # Flutter Web application
```

The backend serves the Flutter Web build as static files in production — a single deployable unit.

---

## 🛠️ Tech Stack

### Backend
| Technology | Purpose |
|---|---|
| **Node.js** + **Express 5** | HTTP server & REST API |
| **TypeScript** | Type-safe server code |
| **Prisma 7** | ORM & database migrations |
| **PostgreSQL** (Neon) | Primary database |
| **WebSockets** (`ws`) | Real-time notifications |
| **Backblaze B2** (S3-compatible) | Artwork & avatar file storage |
| **Argon2** | Secure password hashing |
| **Zod** | Request validation & schema parsing |
| **express-rate-limit** | API rate limiting |

### Frontend
| Technology | Purpose |
|---|---|
| **Flutter Web** | Cross-platform UI framework |
| **go_router** | Declarative client-side routing |
| **Provider** | State management |
| **web_socket_channel** | Real-time notifications |
| **http** | REST API client |
| **cached_network_image** | Efficient image loading |
| **file_picker** | Artwork upload |
| **google_fonts** + **intl** | Typography & localization utilities |

---

## 📐 Data Model

```
User ──< Letter (sent)
User ──< Letter (claimed / as artist)
Letter ──── Artwork          (1-to-1, the delivered piece)
Letter ──< ArtworkUpload     (presigned upload staging)
Letter ──< Reply             (conversation thread)
Letter ──< Notification
User   ──< GuestbookEntry (hosted)
User   ──< GuestbookEntry (authored)
User   ──< Session
```

**Letter lifecycle:** `AVAILABLE` → `CLAIMED` → `DELIVERED`

---

## 🚀 Getting Started

### Prerequisites

- **Node.js** ≥ 20
- **Flutter SDK** ≥ 3.0
- **PostgreSQL** database (local or hosted — [Neon](https://neon.tech) recommended)
- **Backblaze B2** account with two buckets:
  - `dear-stranger-artworks` (private, for artwork uploads)
  - `dear-stranger-avatars` (public, for profile avatars)

---

### Backend Setup

```bash
cd backend

# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env with your credentials (see Environment Variables section)

# 3. Run database migrations
npx prisma migrate deploy

# 4. Generate Prisma client
npx prisma generate

# 5. Start the development server
npm run dev
```

The API server will be available at `http://localhost:3000`.

---

### Frontend Setup

```bash
cd frontend

# 1. Install Flutter dependencies
flutter pub get

# 2. Run in a browser (development)
flutter run -d chrome
```

> **Note:** The frontend communicates with the backend at `http://localhost:3000` by default. Update the base URL in `lib/core/` if your backend runs on a different port.

---

### Production Build

```bash
# 1. Build the Flutter web app
cd frontend
flutter build web

# 2. Copy the build output to the backend's public directory
cp -r build/web/* ../backend/public/

# 3. Build and start the backend (serves Flutter as static files)
cd ../backend
npm run build
npm start
```


---

## 📡 API Reference

All endpoints are prefixed with `/api`.

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| **Auth** | | |
| `POST` | `/api/auth/register` | Register a new account |
| `POST` | `/api/auth/login` | Log in |
| `POST` | `/api/auth/logout` | Log out |
| `GET` | `/api/auth/me` | Get current session user |
| **Letters** | | |
| `GET` | `/api/letters` | Browse available letters (feed) |
| `POST` | `/api/letters` | Send a new letter |
| `GET` | `/api/letters/:id` | Get letter details |
| `POST` | `/api/letters/:id/claim` | Claim a letter (artist) |
| `POST` | `/api/letters/:id/artwork` | Submit artwork for a letter |
| `POST` | `/api/letters/:id/replies` | Post a reply |
| `GET` | `/api/letters/mine/sent` | Letters I have sent |
| `GET` | `/api/letters/mine/claimed` | Letters I have claimed |
| **Users** | | |
| `GET` | `/api/users/:username` | Get a user's public profile |
| `PATCH` | `/api/users/me` | Update my profile |
| `POST` | `/api/users/me/avatar` | Upload avatar |
| `GET` | `/api/users/search` | Search users |
| `POST` | `/api/users/:username/guestbook` | Post a guestbook entry |
| **Notifications** | | |
| `GET` | `/api/notifications` | List my notifications |
| `PATCH` | `/api/notifications/:id/read` | Mark notification as read |

### WebSocket

Connect to `ws://host/ws` with a valid session cookie to receive real-time notification events.

---

## 📁 Project Structure

### Backend

```
backend/src/
├── app.ts                    # Express app setup, middleware, routes
├── server.ts                 # HTTP server, WebSocket init, B2 CORS bootstrap
├── lib/
│   ├── b2.ts                 # Backblaze B2 S3 client & CORS config
│   ├── cors.ts               # Allowed origins list
│   ├── frontend-static.ts    # Serve Flutter build as static files
│   ├── prisma.ts             # Prisma client singleton
│   └── websocket.ts          # WebSocket server & notification delivery
└── modules/
    ├── auth/                 # Registration, login, session management
    ├── letters/              # Letters, artwork upload, replies
    ├── users/                # Profiles, avatars, guestbook, search
    └── notifications/        # Notification listing & read state
```

### Frontend

```
frontend/lib/
├── main.dart                 # App entry point
├── app.dart                  # Root widget, providers, router init
├── core/
│   ├── providers/            # AuthProvider, LettersFeedProvider, NotificationProvider
│   ├── router/               # go_router route definitions
│   └── theme/                # App theme & typography
├── features/
│   ├── auth/                 # Login & registration screens
│   ├── letters/              # Feed, letter detail, send, my letters, claimed letters
│   └── users/                # Profile, settings, user search
└── shared/                   # Shared widgets, models, API services
```

---

## 🔒 Security

- **Passwords** hashed with Argon2id.
- **Sessions** stored server-side; token hash stored in the database.
- **Artwork uploads** use short-lived pre-signed B2 URLs — clients upload directly to B2, never through the server.
- **Rate limiting** applied to authentication endpoints.
- **CORS** restricted to allowed origins.
- **Input validation** enforced via Zod schemas on all POST/PATCH endpoints.

---

## 🤝 Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Commit your changes with clear messages.
4. Push and open a Pull Request.

Please keep frontend (Flutter) and backend (Node.js) changes in separate commits when possible.

---

## 📄 License

This project is licensed under the **ISC License**. See [`LICENSE`](LICENSE) for details.
