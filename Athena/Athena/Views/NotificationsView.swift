//
//  NotificationsView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI

struct NotificationsView: View {
    @AppStorage("all_notif") var allNotifications: Bool = true
    @AppStorage("daily_notif") var dailyReminder: Bool = true
    @AppStorage("team_notif") var teamAthena: Bool = true
    
    @State private var selectedTime = Date()
    let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
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
                        Text("Notifications Enabled")
                        Spacer()
                        Toggle("", isOn: $allNotifications)
                    }
                    .onChange(of: allNotifications) { newValue in
                        if newValue == false {
                            dailyReminder = false
                            teamAthena = false
                        }
                    }
                    
                    HStack {
                        Text("Daily Reminder Enabled")
                        Spacer()
                        Toggle("", isOn: $dailyReminder)
                    }
                    .onChange(of: dailyReminder) { newValue in
                        if newValue == false {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-notification"])
                        } else {
                            // Start schedule
                        }
                    }
                    
                    HStack {
                        Text("Team Athena Updates Enabled")
                        Spacer()
                        Toggle("", isOn: $teamAthena)
                    }
                    .onChange(of: teamAthena) { newValue in
                        if newValue == false {
                            // Remove observer
                        } else {
                            // Add observer
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.2))
                
                Section {
                    VStack {
                        HStack {
                            ForEach(days, id: \.self) { day in
                                Button {
                                    // Toggle
                                } label: {
                                    ZStack {
                                        Circle()
                                            .frame(width: 40, height: 40, alignment: .center)
                                            .foregroundColor(.blue)
                                        Text("\(String(day.prefix(2)))")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        DatePicker("Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                    }
                }
                .listRowBackground(Color.white.opacity(0.2))
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .primaryAction, content: {
                Button {
                    
                } label: {
                    Text("Save")
                }
            })
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization { _, _ in }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
