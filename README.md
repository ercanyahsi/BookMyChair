# BookMyChair - Hairdresser Reservation iOS App

A beautiful, offline-first hairdresser reservation app built with Swift and SwiftUI, featuring modern UI design with gradients, animations, and intuitive user experience.

## Features

### Core Functionality
- 📱 **Offline-first**: All data stored locally using SwiftData
- 👥 **Multiple hairdressers**: Create and manage multiple hairdresser profiles with delete confirmation
- 📅 **Day-based scheduling**: View today's and tomorrow's reservations with actual dates displayed
- ⏰ **Business hours**: 8:00 AM - 9:00 PM with 30-minute time slots
- 🚫 **Conflict prevention**: Automatic detection of overlapping reservations
- 🌍 **Bilingual**: Full support for English and Turkish (based on system locale)
- ⏱️ **Smart time selection**: Prevents booking past time slots, auto-suggests next hour + 1 for today, 8 AM for tomorrow

### User Experience
- 📞 **Quick contact access**: Tap-to-call customers directly from reservation rows
- 📇 **Contact picker integration**: Select customers from phone contacts with permission handling
- 🎨 **Modern UI design**: 
  - Gradient buttons and backgrounds
  - Subtle shadows and depth effects
  - Decorative background icons (calendar, clock, scissors)
  - Enhanced typography with SF Pro Rounded
  - Status-based color coding (current, completed, upcoming)
- 🌓 **Dark mode support**: Fully optimized for both light and dark appearances
- ✨ **Visual feedback**: Status indicators, NOW badges, checkmarks for completed appointments
- 🎯 **Emphasis on convenience**: Contact picker prominently featured over manual entry

### Design Elements
- **Gradients**: Smooth color transitions on buttons, backgrounds, and badges
- **Shadows**: Strategic use of colored shadows for depth
- **Background icons**: Large, subtle SF Symbols (calendar, clock, scissors) for visual context
- **Animations**: Spring physics for smooth interactions
- **Visual hierarchy**: Clear distinction between primary and secondary actions

## Architecture

The app follows industry-standard iOS development patterns:

### MVVM Architecture
- **Models**: `Hairdresser`, `Reservation`, `TimeSlot`
- **Views**: SwiftUI views with clear separation of concerns
- **ViewModels**: Business logic and state management with @Observable pattern
- **Persistence**: SwiftData for local storage

### Project Structure

```
BookMyChair/
├── Models/
│   ├── Hairdresser.swift       # Hairdresser entity
│   ├── Reservation.swift       # Reservation entity with formatted time
│   └── TimeSlot.swift          # Time slot value type (HH:00 or HH:30)
├── ViewModels/
│   ├── HairdresserSelectionViewModel.swift
│   ├── ReservationListViewModel.swift
│   └── ReservationEditorViewModel.swift  # Smart time defaults
├── Views/
│   ├── HairdresserSelectionView.swift    # Welcome screen with feature highlights
│   ├── ReservationListView.swift         # Date-aware reservation list
│   ├── ReservationEditorView.swift       # Contact picker + manual entry
│   └── Components/
│       ├── ReservationRowView.swift      # Status-based styling with call button
│       └── ContactPicker.swift           # SwiftUI wrapper for CNContactPickerViewController
├── Persistence/
│   └── AppDataStore.swift      # SwiftData operations with conflict detection
├── Utilities/
│   ├── DateHelpers.swift       # Date utilities with today/tomorrow logic
│   └── Validation.swift        # Input validation
└── Resources/
    ├── en.lproj/
    │   └── Localizable.strings # English localization (40+ strings)
    └── tr.lproj/
        └── Localizable.strings # Turkish localization (40+ strings)
```
        └── Localizable.strings # Turkish localization
