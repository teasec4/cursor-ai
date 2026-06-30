import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Form {
            TextField("DeepSeek endpoint", text: endpointBinding)
            TextField("Model", text: $settings.deepSeekModel)
            Stepper("Auto-hide: \(Int(settings.overlayAutoHideDelay))s", value: $settings.overlayAutoHideDelay, in: 3...30, step: 1)
        }
        .padding(20)
        .frame(width: 420)
    }

    private var endpointBinding: Binding<String> {
        Binding(
            get: { settings.deepSeekEndpoint.absoluteString },
            set: { value in
                if let url = URL(string: value) {
                    settings.deepSeekEndpoint = url
                }
            }
        )
    }
}
