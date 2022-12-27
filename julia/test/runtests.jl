using PlatformAwareQueens
using Test

@testset "PlatformAwareQueens.jl" begin

    setCutoffDepth(5)
    
    @serial 12

    @mcore 12
    
    setBlockSize(128)

    @sgpu 12

    @mgpu 12

    setCpuPortion(0.2)

    @mcoremgpu 12
end
