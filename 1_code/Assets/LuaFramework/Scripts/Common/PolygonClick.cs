//————————————————————————————————————————————
//  PolygonClick.cs
//
//  Created by Chiyu Ren on ‏‎2016-08-16 11:21
//————————————————————————————————————————————

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using LuaInterface;

/// <summary>
/// 支持设置多边形区域作为点击判断的组件
/// 多边形区域编辑由PolygonCollider2D组件提供
/// </summary>
[RequireComponent(typeof(PolygonCollider2D))]
public class PolygonClick : Image, IPointerUpHandler, IPointerClickHandler, IPointerDownHandler
{
    private PolygonClickedEvent m_OnPointerClick = new PolygonClickedEvent();
    private PolygonClickedEvent m_OnPointerDown = new PolygonClickedEvent();
    private PolygonClickedEvent m_OnPointerUp = new PolygonClickedEvent();

    private RectTransform m_RectTransform = null;
    private Vector2[] m_Vertexs = null;


    private Camera m_camera;
    protected override void Start()
    {
        m_camera = GameObject.Find("Camera").GetComponent<Camera>();
        base.Start();
        // 收集变量
        this.m_RectTransform = base.GetComponent<RectTransform>();
        var c = base.GetComponent<PolygonCollider2D>();
        if (c != null)
        {
            this.m_Vertexs = c.points;
            c.enabled = false;
        }
    }


    protected override void OnDestroy()
    {
        base.OnDestroy();

        this.m_RectTransform = null;
        this.m_Vertexs = null;
        this.m_OnPointerUp.RemoveAllListeners();
        this.m_OnPointerClick.RemoveAllListeners();
        this.m_OnPointerDown.RemoveAllListeners();
        this.m_OnPointerUp = null;
        this.m_OnPointerClick = null;
        this.m_OnPointerDown = null;
    }


    /// <summary>
    /// 点下时发生
    /// </summary>
    public PolygonClickedEvent PointerDown
    {
        get { return this.m_OnPointerDown; }
    }


    /// <summary>
    /// 点击时发生
    /// </summary>
    public PolygonClickedEvent PointerClick
    {
        get { return this.m_OnPointerClick; }
    }


    /// <summary>
    /// 点击松开时发生
    /// </summary>
    public PolygonClickedEvent PointerUp
    {
        get { return this.m_OnPointerUp; }
    }


    /// <summary>
    /// 重写方法，用于干涉点击射线有效性
    /// </summary>
    public override bool IsRaycastLocationValid(Vector2 screenPoint, Camera eventCamera)
    {
        if (this.m_Vertexs == null)
        {
            return base.IsRaycastLocationValid(screenPoint, eventCamera);
        }
        else
        {
            //Debug.Log("<color=red>点击x=</color>" + screenPoint.x + " y=" + screenPoint.y);
            // 点击的坐标转换为相对于图片的坐标
            //UICanvasHelper.Instance.ScreenToUIPoint(ref screenPoint);
            //var selfPoint = UICanvasHelper.Instance.WorldToScreenPoint(this.m_RectTransform.position, UICanvasHelper.Instance.UICamera);
            //screenPoint.x -= selfPoint.x;
            //screenPoint.y -= selfPoint.y;
            // 判断点击是否在区域内
            //
            Vector2 p;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, screenPoint, m_camera, out p);
            return _Contains(this.m_Vertexs, p);
        }
    }


    public void OnPointerUp(PointerEventData eventData)
    {
        if (this.m_OnPointerUp != null)
        {
            this.m_OnPointerUp.Invoke(this);
        }
    }


    public void OnPointerClick(PointerEventData eventData)
    {
        if (this.m_OnPointerClick != null)
        {
            this.m_OnPointerClick.Invoke(this);
        }
    }


    public void OnPointerDown(PointerEventData eventData)
    {
        if (this.m_OnPointerDown != null)
        {
            this.m_OnPointerDown.Invoke(this);
        }
    }


    /// <summary>
    /// 使用Crossing Number算法获取指定的点是否处于指定的多边形内
    /// </summary>
    private static bool _Contains(Vector2[] pVertexs, Vector2 pPoint)
    {
        var crossNumber = 0;

        for (int i = 0, count = pVertexs.Length; i < count; i++)
        {
            var vec1 = pVertexs[i];
            var vec2 = i == count - 1 // 如果当前已到最后一个顶点，则下一个顶点用第一个顶点的数据
                ? pVertexs[0]
                : pVertexs[i + 1];

            if (((vec1.y <= pPoint.y) && (vec2.y > pPoint.y))
                || ((vec1.y > pPoint.y) && (vec2.y <= pPoint.y)))
            {
                if (pPoint.x < vec1.x + (pPoint.y - vec1.y) / (vec2.y - vec1.y) * (vec2.x - vec1.x))
                {
                    crossNumber += 1;
                }
            }
        }

        return (crossNumber & 1) == 1;
    }


    public class PolygonClickedEvent : UnityEvent<PolygonClick> { }
}