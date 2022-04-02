/*  This file is part of the "Simple Waypoint System" project by Rebound Games.
 *  You are only allowed to use these resources if you've bought them directly or indirectly
 *  from Rebound Games. You shall not license, sublicense, sell, resell, transfer, assign,
 *  distribute or otherwise make available to any third party the Service or the Content. 
 */
 
using UnityEngine;
using UnityEditor;

namespace SWS
{
    /// <summary>
    /// Adds a new Fish Manager gameobject to the scene.
    /// <summary>
    public class CreateFishManager : EditorWindow
    {
        //add menu named "Fish Manager" to the Window menu
        [MenuItem("Window/Simple Waypoint System/Fish Manager")]

        //initialize method
        static void Init()
        {
            //search for a Fish Manager object within current scene
            GameObject fManager = GameObject.Find("Fish Manager");

            //if no Fish Manager object was found
            if (fManager == null)
            {
                //create a new gameobject with that name
                fManager = new GameObject("Fish Manager");
                //and attach the WaypointManager component to it
                fManager.AddComponent<FishManager>();
            }

            //in both cases, select the gameobject
            Selection.activeGameObject = fManager;
        }
    }
}