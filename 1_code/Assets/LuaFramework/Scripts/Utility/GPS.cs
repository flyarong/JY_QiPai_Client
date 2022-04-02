using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

using LuaFramework;

public class GPS : MonoBehaviour {
	private int m_errorCode = 0;
	private string m_cityName = string.Empty;
	private Action<int> m_initCallback;
	// Use this for initialization
	void Start () {
		//StartCoroutine (StartGPS ());
	}
	
	// Update is called once per frame
	void Update () {
		// Debug.Log ("curCity:" + getCity());
	}

	public void StartGPS(Action<int> callback) {
		m_initCallback = callback;
		StartCoroutine (StartGPS ());
	}

	IEnumerator StartGPS() {
		if (!Input.location.isEnabledByUser) {
			m_errorCode = -1;
			m_initCallback.Invoke (m_errorCode);
			Debug.LogError ("[GPS] It's turn off");
			yield break;
		}

		Input.location.Start ();

		int maxWait = 20;
		while (Input.location.status == LocationServiceStatus.Initializing && maxWait > 0) {
			yield return new WaitForSeconds (1);
			--maxWait;

			Debug.LogError ("[GPS] Init GPS service Initializing:" + maxWait);
		}

		if (maxWait <= 0) {
			m_errorCode = -2;
			m_initCallback.Invoke (m_errorCode);
			Debug.LogError ("[GPS] Init GPS service timeout");
			yield break;
		}

		if (Input.location.status == LocationServiceStatus.Failed) {
			m_errorCode = -3;
			m_initCallback.Invoke (m_errorCode);
			Debug.LogError ("[GPS] Unable to determine device location");
			yield break;
		}

		m_errorCode = 1;

		m_initCallback.Invoke (m_errorCode);

		float latitude, longitude;
		if (GetLocation (out latitude, out longitude)) {
			Debug.Log (string.Format ("[GPS] QueryCity({0}, {1})", latitude, longitude));
			QueryCityName (latitude, longitude);
		}
	}

	public void QueryCityName(float latitude, float longitude) {
		SDKManager mgr = AppFacade.Instance.GetManager<SDKManager> (ManagerName.SDK);
		if (mgr)
			mgr.QueryCityName (latitude, longitude);
		else
			Debug.LogError ("[GPS] QueryCityName failed: SDKManager invalid.");
	}

	public void SetCityName(string cityName) {
		m_cityName = cityName;

		m_initCallback.Invoke (2);

		Debug.Log ("[GPS] SetCityName: " + cityName);
	}
	public string GetCityName() {
		return m_cityName;
	}

	public bool GetLocation(out float latitude, out float longitude) {
		latitude = 0.0f;
		longitude = 0.0f;
		if (m_errorCode <= 0)
			return false;

		latitude = Input.location.lastData.latitude;
		longitude = Input.location.lastData.longitude;

		return true;
	}

	public float GetLatitude() {
		if (m_errorCode <= 0)
			return 0.0f;
		return Input.location.lastData.latitude;
	}

	public float GetLongitude() {
		if (m_errorCode <= 0)
			return 0.0f;
		return Input.location.lastData.longitude;
	}

	public float getDistance(float lat1,float lng1,float lat2,float lng2)

	{
		float a, b, R;
		R = 6378137; //地球半径

		lat1 = lat1 * Mathf.PI / 180.0f;
		lat2 = lat2 * Mathf.PI / 180.0f;

		a = (lat1 - lat2);
		b = (lng1 - lng2) * Mathf.PI / 180.0f;

		float d;
		float sa2, sb2;
		sa2 = Mathf.Sin(a / 2.0f);
		sb2 = Mathf.Sin(b / 2.0f);

		d = 2 * R * Mathf.Asin(Mathf.Sqrt(sa2 * sa2 + Mathf.Cos(lat1) * Mathf.Cos(lat2) * sb2 * sb2));

		return d;
	}

	private static float rad(float d)
	{
		return d * Mathf.PI / 180.0f;
	}
}
