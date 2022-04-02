using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PosConversion : MonoBehaviour {
	public Vector2 pos;

	void Award () {
		ConversionPos ();
	}


	// Use this for initialization
	void Start () {
		ConversionPos ();
	}
	
	// Update is called once per frame
	void Update () {
		ConversionPos ();
	}

	public void ConversionPos (){
		pos = this.transform.position;
	}
}
