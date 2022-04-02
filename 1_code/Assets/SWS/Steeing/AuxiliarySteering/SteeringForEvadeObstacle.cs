using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     避开障碍物
    /// </summary>
    public class SteeringForEvadeObstacle : Steering
    {
        /// <summary>推力的最小值</summary>
        public float minRepulsiveForce;

        /// <summary>障碍物Tag</summary>
        public string obstacleTag;

        /// <summary>探头长度</summary>
        public float probeLength;

        /// <summary>探头的位置</summary>
        public Transform problePos;

        public override Vector3 ComputeForce()
        {
            RaycastHit hitInfo;
            if (!Physics.Raycast(problePos.position , problePos.forward , out hitInfo , probeLength)
                || hitInfo.collider.tag == obstacleTag)
                return Vector3.zero;

            expectForce = hitInfo.point - hitInfo.collider.transform.position;
            if (expectForce.magnitude < minRepulsiveForce)
                expectForce = expectForce.normalized * minRepulsiveForce;

            return expectForce * weight;
        }
    }
}