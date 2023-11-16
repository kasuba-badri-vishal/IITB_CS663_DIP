train_set = [];
train_index = [];
test_set = [];
test_index = [];

for i = [1:13, 15:39]
    if i<10
        images = dir("CroppedYale/CroppedYale/yaleB0" + num2str(i) + "/*.pgm");
    else    
        images = dir("CroppedYale/CroppedYale/yaleB" + num2str(i) + "/*.pgm");
    end    
    for j = 1:length(images)
        file = images(j).folder + "/" + images(j).name;
        image = im2double(imread(file));

        if (j <= 40)
            train_set = cat(2, train_set, image(:));
            train_index = cat(2, train_index, i);
        else
            test_set = cat(2, test_set, image(:));
            test_index = cat(2, test_index, i);
        end

    end

end

n_train = size(train_set, 2);
n_test = size(test_set, 2);
mean_vector = mean(train_set, 2);

X = train_set - mean_vector;
Y = test_set - mean_vector;
mean = transpose(sum(transpose(train_set)))/(32*6);
X = train_set - kron(mean, ones([1 32*6]));
%% Get eigen space and eigen coefficients

% using eig
L = X' * X;
[V, D] = eig(L, 'vector');
[D, ind] = sort(D, 'descend');
V = V(:, ind);
U = X * V;

% Normalizing the eigen vectors
for i = 1:size(U, 2)
    U(:, i) = U(:, i) / norm(U(:, i));
end
k = [1, 2, 3, 5, 10, 15, 20, 30, 50, 60, 65, 75, 100, 200, 300, 500, 1000]; 
recog_rate = zeros(size(k));

%% squared distance from all eigen vectors.

%for i = 1:length(k)
 %   eigen_space = U(:, 1:k(i));
  %  eigen_coef = (eigen_space') * X;
   % test_coef = (eigen_space') * Y;
    %recog_count = 0;
  
    %for j = 1:n_test
     %   [m, index] = min(sum((eigen_coef - test_coef(:, j)).^2));

      %  if train_index(index) == test_index(j)
       %     recog_count = recog_count + 1;
        %end

    %end 

    %recog_rate(i) = recog_count / n_test;
%end

%plot(k, recog_rate, 'o-');
%ylabel("Recognition rate", 'FontSize', 15); xlabel("k", 'FontSize', 15);


%% Neglecting first 3.

for i = 1:length(k)
    eigen_space = U(:, 1:k(i));
    eigen_coef = (eigen_space') * X;
    eigen_coef = eigen_coef(4:end,:);
    test_coef = (eigen_space') * Y;
    test_coef = test_coef(4:end,:);
    recog_count = 0;
   
    for j = 1:n_test
        [m, index] = min(sum((eigen_coef - test_coef(:, j)).^2));

        if train_index(index) == test_index(j)
            recog_count = recog_count + 1;
        end

    end

    recog_rate(i) = recog_count / n_test;
end

plot(k, recog_rate, 'o-');
ylabel("Recognition rate", 'FontSize', 15); xlabel("k", 'FontSize', 15);