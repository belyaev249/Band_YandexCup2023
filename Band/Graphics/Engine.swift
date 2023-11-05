import MetalKit

final class Engine {
    
    static var device: MTLDevice?
    static var commandQueue: MTLCommandQueue?
    
    static func start(_ device: MTLDevice?) {
        self.device = device
        self.commandQueue = device?.makeCommandQueue()
        ShaderLibrary.start()
    }

}

extension Engine {
    static let clearColor: MTLClearColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
    static let colorPixelFormat: MTLPixelFormat = .bgra8Unorm
}