```

## Key Components

### Data Models

- **Hairdresser**: SwiftData model with one-to-many relationship to reservations
- **Reservation**: Stores customer info, date, time slot, and provides formatted display
- **TimeSlot**: Value type enforcing HH:00 or HH:30 format with validation
- **ReservationStatus**: Enum for tracking appointment state (completed, current, upcoming)

### Business Logic

- **Conflict Detection**: Prevents double-booking of time slots per hairdresser
- **Past Time Prevention**: Automatically filters out past time slots for today
- **Smart Defaults**: New reservations default to current hour + 1 (today) or 8 AM (tomorrow)
- **Date Normalization**: Ensures day-level comparison accuracy
- **Validation**: Centralized input validation with trimmed string checks
- **Status Calculation**: Real-time determination of appointment status (30-minute active window)

### User Interface

- **Native SwiftUI**: Clean, Apple HIG-compliant interface with modern enhancements
- **Accessibility**: Proper labels, hints, and semantic structure throughout
- **Responsive**: Adaptive layouts for different screen sizes
- **Visual Feedback**: 
  - NOW badges for current appointments
  - Checkmarks for completed appointments
  - Dimmed styling for past appointments
  - Gradient borders for active appointments
  - Enhanced shadows on important elements
- **Contact Integration**: 
  - Native contact picker with UIViewControllerRepresentable wrapper
  - Permission handling for contacts access
  - Tap-to-call with tel:// URL scheme
- **Background Design**:
  - Layered gradients for depth
  - Large decorative SF Symbols icons
  - Blur circles for soft visual interest

## User Flow

### First Launch
1. **Welcome Screen**: Beautiful onboarding with app icon, feature highlights, and gradient CTA
2. **Create Hairdresser**: Add your first hairdresser profile

### Daily Usage
1. **Select Hairdresser**: Choose from list (with gradient avatar cards)
2. **View Schedule**: Switch between Today/Tomorrow with actual dates shown
3. **Add Reservation**: 
   - **Option 1 (Recommended)**: Tap prominent contact picker button to select from phone
   - **Option 2**: Manually enter name and phone number
   - Time automatically suggests next available slot
4. **Manage Appointments**: 
   - Tap reservation card to edit/delete
   - Call customer with gradient call button
   - Visual status indicators show current/completed/upcoming

### Hairdresser Management
- Swipe to delete with confirmation alert
- Warning: deletion removes all associated appointments
- Create unlimited hairdresser profiles

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Contacts permission (optional, for contact picker feature)

## Localization

The app automatically displays in Turkish or English based on the device's system language. All user-facing strings are localized in `Resources/[lang].lproj/Localizable.strings`.

**Localized Elements:**
- All UI labels and buttons
- Error messages and alerts
- Validation feedback
- Date/time displays
- Welcome screen content
- Feature descriptions

## Technical Highlights

### SwiftUI & Swift Features
- ✅ SwiftData with @Model macro for persistence
- ✅ Observable pattern (@Observable) for reactive UI
- ✅ Swift 5.9+ features and modern syntax
- ✅ GeometryReader for responsive layouts
- ✅ Custom ViewModifiers for reusable styling

### UI/UX Design
- ✅ LinearGradient for modern visual appeal
- ✅ SF Symbols for consistent iconography
- ✅ Shadow effects with colored shadows
- ✅ Spring animations for smooth interactions
- ✅ Layered backgrounds with blur effects
- ✅ Status-based color coding
- ✅ Dark mode optimization

### Code Quality
- ✅ MVVM architecture with clear separation
- ✅ Proper error handling with typed errors
- ✅ Input validation with trimmed checks
- ✅ Conflict detection with SwiftData predicates
- ✅ No hard-coded strings (full localization)
- ✅ Accessibility support throughout
- ✅ Testable architecture

### iOS Integration
- ✅ ContactsUI framework integration
- ✅ UIApplication.shared.open for tel:// URLs
- ✅ Privacy: NSContactsUsageDescription configured
- ✅ System locale detection for language
- ✅ Light/dark mode adaptive colors

## Design Philosophy

BookMyChair follows Apple's Human Interface Guidelines while adding modern visual flair:

- **Professional yet energetic**: Gradients and shadows add life without compromising professionalism
- **Clarity first**: Visual enhancements never interfere with usability
- **Convenience-focused**: Contact picker emphasized, one-tap calling, smart time defaults
- **Consistent**: Design system with reusable gradient styles and spacing
- **Accessible**: Works beautifully in light/dark mode, proper accessibility labels

## Screenshots & Visual Elements

### Color System
- **Primary Actions**: Gradient (accent color → 80-90% opacity)
- **Status Colors**: Green (current), Gray (completed), Blue (upcoming)
- **Backgrounds**: Subtle gradients with 2-5% opacity
- **Decorative Icons**: Primary color at 5-6% opacity

### Typography
- **Headings**: SF Pro Rounded, Bold
- **Body**: SF Pro Rounded, Regular/Semibold
- **Emphasis**: Letter spacing on labels, increased weight contrast

### Components
- **Buttons**: Gradient fills, colored shadows, rounded corners (12-16pt)
- **Cards**: White background, subtle shadows, gradient borders for emphasis
- **Badges**: Capsule shape, gradient or solid fills, bold text
- **Icons**: 44pt touch targets, gradient circles, semibold weight

## Future Enhancements

Potential features for future versions:
- Week/month calendar view
- Customer history and notes
- Push notifications for upcoming appointments
- Export/backup functionality (CSV, iCloud)
- Multi-device sync (CloudKit integration)
- Recurring appointments
- Custom business hours per hairdresser
- Service duration customization
- Revenue tracking
- Customer photos/preferences
