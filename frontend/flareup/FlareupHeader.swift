import SwiftUI

struct FlareupHeader<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "FFF2E2")
                .ignoresSafeArea(edges: .top)

            HStack(spacing: 8) {
                Image("logo_top")
                    .resizable()
                    .frame(width: 50, height: 50)
                Text("flareUp")
                    .font(.custom("Poppins-Bold", size: 45))
                    .foregroundColor(Color(hex: "F7941D"))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 15)

            VStack {
                Spacer()
                content()
            }
        }
        .frame(height: 110)
    }
}
#Preview {
    MainView()
}
