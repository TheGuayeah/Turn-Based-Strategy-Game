using System.Collections.Generic;
using UnityEngine;

public class GridSystemVisual : Singleton<GridSystemVisual>
{
   [SerializeField]
   private Transform gridSystemVisualSinglePrefab;

   private GridSystemVisualSingle[,] gridSystemVisualSingles;

   private void Start()
   {
      gridSystemVisualSingles =  new GridSystemVisualSingle[
         LevelGrid.Instance.GetWidth(), 
         LevelGrid.Instance.GetHeight()
      ];

      for (int x = 0; x < LevelGrid.Instance.GetWidth(); x++)
      {
         for (int z = 0; z < LevelGrid.Instance.GetHeight(); z++)
         {
            Transform gridSystemVisualSingleTransform = Instantiate(
               gridSystemVisualSinglePrefab,
               LevelGrid.Instance.GetWorldPosition(new GridPosition(x, z)),
               Quaternion.identity,
               transform
            );
            gridSystemVisualSingles[x, z] = 
               gridSystemVisualSingleTransform.GetComponent<GridSystemVisualSingle>();
         }
      }
   }

   private void Update()
   {
      UpdateGridVisual();
   }

   public void HideAllGridPositions()
   {
      for(int x = 0; x < LevelGrid.Instance.GetWidth(); x++)
      {
         for(int z = 0; z < LevelGrid.Instance.GetHeight(); z++)
         {
            gridSystemVisualSingles[x, z].Hide();
         }
      }
   }

   public void ShowGridPositionList(List<GridPosition> gridPositionList)
   {
      foreach (GridPosition gridPosition in gridPositionList)
      {
         gridSystemVisualSingles[gridPosition.x, gridPosition.z].Show();
      }
   }

   private void UpdateGridVisual()
   {
      HideAllGridPositions();
      BaseAction selectedAction = UnitActionSystem.Instance.GetSelectedAction();
      ShowGridPositionList(selectedAction.GetValidActionGridPositions());
   }
}
