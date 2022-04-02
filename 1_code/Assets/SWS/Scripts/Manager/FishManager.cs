/*  This file is part of the "Simple Waypoint System" project by Rebound Games.
 *  You are only allowed to use these resources if you've bought them from the Unity Asset Store.
 * 	You shall not license, sublicense, sell, resell, transfer, assign, distribute or
 * 	otherwise make available to any third party the Service or the Content. */

using UnityEngine;
using System.Linq;
using System.Collections.Generic;
using DG.Tweening;

namespace SWS
{
    /// <summary>
    /// The editor part of this class allows you to create fishs in 2D or 3D space.
    /// At runtime, it manages fish instances for easy lookup of references.
    /// <summary>
    public class FishManager : MonoBehaviour
    {
        /// <summary>
        /// Key for placing new waypoints in the scene
        /// </summary>
        public KeyCode placementKey = KeyCode.T;

        /// <summary>
        /// Key for placing new waypoints at the current scene view camera position
        /// </summary>
        public KeyCode viewPlacementKey = KeyCode.G;

        /// <summary>
        /// Stores all fish components in the scene along with their name.
        /// You can access them by calling FishManager.Fishs["fish name"].
        /// <summary>
        public static readonly Dictionary<string, FishSchoolManager> Fishs = new Dictionary<string, FishSchoolManager>();


        void Awake()
        {
            //http://dotween.demigiant.com/documentation.php#init
            //initialize DOTween immediately instead than having it being
            //automatically initialized when the first Tweener is created.
            //set up specific settings in the DOTween utility panel!
            DOTween.Init();
        }


        /// <summary>
        /// Adds the gameobject to the fish dictionary, if it contains a fish component.
        /// <summary>
        public static void AddFish(GameObject fish)
        {
            //check if the fish has been instantiated,
            //then remove the clone naming scheme
            string fishName = fish.name;
            if (fishName.Contains("(Clone)"))
                fishName = fishName.Replace("(Clone)", "");

            //try to get FishSchoolManager component
            FishSchoolManager fishMan = fish.GetComponentInChildren<FishSchoolManager>();
            if(fishMan == null)
            {
                Debug.LogWarning("Called AddFish() but GameObject " + fishName + " has no FishSchoolManager attached.");
                return;
            }

            CleanUp();

            //check if our dictionary already contains this fish
            //in case it exists already we add a unique number to the end
            if (Fishs.ContainsKey(fishName))
            {
                //find unique naming for it
                int i = 1;
                while (Fishs.ContainsKey(fishName + "#" + i))
                {
                    i++;
                }

                fishName += "#" + i;
                Debug.Log("Renamed " + fish.name + " to " + fishName + " because a fish with the same name was found.");
            }

            //rename fish and add it to dictionary
            fish.name = fishName;
            Fishs.Add(fishName, fishMan);
        }


        /// <summary>
        /// Clears destroyed fish gameobjects from the Fishs dictionary.
        /// <summary>
        public static void CleanUp()
        {
            string[] keys = Fishs.Where(p => p.Value == null).Select(p => p.Key).ToArray();
            for(int i = 0; i < keys.Length; i++)
                Fishs.Remove(keys[i]);
        }


        //static dictionaries keep their variables between scenes,
        //we don't want that to happen - clear the fish dictionary
        //whenever this object gets destroyed (e.g. on scene change)
        void OnDestroy()
        {
            Fishs.Clear();
        }


        /// <summary>
        /// Draws straight gizmo lines between waypoints.
        /// <summary>
        public static void DrawStraight(Vector3[] waypoints)
        {
            for (int i = 0; i < waypoints.Length - 1; i++)
                Gizmos.DrawLine(waypoints[i], waypoints[i + 1]);
        }


