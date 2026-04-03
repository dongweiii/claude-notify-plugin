import Cocoa
import ImageIO

class ImageDisplayView: NSView {
    private var frames: [(image: NSImage, duration: Double)] = []
    private var currentFrame = 0
    private var timer: Timer?

    func loadImage(from url: URL) {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return }
        let count = CGImageSourceGetCount(source)

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            let image = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

            var duration = 0.1
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                if let delay = gifDict[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double, delay > 0 {
                    duration = delay
                } else if let delay = gifDict[kCGImagePropertyGIFDelayTime as String] as? Double, delay > 0 {
                    duration = delay
                }
            }
            frames.append((image: image, duration: duration))
        }

        if frames.count > 1 {
            startAnimation()
        } else {
            needsDisplay = true
        }
    }

    private func startAnimation() {
        currentFrame = 0
        scheduleNext()
    }

    private func scheduleNext() {
        guard frames.count > 1 else { return }
        let duration = frames[currentFrame].duration
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.currentFrame = (self.currentFrame + 1) % self.frames.count
            self.needsDisplay = true
            self.scheduleNext()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard !frames.isEmpty else { return }
        let image = frames[currentFrame].image
        image.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    deinit {
        timer?.invalidate()
    }
}

// --- Main ---

guard CommandLine.arguments.count >= 2 else {
    print("Usage: floating-notify <image_path> [duration_seconds]")
    exit(1)
}

let imagePath = CommandLine.arguments[1]
let duration = CommandLine.arguments.count >= 3 ? Double(CommandLine.arguments[2]) ?? 5.0 : 5.0
let imageURL = URL(fileURLWithPath: imagePath)

guard FileManager.default.fileExists(atPath: imagePath) else {
    print("File not found: \(imagePath)")
    exit(1)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let windowSize: CGFloat = 200
guard let screen = NSScreen.main else { exit(1) }
let screenFrame = screen.visibleFrame

let windowX = screenFrame.maxX - windowSize - 16
let windowY = screenFrame.maxY - windowSize - 16

let window = NSWindow(
    contentRect: NSRect(x: windowX, y: windowY, width: windowSize, height: windowSize),
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)

window.level = .floating
window.isOpaque = false
window.backgroundColor = .clear
window.hasShadow = true
window.ignoresMouseEvents = true
window.collectionBehavior = [.canJoinAllSpaces, .stationary]

let containerView = NSView(frame: NSRect(x: 0, y: 0, width: windowSize, height: windowSize))
containerView.wantsLayer = true
containerView.layer?.cornerRadius = 12
containerView.layer?.masksToBounds = true
containerView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

let imageView = ImageDisplayView(frame: NSRect(x: 0, y: 0, width: windowSize, height: windowSize))
imageView.loadImage(from: imageURL)

containerView.addSubview(imageView)
window.contentView = containerView
window.orderFrontRegardless()

DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
    app.terminate(nil)
}

app.run()
