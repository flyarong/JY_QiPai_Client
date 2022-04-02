using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyRayCast : MonoBehaviour
{
    public Camera cam;
    void Update()
    {
        Vector3 ve = Input.mousePosition;
        //射线检测
        RaycastHit2D hit = UnityEngine.Physics2D.Raycast(new Vector2(ve.x, ve.y), Vector2.zero, 1000);

        if(hit.transform != null)
        {
            Debug.Log("name = " + hit.transform.gameObject.name);
        }
    }
}
