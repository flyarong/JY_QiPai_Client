using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AI.Steering;
using SWS;

public class FishController : MonoBehaviour
{
    public LocomotionController locomotionController;

	private FishSchoolOption fsOption;

	private Steering steer;

	private Transform wpr;

	public FishType ft = FishType.fish1;

    void Award()
    {
        locomotionController = AddLocomotionController();
    }

    // Use this for initialization
    void Start()
    {
        locomotionController = AddLocomotionController();
    }

    // Update is called once per frame
    void Update()
    {

    }

    public LocomotionController AddLocomotionController()
    {
        var lc = this.transform.GetComponent<LocomotionController>();
        if (lc == null)
        {
            this.gameObject.AddComponent<LocomotionController>();
        }
		locomotionController = lc;
        return lc;
    }

    public void ChangeFishSchoolOption(FishSchoolOption fishOption)
    {
		fsOption = fishOption;
		SteeringForFollowPath fp;
		SteeringForOffsetPursuit op;
        switch (fishOption)
        {
            case FishSchoolOption.FollowPath:
                fp = this.gameObject.GetComponent<SteeringForFollowPath> ();
				if (fp == null) fp = this.gameObject.AddComponent<SteeringForFollowPath>();
				op = this.gameObject.GetComponent<SteeringForOffsetPursuit> ();
				if (op != null) GameObject.DestroyImmediate(op);
				steer = fp;
				SetTarget();
                break;
            case FishSchoolOption.OffsetPursuit:
				if (this.transform.GetSiblingIndex() == 0){
					 fp = this.gameObject.GetComponent<SteeringForFollowPath> ();
					if (fp == null) fp = this.gameObject.AddComponent<SteeringForFollowPath>();
					op = this.gameObject.GetComponent<SteeringForOffsetPursuit> ();
					if (op != null) GameObject.DestroyImmediate(op);
					steer = fp;
				}
				else
				{
					fp = this.gameObject.GetComponent<SteeringForFollowPath> ();
					if (fp != null) GameObject.DestroyImmediate(fp);
					op = this.gameObject.GetComponent<SteeringForOffsetPursuit> ();
					if (op == null) op = this.gameObject.AddComponent<SteeringForOffsetPursuit>();
					steer = op;
					SetLeader();
				}
				SetTarget();
                break;
        }
    }

	public void SetTarget()
	{
		if (steer != null)
		{
			steer.target = this.transform;
		}
	}

	public void SetLeader()
	{
		if (steer != null)
		{
			((SteeringForOffsetPursuit)steer).leader = this.transform.GetChild(0).GetComponent<Steering>();
		}
	}

	public void SetWayPoints()
	{
		switch (fsOption)
		{
			case FishSchoolOption.FollowPath:
				SteeringForFollowPath steering = (SteeringForFollowPath)steer;
				if (steering == null)
				{
					steering = this.gameObject.GetComponent<SteeringForFollowPath>();
				}
				if ((steering != null && steering.WayPoints.Length == 0) || (steering != null && steering.WayPointsRoot != null && wpr != steering.WayPointsRoot.transform))
				{
					wpr = steering.WayPointsRoot;
					var pm = wpr.GetComponent<PathManager>();
					if (pm == null) return;
					steering.WayPoints = pm.waypoints;
				}
                break;
            case FishSchoolOption.OffsetPursuit:
                
                break;
		}
	}

	public void SetFishPerfab()
	{
		string name = "Fish0";
		if ((int)ft < 10) name = name + "0";
		name = name + (int) ft + "_";
		if (this.transform.childCount == 0)
		{
			CreateFish(name);
			return;
		}
		var child = this.transform.GetChild(0);
		if (child.name == name) return;
		DestroyImmediate(child.gameObject);
		CreateFish(name);
#if UNITY_EDITOR
		UnityEditor.SceneView.RepaintAll();
#endif
	}

	private void CreateFish(string name)
	{
		GameObject go = Instantiate(Resources.Load(name)) as GameObject;
		go.name = name;
		go.transform.SetParent(this.transform);
		go.transform.localPosition = Vector3.zero;
		go.transform.localScale = Vector3.one;
	}

	public enum FishType {
		fish1 = 1,
		fish2,
		fish3,
		fish4,
		fish5,
		fish6,
		fish7,
		fish8,
		fish9,
		fish10,
		fish11,
		fish12,
		fish13,
		fish14,
		fish15,
		fish16,
		fish17,
		fish18,
		fish19,
		fish21 = 21,
		fish22,
		fish23,
	}
}
