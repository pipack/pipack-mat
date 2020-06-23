function options = ApplyStencilProfileSettings(z, options)

imag_propagator_profile = {
    {'LeftWidth', 1/3}
    {'RightWidth', 1}
    {'alpha', 2/3}
    {'height', 8/3}
    {'Padding', [1/6 1/6 1/6 2/6]}; % how much padding is added around axis (Top, Right, Bottom, Left)
    {'LabelPadding', [1/3 7/12 1/3 7/12]}; % how much padding is added around axis (Top, Right, Bottom, Left)
    };

imag_iterator_profile = {
    {'LeftWidth', 1/3}
    {'RightWidth', 1/3}
    {'alpha', 0}
    {'height', 8/3}
    {'Padding', [1/6 1/6 1/6 1/6]}; % how much padding is added around axis (Top, Right, Bottom, Left)
    {'LabelPadding', [1/3 7/12 1/3 7/12]}; % how much padding is added around axis (Top, Right, Bottom, Left)
    };

real_propagator_profile = {
    {'LeftWidth', 4/3}
    {'RightWidth', 4 + 1/3}
    {'alpha', 3}
    {'height', 2/3}
    {'Padding', [1/4 1/2 1/4 1/6]}; % Padding Around Axis
    {'LabelPadding', [1/2 3/4 1/2 1]}; % Additional Padding for Top, Right, Bottom, Left Labels
    };

real_iterator_profile = {
    {'LeftWidth', 1/3}
    {'RightWidth', 1}
    {'alpha', 0}
    {'height', 8/3}
    {'Padding', [1/2 3/4 1/2 1/6]}; % Padding Around Axis
    {'LabelPadding', [1/2 1/2 1/2 1/6]}; % Additional Padding for Top, Right, Bottom, Left Labels
    };

if(isfield(options, 'profile'))
    profile = options.profile;
else
    profile = 'auto';
end

if(strcmp(profile, 'auto'))
    if(isreal(z))
        if(isfield(options,'alpha') && options.alpha == 0)
            profile = 'real_iterator';
        else
            profile = 'real_propagator';
        end
    else
        if(isfield(options,'alpha') && options.alpha == 0)
            profile = 'real_imaginary';
        else
            profile = 'real_imaginary';
        end
    end
end

if(strcmp(profile, 'imaginary_propagator'))
    default_field_value_pairs = imag_propagator_profile;
elseif(strcmp(profile, 'imaginary_iterator'))
    default_field_value_pairs = imag_iterator_profile;
elseif(strcmp(profile, 'real_propagator'))
    default_field_value_pairs = real_propagator_profile;
elseif(strcmp(profile, 'real_iterator'))
    default_field_value_pairs = real_iterator_profile;
else
    default_field_value_pairs = {};
end

options = setDefaultOptions(options, default_field_value_pairs);

end