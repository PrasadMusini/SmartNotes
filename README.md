# Offline-First Notes Application with Sync & Conflict Resolution

## Overview

Build a Flutter-based Notes Application that works completely offline and synchronizes data with a mock REST API when connectivity is restored.

The primary objective of this assignment is to evaluate the ability to:

- Design and implement offline-first applications
- Handle data synchronization
- Resolve real-world data conflicts between local and remote sources

Users should be able to create, edit, and manage notes without requiring an internet connection. All changes must be stored locally and automatically synchronized with a remote API once connectivity becomes available.

A critical part of the assignment is conflict detection and resolution. The application should identify situations where both the local and server versions of a note have been modified and provide users with options to resolve the conflict.

---

## Features

### Core Features

- Create notes
- Edit notes
- Delete notes
- View all notes
- Store note title and body
- Work completely offline
- Persist data locally

### Local Storage

The application can use one of the following local databases:

- Hive
- Isar
- SQLite

---

## Sync Status Indicators

Each note should display its current synchronization status:

| Status | Description |
|----------|-------------|
| ✅ Synced | Note is synchronized with the server |
| ⏳ Pending Sync | Local changes are waiting to be synchronized |
| ⚠️ Conflict | Local and server versions differ and require resolution |

Users should always be able to understand whether their data is synchronized with the server.

---

## Synchronization & Conflict Handling

### Synchronization Requirements

The application should automatically synchronize local changes when connectivity is restored.

#### Requirements

- Detect internet connectivity changes
- Queue local operations while offline
- Push pending changes to the server when online
- Pull the latest note updates from the server
- Keep local and remote data consistent

### Conflict Resolution

The application must detect conflicts when:

- A note has been modified locally
- The same note has also been modified on the server

The conflict resolution experience should:

- Clearly indicate that a conflict exists
- Show differences between local and server versions
- Allow users to choose which version to keep
- Update local and remote data accordingly

---

## Mock API Setup

Any of the following options can be used:

- JSON Server
- MockAPI
- Any equivalent mock REST service
- A custom local mock server

---

## State Management

Use one of the following:

- Bloc
- Riverpod

---

## Technical Requirements

### Flutter

- Flutter SDK
- Dart

### Local Database

Choose one:

- Hive
- Isar
- SQLite

### State Management

Choose one:

- Bloc
- Riverpod

### Networking

- REST API integration
- Connectivity monitoring
- Background synchronization

---

## Expected Outcome

The final application should:

- Function completely offline
- Persist all note operations locally
- Automatically synchronize when internet connectivity is restored
- Detect and resolve data conflicts
- Clearly display synchronization status
- Maintain consistency between local and remote data
