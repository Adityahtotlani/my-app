import SwiftUI

// MARK: - Shared card style
struct SkyCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}

extension View {
    func skyCard() -> some View {
        modifier(SkyCardModifier())
    }
}

// MARK: - Primary button
struct SKYPrimaryButton: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(disabled ? Color.skyIndigo.opacity(0.5) : Color.skyIndigo)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(disabled)
    }
}

// MARK: - Text field
struct SKYTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(Color(UIColor.systemGray4), lineWidth: 1)
        }
        .font(.system(size: 16))
    }
}
