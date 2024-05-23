% 设置文件夹路径
root_path = 'E:\代码接单\语音情感识别\project2_database\enterface database';
subject_folders = dir(fullfile(root_path, 'subject *'));
emotions = {'anger', 'disgust', 'fear', 'happiness', 'sadness', 'surprise'};

% 预处理参数
target_sample_rate = 16000; % 重采样目标采样率（Hz）
frame_length = 0.025; % 帧长度（s）
frame_overlap = 0.01; % 帧重叠（s）

% 初始化特征矩阵和标签向量
pitch_features = [];
timbre_features = [];
loudness_features = [];
duration_features = [];
labels = [];

% 遍历所有志愿者文件夹
for subject_index = 1:length(subject_folders)
    subject_folder = fullfile(root_path, subject_folders(subject_index).name);
    
    % 遍历所有情感文件夹
    for emotion_index = 1:length(emotions)
        emotion_folder = fullfile(subject_folder, emotions{emotion_index});
        
        % 遍历所有句子文件夹
        for sentence_index = 1:5
            sentence_folder = fullfile(emotion_folder, ['sentence ' num2str(sentence_index)]);
            
            % 检查句子文件夹是否存在
            if isfolder(sentence_folder)
                wav_file = dir(fullfile(sentence_folder, '*.wav'));
                
                % 检查WAV文件是否存在
                if ~isempty(wav_file)
                    wav_file_path = fullfile(sentence_folder, wav_file.name);
                    
                    % 读取音频文件
                    [audio_data, audio_fs] = audioread(wav_file_path);
                    
                    % 重采样
                    if audio_fs ~= target_sample_rate
                        audio_data = resample(audio_data, target_sample_rate, audio_fs);
                        audio_fs = target_sample_rate;
                    end

                    % 转换为单声道（如果需要）
                    if size(audio_data, 2) > 1
                        audio_data = mean(audio_data, 2);
                    end

                    % 提取音色特征 (如 MFCC)
                    mfccs = mfcc(audio_data, audio_fs, 'LogEnergy', 'Replace');

                    % 提取音高特征
                    pitch_values = pitch(audio_data, audio_fs);
                    pitch_values = repmat(mean(pitch_values), size(mfccs, 1), 1);

                    % 计算音强特征
                    frame_length_samples = round(frame_length * audio_fs);
                    frame_overlap_samples = round(frame_overlap * audio_fs);
                    rms_window = hamming(frame_length_samples, 'periodic');
                    frame_starts = 1:frame_overlap_samples:length(audio_data)-frame_length_samples+1;
                    rms_values = zeros(length(frame_starts), 1);
                    for i = 1:length(frame_starts)
                        frame = audio_data(frame_starts(i):frame_starts(i)+frame_length_samples-1);
                        rms_values(i) = sqrt(mean(frame.^2));
                    end
                    rms_values = rms_values(1:size(mfccs, 1), :);

                    % 提取持续时间特征
                    duration_value = length(audio_data) / audio_fs;

                    % 将特征添加到特征矩阵中
                    pitch_features = [pitch_features; pitch_values];
                    timbre_features = [timbre_features; mfccs];
                    loudness_features = [loudness_features; rms_values];
                    duration_features = [duration_features; repmat(duration_value, size(mfccs, 1), 1)];

                    % 将情感标签添加到标签向量中
                    emotion_label = emotion_index;
                    labels = [labels; repmat(emotion_label, length(pitch_values), 1)];
                end
            end
        end
    end
end

% 保存特征矩阵和标签向量
save('pitch_features_labels.mat', 'pitch_features', 'labels');
save('timbre_features_labels.mat', 'timbre_features', 'labels');
save('loudness_features_labels.mat', 'loudness_features', 'labels');
save('duration_features_labels.mat', 'duration_features', 'labels');

% 确保特征矩阵和标签向量的长度一致
min_length = min([size(pitch_features, 1), size(timbre_features, 1), size(loudness_features, 1), size(duration_features, 1), length(labels)]);
pitch_features = pitch_features(1:min_length, :);
timbre_features = timbre_features(1:min_length, :);
loudness_features = loudness_features(1:min_length, :);
duration_features = duration_features(1:min_length, :);
labels = labels(1:min_length);

% 重新保存特征矩阵和标签向量
save('pitch_features_labels.mat', 'pitch_features', 'labels');
save('timbre_features_labels.mat', 'timbre_features', 'labels');
save('loudness_features_labels.mat', 'loudness_features', 'labels');
save('duration_features_labels.mat', 'duration_features', 'labels');