using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     分散
    /// </summary>
    public class SteeringForDisperse : Steering
    {
        /// <summary>最小相距距离</summary>
        public float minApartDistance;

        /// <summary>雷达</summary>
        private Radar radar;

        private new void Start()
        {
            base.Start();
            radar = GetComponent<Radar>();
        }

        public override Vector3 ComputeForce()
        {
            //计算与所有目标的远离操控力的合力
            expectForce = Vector3.zero;
            var array = radar.ScanTarget();
            for (var i = 0; i < array.Length; i++)
            {
                if (array[i].gameObject != gameObject
                    && Vector3.Distance(transform.position, array[i].transform.position) < minApartDistance)
                    expectForce += (transform.position - array[i].transform.position).normalized * speed;
            }

            if (expectForce == Vector3.zero) return Vector3.zero;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }
}