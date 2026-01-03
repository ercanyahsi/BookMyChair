# BookMyChair - Hairdresser Reservation iOS App

A clean, offline-first hairdresser reservation app built with Swift and SwiftUI.

## Features

- 📱 **Offline-first**: All data stored locally using SwiftData
- 👥 **Multiple hairdressers**: Create and manage multiple hairdresser profiles
- 📅 **Day-based scheduling**: View today's and tomorrow's reservations
- ⏰ **30-minute slots**: Time slots restricted to HH:00 and HH:30
- 🚫 **Conflict prevention**: Automatic detection of overlapping reservations
- 🌍 **Bilingual**: Full support for English and Turkish (based on system locale)

## Architecture

The app follows industry-standard iOS development patterns:

### MVVM Architecture
- **Models**: `Hairdresser`, `Reservation`, `TimeSlot`
- **Views**: SwiftUI views with clear separation of concerns
- **ViewModels**: Business logic and state management
- **Persistence**: SwiftData for local storage

### Project Structure

```
BookMyChair/
├── Models/
│   ├── Hairdresser.swift       # Hairdresser entity
│   ├── Reservation.swift       # Reservation entity
│   └── TimeSlot.swift          # Time slot value type
├── ViewModels/
│   ├── HairdresserSelectionViewModel.swift
│   ├── ReservationListViewModel.swift
│   └── ReservationEditorViewModel.swift
├── Views/
│   ├── HairdresserSelectionView.swift
│   ├── ReservationListView.swift
│   ├── ReservationEditorView.swift
│   └── Components/
│       └── ReservationRowView.swift
├── Persistence/
│   └── DataStore.swift         # SwiftData operations
├── Utilities/
│   ├── DateHelpers.swift       # Date utilities
│   └── Validation.swift        # Input validation
└── Resources/
    ├── en.lproj/
    │   └── Localizable.strings # English localization
    └── tr.lproj/
        └── Localizable.strings # Turkish localization
```

## Key Components

### Data Models

- **Hairdresser**: SwiftData model with one-to-many relationship to reservations
- **Reservation**: Stores customer info, date, and time slot
- **TimeSlot**: Value type enforcing HH:00 or HH:30 format

### Business Logic

- **Conflict Detection**: Prevents double-booking of time slots
- **Date Normalization**: Ensures day-level comparison accuracy
- **Validation**: Centralized input validation for names and phone numbers

### User Interface

- **Native SwiftUI**: Clean, Apple HIG-compliant interface
- **Accessibility**: Proper labels and semantic structure
- **Responsive**: Adaptive layouts for different screen sizes

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Usage

1. **First Launch**: Create a hairdresser profile
2. **Select Hairdresser**: Choose from the list to view reservations
3. **Add Reservation**: Tap + to create a new reservation
4. **Toggle Days**: Switch between Today and Tomorrow views
5. **Edit/Delete**: Tap on a reservation to edit or delete it

## Localization

The app automatically displays in Turkish or English based on the device's system language. All user-facing strings are localized in `Resources/[lang].lproj/Localizable.strings`.

## Technical Highlights

- ✅ SwiftData for persistence
- ✅ Observable pattern for reactive UI
- ✅ Proper error handling
- ✅ Input validation
- ✅ Conflict detection
- ✅ Clean separation of concerns
- ✅ Testable architecture
- ✅ No hard-coded strings

## Future Enhancements

Potential features for future versions:
- Week/month view
- Customer history
- Appointment notifications
- Export/backup functionality
- Dark mode customization
- Multi-device sync (with backend)
