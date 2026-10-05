import SwitcherCore
import SwiftUI

struct TiboForecastEntry: View {
    @ObservedObject var model: AppModel
    @ObservedObject var forecastModel: TiboForecastModel
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Button(action: onOpen) {
                HStack(spacing: 7) {
                    Image(systemName: "clock.arrow.circlepath")
                        .frame(width: 15)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.text("tibo_title"))
                            .font(.system(size: 11.5, weight: .medium))
                        Text(summary)
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                        if forecastModel.forecast?.forwardSignal != nil {
                            Text(model.text("tibo_forward_short"))
                                .font(.system(size: 10))
                                .foregroundStyle(.orange)
                        }
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            HStack(spacing: 2) {
                Text(model.text("tibo_data"))
                    .foregroundStyle(.secondary)
                Link("codex-reset.com", destination: TiboForecastFormatting.sourceURL)
                    .foregroundStyle(.blue)
            }
            .font(.system(size: 10))
            .padding(.leading, 22)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var summary: String {
        guard let forecast = forecastModel.forecast else {
            return model.text(forecastModel.isLoading ? "tibo_loading" : "tibo_unavailable")
        }
        return "\(model.text("tibo_24h")) \(forecast.next24HourPercent)% · "
            + "\(model.text("tibo_48h")) \(forecast.next48HourPercent)% "
            + model.text("tibo_experimental_short")
    }
}

struct TiboForecastView: View {
    @ObservedObject var model: AppModel
    @ObservedObject var forecastModel: TiboForecastModel
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PopoverHeader(title: model.text("tibo_title"), backTitle: model.text("back"), onBack: onBack)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let forecast = forecastModel.forecast {
                        if let signal = forecast.forwardSignal {
                            forwardSignalDetails(signal)
                            Divider()
                        }
                        forecastDetails(forecast)
                        sourceCredit
                        Divider()
                        Text(model.text("tibo_history"))
                            .font(.system(size: 12, weight: .semibold))
                        ForEach(forecast.events) { event in
                            HStack(alignment: .firstTextBaseline, spacing: 7) {
                                Text(TiboForecastFormatting.beijingTime(event.postedAt))
                                    .font(.system(size: 10.5).monospacedDigit())
                                Spacer(minLength: 4)
                                Link(model.text("tibo_original"), destination: event.url)
                                    .font(.system(size: 10.5))
                            }
                            Text(verbatim: event.summary)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            Divider()
                        }
                    } else {
                        Text(model.text(forecastModel.isLoading ? "tibo_loading" : "tibo_unavailable"))
                            .font(.system(size: 11.5))
                            .foregroundStyle(.secondary)
                    }
                    Text(model.text("tibo_scope"))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .frame(maxHeight: 430)
        }
    }

    private var sourceCredit: some View {
        HStack(spacing: 2) {
            Text(model.text("tibo_data"))
                .foregroundStyle(.secondary)
            Link("codex-reset.com", destination: TiboForecastFormatting.sourceURL)
                .foregroundStyle(.blue)
        }
        .font(.system(size: 10.5))
    }

    private func forwardSignalDetails(_ signal: TiboResetForecast.ForwardSignal) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(model.text("tibo_forward_heading"))
                .font(.system(size: 12, weight: .semibold))
            Text(model.text("tibo_forward_detail"))
                .font(.system(size: 10.5))
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("\(model.text("tibo_posted")) "
                     + TiboForecastFormatting.beijingTime(signal.postedAt))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 4)
                Link(model.text("tibo_original"), destination: signal.url)
                    .foregroundStyle(.blue)
            }
            .font(.system(size: 10))
        }
    }

    private func forecastDetails(_ forecast: TiboResetForecast) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.text("tibo_forecast_heading"))
                .font(.system(size: 12, weight: .semibold))
            HStack(spacing: 12) {
                probability(model.text("tibo_24h"), forecast.next24HourPercent)
                probability(model.text("tibo_48h"), forecast.next48HourPercent)
            }
            Text(model.text("tibo_probability_note"))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let window = forecast.historicalNextWindow, let medianDays = forecast.recentMedianDays {
                Text("\(model.text("tibo_historical_window")) "
                     + TiboForecastFormatting.beijingWindow(window))
                    .font(.system(size: 11, weight: .medium))
                Text("\(model.text("tibo_median_gap")) "
                     + String(format: "%.1f", medianDays)
                     + " \(model.text("tibo_days"))")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
            }
            Text("\(model.text("tibo_common_hours")) "
                 + TiboForecastFormatting.hourWindow(forecast.commonHourStart, forecast.commonHourEnd))
                .font(.system(size: 10.5))
            Text("\(model.text("tibo_last_reset")) "
                 + TiboForecastFormatting.beijingTime(forecast.lastResetAt))
                .font(.system(size: 10.5))
            Text("\(model.text("tibo_confidence")) "
                 + model.text("tibo_confidence_\(forecast.confidence)"))
                .font(.system(size: 10.5))
                .foregroundStyle(.orange)
            Text(model.text("tibo_uncertainty"))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(model.text("tibo_updated")) "
                 + TiboForecastFormatting.beijingTime(forecast.updatedAt))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }

    private func probability(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text("\(value)%")
                .font(.system(size: 20, weight: .semibold).monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 7))
    }
}

private enum TiboForecastFormatting {
    static let sourceURL = URL(string: "https://codex-reset.com/")!

    static func beijingTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }

    static func hourWindow(_ start: Int, _ end: Int) -> String {
        String(format: "%02d:00–%02d:00", start, end)
    }

    static func beijingWindow(_ window: Range<Date>) -> String {
        let start = beijingTime(window.lowerBound)
        let end = beijingTime(window.upperBound)
        return "\(start)–\(end.suffix(5))"
    }
}
