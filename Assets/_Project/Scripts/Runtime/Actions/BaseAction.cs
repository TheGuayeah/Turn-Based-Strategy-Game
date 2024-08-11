using System;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Unit))]
public abstract class BaseAction : MonoBehaviour
{
   public delegate void ActionCompleteDelegate();

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
}
