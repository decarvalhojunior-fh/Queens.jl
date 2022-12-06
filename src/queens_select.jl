# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

function check_cuda()
    try
        CUDA.functional(), length(CUDA.devices())
    catch
        false, 0
    end
end

function count_procs()
    try
        nprocs()
    catch
        1
    end
end

function count_cores()
    CpuId.cpucores_total()
end

function select_kernel_method()

    is_cuda_functional, gpu_count = check_cuda()
    core_count = count_cores()
    process_count = count_procs()

    if (process_count == 1)
        if (is_cuda_functional)
            if (core_count == 1)
                if gpu_count == 1
                    init_queens_sgpu, queens_sgpu
                elseif gpu_count > 1
                    init_queens_mgpu, queens_mgpu
                end
            elseif gpu_count > 0 && core_count > 1
                init_queens_mgpu_mcore, queens_mgpu_mcore
            end
        elseif core_count > 1
            init_queens_mcore, queens_mcore
        else
            init_queens_serial, queens_serial
        end
    elseif process_count > 1
        init_queens_distributed, queens_distributed
    end
end

const init_queens, queens = select_kernel_method()  