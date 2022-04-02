using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

namespace LuaFramework {

	public class EventManager : Manager {
		private const string SAVE_DIR_NAME = "localconfig/";
		public int Status {
			get;
			set;
		}

		void Awake() {
			Status = 0;
		}

		private void ClearLocal(string localPath) {
			string fileListFile = localPath + GameManager.FILE_LIST;
			string fileName = string.Empty;
			if (File.Exists (fileListFile)) {
				string[] lines = File.ReadAllLines (fileListFile);
				if (lines != null && lines.Length > 0) {
					string[] item = { };
					foreach(string line in lines) {
						item = line.Split ('|');
						if (item == null || item.Length != 4)
							continue;
						fileName = localPath + item [0];
						if (File.Exists (fileName))
							File.Delete (fileName);
					}

				}
				File.Delete (fileListFile);
			}
		}

		public void StartUp(string configVersion, string md5) {
			GameManager gameMgr = AppFacade.Instance.GetManager<GameManager> (ManagerName.Game);
			string localPath = gameMgr.getLocalPath (SAVE_DIR_NAME);

			if (string.IsNullOrEmpty (configVersion)) {
				Status = 1;
				ClearLocal (localPath);
				Debug.Log ("[Event] configVersion is empty.");
				return;
			}

			string remotePath = SAVE_DIR_NAME + configVersion + "/";

			Debug.Log ("[Event] check update:" + remotePath);

			StartCoroutine(gameMgr.CheckFilesUpdate (remotePath, localPath, GameManager.FILE_LIST, md5, (current, total) => {
			}, (isOK) => {
				Status = isOK ? 2: -1;
				Debug.Log(string.Format("[Event] config({0}) update {1}.", remotePath, isOK));
			}));
		}

		public bool CheckLuaExist(string fileName) {
			GameManager gameMgr = AppFacade.Instance.GetManager<GameManager> (ManagerName.Game);
			if (gameMgr == null)
				return false;

			string localFile = gameMgr.getLocalPath (SAVE_DIR_NAME) + fileName;
			return File.Exists (localFile);
		}

		public bool ReadLocal(string fileName, ref byte[] data) {
			GameManager gameMgr = AppFacade.Instance.GetManager<GameManager> (ManagerName.Game);
			if (gameMgr == null)
				return false;
			
			string localFile = gameMgr.getLocalPath (SAVE_DIR_NAME) + fileName;
			if (!File.Exists (localFile))
				return false;

			data = File.ReadAllBytes (localFile);

			return data != null && data.Length > 0;
		}
	}
}
