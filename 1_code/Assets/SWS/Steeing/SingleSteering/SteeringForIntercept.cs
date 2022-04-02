using UnityEngine;
using System.Collections;

namespace AI.Steering
{
    /// <summary>
    /// 拦截
    /// </summary>
    public class SteeringForIntercept : Steering
    {

        #region MyRegion -> 要多加加刚体不可取
        ///// <summary>目标刚体</summary>
        //private Rigidbody targetRigidbody;
        ///// <summary>自身刚体</summary>
        //private Rigidbody myRigidbody;

        //private void Start ()
        //{
        //    base.Start();
        //    targetRigidbody = target.GetComponent<Rigidbody>();
        //    myRigidbody = this.GetComponent<Rigidbody>();
        //}
        //public override Vector3 ComputeForce ()
        //{
        //    float time = 0;
        //    if(targetRigidbody.velocity != Vector3.zero)
        //     time = Vector3.Distance(transform.position, target.position) /
        //                 (myRigidbody.velocity + targetRigidbody.velocity).magnitude;
        //    var tempDistance = targetRigidbody.velocity * time;
        //    var interceptPoint = target.position + tempDistance;

        //    expectForce = (interceptPoint - transform.position) * speed;

        //    return (expectForce - vehicle.currentForce) * weight;
        //}
        #endregion

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
                expectForce = (interceptPoint - transform.position).normalized * speed;
            }
            //位于目标前方或后方
            else
                expectForce = (target.position - transform.position).normalized * speed;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }
}