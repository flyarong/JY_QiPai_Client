using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class glittering : MonoBehaviour {
	private SpriteRenderer spriteRenderer;
	private Sprite sprite;
	private Vector4 _Rect;
	// Use this for initialization
	void Start () {
		spriteRenderer = GetComponent<SpriteRenderer> ();
	}
	
	// Update is called once per frame
	void Update () {
		sprite = spriteRenderer.sprite;
		_Rect.x = sprite.rect.min.x / sprite.texture.width;
		_Rect.y = sprite.rect.min.y / sprite.texture.height;
		_Rect.z = sprite.rect.max.x / sprite.texture.width;
		_Rect.w = sprite.rect.max.y / sprite.texture.width;
		spriteRenderer.sharedMaterial.SetVector ("_Rect", _Rect);
	}
}
