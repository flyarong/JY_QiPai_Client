using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


    public class SoftClipHelper : MonoBehaviour {
        private static SoftClipHelper _instance;

        public static SoftClipHelper Instance
        {
            get{
                if (_instance == null) {
                    _instance = AppFacade.Instance.AddManager<SoftClipHelper>("SoftClipHelper");
                    _instance = AppFacade.Instance.GetManager<SoftClipHelper> ("SoftClipHelper");
                }
                return _instance;
            }
        }

        /// <summary>
        /// 设置Scroll软裁剪方式
        /// </summary>
        /// <param name="content">ScrollContent</param>
        /// <param name="softArgs">软裁剪范围 softArgs.x和softArgs.y分别表示裁剪区域到ScrollViewport边框的距离</param>
        /// <param name="direction">淡出方向direction.up/down/left/right/zero分别表示从上/下/左/右/中心淡出</param>
        /// <param name="depth">裁剪物体的Alpha的深度</param>
        /// <param name="force">裁剪物体淡出的强度 force越大表示淡出越快</param>
        /// <returns></returns>
        public void SetSoftClipFactors(Transform content, Vector2 softArgs,Vector2 direction , float depth = 1, float force = 1)
        {
            RectTransform curRT = content.parent.GetComponent<RectTransform>();
            RectTransform RT = content.parent.parent.GetComponent<RectTransform>();
            RectTransform canvas = GameObject.Find("Canvas").GetComponent<RectTransform>();
            CanvasScaler cs = canvas.GetComponent<CanvasScaler>();
            bool matchWidthOrHeight =  cs.matchWidthOrHeight == 0 ? false : true;

            Vector2 pos = RectTransformUtility.WorldToScreenPoint(Camera.main,RT.position); // Camera.main.WorldToScreenPoint(RT.position);
            pos = pos * (matchWidthOrHeight ? (canvas.rect.height / Screen.height) : (canvas.rect.width / Screen.width));
            // Debug.Log("pos" + pos.x + "  " + pos.y);
            // Vector4 cr = new Vector4(pos.x - Screen.width / 2, pos.y - Screen.height / 2, curRT.rect.width / 2, curRT.rect.height / 2);
            Vector4 cr = new Vector4(pos.x - canvas.rect.width / 2, pos.y - canvas.rect.height / 2, curRT.rect.width / 2, curRT.rect.height / 2);
            // Debug.Log(cr.x + "  " + cr.y + "  " + cr.z +" " + cr.w);

            Material mDynamicImageMat = new Material(Shader.Find("Unlit/Transparent Colored 1"));
            Material mDynamicTextMat = new Material(Shader.Find("Unlit/Text 1"));

            float angle = 0;
            angle *= -Mathf.Deg2Rad;
            Vector2 sharpness = new Vector2(1000.0f, 1000.0f);
            if (softArgs.x > 0f) sharpness.x = cr.z / softArgs.x;
            if (softArgs.y > 0f) sharpness.y = cr.w / softArgs.y;

            //设置Material
            Vector4 clipRange = new Vector4(-cr.x / cr.z, -cr.y / cr.w, 1f / cr.z, 1f / cr.w);
            Vector4 clipArgs = new Vector4(sharpness.x, sharpness.y, Mathf.Sin(angle), Mathf.Cos(angle));

            mDynamicImageMat.SetVector(Shader.PropertyToID("_ClipRange"), clipRange);
            mDynamicImageMat.SetVector(Shader.PropertyToID("_ClipArgs"), clipArgs);
            mDynamicImageMat.SetVector(Shader.PropertyToID("_ClipDirection"), direction);
            mDynamicImageMat.SetFloat(Shader.PropertyToID("_ClipDepth"), depth);
            mDynamicImageMat.SetFloat(Shader.PropertyToID("_ClipForce"), force);
            mDynamicTextMat.SetVector(Shader.PropertyToID("_ClipRange"), clipRange);
            mDynamicTextMat.SetVector(Shader.PropertyToID("_ClipArgs"), clipArgs);
            mDynamicTextMat.SetVector(Shader.PropertyToID("_ClipDirection"),direction);
            mDynamicTextMat.SetFloat(Shader.PropertyToID("_ClipDepth"), depth);
            mDynamicTextMat.SetFloat(Shader.PropertyToID("_ClipForce"), force);

            Material[] materials = new Material[] { mDynamicImageMat, mDynamicTextMat };
            foreach (Transform child in content.transform)
            {
                StartCoroutine(SoftClipHelper.Instance.SetSoftClipping(child.transform, materials));
            }
        }

        /// <summary>
        /// 设置软裁切
        /// </summary>
        /// <param name="target">裁切目标</param>
        /// <param name="materisls">裁切方式</param>
        /// <returns></returns>
        public IEnumerator SetSoftClipping(Transform target, Material[] materisls)
        {
            if (materisls != null)
            {
                Image[] imageArray = target.GetComponentsInChildren<Image>();
                Text[] textArray = target.GetComponentsInChildren<Text>();

                yield return null;
                for (int i = 0; i < textArray.Length; i++)
                {
                    if (textArray[i].material != materisls[1])
                        textArray[i].material = materisls[1];
                }
                for (int i = 0; i < imageArray.Length; i++)
                {
                    if (imageArray[i].material != materisls[0])
                        imageArray[i].material = materisls[0];
                }
                yield return null;
            }
        }
    }