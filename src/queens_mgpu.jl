# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

function get_load_each_gpu(gpu_load, num_gpus, device_load)

	for device in 1:num_gpus
		device_load[device] = floor(Int64, gpu_load/num_gpus)
		if(device == num_gpus)
			device_load[device]+= gpu_load%num_gpus
		end
	end

end 

function get_starting_point_each_gpu(cpu_load::Int64, num_devices, device_load,device_starting_point)
	
	starting_point = cpu_load
	device_starting_point[1] = starting_point + 1
	if(num_devices>1)
		for device in 2:num_devices			
			device_starting_point[device] = device_starting_point[device-1]+device_load[device-1]
		end
	end

end ###

function init_queens_mgpu()
	@info "running mgpu queens"
	configureHeap()
end

function queens_mgpu(size)
	
	size += 1
	cutoff_depth = getCutoffDepth()
	num_gpus = Int64(length(CUDA.devices()))

	(subproblems, number_of_subproblems, partial_tree_size) = queens_partial_search!(Val(size), cutoff_depth)

	tree_each_task = zeros(Int64, num_gpus + 1)
	sols_each_task = zeros(Int64, num_gpus + 1)
    
    device_load = zeros(Int64, num_gpus)
    device_starting_position = zeros(Int64, num_gpus)

	get_load_each_gpu(number_of_subproblems, num_gpus, device_load)
	get_starting_point_each_gpu(0, num_gpus, device_load, device_starting_position)   
	
	#for device in 1:num_gpus
	#	@info "Device - $device - Load: $(device_load[device]) - Start point: $(device_starting_position[device])"
	#end

	@sync begin
			for gpu_dev in 1:num_gpus
				Threads.@spawn begin
					device!(gpu_dev - 1)
					# @info "- starting device: $(gpu_dev - 1)"
					(sols_each_task[gpu_dev],tree_each_task[gpu_dev]) = queens_gpu_caller(size, 
					                                                                      cutoff_depth, 																						   
																						  device_load[gpu_dev],
					                                                                      device_starting_position[gpu_dev], 
																						  subproblems)
				end
			end##for
	end##syncbegin

	final_tree = sum(tree_each_task) + partial_tree_size
	final_num_sols = sum(sols_each_task)

	return final_num_sols, final_tree
end