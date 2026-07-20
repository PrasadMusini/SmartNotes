Offline-First Notes Application with Sync & Conflict Resolution
Build a Flutter-based notes application that works completely offline and synchronizes data with a mock REST
API when connectivity is restored.
The primary objective of this assignment is to evaluate a candidate's ability to design and implement offline-first
applications, handle data synchronization, and resolve real-world data conflicts between local and remote
sources.
Project Details
Users should be able to create, edit, and manage notes without requiring an internet connection. All changes
must be stored locally and automatically synchronized with a remote API once connectivity becomes available.
A critical part of the assignment is conflict detection and resolution. The application should identify situations
where both the local and server versions of a note have been modified and provide the user with options to
resolve the conflict.
Feature Requirements
Core Features
Implement the following note management functionality:
● Create notes
● Edit notes
● Delete notes
● View all notes
● Store note title and body
● All operations must work without an internet connection
● Persist data locally using:
○ Hive
○ Isar
○ SQLite
Sync Status Indicators
Each note should clearly display its current synchronization state:
● Synced
● Pending Sync
● Conflict
Users should always understand whether their data is synchronized with the server.

Sync & Conflict Handling (Critical Requirement)
The application should automatically synchronize local changes when connectivity is restored.
Synchronization Requirements
● Detect internet connectivity changes
● Queue local operations while offline
● Push pending changes to the server when online
● Pull latest note updates from the server
● Keep local and remote data consistent
The conflict resolution experience should be intuitive and clearly communicate the differences between both
versions.

Mock API Setup
Candidates may use either:
● JSON Server
● MockAPI
● Any equivalent mock REST service
Alternatively, candidates may configure and run their own local mock server.
Core App Requirements
Local Data Storage
Use any one of:
● Hive
● Isar
● SQLite
State Management
Use any one of:
● Bloc
● Riverpod
