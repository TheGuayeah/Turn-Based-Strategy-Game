using System;
using System.Collections.Generic;
using UnityEngine;

public class MoveAction : BaseAction
{
   public event EventHandler OnStartMoving;
   public event EventHandler OnStopMoving;
   public event EventHandler<OnStartJumpEventArgs> OnStartJumping;
   public class OnStartJumpEventArgs : EventArgs
   {
      public GridPosition unitGridPosition;
      public GridPosition targetGridPosition;
   }

   [SerializeField]
   private float moveSpeed = 4f;
   [SerializeField]
   private float stoppingDistance = 0.1f;
   [SerializeField]
   private float rotateSpeed = 25f;
   [SerializeField]
   private int maxMoveDistance = 4;

   private List<Vector3> positons;
   private int currentPositionIndex;
   private bool isChangingFloors;
   private float floorTeleportTimer;
   private float floorTeleportTimerMax = 0.5f;

   private void Update()
   {
      if (!isActive) return;

      Vector3 targetPosition = positons[currentPositionIndex];

      if (isChangingFloors) //Stop and Teleport Logic
      {
         Vector3 targetSameFloorPosition = targetPosition;
         targetSameFloorPosition.y = transform.position.y;

         Vector3 rotateDirection = (targetSameFloorPosition - transform.position).normalized;

         transform.forward = Vector3.Slerp(transform.forward, rotateDirection,
                              rotateSpeed * Time.deltaTime);


         floorTeleportTimer -= Time.deltaTime;

         if (floorTeleportTimer <= 0f)
         {
            isChangingFloors = false;
            transform.position = targetPosition;
         }
      }
      else //Regular Move Logic
      {
         Vector3 moveDirection = (targetPosition - transform.position).normalized;

         transform.forward = Vector3.Slerp(transform.forward, moveDirection,
                              rotateSpeed * Time.deltaTime);

         transform.position += moveDirection * moveSpeed * Time.deltaTime;

      }

      float distance = Vector3.Distance(transform.position, targetPosition);

      if (distance < stoppingDistance)
      {
         currentPositionIndex++;

         if (currentPositionIndex >= positons.Count)
         {
            OnStopMoving?.Invoke(this, EventArgs.Empty);
            ActionComplete();
         }
         else
         {
            targetPosition = positons[currentPositionIndex];
            GridPosition targetGridPosition = 
               LevelGrid.Instance.GetGridPosition(targetPosition);
            GridPosition unitGridPosition = 
               LevelGrid.Instance.GetGridPosition(transform.position);


            if (targetGridPosition.floor != unitGridPosition.floor)
            {
               isChangingFloors = true;
               floorTeleportTimer = floorTeleportTimerMax;

               OnStartJumping?.Invoke(this, new OnStartJumpEventArgs
               {
                  unitGridPosition = unitGridPosition,
                  targetGridPosition = targetGridPosition
               });
            }
         }         
      }
   }

   public override void TakeAction(GridPosition gridPosition, Action onMoveComplete)
   {
      List<GridPosition> path = Pathfinding.Instance.FindPath(
         unit.GetGridPosition(), 
         gridPosition, 
         out int pathLength
      );
      currentPositionIndex = 0;

      positons = new List<Vector3>();

      foreach (GridPosition pathPosition in path)
      {
         positons.Add(LevelGrid.Instance.GetWorldPosition(pathPosition));
      }

      OnStartMoving?.Invoke(this, EventArgs.Empty);

      ActionStart(onMoveComplete);
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      List<GridPosition> validActionGridPositions = new List<GridPosition>();
      GridPosition unitGridPosition = unit.GetGridPosition();

      for (int x = -maxMoveDistance; x <= maxMoveDistance; x++)
      {
         for (int z = -maxMoveDistance; z <= maxMoveDistance; z++)
         {
            for (int floor = -maxMoveDistance; floor <= maxMoveDistance; floor++)
            {
               GridPosition offsetGridPosition = new GridPosition(x, z, floor);
               GridPosition testGridPosition = unitGridPosition + offsetGridPosition;

               if (!LevelGrid.Instance.IsValidGridPosition(testGridPosition))
               {
                  continue;
               }

               if (unitGridPosition == testGridPosition)
               {
                  continue; //The unit is already at this position.
               }

               if (LevelGrid.Instance.IsAnyUnitAtGridPosition(testGridPosition))
               {
                  continue; //There is already a unit at this position.
               }

               if (!Pathfinding.Instance.IsWalkableGridPosition(testGridPosition))
               {
                  continue; //The position is not walkable.
               }

               if (!Pathfinding.Instance.HasPath(unitGridPosition, testGridPosition))
               {
                  continue; //This position is not reachable.
               }

               int pathfindingDistanceMultiplier = 10;
               bool isPathTooLong =
                  Pathfinding.Instance.GetPathLength(unitGridPosition, testGridPosition) >
                  maxMoveDistance * pathfindingDistanceMultiplier;

               if (isPathTooLong) continue;

               validActionGridPositions.Add(testGridPosition);
            }
         }
      }

      return validActionGridPositions;
   }

   public override string GetActionName()
   {
      return "Move";
   }

   public override EnemyAIAction GetEnemyAIAction(GridPosition gridPosition)
   {
      int targetCount = unit.GetAction<ShootAction>().GetTargetCountAtPosition(gridPosition);

      return new EnemyAIAction
      {
         gridPosition = gridPosition,
         actionValue = targetCount * 10
      };
   }
}
