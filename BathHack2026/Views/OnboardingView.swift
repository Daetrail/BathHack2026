import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Text("C.H.U.D")
                    .font(.largeTitle)
                    .foregroundStyle(.white)

                VStack(spacing: 16) {
                    Button("Sign In") {
                        viewModel.goToSignIn()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .buttonStyle(.glassProminent)

                    Button("Register") {
                        viewModel.goToRegister()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .buttonStyle(.glass)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationDestination(isPresented: $viewModel.navigateToSignIn) {
                SignInView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToRegister) {
                AgeView()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
