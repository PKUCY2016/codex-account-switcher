import SwitcherCore
import SwiftUI

struct TiboForecastEntry: View {
    @ObservedObject var model: AppModel
    @ObservedObject var forecastModel: TiboForecastModel

    var body: some View {
        Link(destination: URL(string: "https://codex-reset.com/")!) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14))
                    .accessibilityHidden(true)
                probability(model.text("tibo_24h"), forecastModel.forecast?.next24HourPercent)
                probability(model.text("tibo_48h"), forecastModel.forecast?.next48HourPercent)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(model.text("tibo_title"))
        .accessibilityValue(summary)
        .help(forecastModel.forecast == nil
              ? model.text(forecastModel.isLoading ? "tibo_loading" : "tibo_unavailable")
                + "\n" + model.text("tibo_source_hint")
              : model.text("tibo_source_hint"))
    }

    private func probability(_ label: String, _ value: Int?) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(value.map { "\($0)%" } ?? (forecastModel.isLoading ? "…" : "—"))
                .font(.system(size: 13, weight: .semibold).monospacedDigit())
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 7))
    }

    private var summary: String {
        guard let forecast = forecastModel.forecast else {
            return model.text(forecastModel.isLoading ? "tibo_loading" : "tibo_unavailable")
        }
        return "\(model.text("tibo_24h")) \(forecast.next24HourPercent)% · "
            + "\(model.text("tibo_48h")) \(forecast.next48HourPercent)%"
    }
}
