using UnityEngine;
using System.Collections;

namespace AI.Steering
{
    /// <summary>
    /// 到达
    /// </summary>
    public class SteeringForArrive : Steering
    {
        /// <summary>到达区半径</summary>
        public float arriveRadius;

        /// <summary>减速区半径</summary>
        public float decelerateRadius;

        public override Vector3 ComputeForce()
        {
            var tempDistance = Vector3.Distance(target.position, transform.position) - arriveRadius;
            //到达目标
            if (tempDistance <= 0)
                return Vector3.zero;
            //当前速度
            var realSpeed = vehicle.currentForce.magnitude;
            //在减速区
            if (tempDistance < decelerateRadius)
            {
                realSpeed = tempDistance / decelerateRadius * realSpeed;
                realSpeed = realSpeed < 1 ? 1 : realSpeed;
            }
            //减速区外
            else
                realSpeed = speed;
            expectForce = (target.position - transform.position).normalized * realSpeed;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }
}