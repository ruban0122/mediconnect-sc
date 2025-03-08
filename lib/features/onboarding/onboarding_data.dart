class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnboardingData> onboardingData = [
  OnboardingData(
    image: "assets/onboarding_image.png",
    title: "Our Services",
    description:
        "Mediconnect aims to improve accessibility to all your health and wellness needs. Connect to General Practitioners on demand.",
  ),
  OnboardingData(
    image: "assets/onboarding_vc.png",
    title: "Video call a healthcare doctor now",
    description:
        "Skip the queue. Get the advice you need from the comfort of your own home instantly. You can also schedule an appointment at your convenience.",
  ),
];
