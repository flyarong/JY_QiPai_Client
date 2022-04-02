using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class ScrollIndexCallback : MonoBehaviour 
{
    private void Awake()
    {
        Debug.Log("<color=red>ScrollIndexCallback Awake</color>");
    }
    private void Start()
    {
        Debug.Log("<color=red>ScrollIndexCallback Start</color>");
    }
    public LayoutElement element;
    void ScrollCellIndex(int idx)
    {
        string name = "Cell " + idx.ToString();
        gameObject.name = name;
    }
}
