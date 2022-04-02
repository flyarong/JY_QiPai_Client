using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class AudioSettingManager
{
    static bool btFirst = true;//true为包体大小优先(false是性能优先)
    static string[] AudioType = new string[] { ".mp3", ".wav", ".ogg" };
    static void AddFileList(List<string> filePaths, string path)
    {
        for (int j = 0; j < AudioType.Length; ++j)
        {
            if (AudioType[j] == Path.GetExtension(path))
            {
                filePaths.Add(path);
            }
        }
    }

    const string AudioLazySettingTag = "Assets/Audio Tool/优化音频文件设置(懒人式)";
    [MenuItem(AudioLazySettingTag, false, 64)]
    public static void AudioLazySetting()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;
        if (assetGUIDArray.Length > 0)
        {
            List<string> filePaths = new List<string>();
            for (int i = 0; i < assetGUIDArray.Length; ++i)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[i]);
                if (Directory.Exists(assetPath))
                {
                    string[] folder = new string[] { assetPath };
                    //将文件夹下所有资源作为选择资源
                    string[] paths = AssetDatabase.FindAssets(null, folder);
                    foreach (var p in paths)
                    {
                        string ppath = AssetDatabase.GUIDToAssetPath(p);
                        if (!Directory.Exists(ppath))
                        {
                            AddFileList(filePaths, ppath);
                        }
                    }
                }
                else
                {
                    AddFileList(filePaths, assetPath);
                }
            }
            var count = 0;
            AudioClipLoadType loadtype = AudioClipLoadType.DecompressOnLoad;
            AudioCompressionFormat audioCompressionFormat = AudioCompressionFormat.Vorbis;
            EditorUtility.DisplayProgressBar("3.Set Audio ", "3.Set Audio ...", 0);
            foreach (string path in filePaths)
            {
                count++;
                EditorUtility.DisplayProgressBar("3.Set Audio " + "(" + count + "/" + filePaths.Count + ")", path, count / (float)filePaths.Count);
                AudioImporter audioImporter = AssetImporter.GetAtPath(path) as AudioImporter;
                AudioClip audio = AssetDatabase.LoadAssetAtPath<AudioClip>(path);
                audioImporter.forceToMono = true;
                AudioImporterSampleSettings generalSettings = new AudioImporterSampleSettings();
                if (audio.samples / audio.length > 22050)
                {
                    Debug.Log(audio.samples / audio.length);
                    generalSettings.sampleRateSetting = AudioSampleRateSetting.OverrideSampleRate;
                    generalSettings.sampleRateOverride = 22050;
                }
                if (audio.length >= 5)
                {
                    loadtype = AudioClipLoadType.Streaming;
                    audioCompressionFormat = AudioCompressionFormat.Vorbis;
                }
                else if (audio.length < 1)
                {
                    loadtype = AudioClipLoadType.DecompressOnLoad;
                    audioCompressionFormat = AudioCompressionFormat.ADPCM;
                }
                else
                {
                    loadtype = AudioClipLoadType.CompressedInMemory;
                    audioCompressionFormat = AudioCompressionFormat.ADPCM;
                }

                generalSettings.loadType = loadtype;
                if (btFirst)
                {
                    generalSettings.compressionFormat = AudioCompressionFormat.Vorbis;
                }
                else
                {
                    generalSettings.compressionFormat = audioCompressionFormat;
                }
                generalSettings.quality = 0.5f;
                audioImporter.defaultSampleSettings = generalSettings;

                //audioImporter.SetOverrideSampleSettings("Android", androidSettings);
                //audioImporter.SetOverrideSampleSettings("IOS", iOSSettings);

                AssetDatabase.ImportAsset(path);
            }
            EditorUtility.ClearProgressBar();
        }
    }
}
