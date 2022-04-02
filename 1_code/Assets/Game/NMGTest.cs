using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;
using UnityEngine.UI;
using DG.Tweening;
using System.IO;

public class NMGTest : Manager
{
    private GameObject tt;
    private void Awake()
    {
        tt = GameObject.Find("Canvas/GUIRoot");
    }
    public string audioName;
    public int count = 0;
    public bool isPlay = false;
    void Update ()
    {
        if (isPlay)
        {
            Sequence s11 = DOTween.Sequence();
            s11.Append(transform.GetComponent<Image>().DOFade(0.5f, 1f).SetLoops(-1, LoopType.Yoyo));
            isPlay = false;
            for (int j = 0; j < count; ++j)
            {
                FileStream fs = File.Create("");
                StreamReader sr = new StreamReader(fs);
                string a = sr.ReadLine();
                Button d = transform.GetComponent<Button>();
                d.onClick = null;
                d.onClick.AddListener(null);
                Text tt = transform.GetComponent<Text>();
                RectTransform dt = transform.GetComponent<RectTransform>();
                int d2 = dt.GetSiblingIndex();
                dt.sizeDelta = Vector2.one;
                //Vector3.zero;
                GameObject obj1 = GameObject.Find("");
                Scrollbar sbb = transform.GetComponent<Scrollbar>();
                GameObject.Destroy(null);
                sbb.onValueChanged = null;
                transform.SetParent(null);
                CanvasScaler cs1 = GameObject.Find("Canvas").transform.GetComponent<CanvasScaler>();
                cs1.matchWidthOrHeight = 1f;

                ResManager.LoadPrefab(audioName, (objs) =>
                {
                    for (int i = 0; i < objs.Length; ++i)
                    {//transform.parent
                        GameObject oo = GameObject.Instantiate(objs[i]) as GameObject;
                        oo.transform.SetParent(tt.transform);
                        oo.transform.localScale = Vector3.one;
                        oo.transform.localRotation = Quaternion.Euler(90, 0, 0);
                        oo.transform.localPosition = Vector3.zero;
                        Debug.Log("obj = " + oo.name);
                    }
                });
            }
        }
	}
    private void OnDestroy()
    {
        
    }
}
