using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     逃避
    /// </summary>
    public class SteeringForEscape : Steering
    {
        public override Vector3 ComputeForce()
        {
            var angle = Vector3.Angle(target.forward , transform.position - target.position);

            //位于目标侧方
            if (angle > 20 && angle < 160)
            {
                //目标速度
                var targetSpeed = target.GetComponent<Vehicle>().currentForce.magnitude;
                var distance = Vector3.Distance(target.position , transform.position);
                //时间 = 距离 / 双方速度之和
                var time = distance / (targetSpeed + vehicle.currentForce.magnitude);
                //距离 = 目标速度 * 时间
                var runDistance = targetSpeed * time;
                //拦截点位置 = 目标位置 + 距离
                var interceptPoint = target.position + runDistance * target.forward;
                //期望操控力
                expectForce = (transform.position - interceptPoint).normalized * speed;
            }
            //位于目标前方或后方
            else
                expectForce = (transform.position - target.position).normalized * speed;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }
}