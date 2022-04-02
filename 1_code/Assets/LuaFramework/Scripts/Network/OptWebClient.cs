using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Runtime.CompilerServices;
using UnityEngine;

public class OptWebClient : WebClient {
	public int Timeout { get; set; }

	protected override WebRequest GetWebRequest(Uri uri) {
		GC.Collect ();

		WebRequest req = base.GetWebRequest (uri);
		req.Timeout = Timeout * 1000;
		((HttpWebRequest)req).ReadWriteTimeout = Timeout * 1000;
		return req;
	}
}
