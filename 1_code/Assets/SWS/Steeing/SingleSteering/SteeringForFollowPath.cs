using System;
using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     巡逻
    /// </summary>
    public class SteeringForFollowPath : Steering
    {
        /// <summary>当前巡逻点</summary>
        private int currentWPIndex;

        /// <summary>是否结束巡逻</summary>
        private bool isPatrolComplete;

        /// <summary>停止巡逻距离</summary>
        public float patrolArrivalDistance;

        /// <summary>巡逻方式</summary>
        public PatrolMode patroMode;

        /// <summary>巡逻点</summary>
        public Transform WayPointsRoot;

        /// <summary>巡逻点</summary>
        public Transform[] WayPoints;

        /// <summary>开始后经历的时间</summary>
        public float time;
        private float startTime;
        private bool can_time = true;

        public override Vector3 ComputeForce()
        {
            if (Vector3.Distance(WayPoints[currentWPIndex].position , transform.position) <
                patrolArrivalDistance)
            {
                 if (currentWPIndex == 0)
                {
                    time = 0;
                    startTime = Time.time;// TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)); // 当地时区
                }
                if(currentWPIndex ==  WayPoints.Length - 1)
                {
                    // int timeStamp = (int)(DateTime.Now - startTime).TotalSeconds; // 相差秒数
                    if (can_time)
                    {
                        time = Time.time - startTime;
                        can_time = false;
                    }
                }

                if (currentWPIndex == WayPoints.Length - 1)
                {
                    switch (patroMode)
                    {
                        case PatrolMode.Once:
                            isPatrolComplete = true;
                            return Vector3.zero;
                        case PatrolMode.Loop:
                            break;
                        case PatrolMode.PingPong:
                            Array.Reverse(WayPoints);
                            break;
                    }
                }
                currentWPIndex = ++currentWPIndex % WayPoints.Length;
            }
            expectForce = (WayPoints[currentWPIndex].position - transform.position).normalized * speed;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }

    /// <summary>
    ///     巡逻方式枚举
    /// </summary>
    [HideInInspector]
    public enum PatrolMode
    {
        Once ,
        Loop ,
        PingPong
    }
}