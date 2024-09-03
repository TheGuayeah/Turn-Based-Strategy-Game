using System.Collections.Generic;
using UnityEngine;

public class Testing : MonoBehaviour
{
   [SerializeField]
   private Unit unit;

   private void Start()
   {
      
   }

   private void Update()
   {
      if (Input.GetKeyDown(KeyCode.T))
      {
         GridPosition mouseGridPosition = 
            LevelGrid.Instance.GetGridPosition(MouseWorld.GetPosition());
         GridPosition startGridPosition = new GridPosition(0, 0);

         List<GridPosition> pathGridPositions =
            Pathfinding.Instance.FindPath(startGridPosition, mouseGridPosition);

         for (int i = 0; i < pathGridPositions.Count - 1; i++)
         {
            Debug.DrawLine( // White line for walkable path
               LevelGrid.Instance.GetWorldPosition(pathGridPositions[i]),
               LevelGrid.Instance.GetWorldPosition(pathGridPositions[i + 1]),
               Color.white,
               10f
            );
         }
      }
   }
}
