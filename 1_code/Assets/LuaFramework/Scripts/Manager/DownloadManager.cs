using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using LuaFramework;
using System.Text;

//借用ThreadManager实现多线程下载

public class DownloadManager : Manager
{
	private const int MAX_TASK = 2;
	private const string TMP_SUFFIX = ".tmp";
	private const int MAX_TRY = 5;

	public int urlIndex = 0;
	private int[] urlRefTbl;
	private List<string> m_urlList;
	public List<string> urlList
	{
		get { return m_urlList; }
		set
		{
			m_urlList = value;
			urlIndex = 0;
			urlRefTbl = new int[value.Count];
		}
	}
	public void UpdateURLIndex(int idx)
	{
		if (++urlRefTbl[idx] > urlRefTbl[urlIndex])
			urlIndex = idx;
	}

	public int GetDownloadTimeout()
	{
		int timeOut = GameManager.DOWNLOAD_TIMEOUT;
		if (gameMgr != null)
			timeOut = gameMgr.GetDownloadTimeOut();

		Debug.Log("[Download] trace timeout:" + timeOut);

		return timeOut;
	}

	internal class Task
	{
		public string fileName;
		public Action<bool, string> callback;
		public string md5;
		public int result;

		public int currentURL;
		private List<int> urlIndices;
		private bool urlOverflow;
		private int tryCnt;
		private DownloadManager dlMgr;

		public Task(string fileName, Action<bool, string> callback, string md5, DownloadManager dlMgr)
		{
			this.fileName = fileName;
			this.callback = callback;
			this.md5 = md5;
			this.dlMgr = dlMgr;

			result = 0;
			currentURL = 0;
			urlIndices = new List<int>();
			for (int idx = 0; idx < dlMgr.urlList.Count; ++idx)
				urlIndices.Add(idx);
			urlOverflow = false;
			tryCnt = MAX_TRY;
		}

		public bool TryNext()
		{
			--tryCnt;

			if (tryCnt <= 0 || result == -2)
			{
				if (urlIndices.Count <= 0)
					return false;

				if (!urlOverflow)
				{
					if (++currentURL >= dlMgr.urlList.Count)
						urlOverflow = true;
				}
				tryCnt = 0;
			}
			result = 0;

			return true;
		}

		public string GetURL()
		{
			if (urlOverflow)
			{
				currentURL = urlIndices[0];
				urlIndices.RemoveAt(0);
			}
			else
			{
				if (currentURL < dlMgr.urlIndex)
					currentURL = dlMgr.urlIndex;
				urlIndices.Remove(currentURL);
			}

			return dlMgr.urlList[currentURL] + fileName;
		}

		public void HandleFinish(bool isOK)
		{
			if (callback == null)
				return;
			callback.Invoke(isOK, fileName);
		}

		public bool IsUrlOverflow()
		{
			return urlOverflow;
		}
	};

	private GameManager gameMgr;
	private Dictionary<string, Task> m_WaitingTask = new Dictionary<string, Task>();
	private Dictionary<string, Task> m_DownloadingTask = new Dictionary<string, Task>();

	private bool m_NetReachable = true;
	private float m_NetBreakeStamp = 0.0f;
	public bool IsNetBreakeTimeOut(float second)
	{
		if (m_NetReachable)
			return false;
		return (Time.time - m_NetBreakeStamp) > second;
	}

	private bool m_Reset = false;
	public void Reset(bool clear)
	{
		if (clear)
			m_WaitingTask.Clear();

		m_Reset = clear;
	}

	public bool IsIdle()
	{
		return m_WaitingTask.Count <= 0 && m_DownloadingTask.Count <= 0;
	}
	public int GetDownloadingCount() { return m_DownloadingTask.Count; }

	public bool CheckNetValid()
	{
		if (Application.internetReachability == NetworkReachability.NotReachable)
		{
			if (m_NetReachable)
			{
				m_NetReachable = false;
				m_NetBreakeStamp = Time.time;
				Debug.Log("[Download] Network NotReachable");
			}
			return false;
		}
		else
		{
			if (!m_NetReachable)
			{
				m_NetReachable = true;
				m_NetBreakeStamp = 0.0f;
				Debug.Log("[Download] Network Recover");
			}
			return true;
		}
	}

