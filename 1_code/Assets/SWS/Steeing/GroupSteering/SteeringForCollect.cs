using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     聚集
    /// </summary>
    public class SteeringForCollect : Steering
    {
        /// <summary>雷达</summary>
        private Radar radar;

        /// <summary>最近距离</summary>
        public float nearDistance;

        private void Start()
        {
            base.Start();
            radar = GetComponent<Radar>();
        }

        public override Vector3 ComputeForce()
        {
            //扫描目标
            var array = radar.ScanTarget();
            if (array.Length == 0) return Vector3.zero;

            var sumPos = Vector3.zero;
            for (int i = 0; i < array.Length; i++)
                sumPos += array[i].transform.position;
            //计算所有目标位置平均值(聚集点)
            var targetPos = sumPos / array.Length;

            if (Vector3.Distance(transform.position , targetPos) < nearDistance)
                return Vector3.zero;

            expectForce = (targetPos - transform.position).normalized * speed;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }
}