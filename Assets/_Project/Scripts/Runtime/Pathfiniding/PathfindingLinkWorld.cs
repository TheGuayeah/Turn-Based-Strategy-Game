using UnityEngine;

public class PathfindingLinkWorld : MonoBehaviour
{
   public Vector3 linkPositionA;
   public Vector3 linkPositionB;

   public PathfindingLinkGrid GetPathfindingLink()
   {
      return new PathfindingLinkGrid { 
         gridPositionA = LevelGrid.Instance.GetGridPosition(linkPositionA),
         gridPositionB = LevelGrid.Instance.GetGridPosition(linkPositionB),
      };
   }
}
