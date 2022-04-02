using UnityEngine;
using LuaInterface;
using UnityEngine.UI;

/// <summary>
/// Small script that makes it easy to create looping 2D sprite animations.
/// </summary>

public class UI2DImageAnimation : MonoBehaviour {
    /// <summary>
    /// Index of the current frame in the sprite animation.
    /// </summary>

    public int frameIndex = 0;

    /// <summary>
    /// How many frames there are in the animation per second.
    /// </summary>

    public int framerate = 20;

    /// <summary>
    /// Should this animation be affected by time scale?
    /// </summary>

    public bool ignoreTimeScale = true;

    /// <summary>
    /// Should this animation be looped?
    /// </summary>

    public bool loop = true;

    /// <summary>
    /// Actual sprites used for the animation.
    /// </summary>

    public UnityEngine.Sprite[] bgFrames;
	public UnityEngine.Sprite[] fgFrames;

	public Image bgImage;
	public Image fgImage;

    float mUpdate = 0f;

    /// <summary>
    /// Returns is the animation is still playing or not
    /// </summary>

    public bool isPlaying { get { return enabled; } }

    /// <summary>
    /// Animation framerate.
    /// </summary>

    public int framesPerSecond { get { return framerate; } set { framerate = value; } }

    public LuaFunction aniPlayEndfun = null;

	public void SetBGFrame(int idx, UnityEngine.Sprite sprite) {
		bgFrames [idx] = sprite;
	}
	public void SetFGFrame(int idx, UnityEngine.Sprite sprite) {
		fgFrames [idx] = sprite;
	}
    /// <summary>
    /// Continue playing the animation. If the animation has reached the end, it will restart from beginning
    /// </summary>

    public void Play(LuaFunction endFun = null, LuaFunction startFun = null) {
		if (bgFrames != null && bgFrames.Length > 0) {
			if (!enabled && !loop) {
				int newIndex = framerate > 0 ? frameIndex + 1 : frameIndex - 1;
				if (newIndex < 0 || newIndex >= bgFrames.Length)
					frameIndex = framerate < 0 ? bgFrames.Length - 1 : 0;
			}

			enabled = true;
			UpdateSprite();
		}

        if (startFun != null)
            startFun.Call(this.gameObject);
        if (endFun != null) {
            aniPlayEndfun = endFun;
        }
    }

    /// <summary>
    /// Pause the animation.
    /// </summary>

    public void Pause(LuaFunction fun = null) {
        enabled = false;

        if (fun != null)
            fun.Call(this.gameObject);
    }

    /// <summary>
    /// Reset the animation to the beginning.
    /// </summary>

    public void ResetToBeginning(LuaFunction fun = null) {
		frameIndex = framerate < 0 ? bgFrames.Length - 1 : 0;
        UpdateSprite();
        if (fun != null)
            fun.Call(this.gameObject);
    }

    /// <summary>
    /// Start playing the animation right away.
    /// </summary>

    //void Start() { Play(); }

    /// <summary>
    /// Advance the animation as necessary.
    /// </summary>

    void Update() {
		if (bgFrames == null || bgFrames.Length == 0) {
            enabled = false;
        }
        else if (framerate != 0) {
            float time = ignoreTimeScale ? Time.unscaledTime : Time.time;

            if (mUpdate < time) {
                mUpdate = time;
                int newIndex = framerate > 0 ? frameIndex + 1 : frameIndex - 1;

				if (!loop && (newIndex < 0 || newIndex >= bgFrames.Length)) {
                    enabled = false;
                    if(aniPlayEndfun != null) {
                        aniPlayEndfun.Call(this.gameObject);
                        aniPlayEndfun = null;
                    }
                    return;
                }

				frameIndex = RepeatIndex(newIndex, bgFrames.Length);
                UpdateSprite();
            }
        }
    }

    /// <summary>
    /// Immediately update the visible sprite.
    /// </summary>

    void UpdateSprite() {
		float time = ignoreTimeScale ? Time.unscaledTime : Time.time;
		if (framerate != 0) mUpdate = time + Mathf.Abs(1f / framerate);

		bgImage.sprite = bgFrames[frameIndex];
		if (fgFrames [frameIndex] == null)
			fgImage.gameObject.SetActive (false);
		else {
			fgImage.sprite = fgFrames [frameIndex];
			fgImage.gameObject.SetActive (true);
		}
    }

    /// <summary>
    /// Wrap the index using repeating logic, so that for example +1 past the end means index of '1'.
    /// </summary>
    static public int RepeatIndex(int val, int max) {
        if (max < 1) return 0;
        while (val < 0) val += max;
        while (val >= max) val -= max;
        return val;
    }
}
