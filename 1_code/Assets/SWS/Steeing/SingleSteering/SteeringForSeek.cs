using System;
using UnityEngine;

namespace AI.Steering
{
    /// <summary>
    ///     靠近
    /// </summary>
    public class SteeringForSeek : Steering
    {
        public override Vector3 ComputeForce()
        {
            expectForce = (target.position -transform.position).normalized * speed;
            return (expectForce - vehicle.currentForce) * weight;
        }
    }
}