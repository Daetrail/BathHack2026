import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Text("Find My Toilet")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    Button {
                        viewModel.goToSignIn()
                    } label: {
                        Text("Sign In")
                            .font(.title)
                            .padding(.horizontal, 50)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .buttonStyle(.glassProminent)

                    Button {
                        viewModel.goToRegister()
                    } label: {
                        Text("Register")
                            .font(.title)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .tint(.gray)
                    .buttonStyle(.glassProminent)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationDestination(isPresented: $viewModel.navigateToSignIn) {
                SignInView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToRegister) {
                RegisterView()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
