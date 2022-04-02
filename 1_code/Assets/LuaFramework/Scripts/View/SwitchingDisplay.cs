using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using DG.Tweening;

public class SwitchingDisplay : MonoBehaviour {
	public Sprite[] sprites;
	public string[] tips;

	[SerializeField]
	public Transform m_pageRoot;
	[SerializeField]
	public Transform m_pageParent;
	[SerializeField]
	public GameObject m_pageTmpl;
	[SerializeField]
	public ScrollRect m_pageScrollRect;
	[SerializeField]
	public float m_switchPageTime = 0.2f;

	[SerializeField]
	public Transform m_tipRoot;
	[SerializeField]
	public Transform m_tipParent;
	[SerializeField]
	public GameObject m_tipTmpl;
	[SerializeField]
	public ScrollRect m_tipScrollRect;
	[SerializeField]
	public float m_switchTipTime = 0.25f;

	private List<GameObject> m_pages = new List<GameObject>();
	private List<GameObject> m_tips = new List<GameObject>();

	private List<float> m_pageWeights = new List<float> ();
	private int m_pageIdx = 0;

	private List<float> m_tipWeights = new List<float> ();
	private int m_tipIdx = 0;

	void Awake() {
		m_pageRoot.gameObject.SetActive (false);
		m_tipRoot.gameObject.SetActive (false);
	}

	// Use this for initialization
	void Start () {
		//Image image = transform.Find ("bg").GetComponent<Image>();
		//image.material.shader = Shader.Find ("Unlit/loading_blur");

		//test
		if (sprites.Length > 0) {
			List<Sprite> s = new List<Sprite> ();
			for (int idx = 0; idx < sprites.Length; ++idx)
				s.Add (sprites [idx]);
			BuildPageScroll (s, 3.0f);
		}

		if (tips.Length > 0) {
			List<string> t = new List<string> ();
			for (int idx = 0; idx < tips.Length; ++idx)
				t.Add (tips [idx]);
			BuildTipScroll (t, 1.0f);
		}
	}
	
	// Update is called once per frame
	void Update () {
	}

	public void BuildPageScroll(List<Sprite> sprites, float interval) {
		ClearPages ();

		int count = sprites.Count;
		if (count <= 0)
			return;

		BuildWeights (count, ref m_pageWeights, false);

		GameObject go = null;
		Image img = null;
		for (int idx = 0; idx < count; ++idx) {
			go = GameObject.Instantiate (m_pageTmpl, m_pageParent);
			go.transform.localPosition = Vector3.zero;
			go.transform.localRotation = Quaternion.identity;
			go.gameObject.SetActive (true);
			m_pages.Add (go);

			img = go.transform.Find("Image").GetComponent<Image>();
			img.sprite = sprites[idx];
		}

		m_pageRoot.gameObject.SetActive (true);
		StartCoroutine (LoopPages (count, interval));
	}

	IEnumerator LoopPages(int count, float interval)
	{
		while (m_pageIdx >= 0) {
			m_pageScrollRect.DOHorizontalNormalizedPos (m_pageWeights [m_pageIdx], m_switchPageTime);
			m_pageIdx = (m_pageIdx + 1) % count;
			yield return new WaitForSeconds(interval);

			if(m_pageIdx == 0)
			{
				m_pageScrollRect.horizontalNormalizedPosition = m_pageWeights [0];
				m_pageIdx = 1;
			}
		}
	}

	public void BuildTipScroll(List<string> tips, float interval) {
		ClearTips ();

		int count = tips.Count;
		if (count <= 0)
			return;

		BuildWeights (count, ref m_tipWeights, true);

		GameObject go = null;
		Text txt = null;
		for (int idx = 0; idx < count; ++idx) {
			go = GameObject.Instantiate (m_tipTmpl, m_tipParent);
			go.transform.localPosition = Vector3.zero;
			go.transform.localRotation = Quaternion.identity;
			go.gameObject.SetActive (true);
			m_tips.Add (go);

			txt = go.transform.Find("Text").GetComponent<Text>();
			txt.text = tips [idx];
		}

		m_tipRoot.gameObject.SetActive (true);
		StartCoroutine (LoopTips (count, interval));
	}

	IEnumerator LoopTips(int count, float interval)
	{
		while (m_tipIdx >= 0) {
			m_tipScrollRect.DOVerticalNormalizedPos (m_tipWeights [m_tipIdx], m_switchTipTime);
			m_tipIdx = (m_tipIdx + 1) % count;
			yield return new WaitForSeconds(interval);

			if(m_tipIdx == 0)
			{
				m_tipScrollRect.verticalNormalizedPosition = m_tipWeights [0];
				m_tipIdx = 1;
			}
		}
	}

	void BuildWeights(int count, ref List<float> weights, bool revert) {
		float weight = 0.0f;
		if (count > 1)
			weight = 1.0f / (count - 1);
		
		if (revert) {
			for (int idx = 0; idx < count; ++idx)
				weights.Add (1.0f - idx * weight);
		} else {
			for (int idx = 0; idx < count; ++idx)
				weights.Add (idx * weight);
		}
	}

	void ClearPages() {
		ClearList (ref m_pages);
		m_pageWeights.Clear ();
		m_pageIdx = 0;
	}

	void ClearTips() {
		ClearList (ref m_tips);
		m_tipWeights.Clear ();
		m_tipIdx = 0;
	}

	void ClearList(ref List<GameObject> list) {
		for (int idx = 0; idx < list.Count; ++idx)
			GameObject.Destroy (list [idx].gameObject);
		list.Clear ();
	}
}
