import SwiftUI

struct AvatarView: View {
    let customer: Customer
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let data = customer.thumbnail, let img = UIImage(data: data) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                ZStack {
                    Circle().fill(.tint.opacity(0.15))
                    Text(customer.initials).font(.system(size: size * 0.4, weight: .semibold)).foregroundStyle(.tint)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
