using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    /// 徘徊
    /// </summary>
    public class SteeringForWander : Steering
    {
        /// <summary>改变目标点的时间间隔</summary>
        public float changeInterval;

        /// <summary>圆周点</summary>
        private Vector3 circlrPos;

        /// <summary>最大偏移值</summary>
        public float maxOffset;

        /// <summary>目标位置</summary>
        private Vector3 targetPos;

        /// <summary>到徘徊圆的距离</summary>
        public float wanderDistance;

        /// <summary>徘徊圆半径</summary>
        public float wanderRadius;

        private new void Start()
        {
            base.Start();
            //设置最初目标点
            targetPos = Vector3.zero;
            circlrPos = new Vector3(wanderRadius , 0 , 0);
            InvokeRepeating("ChangeTarget" , 0 , changeInterval);
        }

        private void ChangeTarget()
        {
            #region MyRegion

            //随机产生一个偏移点//将偏移点加在初始点上,得到偏移目标点
            //targetPos += new Vector3(
            //    Random.Range(-maxOffset, maxOffset),
            //    Random.Range(-maxOffset, maxOffset),
            //    Random.Range(-maxOffset, maxOffset));
            ////将偏移目标点投射到圆周上
            //var circleCentre = transform.position + transform.forward * wanderDistance;
            //targetPos = (targetPos - circleCentre).normalized * wanderRadius + circleCentre;

            #endregion
            //随机产生一个偏移点//将偏移点加在初始点上,得到偏移目标点
            circlrPos += new Vector3(
                Random.Range(-maxOffset, maxOffset),
                Random.Range(-maxOffset, maxOffset),
                Random.Range(-maxOffset, maxOffset));

            //将偏移目标点投射到圆周上
            circlrPos = circlrPos.normalized * wanderRadius;
            //将圆周的目标点转为世界坐标点
            targetPos = transform.position + transform.forward * wanderDistance + circlrPos;
        }

        public override Vector3 ComputeForce()
        {
            expectForce = (targetPos - transform.position).normalized * speed;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }
}