        /// <summary>
        /// Draws curved gizmo lines between waypoints, taken and modified from HOTween.
        /// <summary>
        //http://code.google.com/p/hotween/source/browse/trunk/Holoville/HOTween/Core/Fish.cs
        public static void DrawCurved(Vector3[] fishPoints)
        {
            fishPoints = GetCurved(fishPoints);
            Vector3 prevPt = fishPoints[0];
            Vector3 currPt;
            
            for (int i = 1; i < fishPoints.Length; ++i)
            {
                currPt = fishPoints[i];
                Gizmos.DrawLine(currPt, prevPt);
                prevPt = currPt;
            }
        }
        

        public static Vector3[] GetCurved(Vector3[] waypoints)
        {
            //helper array for curved fishs, includes control points for waypoint array
            Vector3[] gizmoPoints = new Vector3[waypoints.Length + 2];
            waypoints.CopyTo(gizmoPoints, 1);
            gizmoPoints[0] = waypoints[1];
            gizmoPoints[gizmoPoints.Length - 1] = gizmoPoints[gizmoPoints.Length - 2];

            Vector3[] drawPs;
            Vector3 currPt;

            //store draw points
            int subdivisions = gizmoPoints.Length * 10;
            drawPs = new Vector3[subdivisions + 1];
            for (int i = 0; i <= subdivisions; ++i)
            {
                float pm = i / (float)subdivisions;
                currPt = GetPoint(gizmoPoints, pm);
                drawPs[i] = currPt;
            }
            
            return drawPs;
        }


        /// <summary>
        /// Gets the point on the curve at a given percentage (0-1). Taken and modified from HOTween.
        /// <summary>
        //http://code.google.com/p/hotween/source/browse/trunk/Holoville/HOTween/Core/Fish.cs
        public static Vector3 GetPoint(Vector3[] gizmoPoints, float t)
        {
            int numSections = gizmoPoints.Length - 3;
            int tSec = (int)Mathf.Floor(t * numSections);
            int currPt = numSections - 1;
            if (currPt > tSec)
            {
                currPt = tSec;
            }
            float u = t * numSections - currPt;

            Vector3 a = gizmoPoints[currPt];
            Vector3 b = gizmoPoints[currPt + 1];
            Vector3 c = gizmoPoints[currPt + 2];
            Vector3 d = gizmoPoints[currPt + 3];

            return .5f * (
                           (-a + 3f * b - 3f * c + d) * (u * u * u)
                           + (2f * a - 5f * b + 4f * c - d) * (u * u)
                           + (-a + c) * u
                           + 2f * b
                       );
        }

        /// <summary>
        /// Calculates the total fish length.
        /// <summary>
        public static float GetFishLength(Vector3[] waypoints)
        {
            float dist = 0f;
            for (int i = 0; i < waypoints.Length - 1; i++)
                dist += Vector3.Distance(waypoints[i], waypoints[i + 1]);
            return dist;
        }


        /// <summary>
        /// Smoothes a list of Vector3's based on the number of interpolations. Credits to "Codetastic".
        /// <summary>
        //http://answers.unity3d.com/questions/392606/line-drawing-how-can-i-interpolate-between-points.html
        public static List<Vector3> SmoothCurve(List<Vector3> fishToCurve, int interpolations)
        {
            List<Vector3> tempPoints;
            List<Vector3> curvedPoints;
            int pointsLength = 0;
            int curvedLength = 0;

            if (interpolations < 1)
                interpolations = 1;

            pointsLength = fishToCurve.Count;
            curvedLength = (pointsLength * Mathf.RoundToInt(interpolations)) - 1;
            curvedPoints = new List<Vector3>(curvedLength);

            float t = 0.0f;
            for (int pointInTimeOnCurve = 0; pointInTimeOnCurve < curvedLength + 1; pointInTimeOnCurve++)
            {
                t = Mathf.InverseLerp(0, curvedLength, pointInTimeOnCurve);
                tempPoints = new List<Vector3>(fishToCurve);
                for (int j = pointsLength - 1; j > 0; j--)
                {
                    for (int i = 0; i < j; i++)
                    {
                        tempPoints[i] = (1 - t) * tempPoints[i] + t * tempPoints[i + 1];
                    }
                }
                curvedPoints.Add(tempPoints[0]);
            }

            return curvedPoints;
        }
    }
}