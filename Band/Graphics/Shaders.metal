#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex_shader(uint vid [[ vertex_id ]]) {
    const float4x4 vertices = float4x4(float4(-0.5, -0.5, 0.0, 0.5),
                                       float4( 0.5, -0.5, 0.0, 0.5),
                                       float4(-0.5,  0.5, 0.0, 0.5),
                                       float4( 0.5,  0.5, 0.0, 0.5));
    return vertices[vid];
}

fragment float4 backgroundGradient_fragment_shader(float4 pixPos [[position]],
                                                   device float2& res [[ buffer(0) ]],
                                                   device float& time [[ buffer(1) ]]) {
    
    float2 uv = (2.0 * pixPos.xy - res) / min(res.x, res.y);
    
    float g = smoothstep(-1.5, 0, uv.y);
    float col = abs(sin(time / 2));
    return float4((col / 2) + 0.2, 0.1, 1, 1.0) * g * 0.8;
}
