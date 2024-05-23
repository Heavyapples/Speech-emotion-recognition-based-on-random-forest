% 加载随机森林分类器
rng(1); % 设置随机数生成器的种子以获得可重复的结果

% 初始化准确率矩阵
accuracies = zeros(4, 1);

% 读取特征矩阵和标签向量
feature_files = {'pitch_features_labels.mat', 'timbre_features_labels.mat', 'loudness_features_labels.mat', 'duration_features_labels.mat'};
feature_names = {'Pitch', 'Timbre (MFCC)', 'Loudness (RMS)', 'Duration'};

% 遍历所有特征文件
for feature_index = 1:length(feature_files)
    load(feature_files{feature_index});

    % 根据当前特征文件选择对应的特征矩阵
    switch feature_index
        case 1
            features = pitch_features;
        case 2
            features = timbre_features;
        case 3
            features = loudness_features;
        case 4
            features = duration_features;
    end

    % 划分训练集和测试集（例如，80% 训练，20% 测试）
    cv = cvpartition(labels, 'HoldOut', 0.2);

    % 训练随机森林分类器
    rf_model = TreeBagger(100, features(cv.training, :), labels(cv.training), 'Method', 'classification', 'OOBPrediction', 'on');

    % 保存训练好的模型
    save(['rf_model_' feature_names{feature_index} '.mat'], 'rf_model', '-v7.3');

    % 对测试集进行预测
    predicted_labels = str2double(predict(rf_model, features(cv.test, :)));

    % 计算准确率
    accuracy = sum(predicted_labels == labels(cv.test)) / length(labels(cv.test));

    % 将准确率添加到准确率矩阵中
    accuracies(feature_index) = accuracy;

    % 打印当前特征的准确率
    fprintf('%s accuracy: %.2f%%\n', feature_names{feature_index}, accuracy * 100);
end

% 输出准确率矩阵
disp('Accuracies:');
disp(accuracies);