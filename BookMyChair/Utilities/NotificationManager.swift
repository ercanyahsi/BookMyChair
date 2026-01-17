//
//  NotificationManager.swift
//  BookMyChair
//
//  Created on 17/01/2026.
//

import Foundation
import UserNotifications

/// Manages local notifications for appointment reminders
@MainActor
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Request notification permission from the user
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    /// Schedule notifications for a reservation (15 min and 5 min before)
    func scheduleNotifications(for reservation: Reservation) async {
        // Remove any existing notifications for this reservation
        await cancelNotifications(for: reservation.id)
        
        // Check if authorization is granted
        let status = await checkAuthorizationStatus()
        guard status == .authorized else { return }
        
        // Calculate notification times
        let appointmentDate = createAppointmentDate(from: reservation)
        
        // Schedule 15-minute reminder
        await scheduleNotification(
            for: reservation,
            appointmentDate: appointmentDate,
            minutesBefore: 15
        )
        
        // Schedule 5-minute reminder
        await scheduleNotification(
            for: reservation,
            appointmentDate: appointmentDate,
            minutesBefore: 5
        )
    }
    
    /// Schedule a single notification
    private func scheduleNotification(
        for reservation: Reservation,
        appointmentDate: Date,
        minutesBefore: Int
    ) async {
        let notificationDate = appointmentDate.addingTimeInterval(-Double(minutesBefore * 60))
        
        // Don't schedule notifications in the past
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        
        if minutesBefore == 15 {
            content.title = NSLocalizedString("notification_title_15min", comment: "")
        } else {
            content.title = NSLocalizedString("notification_title_5min", comment: "")
        }
        
        let timeString = reservation.formattedTime
        let bodyFormat = NSLocalizedString("notification_body", comment: "")
        content.body = String(format: bodyFormat, reservation.customerName, timeString)
        content.sound = .default
        content.badge = 1
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "\(reservation.id.uuidString)-\(minutesBefore)min"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    /// Cancel all notifications for a specific reservation
    func cancelNotifications(for reservationId: UUID) async {
        let identifiers = [
            "\(reservationId.uuidString)-15min",
            "\(reservationId.uuidString)-5min"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Create a full Date object from reservation date and time
    private func createAppointmentDate(from reservation: Reservation) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: reservation.date)
        components.hour = reservation.timeSlotHour
        components.minute = reservation.timeSlotMinute
        return Calendar.current.date(from: components) ?? reservation.date
    }
}
