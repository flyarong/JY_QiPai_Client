using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using LuaInterface;

namespace LuaFramework
{
    public class SoundManager : Manager
    {
        private AudioSource bgAudioSource;
        private const string IsShakeOnKey = "IsShakeOn_";
        private const string IsSoundOnKey = "IsSoundOn_";
        private const string IsMusicOnKey = "IsMusicOn_";
        private const string IsCenterOnKey = "IsCenterOn_";
        private const string MusicVolumeKey = "MusicVolume_";
        private const string SoundVolumeKey = "SoundVolume_";
        private const string CenterVolumeKey = "CenterVolume_"; 

        void Start()
        {
            bgAudioSource = gameObject.AddComponent<AudioSource>();
            bgAudioSource.loop = true;
        }

        /// <summary>
        /// 载入音乐文件的缓存
        /// </summary>
        private Dictionary<string, AudioClip> soundsDic = new Dictionary<string, AudioClip>();
        
        // 扩展音乐管理器
        // 震动开关
        public bool GetIsShakeOn(string pattern = null)
        {
            string key = IsShakeOnKey;
            if(pattern != null)
            {
                key = key + pattern;
            }
            return PlayerPrefs.GetInt(key, 1) == 1;
        }
        public void SetIsShakeOn(bool val, string pattern = null)
        {
            string key = IsShakeOnKey;
            if(pattern != null)
            {
                key = key + pattern;
            }
            PlayerPrefs.SetInt(key, val ? 1 : 0);
        }
        // 是否开启音效   操作音效
        public bool GetIsSoundOn(string pattern = null)
        {
            string key = IsSoundOnKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            return PlayerPrefs.GetInt(key, 1) == 1;
        }
        public void SetIsSoundOn(bool val, string pattern = null)
        {
            string key = IsSoundOnKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            PlayerPrefs.SetInt(key, val ? 1 : 0);
            SetSoundEnabled(pattern);
        }
        // 是否开启音乐   背景音
        public bool GetIsMusicOn(string pattern = null)
        {
            string key = IsMusicOnKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            return PlayerPrefs.GetInt(key, 1) == 1;
        }
        public void SetIsMusicOn(bool val, string pattern = null)
        {
            string key = IsMusicOnKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            PlayerPrefs.SetInt(key, val ? 1 : 0);
            SetMusicEnabled(pattern);
        }
        // 中控开关
        public bool GetIsCenterOn(string pattern = null)
        {
            string key = IsCenterOnKey;
            return PlayerPrefs.GetInt(key, 1) == 1;
        }
        public void SetIsCenterOn(bool val, string pattern = null)
        {
            string key = IsCenterOnKey;
            PlayerPrefs.SetInt(key, val ? 1 : 0);
            SetMusicEnabled(pattern);
            SetSoundEnabled(pattern);
        }
        // 中控音量
        public float GetCenterVolume(string pattern = null)
        {
            string key = CenterVolumeKey;
            return PlayerPrefs.GetFloat(key, 1.0f);
        }
        public void SetCenterVolume(float value, string pattern = null)
        {
            string key = CenterVolumeKey;
            PlayerPrefs.SetFloat(key, value);
            UpdateMusicVolume(pattern);
            UpdateSoundVolume(pattern);
        }
        // 背景音量
        public float GetMusicVolume(string pattern = null)
        {
            string key = MusicVolumeKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            return PlayerPrefs.GetFloat(key, 1.0f) * GetCenterVolume(pattern);
        }
        public void SetMusicVolume(float value,string pattern = null)
        {
            string key = MusicVolumeKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            PlayerPrefs.SetFloat(key, value);
            UpdateMusicVolume(pattern);
        }
        // 音效音量
        public float GetSoundVolume(string pattern = null)
        {
            string key = SoundVolumeKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            return PlayerPrefs.GetFloat(key, 1.0f) * GetCenterVolume(pattern);
        }
        public void SetSoundVolume(float value, string pattern = null)
        {
            string key = SoundVolumeKey;
            if (pattern != null)
            {
                key = key + pattern;
            }
            PlayerPrefs.SetFloat(key, value);
            UpdateSoundVolume(pattern);
        }
        // 设置背景音量
        private void UpdateMusicVolume(string pattern = null)
        {
            bgAudioSource.volume = GetMusicVolume(pattern);
        }
        // 更新音效音量
        private void UpdateSoundVolume(string pattern = null)
        {
            float sv = GetSoundVolume(pattern);
            foreach (var item in m_loopAudioDic)
            {
                if (pattern == null && item.Value.pattern == null)
                {
                    item.Value.audio.volume = sv;
                }
                if (pattern != null && item.Value.pattern != null && pattern == item.Value.pattern)
                {
                    item.Value.audio.volume = sv;
                }
            }
        }
        // 设置音效开关
        private void SetMusicEnabled(string pattern = null)
        {
            bool b1 = GetIsMusicOn(pattern);
            bool b2 = GetIsCenterOn(pattern);
            bool b = b1 && b2;
            bgAudioSource.enabled = b;
        }
        // 设置音效开关
        private void SetSoundEnabled(string pattern = null)
        {
            bool b1 = GetIsSoundOn(pattern);
            bool b2 = GetIsCenterOn(pattern);
            bool b = b1 && b2;
            foreach (var item in m_loopAudioDic)
            {
                if (pattern == null && item.Value.pattern == null)
                {
                    item.Value.audio.enabled = b;
                }
                if (pattern != null && item.Value.pattern != null && pattern == item.Value.pattern)
                {
                    item.Value.audio.enabled = b;
                }
            }
        }

