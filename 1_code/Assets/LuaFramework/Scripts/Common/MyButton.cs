using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.Events;

public class MyButton : MonoBehaviour, IPointerClickHandler, IPointerDownHandler, IPointerUpHandler
{
    MyButtonClickedEvent _onClick = new MyButtonClickedEvent();
    MyButtonClickedEvent _onDown = new MyButtonClickedEvent();
    MyButtonClickedEvent _onUp = new MyButtonClickedEvent();
    public MyButtonClickedEvent onClick
    {
        get
        {
            return _onClick;
        }
        set
        {
            _onClick = value;
        }
    }
    public MyButtonClickedEvent onDown
    {
        get
        {
            return _onDown;
        }
        set
        {
            _onDown = value;
        }
    }
    public MyButtonClickedEvent onUp
    {
        get
        {
            return _onUp;
        }
        set
        {
            _onUp = value;
        }
    }

    //监听按下
    public void OnPointerDown(PointerEventData eventData)
    {
        if (this.onDown != null)
        {
            this.onDown.Invoke();
        }
        PassEvent(eventData, ExecuteEvents.pointerDownHandler);
    }

    //监听抬起
    public void OnPointerUp(PointerEventData eventData)
    {
        if (this.onUp != null)
        {
            this.onUp.Invoke();
        }
        PassEvent(eventData, ExecuteEvents.pointerUpHandler);
    }

    //监听点击
    public void OnPointerClick(PointerEventData eventData)
    {
        if (this.onClick != null)
        {
            this.onClick.Invoke();
        }
        //PassEvent(eventData, ExecuteEvents.submitHandler);
        PassEvent(eventData, ExecuteEvents.pointerClickHandler);
    }

    //把事件透下去
    public void PassEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(data, results);
        GameObject current = data.pointerCurrentRaycast.gameObject;
        for (int i = 0; i < results.Count; i++)
        {
            MyButton myBtn = results[i].gameObject.GetComponent<MyButton>();
            if (myBtn == null && current != results[i].gameObject)
            {
                ExecuteEvents.Execute(results[i].gameObject, data, function);
                break;
                //RaycastAll后ugui会自己排序，如果你只想响应透下去的最近的一个响应，这里ExecuteEvents.Execute后直接break就行。
            }
        }
    }
    public class MyButtonClickedEvent : UnityEvent
    {
        public MyButtonClickedEvent() : base()
        {

        }
    }

}
