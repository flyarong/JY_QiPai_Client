/*  This file is part of the "Simple Waypoint System" project by Rebound Games.
 *  You are only allowed to use these resources if you've bought them directly or indirectly
 *  from Rebound Games. You shall not license, sublicense, sell, resell, transfer, assign,
 *  distribute or otherwise make available to any third party the Service or the Content. 
 */

using LitJson;		//引用LitJson
using System.IO;

using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Text;
using System;

namespace SWS
{
    /// <summary>
    /// Waypoint and fish creation editor.
    /// <summary>
    [CustomEditor(typeof(FishManager))]
    public class FishEditor : Editor
    {
        //manager reference
        private FishManager script;
        //new fish name
        private string fishName = "";
        //enables 2D mode placement (auto-detection)
        private bool mode2D = false;

        //if we are placing new fishs in editor
        private static bool placing = false;
        //new fish gameobject
        private static GameObject fish;
        //Fish Manager reference for editing fishs
        private static FishSchoolManager fishMan;
        //temporary list for editor created fishs in a fish
        private static List<GameObject> fishList = new List<GameObject>();

        //fish type selection enum
        private enum FishType
        {
            standard,
            fishSchool,
        }
        private FishType fishType = FishType.standard;


        public void OnSceneGUI()
        {
            //with creation mode enabled, place new fishs on keypress
            if (Event.current.type != EventType.KeyDown || !placing) return;

            //scene view camera placement
            if (Event.current.keyCode == KeyCode.G)
            {
                Event.current.Use();
                Vector3 camPos = GetSceneView().camera.transform.position;

                //place a waypoint at the camera
                PlaceWaypoint(camPos);

            }
            else if (Event.current.keyCode == script.placementKey)
            {
                //cast a ray against mouse position
                Ray worldRay = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);
                RaycastHit hitInfo;

                //2d placement
                if (mode2D)
                {
                    Event.current.Use();
                    //convert screen to 2d position
                    Vector3 pos2D = worldRay.origin;
                    pos2D.z = 0;

                    //place a waypoint at clicked point
                    PlaceWaypoint(pos2D);

                }
                //3d placement
                else
                {
                    if (Physics.Raycast(worldRay, out hitInfo))
                    {
                        Event.current.Use();

                        //place a waypoint at clicked point
                        PlaceWaypoint(hitInfo.point);
                    }
                    else
                    {
                        Debug.LogWarning("Waypoint Manager: 3D Mode. Trying to place a waypoint but couldn't "
                                         + "find valid target. Have you clicked on a collider?");
                    }
                }
            }
        }


        public override void OnInspectorGUI()
        {
            //show default variables of manager
            DrawDefaultInspector();
            //get manager reference
            script = (FishManager)target;
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

            //get sceneview to auto-detect 2D mode
            SceneView view = GetSceneView();
            mode2D = view.in2DMode;

            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();

            //draw fish text label
            GUILayout.Label("Enter Fish Name: ", GUILayout.Height(15));
            //display text field for creating a fish with that name
            fishName = EditorGUILayout.TextField(fishName, GUILayout.Height(15));

            EditorGUILayout.EndHorizontal();
            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();

            //draw fish type selection enum
            GUILayout.Label("Select Fish Type: ", GUILayout.Height(15));
            fishType = (FishType)EditorGUILayout.EnumPopup(fishType);

            EditorGUILayout.EndHorizontal();
            EditorGUILayout.Space();

            //display label of current mode
            if (mode2D)
                GUILayout.Label("2D Mode Detected.", GUILayout.Height(15));
            else
                GUILayout.Label("3D Mode Detected.", GUILayout.Height(15));
            EditorGUILayout.Space();

            //draw fish creation button
            if (!placing && GUILayout.Button("Start Fish", GUILayout.Height(40)))
            {
                if (fishName == "")
                {
                    EditorUtility.DisplayDialog("No Fish Name", "Please enter a unique name for your fish.", "Ok");
                    return;
                }

                if (script.transform.Find(fishName) != null)
                {
                    if (EditorUtility.DisplayDialog("Fish Exists Already",
                        "A fish with this name exists already.\n\nWould you like to edit it?", "Ok", "Cancel"))
                    {
                        Selection.activeTransform = script.transform.Find(fishName);
                    }
                    return;
                }

                //create a new container transform which will hold all new fishs
                fish = new GameObject(fishName);
                //reset position and parent container gameobject to this manager gameobject
                fish.transform.position = script.gameObject.transform.position;
                fish.transform.parent = script.gameObject.transform;
                StartFish();

                //we passed all prior checks, toggle waypoint placement
                placing = true;
                //focus sceneview for placement
                view.Focus();
            }

            GUI.backgroundColor = Color.yellow;

            //finish fish button
            if (placing && GUILayout.Button("Finish Editing", GUILayout.Height(40)))
            {
                FinishFish();
            }

            GUI.backgroundColor = Color.white;
            EditorGUILayout.Space();
            //draw instructions
            GUILayout.TextArea("Hint:\nEnter a unique name for your fish, "
                            + "then press 'Start Fish' to begin placement mode. Press '" + script.placementKey
                            + "' on your keyboard to place new fishs in the Scene view. In 3D Mode "
                            + "you have to place fishs onto game objects with colliders. You can "
                            + "also place fishs at the current scene view camera position by pressing '"
                            + script.viewPlacementKey + "'.\n\nPress 'Finish Editing' to end your fish.");

            EditorGUILayout.Space();

            //draw fish creation button
            if (!placing && GUILayout.Button("Exprot Json Fish", GUILayout.Height(40)))
            {
                ExportJson();
            }
            //draw fish creation button
            if (!placing && GUILayout.Button("Exprot Lua Fish", GUILayout.Height(40)))
            {
                ExportLua();
            }
        }


