using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using LuaFramework;

public class HintNoticePanel : MonoBehaviour {

	private Text currentText;
	private Action callback;

	void Awake() {
		currentText = transform.Find ("ImgPopupPanel/Text").GetComponent<Text>();
	}

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	public void SetActive(bool value) {
		gameObject.SetActive (value);
	}
	public void SetText(string text) {
		if (currentText)
			currentText.text = text;
	}
	public void SetCallback(Action callback) {
		this.callback = callback;
	}

	public void OnOK() {
		if (callback != null)
			callback.Invoke ();
		
		GameManager gameMgr = AppFacade.Instance.GetManager<GameManager> (ManagerName.Game);
		if(gameMgr)
			gameMgr.HandleBtnHintNoticeDlgOK ();
	}
}
