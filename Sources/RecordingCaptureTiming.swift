/// Keeps capture duration independent of when the first non-silent buffer arrives.
/// AudioRecorder protects this state with its captureTiming lock.
struct RecordingCaptureTiming {
    private var startedAt: ContinuousClock.Instant?
    private var reportedReady = false

    mutating func start(at instant: ContinuousClock.Instant) {
        startedAt = instant
        reportedReady = false
    }

    /// Reports readiness once per recording, carrying the capture-start instant.
    mutating func recordingStartIfReady(rms: Float) -> ContinuousClock.Instant? {
        guard !reportedReady, rms > 0, let startedAt else { return nil }
        reportedReady = true
        return startedAt
    }
}
