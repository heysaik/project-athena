//
//  NotificationsView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI

struct NotificationsView: View {
    @AppStorage("read_remind") var readReminder: Bool = true
    @AppStorage("remind_time") var reminderDate: Data = Data()
    @AppStorage("team_notif") var teamAthena: Bool = true

    @State private var selectedTime = Date()
    @Environment(\.presentationMode) var presentationMode
    
    
    // Used to show the gradient
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            Form {
                Section {
                    HStack {
                        Text("Daily Reading Reminder")
                        Spacer()
                        Toggle("", isOn: $readReminder)
                            .tint(Color(uiColor: UIColor(red: 0, green: 68/255, blue: 215/255, alpha: 1)))
                    }
                    .onChange(of: readReminder) { newValue in
                        if newValue == false {
                            teamAthena = false
                        }
                    }
                    DatePicker("Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                        .onChange(of: selectedTime) { newTime in
                            reminderDate = Storage.archiveDate(object: newTime)
                        }
                        .tint(.white)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.white.opacity(0.2))
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .primaryAction, content: {
                Button {
                    if readReminder == false {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["read-reminder"])
                    } else {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["read-reminder"])

                        let content = UNMutableNotificationContent()
                        content.title = "Reading Reminder"
                        content.body = "Grab a book and get cozy! Your reading session starts now! Let's knock some books out of your library!"
                        content.badge = NSNumber(value: 1)
                        content.sound = .default
                        
                        var dateComponents = DateComponents()
                        dateComponents.hour = Calendar.current.component(.hour, from: selectedTime)
                        dateComponents.minute = Calendar.current.component(.minute, from: selectedTime)
                        
                        // Create the trigger as a repeating event.
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        let request = UNNotificationRequest(identifier: "read-reminder", content: content, trigger: trigger)

                        // Schedule the request with the system.
                        UNUserNotificationCenter.current().add(request)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Save")
                }
            })
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                
            }
            selectedTime = Storage.loadDate(data: reminderDate)
        }
        .foregroundColor(.white)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}

class Storage: NSObject {
    static func archiveStringArray(object: [String]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
        
    }
    
    static func loadStringArray(data: Data) -> [String] {
        do {
            guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] else {
                return []
            }
            return array
        } catch {
            fatalError("loadWStringArray - Can't encode data: \(error)")
        }
    }
    
    static func archiveDate(object: Date) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
        
    }
    
    static func loadDate(data: Data) -> Date {
        do {
            guard let date = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Date else {
                return Date()
            }
            return date
        } catch {
            fatalError("loadDate - Can't encode data: \(error)")
        }
    }
}
