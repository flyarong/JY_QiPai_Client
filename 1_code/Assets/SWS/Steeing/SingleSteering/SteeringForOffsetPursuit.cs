using System;
using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     巡逻
    /// </summary>
    public class SteeringForOffsetPursuit : Steering
    {
        /// <summary>领航员</summary>
        public Steering leader;

        /// <summary>相对偏移</summary>
        public Vector2 offset;

        /// <summary>到达区半径</summary>
        public float arriveRadius;

        /// <summary>减速区半径</summary>
        public float decelerateRadius;

        public override Vector3 ComputeForce()
        {
            Vector3 WorldOffsetPos = PointToWorldSpace(offset,leader.vehicle.currentForce.normalized,Vec2DPerp(leader.vehicle.currentForce.normalized),leader.transform.position);
            Vector3 ToOffset = WorldOffsetPos + vehicle.transform.position;
            float LookAheadTime = ToOffset.magnitude / (vehicle.maxSpeed + leader.speed);
            Vector3 targetPos = WorldOffsetPos + leader.vehicle.currentForce * LookAheadTime;

            var tempDistance = Vector3.Distance(targetPos, transform.position) - arriveRadius;
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
            expectForce = (targetPos - transform.position).normalized * realSpeed;
            return (expectForce - vehicle.currentForce) * weight;
        }

        private Vector2 Vec2DPerp(Vector2 vec){
            Vector2 vec2 = new Vector2(0,0);
            float cosB = 0;
            float sinB = -1;
            vec2.x = vec.x * cosB - vec.y * sinB;
            vec2.y = vec.x * sinB + vec.y * cosB;
            return vec2;
        }

        private Vector2 PointToWorldSpace(Vector2 point,Vector2 AgentHeading,Vector2 AgentSide,Vector2 AgentPosition){
            float x = point.x * AgentHeading.x + point.y * AgentSide.x + AgentPosition.x;
            float y = point.x * AgentHeading.y + point.y * AgentSide.y + AgentPosition.y;
            return new Vector2(x,y);
        }
    }
}