% 设置文件夹路径
root_path = 'E:\代码接单\语音情感识别\project2_database\enterface database';
subject_folders = dir(fullfile(root_path, 'subject *'));
emotions = {'anger', 'disgust', 'fear', 'happiness', 'sadness', 'surprise'};

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
                avi_file = dir(fullfile(sentence_folder, '*.avi'));
                
                % 检查AVI文件是否存在
                if ~isempty(avi_file)
                    avi_file_path = fullfile(sentence_folder, avi_file.name);
                    
                    % 转换视频文件为音频文件
                    [audio_data, audio_fs] = audioread(avi_file_path, 'native');
                    
                    % 保存音频文件为WAV格式
                    wav_file_path = fullfile(sentence_folder, [avi_file.name(1:end-4) '.wav']);
                    audiowrite(wav_file_path, audio_data, audio_fs);
                end
            end
        end
    end
end
