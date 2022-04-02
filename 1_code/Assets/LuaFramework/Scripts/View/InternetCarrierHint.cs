using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

using LuaFramework;
public class InternetCarrierHint : MonoBehaviour {
	const int MEGABYTE = 1024 * 1024;

	[SerializeField]
	public long ThresholdValue = 10;

	private GameManager gameMgr;

	private Text currentText;
	private Text nextText;
	private Text detailText;

	void Awake() {
		gameMgr = AppFacade.Instance.GetManager<GameManager> (ManagerName.Game);

		currentText = transform.Find ("ImgPopupPanel/CurrentVersionInfoTxt").GetComponent<Text>();
		nextText = transform.Find ("ImgPopupPanel/NextVersionInfoTxt").GetComponent<Text>();
		detailText = transform.Find ("ImgPopupPanel/DetailTxt").GetComponent<Text>();
	}

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	public bool IsOverLimit(long value) {
		return value >= (ThresholdValue * MEGABYTE);
	}

	public void SetActive(bool value) {
		gameObject.SetActive (value);
	}
	public void SetVersion(string current, string next) {
		if (currentText)
			currentText.text = current;
		if (nextText)
			nextText.text = next;
	}
	public void SetDetail(long value) {
		if (detailText == null)
			return;
		
		detailText.text = string.Format ("{0:F1}", 1.0f * value / MEGABYTE);
	}

	public void OnOK() {
		gameMgr.HandleBtnInternetCarrierDlgOK ();
	}
	public void OnCancel() {
		gameMgr.HandleBtnInternetCarrierDlgCancel ();
	}
}
