using UnityEngine;

public class ShowFPS : MonoBehaviour
{
	public float ping;
	#if UNITY_ANDROID || UNITY_EDITOR
//#if !UNITY_EDITOR
    
    private float fpsMeasuringDelta = 0.5f;

    private float timePassed;
    private int m_FrameCount = 0;
    private float m_FPS = 0.0f;
    private GUIStyle guiStyle;
    private void Start()
    {
        timePassed = 0.0f;
        guiStyle = new GUIStyle();
        guiStyle.normal.background = null;                          //这是设置背景填充的 
        guiStyle.fontSize = 30;                                     //当然，这是字体大小
    }

    private void Update()
    {
        m_FrameCount = m_FrameCount + 1;
        timePassed = timePassed + Time.deltaTime;

        if (timePassed > fpsMeasuringDelta)
        {
            m_FPS = m_FrameCount / timePassed;

            timePassed = 0.0f;
            m_FrameCount = 0;
        }
    }
     
    private void OnGUI()
    {
        
        // return;
        string labText = string.Empty;
        if (m_FPS > 25)
        {
            labText = string.Format("<color=#00FF00FF>{0}</color>", "FPS: " + m_FPS.ToString("F1"));
        }
        else if (m_FPS > 20)
        {
            labText = string.Format("<color=#ffff00ff>{0}</color>", "FPS: " + m_FPS.ToString("F1"));
        }
        else
        {
            labText = string.Format("<color=#ff0000ff>{0}</color>", "FPS: " + m_FPS.ToString("F1"));
        }
        string pingTxt = string.Empty;

        if (ping > 300)
        {
            pingTxt = string.Format("<color=#ff0000ff>{0}</color>", "ping: " + ping.ToString("F1"));
        }
        else if (ping > 100)
        {
            pingTxt = string.Format("<color=#ffff00ff>{0}</color>", "ping: " + ping.ToString("F1"));
        }
        else
        {
            pingTxt = string.Format("<color=#00FF00FF>{0}</color>", "ping: " + ping.ToString("F1"));
        }
        //居中显示FPS
        GUI.Label(new Rect(20, 10, 100, 100), labText, guiStyle);
        GUI.Label(new Rect(20, 50, 100, 100), pingTxt, guiStyle);
    }
    
	#endif
}