using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     操控基类
    /// </summary>
    public abstract class Steering : MonoBehaviour
    {
        /// <summary>操控速度</summary>
        public float speed;

        /// <summary>目标</summary>
        public Transform target;

        /// <summary>权重</summary>
        public float weight = 1;

        //实际操控力 = 期望操控力 - 当前操控力
        /// <summary>运动体</summary>
        [HideInInspector]
        public Vehicle vehicle;

        /// <summary>期望操控力</summary>
        [HideInInspector]
        public Vector3 expectForce;

        /// <summary>
        ///     计算操控力
        /// </summary>
        public abstract Vector3 ComputeForce();

        public void Start()
        {
            vehicle = GetComponent<Vehicle>();
            if (speed == 0)
                speed = vehicle.maxSpeed;
        }
    }
}