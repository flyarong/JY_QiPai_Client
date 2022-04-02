using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace LuaFramework {

	public class GestureManager : Manager {

		// Use this for initialization
		void Start() {
		}

		public void TryAddGesture(string ident) {
			if (ident == "GestureCircle") {
				GestureCircle component = gameObject.GetComponent<GestureCircle> ();
				if (component == null)
					gameObject.AddComponent<GestureCircle> ();
			}
			else if(ident == "GestureLines")
            {
				GestureLines component = gameObject.GetComponent<GestureLines>();
				if (component == null)
					gameObject.AddComponent<GestureLines>();
			}
		}
	}
}