// 本地 OCR 交叉校验脚本（macOS Vision 框架，离线运行，不经外部服务）
// 用法：swift scripts/ocr_vision.swift <图1.png> [图2.png ...]
// 输出：每张图的识别文本，原样作为客观依据；用于与直接读图结果交叉对照。
import Vision
import AppKit

guard CommandLine.arguments.count > 1 else {
    print("usage: swift ocr_vision.swift <image.png> [image2.png ...]")
    exit(1)
}
for path in CommandLine.arguments.dropFirst() {
    guard let img = NSImage(contentsOfFile: path),
          let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("=== \(path) === NO IMAGE")
        continue
    }
    let req = VNRecognizeTextRequest()
    req.recognitionLevel = .accurate
    req.recognitionLanguages = ["en-US", "zh-Hans"]
    req.usesLanguageCorrection = false   // 关闭语言纠正：命令行内容逐字符照抄，不要被"修正"
    let handler = VNImageRequestHandler(cgImage: cg, options: [:])
    do { try handler.perform([req]) } catch { print("OCR error: \(error)") }
    print("=== \((path as NSString).lastPathComponent) ===")
    for obs in req.results ?? [] {
        if let c = obs.topCandidates(1).first { print(c.string) }
    }
}
