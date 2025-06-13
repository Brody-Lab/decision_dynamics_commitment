function [training_binary lesion_binary] = crystal_ball()

% reset state
rand('twister', sum(100*clock));
training_group = rand(1,300);
fprintf('Max is: %1.1f while min is %1.1f\n', max(training_group), min(training_group));
training_binary = {};
for k = 1:length(training_group)
    if training_group(k) > 0.5
        training_binary{k} = 'pitch';
    else
        training_binary{k} = 'duration';
    end;
end;

% reset state again
rand('twister',sum(100*clock));
lesion_group = rand(1,300);
fprintf('Max is: %1.1f while min is %1.1f\n', max(lesion_group), min(lesion_group));
lesion_binary = {};
for k = 1:length(lesion_group)
    if lesion_group(k) > 0.5
        lesion_binary{k} = 'saline';
    else
        lesion_binary{k} = 'toxin';
    end;
end;



