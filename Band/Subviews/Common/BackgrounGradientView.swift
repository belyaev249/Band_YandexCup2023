import MetalKit

private final class BackgrounGradientViewObject: RenderObject {
    init() {
        let vertexFunction = ShaderLibrary.function(Basic_VertexShader.name)
        let fragmentFunction = ShaderLibrary.function(BackgroundGradient_FragmentShader.name)
        super.init(vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
    }
}

final class BackgrounGradientView: MTKView {
    private let renderer: Renderer
        
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        
        let renderObject = BackgrounGradientViewObject()
        self.renderer = Renderer(renderObject)
        
        super.init(frame: frameRect, device: Engine.device)
        
        self.clearColor = Engine.clearColor
        self.colorPixelFormat = Engine.colorPixelFormat
        self.delegate = renderer
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
