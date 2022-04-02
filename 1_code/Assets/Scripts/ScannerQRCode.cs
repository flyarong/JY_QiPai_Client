using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using LuaInterface;

using BarcodeScanner;
using BarcodeScanner.Scanner;

namespace LuaFramework {
	public class ScannerQRCode : MonoBehaviour {
		public Transform rootNode;
		public RawImage rawImage;
		private IScanner m_Scanner;
		private bool m_Ready;

		bool[] m_rawAutoRotateSetting = new bool[2] { false, false };

		// Use this for initialization
		void Awake () {
			rootNode.gameObject.SetActive (false);
			m_Ready = false;

			m_rawAutoRotateSetting [0] = Screen.autorotateToPortrait;
			m_rawAutoRotateSetting [1] = Screen.autorotateToPortraitUpsideDown;

			//Screen.autorotateToPortrait = false;
			//Screen.autorotateToPortraitUpsideDown = false;
		}

		IEnumerator Start() {
			yield return Application.RequestUserAuthorization(UserAuthorization.WebCam);
			if (!Application.HasUserAuthorization(UserAuthorization.WebCam))
			{
				throw new Exception("[SCANNER QR CODE] Webcam library can't work without the webcam authorization");
				yield break;
			}

			m_Scanner = new Scanner ();
			m_Scanner.Camera.Play ();

			m_Scanner.OnReady += (sender, e) => {
				rawImage.transform.localEulerAngles = m_Scanner.Camera.GetEulerAngles();
				rawImage.transform.localScale = m_Scanner.Camera.GetScale();
				rawImage.texture = m_Scanner.Camera.Texture;

				RectTransform rt = rawImage.GetComponent<RectTransform>();
				float height = rt.sizeDelta.x * m_Scanner.Camera.Height / m_Scanner.Camera.Width;
				rt.sizeDelta = new Vector2(rt.sizeDelta.x, height);

				rootNode.gameObject.SetActive (true);
				m_Ready = true;
			};
			m_Scanner.StatusChanged += (sender, e) => {
			};
		}
		
		// Update is called once per frame
		void Update () {
			if (m_Scanner == null)
				return;
			m_Scanner.Update ();
		}

		void OnDestroy() {
			Screen.autorotateToPortrait = m_rawAutoRotateSetting [0];
			Screen.autorotateToPortraitUpsideDown = m_rawAutoRotateSetting [1];
			m_Ready = false;
		}

		private IEnumerator StartScan(Action<bool, string, string> callback) {
			int count = 0;
			while(count++ < 30 && !m_Ready)
				yield return new WaitForSeconds (0.25f);
			
			if (!m_Ready) {
				Debug.LogError ("[SCANNER QR CODE] StartScan failed: It's not ready");

				if (callback != null)
					callback.Invoke (false, string.Empty, string.Empty);
				
				yield break;
			}

			m_Scanner.Scan ((codeType, codeValue) => {
				m_Scanner.Stop ();

				#if UNITY_ANDROID || UNITY_IOS
				Handheld.Vibrate();
				#endif

				if(callback != null)
					callback.Invoke(true, codeType, codeValue);
			});
		}

		public bool StartScan(LuaFunction callback) {
			StartCoroutine (StartScan ((isOK, codeType, codeValue) => {
				if(callback != null)
					callback.Call(isOK, codeType, codeValue);
			}));
			return true;
		}

		public void StopScan(LuaFunction callback) {
			StartCoroutine (Stoping (callback));
		}

		private IEnumerator Stoping(LuaFunction callback) {
			rawImage = null;
			if (m_Scanner != null) {
				if (m_Scanner.Status == ScannerStatus.Running)
					m_Scanner.Stop ();
				m_Scanner.Destroy ();
				m_Scanner = null;
			}

			yield return new WaitForSeconds (0.1f);

			if(callback != null)
				callback.Call ();
		}
	}
}