		private void StopSound(string audioKey, bool removeAudio) {
			AudioSourceData asd;
			if (!m_loopAudioDic.TryGetValue (audioKey, out asd))
				return;

			if (asd.coroutine != null) {
				StopCoroutine (asd.coroutine);
				asd.coroutine = null;
			}

			if (removeAudio) {
				asd.audio.Stop ();
				Destroy(asd.audio);
				m_loopAudioDic.Remove(audioKey);
			} else
				asd.audio.Pause ();

		}

        /// <summary>
        /// 播放背景音
        /// </summary>
        public void PlayBGM(string audioClipName, string pattern = null)
        {
            bgAudioSource.enabled = GetIsMusicOn(pattern) && GetIsCenterOn(pattern);
            LoadAudioClip(audioClipName, (audioClip) =>
            {
                UpdateMusicVolume(pattern);
                bgAudioSource.clip = audioClip;
                bgAudioSource.Play();
            });
        }
        public class AudioSourceData
        {
            public AudioSource audio;
            public string pattern = null;
            public int loopNum;
            public LuaFunction playFinish = null;//播放完成回调
            public Coroutine coroutine;
        }
        Dictionary<string, AudioSourceData> m_loopAudioDic = new Dictionary<string, AudioSourceData>();
        /// <summary>
        /// 播放一个声音
        /// </summary>
        public string PlaySound(string audioClipName, int loopNum = 1, LuaFunction call = null, string pattern = null)
        {
            string key = "";
            if (!GetIsSoundOn(pattern) || !GetIsCenterOn(pattern))
                return key;
            if (loopNum == 0)
            {
                loopNum = 1;
            }
            if (loopNum < 0)
            {
                loopNum = int.MaxValue;
            }

            AudioSource audio = gameObject.AddComponent<AudioSource>();
            key = audio.GetHashCode().ToString();

            string[] str = audioClipName.Split('/');
            if (str.Length > 1)
            {
                WWWAudioClip(audioClipName, (audioClip) =>
                {
                    audio.clip = audioClip;
                    AudioSourceData data = new AudioSourceData();
                    data.pattern = pattern;
                    data.audio = audio;
                    data.audio.volume = GetSoundVolume(pattern);
                    data.loopNum = loopNum;
                    data.playFinish = call;
                    m_loopAudioDic.Add(key, data);
                    data.coroutine = StartCoroutine(LoopPlay(data));
                });
            }
            else
            {
                LoadAudioClip(audioClipName, (audioClip) =>
                {
                    audio.clip = audioClip;
                    AudioSourceData data = new AudioSourceData();
                    data.pattern = pattern;
                    data.audio = audio;
                    data.audio.volume = GetSoundVolume(pattern);
                    data.loopNum = loopNum;
                    data.playFinish = call;
                    m_loopAudioDic.Add(key, data);
                    data.coroutine = StartCoroutine(LoopPlay(data));
                });
            }
            return key;
        }
        private IEnumerator LoopPlay(AudioSourceData data)
        {
            while (data.loopNum > 0)
            {
                data.audio.Play();
                float timeLen = data.audio.clip.length - data.audio.time;
                yield return new WaitForSeconds(timeLen);
                data.loopNum--;
            }

            if (data.playFinish != null)
            {
                data.playFinish.Call();
            }
            // 播放完释放声音
            CloseLoopSound(data.audio.GetHashCode().ToString());
        }