        //when losing editor focus
        void OnDisable()
        {
            FinishFish();
        }

        //differ between fish selection
        void StartFish()
        {
            switch (fishType)
            {
                case FishType.standard:
                    fishMan = fish.AddComponent<FishSchoolManager>();
                    fishMan.fishs = new Transform[0];
                    break;
            }
        }


        public static void ContinueFish(FishSchoolManager p)
        {
            fish = p.gameObject;
            fishMan = p;
            placing = true;

            fishList.Clear();
            for (int i = 0; i < p.fishs.Length; i++)
                fishList.Add(p.fishs[i].gameObject);

            GetSceneView().Focus();
        }


        //fish manager placement
        void PlaceWaypoint(Vector3 placePos)
        {
            //instantiate waypoint gameobject
            GameObject m_fish = new GameObject("Fish");
            // //从硬盘中加载到内存
            // UnityEngine.Object registObj=Resources.Load(Application.dataPath +  @"/Game/game_Fishing/Prefab/Fish001");
            // Debug.Log(registObj);
            // //将内存中的物体实例化为场景中的物体
            // GameObject m_fish = GameObject.Instantiate(registObj) as GameObject;


            //with every new waypoint, our fishs array should increase by 1
            //but arrays gets erased on resize, so we use a classical rule of three
            Transform[] wpCache = new Transform[fishMan.fishs.Length];
            System.Array.Copy(fishMan.fishs, wpCache, fishMan.fishs.Length);

            fishMan.fishs = new Transform[fishMan.fishs.Length + 1];
            System.Array.Copy(wpCache, fishMan.fishs, wpCache.Length);
            fishMan.fishs[fishMan.fishs.Length - 1] = m_fish.transform;

            //this is executed on placement of the first waypoint:
            //we position our fish container transform to the first waypoint position,
            //so the transform (and grab/rotate/scale handles) aren't out of sight
            if (fishList.Count == 0)
                fishMan.transform.position = placePos;

            //position current waypoint at clicked position in scene view
            if (mode2D) placePos.z = 0f;
            m_fish.transform.position = placePos;
            m_fish.transform.rotation = Quaternion.Euler(0, 0, 0);
            //parent it to the defined fish 
            m_fish.transform.parent = fishMan.transform;
            //add waypoint to temporary list
            fishList.Add(m_fish);
            //rename waypoint to match the list count
            m_fish.name = "Fish " + (fishList.Count - 1);
        }

        void FinishFish()
        {
            if (!placing) return;
            //toggle placement off
            placing = false;
            //clear list with temporary waypoint references,
            //we only needed this for getting the waypoint count
            fishList.Clear();
            //reset fish name input field
            fishName = "";
            //make the new fish the active selection
            Selection.activeGameObject = fish;
        }


        /// <summary>
        /// Gets the active SceneView or creates one.
        /// </summary>
        public static SceneView GetSceneView()
        {
            SceneView view = SceneView.lastActiveSceneView;
            if (view == null)
                view = EditorWindow.GetWindow<SceneView>();

            return view;
        }

