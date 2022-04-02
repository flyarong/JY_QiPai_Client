using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;

public class GestureLines : MonoBehaviour {
	private const int MIN_POINTS = 30;

	private Vector2 center = Vector2.zero;
	private List<Vector2> points = new List<Vector2>();
	private List<Vector2> samples = new List<Vector2> ();

	private void Reset() {
		center = Vector2.zero;
		points.Clear ();
		samples.Clear ();
	}

	// Use this for initialization
	void Start () {
		Reset ();
	}
	
	// Update is called once per frame
	void Update () {
		Vector2 tmp = Vector2.zero;

		#if UNITY_EDITOR || UNITY_STANDALONE_WIN

		tmp = Input.mousePosition;
		tmp.y = Screen.height - tmp.y;
		if(Input.GetKey(KeyCode.LeftControl) && Input.GetMouseButtonDown(0)) {
			Reset();
			points.Add(tmp);
		}
		if(Input.GetKey(KeyCode.LeftControl) && Input.GetMouseButtonUp(0)) {
			points.Add(tmp);
			ComputeStatus();
		}
		if(Input.GetKey(KeyCode.LeftControl) && Input.GetMouseButton(0)) {
			points.Add(tmp);
		}
		
		#else

		if(Input.touchCount >= 2) {
			tmp = Input.GetTouch(0).position;
			tmp.y = Screen.height - tmp.y;
			if(Input.GetTouch(0).phase == TouchPhase.Began) {
				Reset();
				points.Add(tmp);
			}
			if(Input.GetTouch(0).phase == TouchPhase.Ended) {
				points.Add(tmp);
				ComputeStatus();
			}
			if(Input.GetTouch(0).phase == TouchPhase.Moved) {
				points.Add(tmp);
			}
		}

		#endif
	}


	private void ComputeStatus() {
		if (points.Count < MIN_POINTS) {
			Reset ();
			return;
		}

		float start = points[0].x;
		float end = points[points.Count - 1].x;
		if(Mathf.Abs(end - start) < Screen.width * 0.75f)
        {
			Reset();
			return;
        }

		Util.CallMethod("MainModel", "OnGestureLines");
	}
}
