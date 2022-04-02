using System.Collections;
using System.Threading;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;
using System.Net;
using System.ComponentModel;
using System;
using UnityEngine;
using System.Runtime.CompilerServices;

public class ThreadEvent {
    public string Key;
    public List<object> evParams = new List<object>();
}

public class NotiData {
    public string evName;
    public object evParam;
	public string evErr;
    public NotiData(string name, object param) {
        this.evName = name;
        this.evParam = param;
    }
}

namespace LuaFramework {
    /// <summary>
    /// 当前线程管理器，同时只能做一个任务
    /// </summary>
    public class ThreadManager : Manager {
        private Thread thread;
        private Action<NotiData> func;
        //private Stopwatch sw = new Stopwatch();
        private string currDownFile = string.Empty;

		static readonly object m_lockEvent = new object();
        static Queue<ThreadEvent> events = new Queue<ThreadEvent>();

        delegate void ThreadSyncEvent(NotiData data);
        private ThreadSyncEvent m_SyncEvent;

		//private int rndCnt = 0;
		//private int MAX_RND_CNT = 65535;
		private float rndSeed = 0.0f;

		static readonly object m_lockWebClient = new object ();
		private List<OptWebClient> webClients = new List<OptWebClient>();

        private GameManager gameMgr;

        void Awake() {
            m_SyncEvent = OnSyncEvent;
            thread = new Thread(OnUpdate);
            thread.IsBackground = true;
        }

        // Use this for initialization
        void Start() {
            gameMgr = AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);

            thread.Start();
        }

		void Update() {
			rndSeed = Time.time;
		}

        /// <summary>
        /// 添加到事件队列
        /// </summary>
        public void AddEvent(ThreadEvent ev, Action<NotiData> func) {
            lock (m_lockEvent) {
                this.func = func;
                events.Enqueue(ev);
            }
        }

        /// <summary>
        /// 通知事件
        /// </summary>
        /// <param name="state"></param>
        private void OnSyncEvent(NotiData data) {
            if (this.func != null) func(data);  //回调逻辑层
            facade.SendMessageCommand(data.evName, data.evParam); //通知View层
        }

        // Update is called once per frame
        void OnUpdate() {
            while (true) {
				lock (m_lockEvent) {
                    if (events.Count > 0) {
                        ThreadEvent e = events.Dequeue();
                        try {
                            switch (e.Key) {
                                case NotiConst.UPDATE_EXTRACT: {     //解压文件
                                    OnExtractFile(e.evParams);
                                }
                                break;
                                case NotiConst.UPDATE_DOWNLOAD: {    //下载文件
                                    OnDownloadFile(e.evParams);
                                }
                                break;
                            }
                        } catch (System.Exception ex) {
                            UnityEngine.Debug.LogError(ex.Message);
                        }
                    }
                }

                Thread.Sleep(1);
            }
        }

		bool Alloc(ref OptWebClient client) {
			client = null;
			lock (m_lockWebClient) {
				if (webClients.Count > 0) {
					client = webClients [0];
					webClients.RemoveAt (0);

					UnityEngine.Debug.Log ("[Download] Alloc from catch");
				} else {
					client = new OptWebClient ();
                    client.Timeout = 8;

					UnityEngine.Debug.Log ("[Download] Alloc from new");
				}
                client.DownloadFileCompleted += ProgressCompleted;
            }

			return true;
		}
		void Free(ref OptWebClient client) {
			lock (m_lockWebClient) {
                client.DownloadFileCompleted -= ProgressCompleted;
                client.CancelAsync ();
				client.Dispose ();
				client.QueryString.Clear ();
				webClients.Add (client);

				if (webClients.Count >= 4)
					UnityEngine.Debug.LogError ("[Download] webclient num is overflow:" + webClients.Count);
			}
		}

        /// <summary>
        /// 下载文件
        /// </summary>
        void OnDownloadFile(List<object> evParams) {
			//rndCnt = ++rndCnt % MAX_RND_CNT;
			string url = evParams [0].ToString () + "?r=" + rndSeed;
            currDownFile = evParams[1].ToString();

			UnityEngine.Debug.Log ("[Download] download file:" + currDownFile);

            OptWebClient client = null;
            /*if(Alloc(ref client))
            {
                try
                {
                    client.QueryString.Add("fileName", currDownFile);
                    client.DownloadFile(new System.Uri(url), currDownFile);
                    ProgressCompleted(client, null);
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogError(string.Format("[Download] {0} exception:{1}", url, e.Message));
                    ProgressCompleted(client, new AsyncCompletedEventArgs(e, true, null));
                }
            }*/
            
            if (Alloc (ref client)) {
				client.QueryString.Add ("fileName", evParams [1].ToString ());
				client.DownloadFileAsync (new System.Uri (url), evParams [1].ToString ());
            }
        }

		private void ProgressCompleted(object sender, AsyncCompletedEventArgs e) {
            OptWebClient webClient = (OptWebClient)sender;
			string fileName = webClient.QueryString ["fileName"];
			NotiData data = new NotiData (NotiConst.UPDATE_DOWNLOAD, fileName);

			if (e != null && e.Error != null) {
				data.evErr = e.Error.ToString ();

				UnityEngine.Debug.LogError ("[Download] ProgressCompleted Exception: Begin " + fileName + ", " + data.evErr);

				while (webClient.IsBusy)
					Thread.Sleep (100);

				UnityEngine.Debug.LogError ("[Download] ProgressCompleted Exception: End " + fileName + ", " + data.evErr);
			}

			lock (m_lockEvent) {
				if (m_SyncEvent != null)
					m_SyncEvent (data);
			}

			Free (ref webClient);
		}

        /// <summary>
        /// 调用方法
        /// </summary>
        void OnExtractFile(List<object> evParams) {
            UnityEngine.Debug.LogWarning("Thread evParams: >>" + evParams.Count);

            ///------------------通知更新面板解压完成--------------------
            NotiData data = new NotiData(NotiConst.UPDATE_DOWNLOAD, null);
			lock (m_lockEvent) {
				if (m_SyncEvent != null)
					m_SyncEvent (data);
			}
        }

        /// <summary>
        /// 应用程序退出
        /// </summary>
        void OnDestroy() {
            thread.Abort();
        }
    }
}