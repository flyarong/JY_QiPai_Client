using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;

public class GestureCircle : MonoBehaviour {
	private const int MIN_POINTS = 30;
	private const float ANGLE_THRESHOLD = 300.0f;
	private const float MAX_DELTA_ANGLE = 90.0f;
	private const float MIN_RADIUS = 9.0f;

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
		if(Input.GetMouseButtonDown(0)) {
			Reset();
			points.Add(tmp);
		}
		if(Input.GetMouseButtonUp(0)) {
			points.Add(tmp);
			ComputeStatus();
		}
		if(Input.GetMouseButton(0))
			points.Add(tmp);
		
		#else

		if(Input.touchCount > 0) {
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
			if(Input.GetTouch(0).phase == TouchPhase.Moved)
				points.Add(tmp);
		}

		#endif
	}


	private void ComputeStatus() {
		if (points.Count < MIN_POINTS) {
			Reset ();
			return;
		}

		center = Vector2.zero;
		for (int idx = 0; idx < points.Count; ++idx)
			center += points [idx];
		center /= points.Count;

		Vector2 tmp = Vector2.zero;
		for (int idx = 0; idx < points.Count; ++idx) {
			tmp = points [idx] - center;
			if (tmp.magnitude < MIN_RADIUS)
				continue;
			samples.Add (tmp);
		}

		if (samples.Count <= 0) {
			Reset ();
			return;
		}

		float angle = 0.0f;
		float delta = 0.0f;
		tmp = samples [0];
		for (int idx = 1; idx < samples.Count; ++idx) {
			delta = Vector2.Angle (tmp, samples [idx]);
			if (delta > MAX_DELTA_ANGLE) {
				Reset ();
				return;
			}
			angle += delta;
			tmp = samples [idx];
		}

		if (angle > ANGLE_THRESHOLD)
			Util.CallMethod("MainModel", "OnGestureCircle");
	}
}
