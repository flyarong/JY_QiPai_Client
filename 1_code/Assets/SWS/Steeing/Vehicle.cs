using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     运动体
    /// </summary>
    public class Vehicle : MonoBehaviour
    {
        /// <summary>加速度</summary>
        [HideInInspector]
        public Vector3 acceleration;

        /// <summary>计算加速度时间间隔</summary>
        public float computeInteval;

        /// <summary>当前操控力</summary>
        [HideInInspector]
        public Vector3 currentForce;

        /// <summary>合力</summary>
        [HideInInspector]
        public Vector3 finalForce;

        /// <summary>是否是平面</summary>
        public bool isPlane;

        /// <summary>是否是2D</summary>
        public bool is2D;

        /// <summary>质量</summary>
        public float mass = 1;

        /// <summary>合力上限</summary>
        public float maxForce;

        /// <summary>最大速度</summary>
        public float maxSpeed;

        /// <summary>转向速度</summary>
        public float rotationSpeed;

        /// <summary>操控数组</summary>
        [HideInInspector]
        private Steering[] steerings;

        public void Start()
        {
            //获取所有Steering类的组件,初始化数组
            steerings = GetComponents<Steering>();
            InvokeRepeating("ComputeAcceleration", 0, computeInteval);
        }

        /// <summary>
        ///     计算加速度
        /// </summary>
        public void ComputeAcceleration()
        {
            finalForce = Vector3.zero;
            for (var i = 0; i < steerings.Length; i++)
            {
                if (steerings[i].enabled) //判断组件是否启用,启用才计算
                    finalForce += steerings[i].ComputeForce();
            }
            //限制模长
            finalForce = Vector3.ClampMagnitude(finalForce, maxForce);
            //平面控制
            if (isPlane) finalForce.y = 0;
            if (is2D) finalForce.z = 0;
            //合力为零时重置当前合力为零
            if (finalForce == Vector3.zero) currentForce = Vector3.zero;
            acceleration = finalForce / mass;
        }
    }
}