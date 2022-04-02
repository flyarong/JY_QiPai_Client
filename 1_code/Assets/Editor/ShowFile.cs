using UnityEngine;
using UnityEditor;
using System;
using System.Diagnostics;

public class ShowFile : EditorWindow
{
    static string localstr = "";
    [MenuItem("检查+/本地文件根目录")]
    static void ShowFile_F()
    {
        localstr = "<color=red>本地文件根目录：</color>" + Application.dataPath;
        //UnityEngine.Debug.Log("<color=red>本地文件根目录：</color>"+ Application.dataPath);
        Run(); 
    }
    static int count = 0;

    static void p_OutputDataReceived(object sender, DataReceivedEventArgs e)
    {
        if (count == 0) {
            UnityEngine.Debug.Log("<color=red>分支对应：</color>" + e.Data + "   " + localstr);
        }
        if (e.Data != null)
            ++count;
    }

    static void Run()
    {
        Process p = new Process();
        p.StartInfo.FileName = @"C:\Program Files\Git\bin\git.exe";
        p.StartInfo.Arguments = "status";
        p.StartInfo.WorkingDirectory = Application.dataPath;
        p.StartInfo.CreateNoWindow = true;
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.RedirectStandardOutput = true;
        p.OutputDataReceived += p_OutputDataReceived;
        count = 0;
        p.Start();
        p.BeginOutputReadLine();
        p.WaitForExit();
    }
}