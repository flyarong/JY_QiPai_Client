using UnityEngine;
using System.Collections;

namespace AI.Steering
{
    /// <summary>
    /// 远离
    /// </summary>
    public class SteeringForFlee : Steering
    {
        /// <summary>安全距离</summary>
        public float safeDistacne;

        public override Vector3 ComputeForce()
        {
            if (Vector3.Distance(transform.position, target.position) < safeDistacne)
            {
                expectForce = (transform.position - target.position).normalized * speed;
                return (expectForce - vehicle.currentForce) * weight;
            }
            return Vector3.zero;
        }
    }
}
