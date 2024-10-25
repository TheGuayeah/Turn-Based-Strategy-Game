using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(PathfindingLinkWorld))]
public class PathfindingLinkWorldEditor : Editor
{

   private void OnSceneGUI()
   {
      PathfindingLinkWorld pathfindingLinkWorld = (PathfindingLinkWorld)target;

      EditorGUI.BeginChangeCheck();

      Vector3 newLinkPositonA = Handles.PositionHandle(
         pathfindingLinkWorld.linkPositionA,
         Quaternion.identity
      );

      Vector3 newLinkPositonB = Handles.PositionHandle(
         pathfindingLinkWorld.linkPositionB,
         Quaternion.identity
      );

      if (EditorGUI.EndChangeCheck())
      {
         Undo.RecordObject(pathfindingLinkWorld, "Change Link Position");
         pathfindingLinkWorld.linkPositionA = newLinkPositonA;
         pathfindingLinkWorld.linkPositionB = newLinkPositonB;
      }
   }
}
