import SwiftUI

extension Color {
    static let skyIndigo = Color(red: 99/255, green: 102/255, blue: 241/255)

    static let skyBg = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 12/255,  green: 16/255,  blue: 30/255,  alpha: 1)
            : UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1)
    })
    static let skyText = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 236/255, green: 240/255, blue: 255/255, alpha: 1)
            : UIColor(red: 30/255,  green: 41/255,  blue: 59/255,  alpha: 1)
    })
    static let skySub = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 155/255, green: 170/255, blue: 195/255, alpha: 1)
            : UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1)
    })
    static let skyMuted = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1)
            : UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1)
    })
    static let skyIndigoLight = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 28/255,  green: 32/255,  blue: 75/255,  alpha: 1)
            : UIColor(red: 238/255, green: 242/255, blue: 255/255, alpha: 1)
    })
}
