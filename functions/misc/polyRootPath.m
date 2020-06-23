function root_path = polyRootPath()
%POLYROOTPATH Returns root directory of polynomial matlab package

file_path  = fileparts(which('polyRootPath'));
file_dirs  = regexp(file_path, filesep, 'split');
root_path  = strjoin(file_dirs(1:end-2), filesep);
end