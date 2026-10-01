import SwiftUI

/// Shown wherever an Apple Intelligence feature can't run; the rest of the app keeps working.
struct AIUnavailableBanner: View {
    var body: some View {
        if case .unavailable(let why) = Intelligence.availability {
            Label(why, systemImage: "sparkles.slash")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
