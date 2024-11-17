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
   [SerializeField]
   private LayerMask obstaclesLayerMask;
   [SerializeField]
   private LayerMask floorLayerMask;

   private GridSystemVisualSingle[,,] gridSystemVisualSingles;

   private void Start()
   {
      gridSystemVisualSingles =  new GridSystemVisualSingle[
         LevelGrid.Instance.GetWidth(), 
         LevelGrid.Instance.GetHeight(),
         LevelGrid.Instance.GetFloorAmount()
      ];

      for (int x = 0; x < LevelGrid.Instance.GetWidth(); x++)
      {
         for (int z = 0; z < LevelGrid.Instance.GetHeight(); z++)
         {
            for (int floor = 0; floor < LevelGrid.Instance.GetFloorAmount(); floor++)
            {
               Transform gridSystemVisualSingleTransform = Instantiate(
                  gridSystemVisualSinglePrefab,
                  LevelGrid.Instance.GetWorldPosition(new GridPosition(x, z, floor)),
                  Quaternion.identity,
                  transform
               );
               gridSystemVisualSingles[x, z, floor] =
                  gridSystemVisualSingleTransform.GetComponent<GridSystemVisualSingle>();
            }
         }
      }

      UnitActionSystem.Instance.OnSelectedActionChanged += UnitActionSystem_OnSelectedActionChanged;
      UnitActionSystem.Instance.OnBusyChanged += UnitActionSystem_OnBusyChanged;
      //LevelGrid.Instance.OnAnyUnitMovedGridPosition += LevelGrid_OnAnyUnitMovedGridPosition;
      Unit.OnAnyUnitDead += Unit_OnAnyUnitDead;
      
      UpdateGridVisual();
   }

   public void HideAllGridPositions()
   {
      for(int x = 0; x < LevelGrid.Instance.GetWidth(); x++)
      {
         for(int z = 0; z < LevelGrid.Instance.GetHeight(); z++)
         {
            for (int floor = 0; floor < LevelGrid.Instance.GetFloorAmount(); floor++)
            {
               gridSystemVisualSingles[x, z, floor].Hide();
            }
         }
      }
   }

   private void ShowGridPosionRangeSquare(GridPosition gridPosition, int range, GridVisualColor gridVisualColor)
   {
      List<GridPosition> gridPositions = new List<GridPosition>();

      for (int x = -range; x <= range; x++)
      {
         for (int z = -range; z <= range; z++)
         {
            GridPosition newGridPosition = gridPosition + new GridPosition(x, z, 0);

            if (!LevelGrid.Instance.IsValidGridPosition(newGridPosition))
            {
               continue;
            }

            gridPositions.Add(newGridPosition);
         }
      }

      ShowGridPositionList(gridPositions, gridVisualColor);
   }

   private void ShowGridPosionRangeCircle(GridPosition gridPosition, int range, GridVisualColor gridVisualColor)
   {
      List<GridPosition> gridPositions = new List<GridPosition>();

      int floorAmount = LevelGrid.Instance.GetFloorAmount();

      for (int x = -range; x <= range; x++)
      {
         for (int z = -range; z <= range; z++)
         {
            for (int floor = -floorAmount; floor < floorAmount; floor++)
            {
               GridPosition newGridPosition = gridPosition + new GridPosition(x, z, floor);

               if (!LevelGrid.Instance.IsValidGridPosition(newGridPosition))
               {
                  continue;
               }

               int testDistance = Math.Abs(x) + Math.Abs(z);
               if (testDistance > range) continue;

               gridPositions.Add(newGridPosition);
            }
         }
      }

      ShowGridPositionList(gridPositions, gridVisualColor);
   }

   public void ShowGridPositionList(
      List<GridPosition> gridPositionList, 
      GridVisualColor gridVisualColor,
      BaseAction baseAction = null
   )
   {
      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();
      if (selectedUnit.IsEnemy()) return;

      foreach (GridPosition gridPosition in gridPositionList)
      {
         if (!HasFloorAtGridPosition(gridPosition)) continue;

         if (HasObstacleAtGridPosition(gridPosition)) continue;

         if (baseAction != null && baseAction.GetType() != typeof(MoveAction))
         {
            if (IsGridPositionBlockedByObstacle(gridPosition)) continue;
         }         

         gridSystemVisualSingles[gridPosition.x, gridPosition.z, gridPosition.floor].
            Show(GetGridVisualMaterial(gridVisualColor));
      }
   }

   private bool HasFloorAtGridPosition(GridPosition gridPosition)
   {
      float raycasOffsetDistance = 1f;

      Vector3 worldPosition =
            LevelGrid.Instance.GetWorldPosition(gridPosition);

      bool floorFound = Physics.Raycast(
         worldPosition + Vector3.up * raycasOffsetDistance,
         Vector3.down,
         raycasOffsetDistance * 2,
         floorLayerMask
      );

      return floorFound;
   }

   private bool HasObstacleAtGridPosition(GridPosition gridPosition)
   {
      float raycasOffsetDistance = 1f;

      Vector3 worldPosition =
            LevelGrid.Instance.GetWorldPosition(gridPosition);

      bool obstaclesFound = Physics.Raycast(
         worldPosition + Vector3.down * raycasOffsetDistance,
         Vector3.up,
         raycasOffsetDistance * 2,
         obstaclesLayerMask
      );

      return obstaclesFound;
   }

   private bool IsGridPositionBlockedByObstacle(GridPosition gridPosition)
   {
      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();
      Vector3 worldPosition =
            LevelGrid.Instance.GetWorldPosition(gridPosition);

      float unitShoulderHeight = 1.7f;
      Vector3 unitWorldPosition =
         LevelGrid.Instance.GetWorldPosition(selectedUnit.GetGridPosition());

      Vector3 shootingOrigin = unitWorldPosition + Vector3.up * unitShoulderHeight;

      Vector3 shootDirection =
         (worldPosition - unitWorldPosition).normalized;

      float shootingDistance =
         Vector3.Distance(unitWorldPosition, worldPosition);

      bool isBlockedByObstacle = Physics.Raycast(
          shootingOrigin,
          shootDirection,
          shootingDistance,
          obstaclesLayerMask | floorLayerMask
      );

      return isBlockedByObstacle;
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

            ShowGridPosionRangeCircle(selectedUnit.GetGridPosition(),
               shootAction.GetMaxShootDistance(), GridVisualColor.RedSoft);
            break;

         case GrenadeAction grenadeAction:
            gridVisualColor = GridVisualColor.Yellow;
            break;

         case SwordAction swordAction:
            gridVisualColor = GridVisualColor.Red;

            ShowGridPosionRangeSquare(selectedUnit.GetGridPosition(),
               swordAction.GetMaxSwordDistance(), GridVisualColor.RedSoft);
            break;

         case InteractAction interactAction:
            gridVisualColor = GridVisualColor.Blue;
            break;
      }
      ShowGridPositionList(
         selectedAction.GetValidActionGridPositions(), 
         gridVisualColor,
         selectedAction
      );
   }

   private void UnitActionSystem_OnSelectedActionChanged(object sender, EventArgs e)
   {
      UpdateGridVisual();
   }

   private void UnitActionSystem_OnBusyChanged(object sender, EventArgs e)
   {
      UpdateGridVisual();
   }


   private void LevelGrid_OnAnyUnitMovedGridPosition(object sender, EventArgs e)
   {
      UpdateGridVisual();
   }

   private void Unit_OnAnyUnitDead(object sender, EventArgs e)
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