        /// <summary>
        /// 暂停音效
        /// </summary>
        public void Pause(string audioKey)
        {
			StopSound (audioKey, false);

            /*if (m_loopAudioDic.ContainsKey(audioKey))
            {
                StopCoroutine(m_loopAudioDic[audioKey].coroutine);
                m_loopAudioDic[audioKey].audio.Pause();
            }*/
        }

        /// <summary>
        /// 继续播放被暂停的音效
        /// </summary>
        public void ContinuePlay(string audioKey)
        {
            if (m_loopAudioDic.ContainsKey(audioKey))
            {                
                m_loopAudioDic[audioKey].coroutine = StartCoroutine(LoopPlay(m_loopAudioDic[audioKey]));
            }
        }

        /// <summary>
        /// 暂停背景音乐
        /// </summary>
        public void PauseBG()
        {
            if (bgAudioSource.clip != null)
            {
                bgAudioSource.Pause();
            }
        }
        /// <summary>
        /// 继续播放被暂停的背景音乐
        /// </summary>
        public void ContinuePlayBG()
        {
            if (bgAudioSource.clip != null)
            {
                bgAudioSource.Play();
            }
        }

        /// <summary>
        /// 清除某个音效
        /// </summary>
        public void CloseLoopSound(string audioKey)
        {
			StopSound (audioKey, true);

            /*if (m_loopAudioDic.ContainsKey(audioKey))
            {
                StopCoroutine(m_loopAudioDic[audioKey].coroutine);
                m_loopAudioDic[audioKey].audio.Stop();
                Destroy(m_loopAudioDic[audioKey].audio);
                m_loopAudioDic.Remove(audioKey);
            }*/
        }
        /// <summary>
        /// 清除所有音效
        /// </summary>
        public void CloseSound()
        {
			List<string> keys = new List<string>();
			keys.AddRange (m_loopAudioDic.Keys);
			for(int idx = 0; idx < keys.Count; ++idx)
				StopSound (keys[idx], true);

            /*foreach (var item in m_loopAudioDic)
            {
                StopCoroutine(item.Value.coroutine);
                Destroy(item.Value.audio);
            }*/

            soundsDic.Clear();
            m_loopAudioDic.Clear();

            ClearMemory();
        }

        /// <summary>
        /// 清除背景音
        /// </summary>
        public void CloseBGMSound()
        {
            bgAudioSource.clip = null;
            bgAudioSource.Stop();
        }

        /// <summary>
        /// 载入一个音频
        /// </summary>
        private void LoadAudioClip(string audioClipName, Action<AudioClip> callBack)
        {
            StartCoroutine(LoadAudioClipYid(audioClipName, callBack));
        }
        private IEnumerator LoadAudioClipYid(string audioClipName, Action<AudioClip> callBack)
        {
            AudioClip audioClip = null;

            string hashKey = audioClipName;

            if (soundsDic.ContainsKey(hashKey) && soundsDic[hashKey] != null)
                audioClip = soundsDic[hashKey] as AudioClip;
            else
            {
                audioClip = ResManager.LoadAsset<AudioClip>(audioClipName, null, null);
                if (audioClip)
                {
                    if (!soundsDic.ContainsKey(hashKey))
                        soundsDic.Add(hashKey, audioClip);
                    else
                        soundsDic[hashKey] = audioClip;
                }
            }
            yield return null;

            callBack(audioClip);
        }

        private void WWWAudioClip(string audioClipName, Action<AudioClip> callBack)
        {
            StartCoroutine(WWWAudioClipYid(audioClipName, callBack));
        }
        private IEnumerator WWWAudioClipYid(string audioClipName, Action<AudioClip> callBack)
        {
            AudioClip audioClip = null;
            Debug.Log(audioClipName);
            WWW www = new WWW("file:///" + audioClipName);

            yield return www;
            if (www.error != null)
            {
                Debug.Log(www.error);
            }
            else
            {
                if (www.isDone)
                {
                    audioClip = www.GetAudioClip(false, false, AudioType.MPEG);
                    callBack(audioClip);
                }
                else
                {
                    Debug.Log("<color=red>下载失败</color>");
                    callBack(audioClip);
                }
            }
        }

        private void ClearMemory()
        {
            //GC.Collect();
            Resources.UnloadUnusedAssets();
        }
    }
}