        Dictionary<string, Vector2[]> Getfishs()
        {
            Dictionary<string, Vector2[]> fishs = new Dictionary<string, Vector2[]>();
            var wm = GameObject.Find("Fish Manager");
            var pat = wm.GetComponentsInChildren<FishSchoolManager>();
            for (int i = 0; i < pat.Length; i++)
            {
                var item = pat[i];
                int len = item.fishs.Length;
                Vector2[] pos_arr = new Vector2[len];
                for (int k = 0; k < len; k++)
                {
                    var pos = item.fishs[k].position;
                    pos_arr[k] = pos;
                }
                fishs.Add(i.ToString(), pos_arr);
            }
            return fishs;
        }

        void ExportJson()
        {
            Debug.Log("导出json数据");
            var fishs = Getfishs();

            JsonData jsonData = new JsonData();    //无名JsonData对象
            foreach (var item in fishs)
            {
                JsonData json2 = new JsonData();
                json2["id"] = item.Key;
                json2["type"] = 1;

                JsonData json4 = new JsonData();
                for (int i = 0; i < item.Value.Length; i++)
                {
                    JsonData json3 = new JsonData();
                    json3["x"] = item.Value[i].x;
                    json3["y"] = item.Value[i].y;
                    json4.Add(json3);
                }
                json2["WayPoints"] = json4;
                jsonData.Add(json2);
            }

            JsonData exportJson = new JsonData();
            exportJson.Add(jsonData);
            string json = exportJson.ToJson();    //将以上数据转为Json格式的文本

            Debug.Log("json:" + json);
            string fish = Application.dataPath + @"/SWS/JsonFish.lua";	//这里保存文件的路径
            StringBuilder builder = new StringBuilder();
            builder.Append("return '");
            builder.Append(json);
            builder.Append("'");

            //找到当前路径
            FileInfo file = new FileInfo(fish);
            //判断有没有文件，有则打开文件，，没有创建后打开文件
            StreamWriter sw = file.CreateText();
            sw.Write(builder.ToString());		//写入数据
            sw.Close();		//关闭流
            sw.Dispose();		//销毁流
            AssetDatabase.Refresh();
        }

        Dictionary<string, Dictionary<string, object>> GetDicWayPoints()
        {
            Dictionary<string, Dictionary<string, object>> fishs = new Dictionary<string, Dictionary<string, object>>();
            var wm = GameObject.Find("Waypoint Manager");
            var pm_arr = wm.GetComponentsInChildren<FishSchoolManager>();
            for (int i = 0; i < pm_arr.Length; i++)
            {
                StringBuilder builder = new StringBuilder();
                builder.Append("[[");
                var item = pm_arr[i];
                int len = item.fishs.Length;
                Dictionary<string, Dictionary<string, string>> wayPoints = new Dictionary<string, Dictionary<string, string>>();
                for (int k = 0; k < len; k++)
                {
                    var _pos = item.fishs[k].position;
                    Dictionary<string, string> pos = new Dictionary<string, string>();
                    float x = _pos.x;
                    x = (float)Math.Round(x, 2);
                    float y = _pos.y;
                    y = (float)Math.Round(y, 2);
                    if (k != 0)
                    {
                        builder.Append("#");
                    }
                    builder.Append(x);
                    builder.Append("#");
                    builder.Append(y);
                    pos.Add("x", x.ToString());
                    pos.Add("y", y.ToString());
                    wayPoints.Add((k + 1).ToString(), pos);
                }
                Dictionary<string, object> fish_dic = new Dictionary<string, object>();
                fish_dic.Add("WayPoints", wayPoints);
                fish_dic.Add("id", (i + 1));
                fish_dic.Add("type", 1);
                builder.Append("]]");
                fish_dic.Add("builder", builder.ToString());
                fishs.Add((i + 1).ToString(), fish_dic);
            }
            return fishs;
        }

        void ExportLua()
        {
            var fishs = GetDicWayPoints();// GetDicfishs(); 
            var lua = TileEditor.HELua.Encode(fishs);//TileEditor.HELua.Encode(fishs);
            Debug.Log(lua);
            string fish = Application.dataPath + @"/SWS/LuaFish.lua";	//这里保存文件的路径
            StringBuilder builder = new StringBuilder();
            builder.Append("return ");
            builder.Append(lua);
            // builder.Append("'");

            //找到当前路径
            FileInfo file = new FileInfo(fish);
            //判断有没有文件，有则打开文件，，没有创建后打开文件
            StreamWriter sw = file.CreateText();
            sw.Write(builder.ToString());		//写入数据
            sw.Close();		//关闭流
            sw.Dispose();		//销毁流
            AssetDatabase.Refresh();
        }
    }
}