	bool CheckFileValid(string fileName, string md5)
	{
		if (!File.Exists(fileName))
			return false;

		FileInfo fileInfo = new FileInfo(fileName);
		if (fileInfo.Length <= 0)
			return false;

		if (string.IsNullOrEmpty(md5))
			return true;

		if (gameMgr != null && gameMgr.CheckMD5())
			return string.Compare(Util.md5file(fileName), md5, true) == 0;
		else
			return true;
	}
	bool CheckDataValid(byte[] data, string md5)
	{
		if (data == null || data.Length <= 0)
			return false;

		if (string.IsNullOrEmpty(md5))
			return true;

		if (gameMgr != null && gameMgr.CheckMD5())
			return string.Compare(Util.md5(System.Text.Encoding.Default.GetString(data)), md5, true) == 0;
		else
			return true;
	}

	// Use this for initialization
	void Start()
	{
		System.Net.ServicePointManager.Expect100Continue = false;
		System.Net.ServicePointManager.DefaultConnectionLimit = 128;
		m_NetReachable = !(Application.internetReachability == NetworkReachability.NotReachable);
		Debug.Log("[Download] Start NetState:" + m_NetReachable);

		gameMgr = AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
		if (gameMgr == null)
			Debug.LogError("[Download] Start GameManager is invalid.");
	}

	void Update()
	{
		if (gameMgr != null)
		{
			if (gameMgr.IsHangUp())
				return;
		}

		if (IsIdle())
			return;

		if (!CheckNetValid())
			return;

		Task task = null;

		List<string> removeList = new List<string>();
		List<string> tryList = new List<string>();
		string fileName = string.Empty;
		foreach (KeyValuePair<string, Task> kv in m_DownloadingTask)
		{
			task = kv.Value;
			if (task.result == 0)
				continue;

			fileName = kv.Key + TMP_SUFFIX;

			if (task.result > 0 && CheckFileValid(fileName, task.md5))
			{
				UpdateURLIndex(task.currentURL);
				File.Copy(fileName, kv.Key, true);
				task.HandleFinish(true);
			}
			else
			{

				if (task.result == 1)
				{
					string md5 = Util.md5file(fileName);
					Debug.LogError(fileName + " : " + md5 + " != " + task.md5);
				}

				if (task.TryNext())
				{
					if (!m_Reset)
						tryList.Add(kv.Key);
				}
				else
				{
					task.HandleFinish(false);
				}
			}

			File.Delete(fileName);
			removeList.Add(kv.Key);
		}

		for (int idx = 0; idx < removeList.Count; ++idx)
		{
			fileName = removeList[idx];

			if (tryList.Contains(fileName))
				CoreDownloading(m_DownloadingTask[fileName].GetURL(), fileName + TMP_SUFFIX);
			else
				m_DownloadingTask.Remove(fileName);
		}

		string dir = string.Empty;
		while (m_DownloadingTask.Count < MAX_TASK && m_WaitingTask.Count > 0)
		{
			foreach (KeyValuePair<string, Task> kv in m_WaitingTask)
			{
				dir = Path.GetDirectoryName(kv.Key);
				if (!Directory.Exists(dir))
					Directory.CreateDirectory(dir);

				m_DownloadingTask.Add(kv.Key, kv.Value);
				m_WaitingTask.Remove(kv.Key);
				CoreDownloading(kv.Value.GetURL(), kv.Key + TMP_SUFFIX);

				break;
			}
		}
	}

	private void CoreDownloading(string url, string localFile)
	{
		/*ThreadEvent threadEvent = new ThreadEvent ();
		threadEvent.Key = NotiConst.UPDATE_DOWNLOAD;
		threadEvent.evParams.AddRange (new object[2] { url, localFile });
		ThreadManager.AddEvent (threadEvent, (NotiData data) => {
			if (data.evName != NotiConst.UPDATE_DOWNLOAD)
				return;

			//xxx.tmp
			string fileName = (string)data.evParam;
			fileName = fileName.Substring(0, fileName.Length - TMP_SUFFIX.Length);

			Task task = null;
			if(!m_DownloadingTask.TryGetValue(fileName, out task))
				return;

			if(string.IsNullOrEmpty(data.evErr))
				task.result = 1;
			else {
				if(data.evErr.IndexOf("404") >= 0)
					task.result = -2;
				else
					task.result = -1;
				Debug.LogError(string.Format("[Download] download file({0}) failed:{1}", fileName, data.evErr));
			}
		});*/

		StartCoroutine(CoreDownloading(url, (isOK, data, errMsg) =>
		{
			string fileName = localFile.Substring(0, localFile.Length - TMP_SUFFIX.Length);
			Task task = null;
			if (!m_DownloadingTask.TryGetValue(fileName, out task))
			{
				Debug.LogError(string.Format("[Download] download file({0}) failed, but can't find download list", fileName));
				return;
			}

			if (isOK)
			{
				File.WriteAllBytes(localFile, data);
				task.result = 1;
			}
			else
			{
				if (errMsg.IndexOf("404") >= 0)
					task.result = -2;
				else
					task.result = -1;
				Debug.LogError(string.Format("[Download] download file({0}) failed:{1}", localFile, errMsg));
			}
		}));
	}

