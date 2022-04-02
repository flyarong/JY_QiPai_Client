using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System;

public class ModelController : MonoBehaviour {  
    public Button button_run,button_walk, button_attack;  
	Image img;
    // Use this for initialization  
    void Start () {  
        button_run = transform.Find("Button_run").GetComponent<Button>();  
        button_walk = transform.Find("Button_walk").GetComponent<Button>();  
        button_attack = transform.Find("Button_attck").GetComponent<Button>();
		img = transform.Find("Image").GetComponent<Image>();
          
        EventTriggerListener.Get(button_run.gameObject).onClick = OnButtonClick;  
        EventTriggerListener.Get(button_walk.gameObject).onClick = OnButtonClick;  
        EventTriggerListener.Get(button_attack.gameObject).onClick = OnButtonClick;  
        EventTriggerListener.Get(button_run.gameObject).onEnter = OnButtonEnter;  
        EventTriggerListener.Get(button_walk.gameObject).onEnter = OnButtonEnter;  
        EventTriggerListener.Get(button_attack.gameObject).onEnter = OnButtonEnter; 

        EventTriggerListener.Get(img.gameObject).onEnter = OnButtonEnter;  

    }

    private void OnButtonEnter(GameObject go)
    {
         if (go == button_run.gameObject){  
            Debug.Log("button_run enter");  
        }else if (go == button_walk.gameObject){  
            Debug.Log("button_walk enter");  
        }else if (go == button_attack.gameObject){  
            Debug.Log("button_attack enter");  
        } 
		else if(go == img.gameObject){
			Debug.Log("img enter");
		}
    }

    private void OnButtonClick(GameObject go) {  
        //在这里监听按钮的点击事件  
        if (go == button_run.gameObject){  
            Debug.Log("button_run");  
        }else if (go == button_walk.gameObject){  
            Debug.Log("button_walk");  
        }else if (go == button_attack.gameObject){  
            Debug.Log("button_attack");  
        }  
    }  
      
    // Update is called once per frame  
    void Update () {  
      
    }  
}  
