using UnityEngine;
using Array = System.Array;

namespace AI.Steering
{
    /// <summary>
    /// 雷达
    /// </summary>
    public class Radar : MonoBehaviour
    {
        /// <summary>雷达半径</summary>
        public float radarRadiur;

        /// <summary>目标标签</summary>
        public string targetTag;

        /// <summary>
        /// 扫描目标
        /// </summary>
        /// <returns>目标数组</returns>
        public GameObject[] ScanTarget()
        {
            var array = GameObject.FindGameObjectsWithTag(targetTag);
            array = Array.FindAll(array ,
                p => Vector3.Distance(p.transform.position , transform.position) <= radarRadiur);
            return array;
        }
    }
}
