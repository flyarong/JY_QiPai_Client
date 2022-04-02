using System;
using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     运动控制
    /// </summary>
    public class LocomotionController : Vehicle
    {
        /// <summary>
        ///     移动
        /// </summary>
        public void Movement()
        {
            //当前操控力+加速度*deltaTime
            currentForce += acceleration * Time.deltaTime;
            //限制当前操控力大小
            currentForce = Vector3.ClampMagnitude(currentForce, maxSpeed);
            //位移
            this.transform.position += currentForce * Time.deltaTime;
        }

        /// <summary>
        ///     转向
        /// </summary>
        public void LookAt()
        {
            if (currentForce == Vector3.zero) return;
            var targetRotation = Quaternion.LookRotation(currentForce);
            if (is2D){
                targetRotation.x = transform.rotation.x;
                targetRotation.y = transform.rotation.y;
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
                return;
            }
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }

        /// <summary>
        ///     播动画
        /// </summary>
        public void PlayAnimation()
        {
            throw new NotImplementedException();
        }

        public void Update()
        {
            base.Start();
            Movement();
            LookAt();
        }
    }
}