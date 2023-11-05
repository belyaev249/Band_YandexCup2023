import MetalKit

final class ShaderLibrary {
    
    public static var library: MTLLibrary?
    private static var shaders: [String: any Shader] = [:]
    
    static func start() {
        library = Engine.device?.makeDefaultLibrary()
        
        shaders.updateValue(Basic_VertexShader(), forKey: Basic_VertexShader.name)
        shaders.updateValue(BackgroundGradient_FragmentShader(), forKey: BackgroundGradient_FragmentShader.name)
    }
    
    static func function(_ functionName: String) -> MTLFunction? {
        shaders[functionName]?.function
    }
    
}

protocol Shader {
    associatedtype Name =  String
    static var name: Name { get }
    var functionName: String { get }
}

extension Shader {
    var function: MTLFunction? {
        let function = ShaderLibrary.library?.makeFunction(name: functionName)
        function?.label = Self.name as? String
        return function
    }
}

struct Basic_VertexShader: Shader {
    private(set) static var name = "Basic_VertexShader"
    private(set) var functionName = "basic_vertex_shader"
}

struct BackgroundGradient_FragmentShader: Shader {
    private(set) static var name = "BackgroundGradient_FragmentShader"
    private(set) var functionName = "backgroundGradient_fragment_shader"
}