	public void Push(string remoteFile, string localFile, string md5, Action<bool, string> callback)
	{
		if (!string.IsNullOrEmpty(md5))
		{
			if (CheckFileValid(localFile, md5))
			{
				callback.Invoke(true, remoteFile);
				return;
			}
			string tcFile = localFile + TMP_SUFFIX;
			if (CheckFileValid(tcFile, md5))
			{
				File.Copy(tcFile, localFile, true);
				File.Delete(tcFile);
				callback.Invoke(true, remoteFile);
				return;
			}
		}

		Task task;
		if (m_WaitingTask.TryGetValue(localFile, out task))
		{
			task.callback += callback;
			return;
		}
		if (m_DownloadingTask.TryGetValue(localFile, out task))
		{
			task.callback += callback;
			return;
		}
		m_WaitingTask.Add(localFile, new Task(remoteFile, callback, md5, this));

		//Debug.Log ("Push download:" + remoteFile);
	}

	public IEnumerator DownloadingURL(string url, Action<bool, byte[]> callback)
	{
		bool result = false;

		int tryCnt = MAX_TRY;
		do
		{
			if (gameMgr != null && gameMgr.IsHangUp())
			{
				Debug.Log("[Download] download url Application is HangUp");
				yield return new WaitForSeconds(0.1f);
			}

			while (!CheckNetValid())
			{
				yield return new WaitForSeconds(0.1f);
			}

			yield return CoreDownloading(url, (isOK, datas, error) =>
			{
				if (isOK)
				{
					result = true;
					callback.Invoke(true, datas);
				}
				else
				{
					if (error.IndexOf("404") >= 0)
						tryCnt = 0;
					else
						--tryCnt;
				}
			});
		} while (!result && tryCnt > 0);

		if (!result)
			callback.Invoke(false, null);
	}

	public IEnumerator Downloading(string remoteFile, string md5, Action<bool, byte[]> callback)
	{
		Task task = new Task(remoteFile, null, md5, this);

		do
		{
			if (gameMgr != null && gameMgr.IsHangUp())
			{
				Debug.Log("[Download] downloading Application is HangUp");
				yield return new WaitForSeconds(0.1f);
			}

			while (!CheckNetValid())
			{
				yield return new WaitForSeconds(0.1f);
			}

			yield return CoreDownloading(task.GetURL(), (isOK, datas, error) =>
			{
				if (isOK && CheckDataValid(datas, task.md5))
				{
					task.result = 1;
					callback.Invoke(true, datas);
				}
				else
				{
					if (error.IndexOf("404") >= 0)
						task.result = -2;
					else
						task.result = -1;
				}
			});

		} while (task.result < 0 && task.TryNext());

		if (task.result <= 0)
			callback.Invoke(false, null);
	}

	/*private IEnumerator CoreDownloading(string url, Action<bool, byte[], string> callback) {
		string newUrl = url + "?r=" + UnityEngine.Time.time;
		Debug.Log ("[Download] CoreDownloading url: " + newUrl);

		WWW www = new WWW(newUrl);
		yield return www;

		if (!string.IsNullOrEmpty (www.error)) {
			Debug.LogError (string.Format ("[Download] CoreDownloading {0} failed: {1}", newUrl, www.error));

			callback.Invoke (false, null, www.error);
			yield break;
		}

		while (!www.isDone)
			yield return null;

		callback.Invoke (true, www.bytes, string.Empty);
		www.Dispose ();

		Debug.Log("[Download] CoreDownloading finish url: " + newUrl);
	}*/

	private IEnumerator CoreDownloading(string url, Action<bool, byte[], string> callback)
	{
		string newUrl = url + "?r=" + UnityEngine.Time.time;
		Debug.Log("[Download] CoreDownloading url: " + newUrl);
		UnityWebRequest wr = UnityWebRequest.Get(newUrl);
		int timeout = GetDownloadTimeout();
		if(timeout > 0)
			wr.timeout = timeout;
		yield return wr.SendWebRequest();

		if(wr.isHttpError || wr.isNetworkError)
        {
			callback.Invoke(false, null, wr.error);
			Debug.LogError(string.Format("[Download] CoreDownloading {0} failed: {1}", newUrl, wr.error));
		}
		else
        {
			while (!wr.isDone)
				yield return null;

			byte[] datas = wr.downloadHandler.data;
			callback.Invoke(true, datas, string.Empty);
			Debug.Log("[Download] CoreDownloading finish url: " + newUrl);
		}

	}
}
