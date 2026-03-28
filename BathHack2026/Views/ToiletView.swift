import SwiftUI

struct ToiletView: View {
    let toilet: Toilets

    var body: some View {
        Text(toilet.toiletName)
            .font(.system(size: 40, weight: .bold))
    }
}
