import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Welcome to\nSickDay Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                disclaimerCard
                privacyCard
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                isPresented = false
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Medical Disclaimer")
                    .font(.headline)
            }

            Text("This app is designed for personal health tracking purposes only and does not provide medical advice, diagnosis, or treatment.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Always consult with a qualified healthcare provider for medical concerns. If you experience severe symptoms or a medical emergency, seek immediate medical attention.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Your Privacy")
                    .font(.headline)
            }

            Text("All your health data stays on your device. We do not collect, store, or transmit any of your personal information to external servers.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("You have complete control over your data and can delete it at any time from the Settings tab.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
