//////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

import SwiftUI

struct BKNotificationsView: View {
  @StateObject var notification = NotificationConfig()
  
  var body: some View {
    List {
      Section(header: Text("BEL Notifications"), footer: Text("Play a sound when a BEL character is received and send a notification if the terminal is not in focus.")) {
        Toggle("Play Sound on active shell", isOn: $notification.playSoundOnActiveShell)
        Toggle("Notification on background shell", isOn: $notification.notificationOnBackgroundShell)
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
          Toggle("Use haptic feedback", isOn: $notification.useHapticFeedback)
        }
      }
      
      Section(header: Text("OSC Sequences"), footer: NotifyNotificationsView()) {
        Toggle("'Notify' notifications", isOn: $notification.notifyNotifications)
      }

      Section(header: Text("In-App Notifications"), footer: BlinkNotifyExamplesView()) {
        Toggle("Show in-app alerts", isOn: $notification.inAppNotifications)
      }
    }
    .listStyle(GroupedListStyle())
    .navigationBarTitle("Notifications")
  }
}

fileprivate enum BKNotifications: CaseIterable {
  case systemNotification
  case systemLike
  
  /// User-facing string describing the type of notification available
  var description: LocalizedStringKey {
    switch self {
    case .systemNotification: return "System notification"
    case .systemLike: return "System-like notification with title & body"
    }
  }
  
  /// Code sample to show to the user
  var example: String {
    switch self {
    case .systemNotification: return "echo -e \"\\033]9;Text to show\\a\""
    case .systemLike: return "echo -e \"\\033]777;notify;Title;Body of the notification\\a\""
    }
  }
}

/**
 Sample view to show off the available commands and samples. Tap on each command copies it and
 */
struct NotifyNotificationsView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("Blink supports standard OSC sequences & iTerm2 growl notifications. Some OSC sequences might not be supported in Mosh. Persist your connections using the geo command to receive notifications in the background after a while.\n\nExamples (tap to copy & use them on a SSH connection):")
      
      ForEach(BKNotifications.allCases, id: \.self) { notification in
        
        Button(action: {
          UIPasteboard.general.string = notification.example
        }) {
          VStack(alignment: .leading) {
            Text(notification.description).bold()
            Text(notification.example).font(.system(.caption, design: .monospaced))
          }
        }.buttonStyle(PlainButtonStyle())
        .clipShape(Rectangle())
        .padding(2)
      }
    }.onDisappear(perform: {
      BLKDefaults.save()
    })
  }
}

class NotificationConfig: ObservableObject {
  @Published var playSoundOnActiveShell: Bool {
    didSet {
      BLKDefaults.setPlaySoundOnBell(playSoundOnActiveShell)
    }
  }
  
  @Published var notificationOnBackgroundShell: Bool {
    didSet {
      _askForNotificationPermissions(completion: { granted in
        if !granted {
          self.notificationOnBackgroundShell = false
        }
        BLKDefaults.setNotificationOnBellUnfocused(self.notificationOnBackgroundShell)
      })
    }
  }
  
  @Published var useHapticFeedback: Bool {
    didSet {
      BLKDefaults.setHapticFeedbackOnBellOff(!useHapticFeedback)
    }
  }
  
  @Published var notifyNotifications: Bool {
    didSet {

      _askForNotificationPermissions(completion: { granted in
        if !granted {
          self.notifyNotifications = false
        }
        BLKDefaults.setOscNotifications(self.notifyNotifications)
      })
    }
  }

  @Published var inAppNotifications: Bool {
    didSet {
      BLKDefaults.setInAppNotifications(inAppNotifications)
    }
  }

  private func _askForNotificationPermissions(completion: @escaping(Bool) -> Void) {
    
    let center = UNUserNotificationCenter.current()
    
    center.requestAuthorization(options: [.alert, .sound, .announcement]) { (granted, error) in
      DispatchQueue.main.async {
        completion(granted)
      }
    }
  }
  
  init() {
    playSoundOnActiveShell = BLKDefaults.isPlaySoundOnBellOn()
    notificationOnBackgroundShell = BLKDefaults.isNotificationOnBellUnfocusedOn()
    useHapticFeedback = !BLKDefaults.hapticFeedbackOnBellOff()
    notifyNotifications = BLKDefaults.isOscNotificationsOn()
    inAppNotifications = BLKDefaults.isInAppNotificationsOn()
  }
}

fileprivate enum BKBlinkNotifyExamples: CaseIterable {
  case richNotification
  case claudeCodeHook

  var description: LocalizedStringKey {
    switch self {
    case .richNotification: return "Rich notification with title & body"
    case .claudeCodeHook: return "Claude Code stop hook"
    }
  }

  var example: String {
    switch self {
    case .richNotification:
      return "printf '\\033]0;blink-notify:Done:Task finished\\007' && printf '\\a'"
    case .claudeCodeHook:
      return "printf '\\033]0;blink-notify:Claude Code:Task completed\\007' && sleep 0.1 && printf '\\a'"
    }
  }
}

struct BlinkNotifyExamplesView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("The blink-notify protocol encodes notification data in the terminal title, which works over Mosh. Set the title to blink-notify:<title>:<body> then send a BEL character.\n\nExamples (tap to copy):")

      ForEach(BKBlinkNotifyExamples.allCases, id: \.self) { example in
        Button(action: {
          UIPasteboard.general.string = example.example
        }) {
          VStack(alignment: .leading) {
            Text(example.description).bold()
            Text(example.example).font(.system(.caption, design: .monospaced))
          }
        }.buttonStyle(PlainButtonStyle())
        .clipShape(Rectangle())
        .padding(2)
      }
    }.onDisappear(perform: {
      BLKDefaults.save()
    })
  }
}
