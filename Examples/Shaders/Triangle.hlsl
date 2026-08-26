struct VertexOutput {
    float4 position : SV_Position;
    float3 color : COLOR0;
};

VertexOutput vertex_main(uint id : SV_VertexID) {
    const float2 positions[3] = {
        float2(0.0, -0.6),
        float2(0.6, 0.5),
        float2(-0.6, 0.5)
    };
    const float3 colors[3] = {
        float3(1.0, 0.25, 0.2),
        float3(0.2, 0.85, 0.45),
        float3(0.25, 0.5, 1.0)
    };

    VertexOutput output;
    output.position = float4(positions[id], 0.0, 1.0);
    output.color = colors[id];
    return output;
}

float4 fragment_main(VertexOutput input) : SV_Target0 {
    return float4(input.color, 1.0);
}
