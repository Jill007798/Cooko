import SwiftUI

struct HeaderLogo: View {
    var body: some View {
        HStack {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundColor(.primaryGreen)
            
            Text("Cooko")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    HeaderLogo()
        .padding()
}
