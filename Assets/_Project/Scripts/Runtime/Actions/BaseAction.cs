using System;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Unit))]
public abstract class BaseAction : MonoBehaviour
{
   public static event EventHandler OnAnyActionStarted;
   public static event EventHandler OnAnyActionCompleted;

   protected Unit unit;
   protected bool isActive;
   protected Action onActionComplete;

   protected virtual void Awake()
   {
      unit = GetComponent<Unit>();
   }

   public abstract string GetActionName();

   public abstract void TakeAction(GridPosition gridPosition, Action onActionComplete);

   public virtual bool IsValidActionGridPosition(GridPosition gridPosition)
   {
      List<GridPosition> validGridPositions = GetValidActionGridPositions();
      return validGridPositions.Contains(gridPosition);
   }

   /// <summary>
   /// Checks which grid positions are valid for the unit to move to.
   /// </summary>
   /// <returns></returns>
   public abstract List<GridPosition> GetValidActionGridPositions();

   public virtual int GetActionPointsCost()
   {
      return 1;
   }

   protected void ActionStart(Action onActionComplete)
   {
      isActive = true;
      this.onActionComplete = onActionComplete;

      OnAnyActionStarted?.Invoke(this, EventArgs.Empty);
   }

   protected void ActionComplete()
   {
      isActive = false;
      onActionComplete();

      OnAnyActionCompleted?.Invoke(this, EventArgs.Empty);
   }

   protected bool IsGridPositionBlockedByObstacle(GridPosition gridPosition, LayerMask obstaclesLayerMask)
   {
      GridPosition unitGridPosition = unit.GetGridPosition();
      float unitShoulderHeight = 1.7f;

      Vector3 worldPosition = LevelGrid.Instance.GetWorldPosition(gridPosition);

      Vector3 unitWorldPosition = LevelGrid.Instance.GetWorldPosition(unitGridPosition);

      Vector3 throwOrigin = unitWorldPosition + Vector3.up * unitShoulderHeight;

      Vector3 throwDirection =
         (worldPosition - unitWorldPosition).normalized;

      float shootingDistance =
         Vector3.Distance(unitWorldPosition, worldPosition);

      bool isBlockedByObstacle = Physics.Raycast(
         throwOrigin,
         throwDirection,
         shootingDistance,
         obstaclesLayerMask
      );

      return isBlockedByObstacle;
   }

   public Unit GetUnit()
   {
      return unit;
   }

   public EnemyAIAction GetBestEnemyAIAction()
   {
      List<EnemyAIAction> allEnemyAIActions = new List<EnemyAIAction>();

      List<GridPosition> validActionGridPositions = GetValidActionGridPositions();

      foreach (GridPosition gridPosition in validActionGridPositions)
      {
         EnemyAIAction enemyAIAction = GetEnemyAIAction(gridPosition);
         allEnemyAIActions.Add(enemyAIAction);
      }

      if(allEnemyAIActions.Count == 0) return null;

      allEnemyAIActions.Sort((a, b) => b.actionValue - a.actionValue);
      return allEnemyAIActions[0];
   }

   public abstract EnemyAIAction GetEnemyAIAction(GridPosition gridPosition);
}
