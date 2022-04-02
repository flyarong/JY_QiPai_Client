using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shadow : MonoBehaviour
{

    // Use this for initialization
    SpriteRenderer parentSprite;
    SpriteRenderer selfSprite;
    Vector3 positive = new Vector3(0.3f, -0.3f);
    Vector3 negative = new Vector3(-0.3f, 0.3f);

    void Start()
    {
        parentSprite = transform.parent.GetComponent<SpriteRenderer>();
        selfSprite = transform.GetComponent<SpriteRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        selfSprite.sprite = parentSprite.sprite;
        selfSprite.flipX = parentSprite.flipX;
        selfSprite.flipY = parentSprite.flipY;
        //判断是否做了旋转
        if (Camera.main.transform.eulerAngles.z != 0)
        {
            this.transform.position = parentSprite.transform.position + negative;
        }
        else
        {
            this.transform.position = parentSprite.transform.position + positive;
        }
    }
}
