import MetalKit

class RenderObject {
    private var vertexFunction: MTLFunction?
    private var fragmentFunction: MTLFunction?
    
    init(vertexFunction: MTLFunction?, fragmentFunction: MTLFunction?) {
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
    }
    func render(renderCommandEncoder: MTLRenderCommandEncoder?) {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Engine.colorPixelFormat
        
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        guard
            let renderPipelineState = try? Engine.device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        else {
            return
        }
        renderCommandEncoder?.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}

class Renderer: NSObject {
    
    let renderObject: RenderObject
    let currentDate = Date()
    
    var resolutionBuffer: MTLBuffer?
    var timeBuffer: MTLBuffer?
        
    init(_ renderObject: RenderObject) {
        self.renderObject = renderObject
        resolutionBuffer = Engine.device?.makeBuffer(length: Float.size(2))
        timeBuffer = Engine.device?.makeBuffer(length: Float.size)
    }
    
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let width = Float(size.width)
        let height = Float(size.height)
        updateResolution(width: width, height: height)
    }
    
    func draw(in view: MTKView) {
        guard
            let commandBuffer = Engine.commandQueue?.makeCommandBuffer(),
            let currentDrawable = view.currentDrawable,
            let currentRenderPassDescriptor = view.currentRenderPassDescriptor,
            let resolutionBuffer,
            let timeBuffer
        else {
            return
        }
        
        let time = Float(Date().timeIntervalSince(currentDate))
        updateTime(time: time, buffer: timeBuffer)
        
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        
        renderCommandEncoder?.setFragmentBuffer(resolutionBuffer, offset: 0, index: 0)
        renderCommandEncoder?.setFragmentBuffer(timeBuffer, offset: 0, index: 1)
        
        renderObject.render(renderCommandEncoder: renderCommandEncoder)
        
        renderCommandEncoder?.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    func updateResolution(width: Float, height: Float) {
        memcpy(resolutionBuffer?.contents(), [width, height], Float.size(2))
    }
    
    func updateTime(time: Float, buffer: MTLBuffer) {
        updateBuffer(time, buffer)
    }
}

extension Renderer {
    func updateBuffer<T>(_ data:T, _ buffer: MTLBuffer) {
        let pointer = buffer.contents()
        let value = pointer.bindMemory(to: T.self, capacity: 1)
        value[0] = data
    }
}
