enum RecordingCaptureTimingTests {
    static func run() {
        var timing = RecordingCaptureTiming()
        TestSupport.expectEqual(timing.recordingStartIfReady(rms: 0.1), nil)

        let captureStart = ContinuousClock.now
        timing.start(at: captureStart)
        // Silent audio is captured without making the overlay ready.
        TestSupport.expectEqual(timing.recordingStartIfReady(rms: 0), nil)
        TestSupport.expectEqual(timing.recordingStartIfReady(rms: 0), nil)

        let speechStart = captureStart.advanced(by: .seconds(5))
        guard let reportedStart = timing.recordingStartIfReady(rms: 0.1) else {
            fatalError("First non-silent audio must report readiness")
        }
        TestSupport.expectEqual(reportedStart, captureStart)
        TestSupport.expectEqual(reportedStart.duration(to: speechStart), .seconds(5))

        // Later silence and sound must not restart the timer or fire readiness again.
        TestSupport.expectEqual(timing.recordingStartIfReady(rms: 0), nil)
        TestSupport.expectEqual(timing.recordingStartIfReady(rms: 0.2), nil)

        // A new recording starts its own clock and can report readiness again.
        let nextStart = captureStart.advanced(by: .seconds(30))
        timing.start(at: nextStart)
        TestSupport.expectEqual(timing.recordingStartIfReady(rms: 0), nil)
        TestSupport.expectEqual(timing.recordingStartIfReady(rms: 0.1), nextStart)
    }
}
