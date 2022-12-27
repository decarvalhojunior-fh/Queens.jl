# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

module PlatformAwareQueens

using CUDA
using StaticArrays
using Distributed
using CpuId

include("queens_params.jl")

include("queens_base.jl")
include("queens_cpu_base.jl")
include("queens_gpu_base.jl")

include("queens_serial.jl")
include("queens_mcore.jl")
include("queens_sgpu.jl")
include("queens_mgpu.jl")
include("queens_mcore_mgpu.jl")
include("queens_distributed.jl")
include("queens_select.jl")

function __init__()    
    init_queens()
end

export queens

end
