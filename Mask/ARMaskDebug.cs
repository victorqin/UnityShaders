using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ARMaskDebug: MonoBehaviour {
	public Texture texture;

	// Use this for initialization
	void Start () {
		Shader.SetGlobalTexture("_VideoTexture", texture);
	}
}
