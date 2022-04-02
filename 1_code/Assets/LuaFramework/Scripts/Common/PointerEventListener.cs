using UnityEngine;  
using System.Collections;  
using UnityEngine.EventSystems;  
public class PointerEventListener : MonoBehaviour, IPointerClickHandler, IPointerDownHandler, IPointerEnterHandler, IPointerExitHandler, IPointerUpHandler
{  
    public delegate void VoidDelegate (GameObject go);  
    public VoidDelegate onClick;  
    public VoidDelegate onDown;  
    public VoidDelegate onEnter;  
    public VoidDelegate onExit;  
    public VoidDelegate onUp;  
  
    static public PointerEventListener Get (GameObject go)  
    {  
        PointerEventListener listener = go.GetComponent<PointerEventListener>();  
        if (listener == null) listener = go.AddComponent<PointerEventListener>();  
        return listener;  
    }

        //监听按下
    public void OnPointerDown(PointerEventData eventData)
    {
        if(onDown != null) onDown(gameObject);  
    }

    //监听抬起
    public void OnPointerUp(PointerEventData eventData)
    {
        if(onUp != null) onUp(gameObject);
    }

    //监听点击
    public void OnPointerClick(PointerEventData eventData)
    {
        if(onClick != null) onClick(gameObject); 
    }
    public void OnPointerEnter (PointerEventData eventData){  
        if(onEnter != null) onEnter(gameObject);  
    }  
    public void OnPointerExit (PointerEventData eventData){  
        if(onExit != null) onExit(gameObject);  
    }  
}