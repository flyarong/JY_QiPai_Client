/*  This file is part of the "Simple Waypoint System" project by Rebound Games.
 *  You are only allowed to use these resources if you've bought them from the Unity Asset Store.
 * 	You shall not license, sublicense, sell, resell, transfer, assign, distribute or
 * 	otherwise make available to any third party the Service or the Content. */

using UnityEngine;
using System.Collections.Generic;

namespace SWS
{

    public enum FishSchoolOption{
        FollowPath,
        OffsetPursuit,
    }

    /// <summary>
    /// Stores fishs, accessed by walker objects.
    /// Provides gizmo visualization in the editor.
    /// <summary>
    public class FishSchoolManager : MonoBehaviour
    {
        /// <summary>
        /// Waypoint array creating the path.
        /// <summary>
        public Transform[] fishs = new Transform[]{};

        /// <summary>
        /// Toggles drawing of linear or curved gizmo lines.
        /// <summary>
        public bool drawCurved = true;
        
        /// <summary>
        /// Toggles drawing of waypoint direction rotation.
        /// <summary>
        public bool drawDirection = false;

        /// <summary>
        /// Gizmo color for path ends.
        /// <summary>
        public Color color1 = new Color(1, 0, 1, 0.5f);

        /// <summary>
        /// Gizmo color for lines and waypoints.
        /// <summary>
        public Color color2 = new Color(1, 235 / 255f, 4 / 255f, 0.5f);

        /// <summary>
        /// Gizmo size for path ends.
        /// <summary>
        public Vector3 size = new Vector3(.7f, .7f, .7f);

        /// <summary>
        /// Skip custom names on waypoint renaming.
        /// </summary>
        public bool skipCustomNames = true;

        public FishSchoolOption fishSchoolOption = FishSchoolOption.FollowPath;

		//auto-add to FishManager
        void Awake()
        {
            FishManager.AddFish(gameObject);
        }


        /// <summary>
        /// Create or update waypoint representation from child objects or external parent.
        /// </summary>
        public void Create(Transform parent = null)
        {
            if (parent == null)
                parent = transform;

            List<Transform> childs = new List<Transform>();
            foreach(Transform child in parent)
                childs.Add(child);

            Create(childs.ToArray());
        }


        /// <summary>
        /// Create or update waypoint representation from the array passed in, optionally parenting them to the path.
        /// </summary>
        public virtual void Create(Transform[] fishs, bool makeChildren = false)
        {
            if(fishs.Length < 2)
            {
                Debug.LogWarning("Not enough fishs placed - minimum is 2. Cancelling.");
                return;
            }

            if(makeChildren)
            {
                for(int i = 0; i < fishs.Length; i++)
                    fishs[i].parent = transform;
            }

            this.fishs = fishs;
        }


        //editor visualization
        void OnDrawGizmos()
        {
            if (fishs.Length <= 0) return;
            UpdateFishController(fishs);
            //get positions
            Vector3[] wpPositions = GetPathPoints();

            //assign path ends color
            Gizmos.color = color1;
            for (int i = 0; i < wpPositions.Length; i++)
            {
                Vector3 end = wpPositions[i];
                Gizmos.DrawWireCube(end, size * GetHandleSize(end) * 1.5f);
            }
        }

        //helper method to get screen based handle sizes
        public virtual float GetHandleSize(Vector3 pos)
        {
            float handleSize = 1f;
            #if UNITY_EDITOR
                handleSize = UnityEditor.HandleUtility.GetHandleSize(pos) * 0.4f;
                handleSize = Mathf.Clamp(handleSize, 0, 1.2f);
            #endif
            return handleSize;
        }


        /// <summary>
        /// Returns waypoint positions (path positions) as Vector3 array.
        /// <summary>
        public virtual Vector3[] GetPathPoints(bool local = false)
        {
            Vector3[] pathPoints = new Vector3[fishs.Length];

            if (local)
            {
                for (int i = 0; i < fishs.Length; i++)
                    pathPoints[i] = fishs[i].localPosition;
            }
            else
            {
                for (int i = 0; i < fishs.Length; i++)
                    pathPoints[i] = fishs[i].position;
            }

            return pathPoints;
        }

        
        /// <summary>
		/// Returns this waypoint transform according to the index passed in.
		/// </summary>
        public virtual Transform GetWaypoint(int index)
        {
            return fishs[index];
        }
        

		/// <summary>
		/// Converts bezier points on the path to waypoint index.
		/// </summary>
		public virtual int GetWaypointIndex(int point)
		{
			return point;
		}


		/// <summary>
		/// Returns waypoint length (should be equal to events count).
		/// </summary>
		public virtual int GetWaypointCount()
		{
			return fishs.Length;
		}

        private void UpdateFishController(Transform[] fishs)
        {
            for (int i = 0; i < fishs.Length; i++)
            {
                var tf = fishs[i];
                var fishController = tf.GetComponent<FishController>();
                if (fishController == null)
                {
                    fishController = tf.gameObject.AddComponent<FishController>();
                }
                fishController.AddLocomotionController();
                fishController.SetWayPoints();
                fishController.SetFishPerfab();
            }
        }
    }
}


