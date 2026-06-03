import SwiftUI

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Community")
                            .font(.system(size: 28, weight: .heavy)).foregroundColor(.skyText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Satsang finder
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Satsang Finder")
                                .font(.system(size: 18, weight: .bold)).foregroundColor(.skyText)
                            Text("Find local & virtual group sessions near you — coming soon.")
                                .font(.system(size: 15)).foregroundColor(.skySub).lineSpacing(4)
                        }
                        .skyCard()

                        // Community stat
                        Text("You're practicing alongside thousands of Art of Living alumni worldwide.")
                            .font(.system(size: 15)).italic()
                            .foregroundColor(Color(red: 55/255, green: 48/255, blue: 163/255))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.skyIndigoLight)
                            .cornerRadius(16)

                        // XP teaser
                        HStack(spacing: 12) {
                            Text("+75 XP")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
                            Text("when you attend a Satsang")
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 21/255, green: 128/255, blue: 61/255))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color(red: 240/255, green: 253/255, blue: 244/255))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
