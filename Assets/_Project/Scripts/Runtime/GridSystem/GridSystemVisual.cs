using System;
using System.Collections.Generic;
using UnityEngine;

public class GridSystemVisual : Singleton<GridSystemVisual>
{
   [Serializable]
   public struct GridVisualType
   {
      public GridVisualColor gridVisualColor;
      public Material material;
   }

   public enum GridVisualColor
   {
      Blue,
      Red,
      RedSoft,
      White,
      Yellow
   }

   [SerializeField]
   private Transform gridSystemVisualSinglePrefab;
   [SerializeField]
   private List<GridVisualType> gridVisualTypes;

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

      UnitActionSystem.Instance.OnSelectedActionChanged += UnitActionSystem_OnSelectedActionChanged;
      LevelGrid.Instance.OnAnyUnitMovedGridPosition += LevelGrid_OnAnyUnitMovedGridPosition;
      
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

   private void ShowGridPosionRange(GridPosition gridPosition, int range, GridVisualColor gridVisualColor)
   {
      List<GridPosition> gridPositions = new List<GridPosition>();

      for (int x = -range; x <= range; x++)
      {
         for (int z = -range; z <= range; z++)
         {
            GridPosition newGridPosition = gridPosition + new GridPosition(x, z);

            if (!LevelGrid.Instance.IsValidGridPosition(newGridPosition))
            {
               continue;
            }

            int testDistance = Math.Abs(x) + Math.Abs(z);
            if (testDistance > range) continue;

            gridPositions.Add(newGridPosition);
         }
      }

      ShowGridPositionList(gridPositions, gridVisualColor);
   }

   public void ShowGridPositionList(List<GridPosition> gridPositionList, GridVisualColor gridVisualColor)
   {
      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();
      if (selectedUnit.IsEnemy()) return;

      foreach (GridPosition gridPosition in gridPositionList)
      {
         gridSystemVisualSingles[gridPosition.x, gridPosition.z].
            Show(GetGridVisualMaterial(gridVisualColor));
      }
   }

   private void UpdateGridVisual()
   {
      HideAllGridPositions();
      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();
      BaseAction selectedAction = UnitActionSystem.Instance.GetSelectedAction();
      GridVisualColor gridVisualColor;

      switch (selectedAction)
      {
         default:
         case MoveAction moveAction:
            gridVisualColor = GridVisualColor.White;
            break;
         case SpinAction spinAction:
            gridVisualColor = GridVisualColor.Blue;
            break;
         case ShootAction shootAction:
            gridVisualColor = GridVisualColor.Red;

            ShowGridPosionRange(selectedUnit.GetGridPosition(), 
               shootAction.GetMaxShootDistance(), GridVisualColor.RedSoft);
            break;
      }
      ShowGridPositionList(selectedAction.GetValidActionGridPositions(), gridVisualColor);
   }

   private void UnitActionSystem_OnSelectedActionChanged(object sender, EventArgs e)
   {
      UpdateGridVisual();
   }

   private void LevelGrid_OnAnyUnitMovedGridPosition(object sender, EventArgs e)
   {
      UpdateGridVisual();
   }

   private Material GetGridVisualMaterial(GridVisualColor gridVisualColor)
   {
      foreach (GridVisualType type in gridVisualTypes)
      {
         if (type.gridVisualColor == gridVisualColor)
         {
            return type.material;
         }
      }

      Debug.LogError("GridVisualType not found for color: " + gridVisualColor);
      return null;
   }
}
