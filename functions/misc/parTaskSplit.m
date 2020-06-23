function indices = parTaskSplit(num_tasks, num_proc, proc_index, partitioning)
%PARTASKSPLIT Summary of this function goes here
%   num_proc (index 1 .... to numproc)
%   num_tasks (indexed 1 ... to num_tasks)
%   patitioning (str) 'contiguous' or 'block'
    
    if(nargin < 4)
        partitioning = 'contiguous';
    end

    if((nargin == 2) || isempty(proc_index))
        indices = arrayfun(@(pi) parTaskSplit(num_tasks, num_proc, pi, partitioning), 1:num_proc, 'UniformOutput', false);
    else
        if(strcmp(partitioning, 'contiguous'))       
            rem = mod(num_tasks, num_proc);
            dlt = floor(num_tasks/num_proc);
            if((proc_index - 1) < rem)
                start_correction = proc_index;
                stop_correction  = 1;
            else
                start_correction = rem + 1;
                stop_correction  = 0;
            end
            start = dlt * (proc_index - 1) + start_correction;
            stop  = start + (dlt - 1) + stop_correction;
            indices = start:stop;
        elseif(strcmp(partitioning, 'interleaved'))
            indices = proc_index:num_proc:num_tasks;
        end
    end
end

