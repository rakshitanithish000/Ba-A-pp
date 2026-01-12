# Rental Management System - Development Plan

## Project Overview
A real-time property management application to manage buildings, owners, leaseholders, flats, rooms, bed-spaces, guests, and payments.

## Module Structure (Hierarchy)
1. **RE Owners**: Real owners of the buildings.
2. **Lease Owners**: People/Entities that lease the building from RE owners.
3. **Flats**: Units within a building, categorized by BHK types.
4. **Rooms**: Units within a flat.
5. **Bed-Spaces**: Individual rental units within a room.
6. **Guests**: Paying guests occupying bed-spaces.
7. **Rental Records**: Payment history and status for each guest.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend API**: PHP (on Hostinger)
- **Database**: MySQL (via phpMyAdmin)

## Implementation Roadmap

### Phase 1: Database & Backend (Foundation)
- [ ] Define MySQL Schema for all 7 modules.
- [ ] Set up foreign key relationships to ensure data integrity.
- [ ] Create PHP API endpoints for CRUD (Create, Read, Update, Delete) operations.

### Phase 2: Flutter Infrastructure
- [ ] Update `api_service.dart` to handle new endpoints.
- [ ] Create shared models/entities in Dart.

### Phase 3: Module Development (Step-by-Step)
For each module (1-7), we will:
1. Create the **Add/Edit** screen.
2. Create the **List/Details** screen.
3. Integrate with the PHP API.
4. Verify real-time updates on the Dashboard.

---

## Status Tracker
- [x] Dashbord Visualization (Basic UI)
- [x] RE Owners Module (UI + API)
- [x] Lease Owners Module (UI + API)
- [x] Flats Module (UI + API)
- [x] Rooms Module (UI + API)
- [x] Bed-Spaces Module (UI + API)
- [x] Guests Module (UI + API)
- [x] Rental Records Module (UI + API)

## Congratulations! All core modules are implemented.

---

## Development Logs
- **2026-01-07**: Initialized `plan.md` and defined module hierarchy.
- **2026-01-07**: Created Database Schema (SQL) and local backup.
- **2026-01-07**: Implemented `manage_owners.php` API.
- **2026-01-07**: Created `REOwnersScreen` and integrated with Dashboard navigation.
